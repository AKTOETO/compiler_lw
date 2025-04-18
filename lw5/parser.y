/* parser.y - Строит AST и печатает его */
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Объявления из Flex
extern int yylex();
extern char *yytext;
extern int yylineno;
extern FILE *yyin;
extern int ch;

// Прототип функции ошибки
void yyerror(const char *s);

// --- Структура узла AST ---
typedef enum {
    NODE_TYPE_PROGRAM,    // Корень списка операторов
    NODE_TYPE_ASSIGN,     // Операция присваивания (sval = ID назначения)
    NODE_TYPE_OP,         // Бинарная операция (sval = '+', '-', '*', '/')
    NODE_TYPE_IDENTIFIER, // Идентификатор (sval = имя)
    NODE_TYPE_CHAR_CONST  // Символьная константа (sval = 'c')
} NodeType;

// Структура узла
typedef struct ASTNode {
    NodeType type;
    char *sval;           // Значение (имя ID, константа, символ операции)
    struct ASTNode *left; // Левый дочерний узел (для OP, ASSIGN) / Первый оператор (для PROGRAM)
    struct ASTNode *right;// Правый дочерний узел (для OP)
    struct ASTNode *next; // Следующий оператор в списке (для PROGRAM, ASSIGN)
} ASTNode;

// Глобальный указатель на корень построенного дерева
ASTNode *ast_root = NULL;

// --- Функции для создания узлов AST ---
ASTNode* create_node(NodeType type, ASTNode *left, ASTNode *right, ASTNode *next, char *sval) {
    ASTNode *node = (ASTNode*)malloc(sizeof(ASTNode));
    if (!node) { yyerror("Out of memory creating AST node"); exit(1); }
    node->type = type;
    node->sval = sval; // sval уже должен быть скопирован (strdup) или быть NULL
    node->left = left;
    node->right = right;
    node->next = next;
    return node;
}

// Создание листа (ID или CONST)
ASTNode* create_leaf(NodeType type, char *sval)
{
    // sval приходит из yylval, он уже скопирован strdup в лексере
    return create_node(type, NULL, NULL, NULL, sval);
}

// Создание узла операции
ASTNode* create_op_node(char *op_symbol, ASTNode *left, ASTNode *right)
{
    // Копируем символ операции
    char* op_copy = strdup(op_symbol);
     if (!op_copy) { yyerror("Out of memory creating AST node (op)"); exit(1); }
    return create_node(NODE_TYPE_OP, left, right, NULL, op_copy);
}

// Создание узла присваивания
ASTNode* create_assign_node(ASTNode *left, ASTNode *right)
{
    // target_id приходит из yylval ($1), он уже скопирован
    return create_node(NODE_TYPE_ASSIGN, left, right, NULL, NULL);
}

// Добавление оператора в конец списка
ASTNode* append_statement(ASTNode *list_head, ASTNode *new_statement) {
    if (!list_head) {
        return new_statement; // Список был пуст
    }
    ASTNode *current = list_head;
    // Идем до последнего элемента в списке
    while (current->next) {
        current = current->next;
    }
    current->next = new_statement; // Присоединяем новый
    return list_head; // Возвращаем голову списка
}

// --- Функция печати AST ---
void print_ast(ASTNode *node, int indent) {
    if (!node) return;

    // Печать отступа
    for (int i = 0; i < indent; ++i) printf("  "); // 2 пробела на уровень

    // Печать информации об узле
    switch(node->type) {
        case NODE_TYPE_PROGRAM:
            printf("PROGRAM\n");
            print_ast(node->left, indent); // Печатаем первый statement
            break;
        case NODE_TYPE_ASSIGN:
            printf("ASSIGN\n");
            print_ast(node->left, indent + 1);
            print_ast(node->right, indent + 1);
            break;
        case NODE_TYPE_OP:
            printf("EXPRESSION (%s)\n", node->sval ? node->sval : "??");
            print_ast(node->left, indent + 1);  // Левый операнд
            print_ast(node->right, indent + 1); // Правый операнд
            break;
        case NODE_TYPE_IDENTIFIER:
            printf("IDENTIFIER (%s)\n", node->sval ? node->sval : "??");
            break;
        case NODE_TYPE_CHAR_CONST:
            printf("CHAR_CONST (%s)\n", node->sval ? node->sval : "??");
            break;
        default:
            printf("Unknown Node Type\n");
    }

    // Печатаем следующий оператор в списке, если он есть
    // (только для узлов, которые могут быть в списке - PROGRAM/ASSIGN)
     if (node->type == NODE_TYPE_PROGRAM || node->type == NODE_TYPE_ASSIGN) {
          print_ast(node->next, indent); // Печатаем следующий на том же уровне
     }
}

// --- Функция освобождения памяти AST ---
void free_ast(ASTNode *node) {
    if (!node) return;
    // Рекурсивно освобождаем дочерние узлы
    free_ast(node->left);
    free_ast(node->right);
    free_ast(node->next); // Освобождаем следующий в списке
    // Освобождаем строку, если она была выделена
    if (node->sval) free(node->sval);
    // Освобождаем сам узел
    free(node);
}

%}

/* --- Декларации Bison --- */
%union {
    char *sval;      // Для значений токенов ID, CHAR_CONST
    struct ASTNode *node; // Для передачи указателей на узлы AST между правилами
}

// Терминалы
%token <sval> T_IDENTIFIER T_CHAR_CONST
%token T_ASSIGN_OP T_ADD_OP T_SUB_OP T_MUL_OP T_DIV_OP T_LPAREN T_RPAREN T_SEPARATOR

// Нетерминалы, которые будут нести значение (указатель на узел AST)
%type <node> program statement_list statement expression term factor

// Приоритеты и ассоциативность
%right T_ASSIGN_OP
%left T_ADD_OP T_SUB_OP
%left T_MUL_OP T_DIV_OP

// Стартовый символ
%start program

%%
/* --- Правила Грамматики с Построением AST --- */

program: /* empty */
            { $$ = NULL; ast_root = $$; /* Пустое дерево */ }
        | statement_list
            { $$ = create_node(NODE_TYPE_PROGRAM, $1, NULL, NULL, NULL); ast_root = $$; /* Корень дерева - список операторов */ }
        ;

statement_list: statement
            { $$ = $1; /* Голова списка - первый оператор */ }
        | statement_list T_SEPARATOR statement
            { $$ = append_statement($1, $3); }
        | statement_list T_SEPARATOR
            //{ $$ = append_statement($1, $1); }
        ;

// Важно: Убрали T_SEPARATOR отсюда, он теперь в statement_list
statement: T_IDENTIFIER T_ASSIGN_OP expression
            //{ $$ = create_assign_node($1, $3); }
            { $$ = create_assign_node(create_leaf(NODE_TYPE_IDENTIFIER, $1), $3); }
         | error T_SEPARATOR
            { yyerrok; $$ = NULL; /* При ошибке не создаем узел, разрешаем следующую ошибку */ }
         ;

expression: term                     { $$ = $1; /* Передаем узел AST от term */ }
          | expression T_ADD_OP term { $$ = create_op_node("+", $1, $3); }
          | expression T_SUB_OP term { $$ = create_op_node("-", $1, $3); }
          ;

term:     factor                 { $$ = $1; /* Передаем узел AST от factor */ }
        | term T_MUL_OP factor   { $$ = create_op_node("*", $1, $3); }
        | term T_DIV_OP factor   { $$ = create_op_node("/", $1, $3); }
        ;

factor:   T_IDENTIFIER         { $$ = create_leaf(NODE_TYPE_IDENTIFIER, $1); }
        | T_CHAR_CONST         { $$ = create_leaf(NODE_TYPE_CHAR_CONST, $1); }
        | T_LPAREN expression T_RPAREN { $$ = $2; /* Передаем узел AST из скобок */ }
        ;

%%
/* --- Пользовательский Код --- */

int main(int argc, char **argv) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) { perror(argv[1]); return 1; }
    } else {
        yyin = stdin; printf("Reading from stdin...\n");
    }

    printf("--- Parsing and Building AST ---\n");
    int result = yyparse(); // Запускаем парсер, строим AST в ast_root
    printf("--- Parsing Finished ---\n");

    if (result == 0 && ast_root != NULL)
    {
        printf("\n--- Abstract Syntax Tree ---\n");
        print_ast(ast_root, 0); // Печатаем построенное дерево
        printf("--- End AST ---\n");
        printf("\nParse successful.\n");
    }
    else if (result == 0 && ast_root == NULL)
        printf("\nParse successful (empty input).\n");
    else
        printf("\nParse failed.\n");

    if (ast_root) free_ast(ast_root);


    if (yyin != stdin) { fclose(yyin); }
    return result;
}

void yyerror(const char *s) {
    fprintf(stderr, "\nError on (%d:%d) near '%s': %s\n", yylineno, ch, yytext ? yytext : "<null>", s);
}