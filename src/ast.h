#ifndef AST_H
#define AST_H
typedef struct Node Node;
Node *make_node();
Node *make_int(int v);
Node *make_ident(char *s);
Node *make_vardecl(char *name, Node *init);
Node *make_assign(char *name, Node *expr);
Node *make_binary(Node *l, int op, Node *r);
Node *make_print(Node *fmt, Node *args);
Node *make_func(char *name, Node *body);
Node *make_return(Node *expr);

/* root to be set by parser */
extern Node *yyparse_root;
#endif
