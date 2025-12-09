#include <stdio.h>
#include <stdlib.h>
#include "ast.h"

int yyparse(void);
extern FILE *yyin;
extern int lineno;
extern AST *yyparse_root;
void run(AST *root);

int main(int argc, char **argv) {
    if (argc < 2) {
        printf("usage: %s <file>\n", argv[0]);
        return 1;
    }
    FILE *f = fopen(argv[1], "r");
    if (!f) {
        printf("cannot open %s\n", argv[1]);
        return 1;
    }
    yyin = f;
    lineno = 1;
    if (yyparse() == 0) {
        run(yyparse_root);
    } else {
        printf("parse failed\n");
    }
    fclose(f);
    return 0;
}
