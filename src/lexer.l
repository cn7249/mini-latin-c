%option noyywrap
%option noinput
%option nounput

%{
#include "parser.tab.h"
#include <ctype.h>
#include <string.h>
#include <stdlib.h>

#define DEBUG_LEX 1

extern int lineno;

int roman_val(char c);
int roman_to_int(const char *s);
%}

%%

\n                  { lineno++; }
[ \t\r]+            ;

"Ave Imperator, morituri te salutant."    { return T_PREAMBLE; }
"integer"           { return T_INTEGER; }
"vacuum"            { return T_VOID; }
"scribere"          {
    if (DEBUG_LEX) printf("[LEX] T_PRINT\n");
    return T_PRINT;
}

"EST"               { return T_ASSIGN; }
"reditus"           { return T_RETURN; }

\"([^"\n]|\\.)*\" {
    yylval.str = strdup(yytext);
    return T_STRING;
}

[IVXLCDM]+          { yylval.intval = roman_to_int(yytext); return T_NUMBER; }

[0-9]+              { yylval.intval = atoi(yytext); return T_NUMBER; }

[a-zA-Z_][a-zA-Z0-9_]* {
                        yylval.str = strdup(yytext);
                        return T_IDENT;
                     }

"("                 { return '('; }
")"                 { return ')'; }
"{"                 { return '{'; }
"}"                 { return '}'; }
";"                 { return ';'; }
","                 { return ','; }

.                   {
        if (DEBUG_LEX) printf("[LEX] Unknown char: %c\n", yytext[0]);
        return yytext[0];
    }


%%

int roman_val(char c) {
    switch (toupper(c)) {
        case 'I': return 1;
        case 'V': return 5;
        case 'X': return 10;
        case 'L': return 50;
        case 'C': return 100;
        case 'D': return 500;
        case 'M': return 1000;
        default: return 0;
    }
}

int roman_to_int(const char *s) {
    int len = strlen(s);
    int total = 0;
    int prev = 0;

    for (int i = len - 1; i >= 0; i--) {
        int v = roman_val(s[i]);
        if (v < prev)
            total -= v;
        else {
            total += v;
            prev = v;
        }
    }
    return total;
}
