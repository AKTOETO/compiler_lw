// tokens.h
#ifndef TOKENS_H
#define TOKENS_H

// Перечисление для типов токенов
typedef enum
{
    TOKEN_IDENTIFIER, // Идентификатор (например, varName)
    TOKEN_CHAR_CONST, // Символьная константа (например, 'a')
    TOKEN_ASSIGN_OP,  // Оператор присваивания (:=)
    TOKEN_ADD_OP,     // Оператор сложения (+)
    TOKEN_SUB_OP,     // Оператор вычитания (-)
    TOKEN_MUL_OP,     // Оператор умножения (*)
    TOKEN_DIV_OP,     // Оператор деления (/)
    TOKEN_LPAREN,     // Открывающая скобка (()
    TOKEN_RPAREN,     // Закрывающая скобка ())
    TOKEN_SEPARATOR,  // Разделитель выражений (;)
    TOKEN_ERROR       // Ошибка лексического анализа
} TokenType;

#endif // TOKENS_H
