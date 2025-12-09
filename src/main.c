#include <stdio.h>
#include <stdlib.h>

extern int yyparse(void);
extern void run(struct Node *root);
extern struct Node *yyparse_root;

int main(int argc, char **argv){
    if (argc < 2){
        fprintf(stderr, "usage: %s file.lc\n", argv[0]);
        return 1;
    }
    FILE *f = fopen(argv[1],"r");
    if (!f){ perror("fopen"); return 1; }
    extern FILE *yyin;
    yyin = f;
    if (yyparse() != 0){
        fprintf(stderr, "parse failed\n");
        return 1;
    }
    if (!yyparse_root){ fprintf(stderr, "no program parsed\n"); return 1; }
    run(yyparse_root);
    return 0;
}
