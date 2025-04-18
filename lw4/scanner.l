%{
#include <stdio.h>
#include <string.h>
#include "tokens.h"

// Позиция символа в строке
int ch = 0;

void print_token(TokenType type, int ch, const char* type_name) {
    printf("%-3d%-12s\t(%d:%-3d)\t'%s'\n", (int)type, type_name, yylineno, ch, yytext);
}

void print_error(int ch) {
    printf("%-3d%-10s\t(%d:%-3d)\t'%s'\n", (int)TOKEN_ERROR, "ERROR", yylineno, ch, yytext);
}

%}

%option noyywrap yylineno

/* Регулярные выражения для именованных паттернов */
ID          [a-zA-Z_][a-zA-Z0-9_]*
CHARCONST   \'([^'\n])\'
WHITESPACE  [ \t]+
NEWLINE     \n
    
%%

{WHITESPACE}  { ch += yyleng; }
{NEWLINE}     { ch = 0; }
{ID}          { print_token(TOKEN_IDENTIFIER, ch, "IDENTIFIER"); ch += yyleng; }
{CHARCONST}   { print_token(TOKEN_CHAR_CONST, ch, "CHAR_CONST"); ch += yyleng; }
":="          { print_token(TOKEN_ASSIGN_OP, ch, "ASSIGN_OP"); ch += yyleng; }
"+"           { print_token(TOKEN_ADD_OP, ch, "ADD_OP"); ch += yyleng; }
"-"           { print_token(TOKEN_SUB_OP, ch, "SUB_OP"); ch += yyleng; }
"*"           { print_token(TOKEN_MUL_OP, ch, "MUL_OP"); ch += yyleng; }
"/"           { print_token(TOKEN_DIV_OP, ch, "DIV_OP"); ch += yyleng; }
"("           { print_token(TOKEN_LPAREN, ch, "LPAREN"); ch += yyleng; }
")"           { print_token(TOKEN_RPAREN, ch, "RPAREN"); ch += yyleng; }
";"           { print_token(TOKEN_SEPARATOR, ch, "SEPARATOR"); ch += yyleng; }
.             { print_error(ch); ch += yyleng; }

%%

int main(int argc, char **argv) {
    FILE *infile = stdin;

    if (argc > 1) {
        // Если передан аргумент командной строки, пытаемся открыть файл
        infile = fopen(argv[1], "r");
        if (!infile) {
            perror(argv[1]); // Сообщить об ошибке открытия файла
            return 1;
        }
        yyin = infile; // Установить yyin на открытый файл
    } else {
        printf("Reading from standard input. Press Ctrl+D (Unix/Linux) or Ctrl+Z then Enter (Windows) to finish.\n");
    }

    printf("----------------------------------------\n");
    printf("Token Type     \t(Ln:ch)  Lexeme\n");
    printf("----------------------------------------\n");

    // Запуск лексического анализатора Flex
    // yylex() читает ввод (из yyin) и выполняет действия, пока не достигнет конца файла
    yylex();

    printf("----------------------------------------\n");

    // Закрыть файл, если он был открыт
    if (infile != stdin) {
        fclose(infile);
    }

    return 0;
}