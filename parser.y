%{
#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
int yyerror(char *s);
int intlen(int i);
extern int yylineno;
extern char * yytext;

%}

%union{
        char  * sValue;
        int     iValue;
};

%token <sValue> ID
%token <sValue> NUMBER_LIT
%token <sValue> STRING_LIT
%token <iValue> NUMBER

%token STATIC CONST TYPE RETURN BOOL_LIT PROCEDURE
%token IF WHILE
%token OPAREN CPAREN OBRACE CBRACE
%token SEMICOLON COMMA
%token OPERATOR

%type <sValue> global_scope globals global global_var static_init func proc bloc_scope func_parameters block_body func_body return_stmt block_stmts block_dec cond_params block_stmt if_stmt while_stmt init attr call expr operator
%type <iValue> operand

%left PLUS MINUS
%left TIMES DIVIDE MOD
%left EQUAL DIFFERENT

%start start_stm

%%

start_stm       :     global_scope { printf("%s\n", $1); }

global_scope    :     { $$ = ""; }
                |     globals { $$ = $1; }

globals         :     global { $$ = $1; }
                |     globals global { $$ = (char *)malloc(sizeof(char) * (strlen($1)+strlen($2)+2)); sprintf($$, "%s\n%s", $1, $2); }

global          :     global_var SEMICOLON { $$ = (char *)malloc(sizeof(char) * (strlen($1)+2)); sprintf($$, "%s;", $1); }
                |     func { $$ = $1; }
                |     proc { $$ = $1; }

global_var      :     init { $$ = $1; }
                |     attr { $$ = $1; }
                |     static_init { $$ = $1; }

static_init     :     STATIC TYPE CONST attr { $$ = (char *)malloc(sizeof(char) * (strlen($4)+19)); sprintf($$, "STATIC TYPE CONST %s", $4); }

func            :     TYPE ID func_parameters func_body { $$ = (char *)malloc(sizeof(char) * (strlen($2)+strlen($3)+strlen($4)+8)); sprintf($$, "TYPE %s %s %s", $2, $3, $4); }

proc            :     PROCEDURE ID func_parameters block_body { $$ = (char *)malloc(sizeof(char) * (strlen($2)+strlen($3)+strlen($4)+13)); sprintf($$, "procedure %s %s %s", $2, $3, $4); }

func_parameters :     OPAREN CPAREN { $$ = "()"; }

func_body       :     OBRACE bloc_scope return_stmt CBRACE { $$ = (char *)malloc(sizeof(char) * (strlen($2)+strlen($3)+6)); sprintf($$, "{ \n%s%s\n}", $2, $3); }

bloc_scope      :     { $$ = ""; }
                |     block_stmts { $$ = $1; }

return_stmt     :     RETURN expr SEMICOLON { $$ = (char *)malloc(sizeof(char) * (strlen($2)+8)); sprintf($$, "return %s;", $2); }

block_body      :     OBRACE bloc_scope CBRACE { $$ = (char *)malloc(sizeof(char) * (strlen($2)+5)); sprintf($$, "{ \n%s}", $2); }

block_stmts     :     block_stmt { $$ = $1; }
                |     block_stmts block_stmt { $$ = (char *)malloc(sizeof(char) * (strlen($1)+strlen($2)+5)); sprintf($$, "%s %s\n", $1, $2); }

block_stmt      :     block_dec SEMICOLON { $$ = (char *)malloc(sizeof(char) * (strlen($1)+2)); sprintf($$, "%s;\n", $1); }
                |     if_stmt { $$ = $1; }
                |     while_stmt { $$ = $1; }

if_stmt         :     IF cond_params block_body { $$ = (char *)malloc(sizeof(char) * (strlen($2)+strlen($3)+2)); sprintf($$, "if %s %s", $2, $3); }

while_stmt      :     WHILE cond_params block_body { $$ = (char *)malloc(sizeof(char) * (strlen($2)+strlen($3)+7)); sprintf($$, "while %s %s", $2, $3); }

cond_params     :     OPAREN CPAREN { $$ = "()"; }

block_dec       :     init { $$ = $1; }
                |     attr { $$ = $1; }
                |     call { $$ = $1; }

init            :     TYPE ID { printf("TYPE ID\n"); }
                |     TYPE attr { $$ = (char *)malloc(sizeof(char) * (strlen($2)+6)); sprintf($$, "TYPE %s", $2); }

attr            :     ID EQUAL expr {  $$ = (char *)malloc(sizeof(char) * (strlen($1)+4+strlen($3)+1)); sprintf( $$, "%s = %s", $1, $3); }

call            :     ID OPAREN CPAREN { $$ = "ID ()"; }

expr            :     operand { $$ = (char *)malloc(sizeof(char) * (intlen($1)+1)); sprintf( $$, "%d", $1 ); }
                |     operand operator expr { $$ = (char *)malloc(sizeof(char) * (intlen($1)+strlen($2)+strlen($3)+6)); sprintf( $$, "%d %s %s", $1, $2, $3 ); }

operand         :     NUMBER { $$ = $1; }

operator        :     PLUS { $$ = "+"; }
                |     MINUS { $$ = "-"; }
                |     TIMES { $$ = "*"; }
                |     DIVIDE { $$ = "/"; }
                |     MOD { $$ = "%"; }

%%

int main (void) {
	return yyparse ( );
}

int intlen(int i){
  if(i == 0)
    return 1;
  else
    return floor(log10(abs(i))) + 1;
}

int yyerror (char *s) {fprintf (stderr, "%s\n", s);}
