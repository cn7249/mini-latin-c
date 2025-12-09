#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

/* Very simple symbol table: linked list of (name, int val) */
typedef struct Sym {
    char *name; int val; struct Sym *next;
} Sym;
static Sym *symtab = NULL;

void sym_set(const char *name, int v){
    for (Sym *s = symtab; s; s = s->next){
        if (strcmp(s->name, name) == 0){ s->val = v; return; }
    }
    Sym *n = malloc(sizeof(Sym)); n->name = strdup(name); n->val = v; n->next = symtab; symtab = n;
}
int sym_get(const char *name, int *ok){
    for (Sym *s = symtab; s; s = s->next){
        if (strcmp(s->name, name) == 0){ *ok = 1; return s->val; }
    }
    *ok = 0; return 0;
}

/* goal: check that identifiers passed as function arguments are in accusative form:
   simple rule: identifier ending with "UM" (case-insensitive) is accusative.
*/
int is_accusative(const char *name){
    int L = strlen(name);
    if (L < 2) return 0;
    char a = name[L-2], b = name[L-1];
    a = toupper(a); b = toupper(b);
    return (a=='U' && b=='M');
}

int eval(Node *n);

void exec_block(Node *block){
    Node *cur = block;
    while(cur){
        if (cur->kind == N_VARDECL){
            /* initialize to 0 or given expr */
            int val = 0;
            if (cur->left) val = eval(cur->left);
            sym_set(cur->sval, val);
        } else if (cur->kind == N_ASSIGN){
            int v = eval(cur->left);
            sym_set(cur->sval, v);
        } else if (cur->kind == N_PRINT){
            /* For prototype: print format string or a single identifier/int */
            if (cur->left && cur->left->kind == N_IDENT){
                /* it's actually a quoted string from lexer with quotes included */
                char *qs = cur->left->sval;
                /* remove surrounding quotes if present */
                if (qs && qs[0] == '"' ){
                    printf("%s", qs+1);
                    if (qs[strlen(qs)-1] == '"') printf("\b"); /* noop */
                } else printf("%s", qs ? qs : "");
                printf("\n");
            } else {
                printf("[print] unsupported format in prototype\n");
            }
        } else if (cur->kind == N_RETURN){
            int rv = eval(cur->left);
            printf("[return] %d\n", rv);
        } else if (cur->kind == N_INT){
            /* expression statement: evaluate and drop */
            eval(cur);
        }
        cur = cur->next;
    }
}

int eval(Node *n){
    if (!n) return 0;
    switch(n->kind){
        case N_INT: return n->ival;
        case N_IDENT: {
            int ok; int v = sym_get(n->sval, &ok);
            if (!ok){ fprintf(stderr, "Runtime error: undefined variable %s\n", n->sval); return 0; }
            return v;
        }
        case N_BINARY: {
            int l = eval(n->left);
            int r = eval(n->right);
            if (n->ival == '*') return l * r;
            if (n->ival == '+') return l + r;
            return 0;
        }
        default:
            return 0;
    }
}

/* top-level run */
void run(Node *root){
    if (!root) { fprintf(stderr, "No AST\n"); return; }
    if (root->kind == N_FUNC){
        printf("[run] executing function %s\n", root->sval);
        exec_block(root->left);
    } else {
        fprintf(stderr, "Unexpected top node\n");
    }
}
