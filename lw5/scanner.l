%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "parser.tab.h"

extern void yyerror(const char *s);
extern YYSTYPE yylval;

extern int yylineno;
extern char *yytext;

// Позиция символа в строке
int ch = 0;
%}

%option noyywrap yylineno

ID          [a-zA-Z_][a-zA-Z0-9_]*
CHARCONST   \'([^'\n])\'
WHITESPACE  [ \t]+
NEWLINE     \n

%%

{WHITESPACE}  { ch += yyleng; }
{NEWLINE}     { ch = 0;  }

{ID}          {
                ch += yyleng; 
                yylval.sval = strdup(yytext);
                if (!yylval.sval) { yyerror("Memory allocation error"); exit(1); }
                return T_IDENTIFIER; // Возвращаем тип токена
              }

{CHARCONST}   {
                ch += yyleng; 
                yylval.sval = strdup(yytext);
                 if (!yylval.sval) { yyerror("Memory allocation error"); exit(1); }
                return T_CHAR_CONST; // Возвращаем тип токена
              }

":="          { ch += yyleng; return T_ASSIGN_OP; }
"+"           { ch += yyleng; return T_ADD_OP; }
"-"           { ch += yyleng; return T_SUB_OP; }
"*"           { ch += yyleng; return T_MUL_OP; }
"/"           { ch += yyleng; return T_DIV_OP; }
"("           { ch += yyleng; return T_LPAREN; }
")"           { ch += yyleng; return T_RPAREN; }
";"           { ch += yyleng; return T_SEPARATOR; }
.             {
                char error_msg[100];
                snprintf(error_msg, sizeof(error_msg), "Invalid character (%d:%d) '%s'", yylineno, ch, yytext);
                yyerror(error_msg); // Вызываем функцию ошибки Bison
              }

%%