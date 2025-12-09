%{
#include <stdio.h>
#include <stdlib.h>
#include "ast.h"

void yyerror(const char *s);
int yylex(void);

int lineno = 1;
%}

%union {
    int intval;
    char *str;
    void *node;
}

%token T_PREAMBLE
%token T_INTEGER T_VOID
%token T_PRINT
%token T_ASSIGN
%token T_RETURN

%token <str> T_IDENT
%token <intval> T_NUMBER
%token <str> T_STRING

%type <node> program
%type <node> func_decl
%type <node> block
%type <node> stmt_list
%type <node> stmt
%type <node> expr
%type <node> var_decl

%%

program:
    T_PREAMBLE func_decl
    {
        yyparse_root = (AST*)$2;
        $$ = $2;
    }
    ;

func_decl:
    T_INTEGER T_IDENT '(' T_VOID ')' block
    {
        $$ = make_func($2, (AST*)$6);
    }
    ;

block:
    '{' stmt_list '}'
    {
        $$ = $2;
    }
    ;

stmt_list:
      /* empty */
    {
        $$ = NULL;
    }
    | stmt_list stmt
    {
        if ($1 == NULL)
            $$ = $2;
        else {
            AST *cur = (AST*)$1;
            while (cur->next) cur = cur->next;
            cur->next = (AST*)$2;
            $$ = $1;
        }
    }
    ;

stmt:
    var_decl ';'
    {
        $$ = $1;
    }
    | T_IDENT T_ASSIGN expr ';'
    {
        $$ = make_assign($1, (AST*)$3);
    }
    | T_PRINT '(' T_STRING ')' ';'
    {
        AST *s = make_string($3);
        $$ = make_print(s, NULL);
    }
    | T_RETURN expr ';'
    {
        $$ = make_return((AST*)$2);
    }
    | expr ';'
    {
        $$ = $1;
    }
    ;

var_decl:
    T_INTEGER T_IDENT
    {
        $$ = make_vardecl($2, NULL);
    }
    | T_INTEGER T_IDENT T_ASSIGN expr
    {
        $$ = make_vardecl($2, (AST*)$4);
    }
    ;

expr:
    T_NUMBER
    {
        $$ = make_int($1);
    }
    | T_IDENT
    {
        $$ = make_ident($1);
    }
    | expr '*' expr
    {
        $$ = make_binary((AST*)$1, '*', (AST*)$3);
    }
    | expr '+' expr
    {
        $$ = make_binary((AST*)$1, '+', (AST*)$3);
    }
    | '(' expr ')'
    {
        $$ = $2;
    }
    ;

%%

void yyerror(const char *s)
{
    fprintf(stderr, "Parse error: %s\n", s);
}
