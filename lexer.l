%{
	#include "y.tab.h"
%}

%%

[ \t\n]                                              ;
"return"                                             { return RETURN; }
"int"|"float"|"double"|"char"|"set"|"bool"|"void"    { return TYPE; }
"static"                                             { return STATIC; }
"const"                                              { return CONST; }
"procedure"                                          { return PROCEDURE; }

"if"                                                 { return IF; }
"while"                                              { return WHILE; }

"+"                                                  { return PLUS; }
"-"                                                  { return MINUS; }
"*"                                                  { return TIMES; }
"/"                                                  { return DIVIDE; }

"%"                                                  { return MOD; }
";"                                                  { return SEMICOLON; }
","                                                  { return COMMA; }
"="                                                  { return EQUAL; }
"!="                                                 { return DIFFERENT; }

"true" | "false"                                     { return BOOL_LIT; }
\"(\\.|[^"\\])*\"                                    { return STRING_LIT; }

"("                                                  { return OPAREN; }
")"                                                  { return CPAREN; }
"{"                                                  { return OBRACE; }
"}"                                                  { return CBRACE; }

[0-9]+                                               { yylval.iValue = atoi(yytext); return NUMBER; }
[-]?[0-9]*\.?[0-9]+|true|false                       { return NUMBER_LIT; }
[_]*[a-z][a-zA-Z0-9_]*                               { yylval.sValue = strdup(yytext); return ID; }

%%

#ifndef yywrap
   int yywrap (void) {return 1;}
#endif
