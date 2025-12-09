%debug
%define parse.error verbose

%{
#include <stdio.h>
#include <stdlib.h>
#include "ast.h"

void yyerror(const char *s);
#undef yylex
int yylex(void);
int lineno = 1;
%}

%union {
    int intval;
    char *str;
    void *node;
}

%token T_PREAMBLE
%token T_INTEGER
%token T_VOID
%token T_PRINT
%token T_ASSIGN
%token T_RETURN

%token <str> T_IDENT
%token <intval> T_NUMBER
%token <str> T_STRING

%token T_EQ
%token T_NE
%token T_LT
%token T_GT
%token T_LE
%token T_GE

%token T_AND
%token T_OR
%token T_NOT

%type <node> program
%type <node> func_decl
%type <node> block
%type <node> stmt_list
%type <node> stmt
%type <node> expr
%type <node> var_decl

%left T_OR
%left T_AND
%left T_EQ T_NE
%left T_LT T_LE T_GT T_GE
%left '+' '-'
%left '*' '/'
%right T_NOT

%%

program:
    T_PREAMBLE func_decl
    {
        yyparse_root = $2;
        $$ = $2;
    }
    ;

func_decl:
    T_INTEGER T_IDENT '(' T_VOID ')' block
    {
        $$ = make_func($2, $6);
    }
    ;

block:
    '{' stmt_list '}'
    {
        $$ = $2;
    }
    ;

stmt_list:
    {
        $$ = NULL;
    }
    | stmt_list stmt
    {
        if ($1 == NULL)
            $$ = $2;
        else {
            void *cur = $1;
            while (((AST*)cur)->next) cur = ((AST*)cur)->next;
            ((AST*)cur)->next = $2;
            $$ = $1;
        }
    }
    ;

stmt:
      var_decl ';'     { $$ = $1; }
    | T_IDENT T_ASSIGN expr ';' { $$ = make_assign($1, $3); }
    | T_PRINT '(' expr ')' ';'  { $$ = make_print($3, NULL); }
    | T_RETURN expr ';'         { $$ = make_return($2); }
    | expr ';'                  { $$ = $1; }
    ;

var_decl:
      T_INTEGER T_IDENT                { $$ = make_vardecl($2, NULL); }
    | T_INTEGER T_IDENT T_ASSIGN expr  { $$ = make_vardecl($2, $4); }
    ;

expr:
      T_NUMBER      { $$ = make_int($1); }
    | T_STRING      { $$ = make_string($1); }
    | T_IDENT       { $$ = make_ident($1); }

    | expr '*' expr { $$ = make_binary($1, '*', $3); }
    | expr '+' expr { $$ = make_binary($1, '+', $3); }

    | '(' expr ')'  { $$ = $2; }

    | expr T_EQ expr  { $$ = make_compare(CMP_EQ, $1, $3); }
    | expr T_NE expr  { $$ = make_compare(CMP_NE, $1, $3); }
    | expr T_LT expr  { $$ = make_compare(CMP_LT, $1, $3); }
    | expr T_GT expr  { $$ = make_compare(CMP_GT, $1, $3); }
    | expr T_LE expr  { $$ = make_compare(CMP_LE, $1, $3); }
    | expr T_GE expr  { $$ = make_compare(CMP_GE, $1, $3); }

    | expr T_AND expr { $$ = make_logic(LOG_AND, $1, $3); }
    | expr T_OR expr  { $$ = make_logic(LOG_OR, $1, $3); }
    | T_NOT expr      { $$ = make_logic(LOG_NOT, $2, NULL); }
    ;

%%

void yyerror(const char *s)
{
    fprintf(stderr, "Parse error at line %d: %s\n", lineno, s);
}

int yylex_debug()
{
    int t = yylex();
    printf("[TOKEN] %d\n", t);
    return t;
}

#define yylex yylex_debug
