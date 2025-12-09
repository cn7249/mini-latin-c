#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "ast.h"

struct Node {
    enum { N_PROGRAM, N_FUNC, N_BLOCK, N_VARDECL, N_ASSIGN, N_INT, N_IDENT, N_BINARY, N_CALL, N_RETURN, N_PRINT } kind;
    int ival;
    char *sval;
    struct Node *left;
    struct Node *right;
    struct Node *next;
    struct Node *args;
};

Node *yyparse_root = NULL;

Node *make_node(){
    Node *n = malloc(sizeof(Node));
    n->kind = N_INT; n->ival = 0; n->sval = NULL; n->left = n->right = n->next = n->args = NULL;
    return n;
}
Node *make_int(int v){
    Node *n = make_node(); n->kind = N_INT; n->ival = v; return n;
}
Node *make_ident(char *s){
    Node *n = make_node(); n->kind = N_IDENT; n->sval = strdup(s); return n;
}
Node *make_vardecl(char *name, Node *init){
    Node *n = make_node(); n->kind = N_VARDECL; n->sval = strdup(name); n->left = init; return n;
}
Node *make_assign(char *name, Node *expr){
    Node *n = make_node(); n->kind = N_ASSIGN; n->sval = strdup(name); n->left = expr; return n;
}
Node *make_binary(Node *l, int op, Node *r){
    Node *n = make_node(); n->kind = N_BINARY; n->ival = op; n->left = l; n->right = r; return n;
}
Node *make_print(Node *fmt, Node *args){
    Node *n = make_node(); n->kind = N_PRINT; n->left = fmt; n->args = args; return n;
}
Node *make_func(char *name, Node *body){
    Node *n = make_node(); n->kind = N_FUNC; n->sval = strdup(name); n->left = body; return n;
}
Node *make_return(Node *expr){
    Node *n = make_node(); n->kind = N_RETURN; n->left = expr; return n;
}
