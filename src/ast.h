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
    N_STMT_LIST
} NodeKind;

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

extern AST *yyparse_root;

#endif
