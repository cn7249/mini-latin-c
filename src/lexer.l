%{
#include "parser.tab.h"
#include <ctype.h>
#include <string.h>
#include <stdlib.h>

void yyerror(const char *s);
int roman_to_int(const char *s);
%}

%x STRING

%%

"Ave Imperator, morituri te salutant."    { return PREAMBLE; }

/\%[^\n]*\n/    { /* allow %... printf-format-like lines in sample (but treat as nothing) */ }

/* keywords - case-insensitive simplest approach: compare uppercase in parser or here */
[ \t\r\n]+      { /* skip whitespace */ }
"//".*          { /* line comment */ }
"/*"([^*]|\*+[^*/])*\*+"/"    { /* block comment */ }

/\"([^\\\"]|\\.)*\"   {
                        yylval.str = strdup(yytext);
                        return STRING;
                    }

/[IVXLCDM]+/ {
                /* detect roman numerals (uppercase only) */
                yylval.ival = roman_to_int(yytext);
                return INTLIT;
            }

/[0-9]+/    {
                yylval.ival = atoi(yytext);
                return INTLIT;
           }

/integer/    { return T_INTEGER; }
 /scribere/ { return T_SCRIBERE; }
 /EST/      { return T_EST; }       /* assignment = */
 /MULTA/    { return T_MULT; }      /* multiplication */
 /PLUS/     { return T_PLUS; }      /* addition (optional) */
 /functio/  { return T_FUNCTIO; }
 /vacuum/   { return T_VACUUM; }
 /reditus/  { return T_RETURN; }

/PRO/       { return T_FOR; }       /* 'for' style (user used PRO) */
 /DUM/      { return T_WHILE; }     /* while */
 /si/       { return T_IF; }
 /aliter/   { return T_ELSE; }

/[A-Za-z_][A-Za-z0-9_]*/ {
                            /* identifiers (preserve original case in yylval.str) */
                            yylval.str = strdup(yytext);
                            return IDENT;
                        }

.   { /* any other single char as token (parens, semicolon, comma, braces, operators) */
        if (yytext[0] == '{') return '{';
        if (yytext[0] == '}') return '}';
        if (yytext[0] == '(') return '(';
        if (yytext[0] == ')') return ')';
        if (yytext[0] == ';') return ';';
        if (yytext[0] == ',') return ',';
        if (yytext[0] == '+') { yylval.ival = '+'; return '+'; }
        if (yytext[0] == '-') { yylval.ival = '-'; return '-'; }
        if (yytext[0] == '*') { yylval.ival = '*'; return '*'; }
        if (yytext[0] == '/') { yylval.ival = '/'; return '/'; }
        /* otherwise ignore unknown char */
    }

%%

int roman_val(char c) {
    switch(c){
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
    for (int i = len-1; i >= 0; --i) {
        int v = roman_val(toupper(s[i]));
        if (v < prev) total -= v;
        else { total += v; prev = v; }
    }
    return total;
}
