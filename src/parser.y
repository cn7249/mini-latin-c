%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
int yylex(void);

typedef struct Node {
    enum { N_PROGRAM, N_FUNC, N_BLOCK, N_VARDECL, N_ASSIGN, N_INT, N_IDENT, N_BINARY, N_CALL, N_RETURN, N_PRINT } kind;
    /* simple union */
    int ival;
    char *sval;
    struct Node *left;
    struct Node *right;
    struct Node *next; /* for list */
    struct Node *args; /* call args */
} Node;

Node *make_node();
Node *make_int(int v);
Node *make_ident(char *s);
Node *make_vardecl(char *name, Node *init);
Node *make_assign(char *name, Node *expr);
Node *make_binary(Node *l, int op, Node *r);
Node *make_print(Node *fmt, Node *args);
Node *make_func(char *name, Node *body);
Node *make_return(Node *expr);

extern int lineno;
%}

%union {
    int ival;
    char* str;
    Node* node;
}

%token PREAMBLE
%token T_INTEGER T_SCRIBERE T_EST T_MULT T_PLUS T_FUNCTIO T_VACUUM T_RETURN
%token T_FOR T_WHILE T_IF T_ELSE
%token IDENT STRING INTLIT

%type <node> program func_decl block stmt stmt_list expr var_decl

%%

program:
    PREAMBLE func_decl    { 
                            /* top-level: require PREAMBLE then one function */
                            printf("[ok] preamble found\n");
                            /* run interpreter on $2 later in main */
                            yyparse_root = $2;
                          }
  ;

func_decl:
    T_INTEGER IDENT '(' T_VACUUM ')' block  {
        $$ = make_func($2, $6);
    }
  ;

block:
    '{' stmt_list '}' {
        $$ = $2;
    }
  ;

stmt_list:
    /* empty */
    { $$ = NULL; }
  | stmt_list stmt {
        if ($1 == NULL) $$ = $2;
        else {
            Node *cur = $1;
            while(cur->next) cur = cur->next;
            cur->next = $2;
            $$ = $1;
        }
    }
  ;

stmt:
    var_decl ';'          { $$ = $1; }
  | IDENT T_EST expr ';'  { $$ = make_assign($1, $3); }
  | T_SCRIBERE '(' STRING { $$ = make_print(make_ident($3), NULL); /* format only for now */ }
      ')' ';'
  | T_RETURN expr ';'     { $$ = make_return($2); }
  | expr ';'              { $$ = $1; }
  ;

var_decl:
    T_INTEGER IDENT       { $$ = make_vardecl($2, NULL); }
  | T_INTEGER IDENT T_EST expr { $$ = make_vardecl($2, $4); }
  ;

expr:
    INTLIT                { $$ = make_int($1); }
  | IDENT                 { $$ = make_ident($1); }
  | expr T_MULT expr      { $$ = make_binary($1, '*', $3); }
  | expr T_PLUS expr      { $$ = make_binary($1, '+', $3); }
  | '(' expr ')'          { $$ = $2; }
  ;

%%

/* root pointer for program AST */
Node *yyparse_root = NULL;

void yyerror(const char *s) {
    fprintf(stderr, "Parse error: %s\n", s);
}
