%{
	#include "y.tab.h"
%}

%%

[ \t\n]                                              ;
"return"                                             { return RETURN; }
"break"                                              { return BREAK; }
"int"|"float"|"double"|"char"|"set"|"bool"|"void"    { yylval.sValue = strdup(yytext); return TYPE; }
"static"                                             { return STATIC; }
"const"                                              { return CONST; }
"procedure"                                          { return PROCEDURE; }
"container"                                          { return CONTAINER; }

"if"                                                 { return IF; }
"else"                                               { return ELSE; }
"while"                                              { return WHILE; }

"&"                                                  { return REF; }

"+"                                                  { return PLUS; }
"-"                                                  { return MINUS; }
"*"                                                  { return ASTERISK; }
"/"                                                  { return DIVIDE; }
">"                                                  { return HIGHER; }
">="                                                 { return HIGHERE; }
"<"                                                  { return MINOR; }
"<="                                                 { return MINORE; }
"and"                                                { return AND; }
"or"                                                 { return OR; }
"not"                                                { return UNOT; }
"xor"                                                { return XOR; }
"=="                                                 { return EQUALITY; }

"%"                                                  { return MOD; }
";"                                                  { return SEMICOLON; }
","                                                  { return COMMA; }
"="                                                  { return EQUAL; }
"!="                                                 { return DIFFERENT; }

"true" | "false"                                     { yylval.sValue = strdup(yytext); return BOOL_LIT; }
\"(\\.|[^"\\])*\"                                    { yylval.sValue = strdup(yytext); return STRING_LIT; }
\'.?\'                                               { yylval.cValue = yytext[1]; return CHAR_LIT; }

"("                                                  { return OPAREN; }
")"                                                  { return CPAREN; }
"{"                                                  { return OBRACE; }
"}"                                                  { return CBRACE; }
"["                                                  { return OBRACKET; }
"]"                                                  { return CBRACKET; }

[0-9]+                                               { yylval.sValue = strdup(yytext); return NUMBER; }
[-]?[0-9]*\.?[0-9]+                                  { yylval.sValue = strdup(yytext); return NUMBER_LIT; }
[_]*[a-z][a-zA-Z0-9_]*                               { yylval.sValue = strdup(yytext); return ID; }
\/\*

%%

#ifndef yywrap
   int yywrap (void) {return 1;}
#endif
