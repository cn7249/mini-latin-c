#ifndef AST_H
#define AST_H

typedef enum {
    N_INT,
    N_STRING,
    N_IDENT,
    N_VARDECL,
    N_ASSIGN,
    N_BINARY,
    N_PRINT,
    N_RETURN,
    N_FUNC,
    N_BLOCK,
    N_STMT_LIST,
    N_COMPARE,
    N_LOGIC
} NodeKind;

typedef enum {
    CMP_EQ,
    CMP_NE,
    CMP_LT,
    CMP_GT,
    CMP_LE,
    CMP_GE,

    LOG_AND,
    LOG_OR,
    LOG_NOT
} OpKind;

typedef struct AST {
    NodeKind kind;
    int ival;
    char *sval;
    struct AST *left;
    struct AST *right;
    struct AST *next;
} AST;

AST *make_node(void);
AST *make_int(int v);
AST *make_string(char *s);
AST *make_ident(char *s);
AST *make_vardecl(char *name, AST *init);
AST *make_assign(char *name, AST *expr);
AST *make_binary(AST *l, int op, AST *r);
AST *make_print(AST *fmt, AST *args);
AST *make_return(AST *expr);
AST *make_func(char *name, AST *body);

AST *make_compare(int op, AST *left, AST *right);
AST *make_logic(int op, AST *left, AST *right);

extern AST *yyparse_root;

#endif
