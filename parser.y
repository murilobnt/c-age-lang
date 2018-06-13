%{
#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include <gmodule.h>

#include "hash_table.h"
#include "value_un.h"
#include "Stack.h"

#define GLOBAL "global"

int yylex(void);
int yyerror(char *s);
int intlen(int i);
extern int yylineno;
extern char * yytext;

Stack * scope_stack;

%}

%union{
        char  * sValue;
        char    cValue;
        int     iValue;
};

%token <sValue> ID
%token <sValue> NUMBER_LIT
%token <sValue> STRING_LIT
%token <sValue> BOOL_LIT
%token <sValue> NUMBER
%token <sValue> TYPE
%token <cValue> CHAR_LIT

%token STATIC CONST RETURN BREAK PROCEDURE CONTAINER
%token IF ELSE WHILE
%token OPAREN CPAREN OBRACE CBRACE OBRACKET CBRACKET
%token SEMICOLON COMMA
%token OPERATOR
%token EQUAL

%type <sValue> global_scope globals global global_var static_init func proc bloc_scope func_parameters block_body return_stmt block_stmts block_dec cond_params
%type <sValue> block_stmt if_stmt while_stmt init attr call expr operator operand declaration decl_scope decl_list p_type
%type <sValue> if_else_stmt else_stmt array_access type_val pointer_scope pointers expr_scope expr_list break_stmt accesses

%left PLUS MINUS OR UNOT
%left ASTERISK REF DIVIDE MOD AND XOR
%left HIGHER HIGHERE MINOR MINORE EQUALITY DIFFERENT

%start start_stm

%%

start_stm       :     { subinfo glob;
                        glob.subp = GLOBAL;
                        glob.type = "void";
                        scope_stack = push(scope_stack, glob);
                      }
                        global_scope { printf("%s\n", $2); }

global_scope    :     { $$ = ""; }
                |     globals { $$ = $1; }

globals         :     global { $$ = $1; }
                |     globals global { $$ = (char *)malloc(sizeof(char) * (strlen($1)+strlen($2)+15)); sprintf($$, "%s\n%s", $1, $2); }

global          :     global_var SEMICOLON { $$ = (char *)malloc(sizeof(char) * (strlen($1)+15)); sprintf($$, "%s;", $1); }
                |     func { $$ = $1; }
                |     proc { $$ = $1; }

global_var      :     init { $$ = $1; }
                |     attr { $$ = $1; }
                |     static_init { $$ = $1; }

static_init     :     STATIC type_val CONST attr { $$ = (char *)malloc(sizeof(char) * (strlen($4)+19)); sprintf($$, "STATIC %s CONST %s", $2, $4); }

func            :     type_val ID func_parameters { subinfo subf;
                        subf.subp = $2;
                        subf.type = $1;
                        scope_stack = push(scope_stack, subf); }
                        block_body { $$ = (char *)malloc(sizeof(char) * (strlen($2)+strlen($3)+strlen($5)+15)); sprintf($$, "%s %s %s %s", $1, $2, $3, $5); }

proc            :     PROCEDURE ID func_parameters block_body { $$ = (char *)malloc(sizeof(char) * (strlen($2)+strlen($3)+strlen($4)+13)); sprintf($$, "procedure %s %s %s", $2, $3, $4); }

func_parameters :     OPAREN decl_scope CPAREN { $$ = (char *)malloc(sizeof(char) * (strlen($2)+15)); sprintf($$, "(%s)", $2); }

decl_scope      :     { $$ = ""; }
                |     decl_list { $$ = $1; }

decl_list       :     declaration { $$ = $1; }
                |     declaration COMMA decl_list { $$ = (char *)malloc(sizeof(char) * (strlen($1) + strlen($3) + 15)); sprintf($$, "%s, %s", $1, $3); }

bloc_scope      :     { $$ = ""; }
                |     block_stmts { $$ = $1; }

return_stmt     :     RETURN expr SEMICOLON { $$ = (char *)malloc(sizeof(char) * (strlen($2)+15)); sprintf($$, "return %s;\n", $2); }
                |     RETURN SEMICOLON { $$ = "return;\n"; }

block_body      :     OBRACE bloc_scope CBRACE { $$ = (char *)malloc(sizeof(char) * (strlen($2)+15)); sprintf($$, "{\n%s}", $2); }

block_stmts     :     block_stmt { $$ = $1; }
                |     block_stmts block_stmt { $$ = (char *)malloc(sizeof(char) * (strlen($1)+strlen($2)+15)); sprintf($$, "%s%s", $1, $2); }

block_stmt      :     block_dec SEMICOLON { $$ = (char *)malloc(sizeof(char) * (strlen($1)+15)); sprintf($$, "%s;\n", $1); }
                |     if_stmt { $$ = $1; }
                |     if_else_stmt { $$ = $1; }
                |     while_stmt { $$ = $1; }
                |     return_stmt { $$ = $1; }
                |     break_stmt { $$ = $1; }

break_stmt      :     BREAK SEMICOLON { $$ = "break;\n"; }

if_stmt         :     IF cond_params block_body { $$ = (char *)malloc(sizeof(char) * (strlen($2)+strlen($3)+15)); sprintf($$, "if %s %s\n", $2, $3); }

if_else_stmt    :     if_stmt else_stmt { $$ = (char *)malloc(sizeof(char) * (strlen($1)+strlen($2)+15)); sprintf($$, "%s%s", $1, $2); }

else_stmt       :     ELSE block_body { $$ = (char *)malloc(sizeof(char) * (strlen($2)+15)); sprintf($$, "else %s\n", $2); }

while_stmt      :     WHILE cond_params block_body { $$ = (char *)malloc(sizeof(char) * (strlen($2)+strlen($3)+15)); sprintf($$, "while %s %s\n", $2, $3); }

cond_params     :     OPAREN expr CPAREN { $$ = (char *)malloc(sizeof(char) * (strlen($2) + 15)); sprintf($$, "(%s)", $2); }

block_dec       :     init { $$ = $1; }
                |     attr { $$ = $1; }
                |     call { $$ = $1; }

declaration     :     type_val ID { $$ = (char *)malloc(sizeof(char) * (strlen($1) + strlen($2) + 15)); sprintf($$, "%s %s", $1, $2); }
                |     type_val ID accesses { $$ = (char *)malloc(sizeof(char) * (strlen($1)+strlen($2)+strlen($3)+15)); sprintf($$, "%s %s%s", $1, $2, $3); }

init            :     declaration { $$ = $1; }
                |     type_val attr { printf("This is top: %s\n", top(scope_stack, 0).subp); $$ = (char *)malloc(sizeof(char) * (strlen($2)+6)); sprintf($$, "%s %s", $1, $2); }

attr            :     ID EQUAL expr { $$ = (char *)malloc(sizeof(char) * (strlen($1)+4+strlen($3)+15)); sprintf( $$, "%s = %s", $1, $3); }
                |     array_access EQUAL expr { $$ = (char *)malloc(sizeof(char) * (strlen($1)+10+strlen($3)+15)); sprintf( $$, "%s = %s", $1, $3); }

call            :     ID OPAREN expr_scope CPAREN { $$ = (char *)malloc(sizeof(char) * (strlen($1)+strlen($3)+15)); sprintf($$, "%s(%s)", $1, $3); }

expr_scope      :     { $$ = ""; }
                |     expr_list { $$ = $1; }

expr_list       :     expr { $$ = $1; }
                |     expr COMMA expr_list { $$ = (char *)malloc(sizeof(char) * (strlen($1) + strlen($3) + 15)); sprintf($$, "%s, %s", $1, $3); }

expr            :     operand { $$ = (char *)malloc(sizeof(char) * (strlen($1)+1)); sprintf( $$, "%s", $1 ); }
                |     operand operator expr { $$ = (char *)malloc(sizeof(char) * (strlen($1)+strlen($2)+strlen($3)+15)); sprintf( $$, "%s %s %s", $1, $2, $3 ); }

operand         :     NUMBER { $$ = $1; }
                |     CHAR_LIT { $$ = (char *)malloc(sizeof(char)); sprintf($$, "%c", $1); }
                |     STRING_LIT { $$ = $1; }
                |     NUMBER_LIT { $$ = $1; }
                |     BOOL_LIT { $$ = $1; }
                |     ID { $$ = $1; }
                |     array_access { $$ = $1; }
                |     call { $$ = $1; }

array_access    :     ID accesses { $$ = (char *)malloc(sizeof(char) * (strlen($1)+strlen($2)+15)); sprintf($$, "%s%s", $1, $2); }

accesses        :     OBRACKET expr CBRACKET { $$ = (char *)malloc(sizeof(char) * (strlen($2) + 3)); sprintf($$, "[%s]", $2); }
                |     OBRACKET expr CBRACKET accesses { $$ = (char *)malloc(sizeof(char) * (strlen($2) + strlen($4) + 4)); sprintf($$, "[%s]%s", $2, $4); }

type_val        :     TYPE pointer_scope { $$ = (char *)malloc(sizeof(char) * (strlen($1)+strlen($2)+15)); sprintf($$, "%s%s", $1, $2); }

pointer_scope   :     { $$ = ""; }
                |     pointers { $$ = $1; }

pointers        :     p_type { $$ = $1; }
                |     pointers p_type { $$ = (char *)malloc(sizeof(char) * (strlen($1)+strlen($2)+15)); sprintf($$, "%s%s", $1, $2); }

p_type          :     ASTERISK { $$ = "*"; }
                |     REF { $$ = "&"; }

operator        :     PLUS { $$ = "+"; }
                |     MINUS { $$ = "-"; }
                |     ASTERISK { $$ = "*"; }
                |     DIVIDE { $$ = "/"; }
                |     MOD { $$ = "%"; }
                |     AND { $$ = "&&"; }
                |     OR { $$ = "||"; }
                |     XOR { $$ = "!x && !y"; }
                |     UNOT { $$ = "!"; }
                |     EQUALITY { $$ = "=="; }
                |     DIFFERENT { $$ = "!="; }
                |     HIGHER { $$ = ">"; }
                |     HIGHERE { $$ = ">="; }
                |     MINOR { $$ = "<"; }
                |     MINORE { $$ = "<="; }
%%

int main (void) {
  init(scope_stack);
  return yyparse ( );
}

int intlen(int i){
  if(i == 0)
    return 1;
  else
    return floor(log10(abs(i))) + 1;
}

int yyerror (char *s) {fprintf (stderr, "%s\n", s);}
