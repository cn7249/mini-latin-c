#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

typedef struct {
    char name[128];
    int value;
    int used;
} Var;

static Var vartab[256];
static int varcount = 0;

static int get_index(const char *name) {
    for (int i = 0; i < varcount; ++i) {
        if (strcmp(vartab[i].name, name) == 0) return i;
    }
    return -1;
}

static int get_var(const char *name, int *ok) {
    int idx = get_index(name);
    if (idx < 0) {
        *ok = 0;
        return 0;
    }
    *ok = 1;
    return vartab[idx].value;
}

static void set_var(const char *name, int v) {
    int idx = get_index(name);
    if (idx >= 0) {
        vartab[idx].value = v;
        vartab[idx].used = 1;
        return;
    }
    if (varcount < (int)(sizeof(vartab) / sizeof(vartab[0]))) {
        strncpy(vartab[varcount].name, name, sizeof(vartab[varcount].name) - 1);
        vartab[varcount].name[sizeof(vartab[varcount].name) - 1] = '\0';
        vartab[varcount].value = v;
        vartab[varcount].used = 1;
        varcount++;
    }
}

static int eval(AST *n);

static int eval_binary(AST *n) {
    int l = eval(n->left);
    int r = eval(n->right);
    int op = n->ival;
    if (op == '+') return l + r;
    if (op == '-') return l - r;
    if (op == '*') return l * r;
    if (op == '/') return r ? l / r : 0;
    return 0;
}

static void eval_string(AST *n) {
    char *s = n->sval;
    int len = strlen(s);

    if (len >= 2 && s[0] == '"' && s[len - 1] == '"') {
        char buf[1024];
        int copy_len = len - 2;
        if (copy_len > 1023) copy_len = 1023;
        strncpy(buf, s + 1, copy_len);
        buf[copy_len] = '\0';
        printf("%s", buf);
    } else {
        printf("%s", s);
    }
}

static int eval_compare(AST *n) {
    int l = eval(n->left);
    int r = eval(n->right);
    switch (n->ival) {
        case CMP_EQ: return l == r;
        case CMP_NE: return l != r;
        case CMP_LT: return l < r;
        case CMP_GT: return l > r;
        case CMP_LE: return l <= r;
        case CMP_GE: return l >= r;
    }
    return 0;
}

static int eval_logic(AST *n) {
    switch (n->ival) {
        case LOG_AND:
            return eval(n->left) && eval(n->right);
        case LOG_OR:
            return eval(n->left) || eval(n->right);
        case LOG_NOT:
            return !eval(n->left);
    }
    return 0;
}


static int eval(AST *n) {
    if (!n) return 0;

    switch (n->kind) {

        case N_INT:
            return n->ival;

        case N_STRING:
            eval_string(n);
            return 0;

        case N_IDENT: {
            int ok;
            int v = get_var(n->sval, &ok);
            if (!ok) {
                fprintf(stderr, "runtime: undefined var %s\n", n->sval);
                return 0;
            }
            return v;
        }

        case N_VARDECL: {
            if (n->left) {
                int v = eval(n->left);
                set_var(n->sval, v);
                return v;
            }
            set_var(n->sval, 0);
            return 0;
        }

        case N_ASSIGN: {
            int v = eval(n->left);
            set_var(n->sval, v);
            return v;
        }
        
        case N_BINARY:
            return eval_binary(n);

        case N_COMPARE:
            return eval_compare(n);

        case N_LOGIC:
            return eval_logic(n);

        case N_PRINT: {
            if (n->left) {
                if (n->left->kind == N_STRING) {
                    eval_string(n->left);
                    printf("\n");
                } else {
                    printf("%d\n", eval(n->left));
                }
            }
            return 0;
        }

        case N_RETURN:
            return eval(n->left);

        default:
            return 0;
    }
}

static void exec_stmt_list(AST *list) {
    AST *cur = list;
    while (cur) {
        if (cur->kind == N_RETURN) return;
        if (cur->kind == N_FUNC) {
            cur = cur->next;
            continue;
        }
        eval(cur);
        cur = cur->next;
    }
}

void run(AST *root) {
    if (!root) return;
    if (root->kind == N_FUNC) {
        exec_stmt_list(root->left);
        return;
    }
    if (root->kind == N_STMT_LIST) {
        exec_stmt_list(root);
    }
}
