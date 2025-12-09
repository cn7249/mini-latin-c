#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "ast.h"

AST *yyparse_root = NULL;

static AST *alloc_node(void) {
    AST *n = (AST *)malloc(sizeof(AST));
    if (!n) {
        fprintf(stderr, "out of memory\n");
        exit(1);
    }
    n->kind = N_INT;
    n->ival = 0;
    n->sval = NULL;
    n->left = NULL;
    n->right = NULL;
    n->next = NULL;
    return n;
}

AST *make_node(void) {
    return alloc_node();
}

AST *make_int(int v) {
    AST *n = alloc_node();
    n->kind = N_INT;
    n->ival = v;
    return n;
}

AST *make_string(char *s) {
    AST *n = alloc_node();
    n->kind = N_STRING;
    n->sval = strdup(s);
    return n;
}

AST *make_ident(char *s) {
    AST *n = alloc_node();
    n->kind = N_IDENT;
    n->sval = strdup(s);
    return n;
}

AST *make_vardecl(char *name, AST *init) {
    AST *n = alloc_node();
    n->kind = N_VARDECL;
    n->sval = strdup(name);
    n->left = init;
    return n;
}

AST *make_assign(char *name, AST *expr) {
    AST *n = alloc_node();
    n->kind = N_ASSIGN;
    n->sval = strdup(name);
    n->left = expr;
    return n;
}

AST *make_binary(AST *l, int op, AST *r) {
    AST *n = alloc_node();
    n->kind = N_BINARY;
    n->ival = op;
    n->left = l;
    n->right = r;
    return n;
}

AST *make_print(AST *fmt, AST *args) {
    AST *n = alloc_node();
    n->kind = N_PRINT;
    n->left = fmt;
    n->right = args;
    return n;
}

AST *make_return(AST *expr) {
    AST *n = alloc_node();
    n->kind = N_RETURN;
    n->left = expr;
    return n;
}

AST *make_func(char *name, AST *body) {
    AST *n = alloc_node();
    n->kind = N_FUNC;
    n->sval = strdup(name);
    n->left = body;
    return n;
}

AST *make_compare(int op, AST *left, AST *right) {
    AST *n = make_node();
    n->kind = N_COMPARE;
    n->ival = op;
    n->left = left;
    n->right = right;
    return n;
}

AST *make_logic(int op, AST *left, AST *right) {
    AST *n = make_node();
    n->kind = N_LOGIC;
    n->ival = op;
    n->left = left;
    n->right = right;
    return n;
}
