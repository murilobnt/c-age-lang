%{
#include <stdio.h>

int yylex(void);
int yyerror(char *s);
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

%token TYPE RETURN BOOL_LIT
%token IF WHILE
%token OPAREN CPAREN OBRACE CBRACE
%token SEMICOLON COMMA
%token OPERATOR

%type <sValue> blocks func func_parameters cond_params block_body block_stmts block_stmt init attr
%type <iValue> expression

%left PLUS MINUS
%left TIMES DIVIDE MOD
%left EQUAL DIFFERENT

%start start_stm

%%

start_stm       :     blocks { printf("%s\n", $1); }

blocks          :     func { $$ = $1; }
                |     blocks func { printf("blocks func\n"); }

func            :     TYPE ID func_parameters block_body { $$ = (char *)malloc(sizeof(char)); sprintf($$, "TYPE %s %s %s", $2, $3, $4); }

func_parameters :     OPAREN CPAREN { $$ = (char *)malloc(sizeof(char)); sprintf($$, "()"); }

block_body      :     OBRACE block_stmts CBRACE { $$ = (char *)malloc(sizeof(char)); sprintf($$, "{ %s }", $2); }

block_stmts     :     block_stmt SEMICOLON { $$ = (char *)malloc(sizeof(char)); sprintf($$, "%s;", $1); }
                |     block_stmt SEMICOLON block_stmts { $$ = (char *)malloc(sizeof(char)); sprintf($$, "%s ; %s", $1, $3); }

block_stmt      :     init { $$ = $1; }
                |     attr { printf("attr\n"); }
                |     call { printf("call\n"); }
                |     if_stmt { printf("if\n"); }
                |     while_stmt { printf("while\n"); }

if_stmt         :     IF cond_params block_body { printf("IF if_parameters block_body\n"); }

while_stmt      :     WHILE cond_params block_body { printf("IF if_parameters block_body\n"); }

cond_params     :     OPAREN CPAREN { $$ = (char *)malloc(sizeof(char)); sprintf($$, "()"); }

init            :     TYPE ID { printf("TYPE ID\n"); }
                |     TYPE attr { $$ = (char *)malloc(sizeof(char)); sprintf($$, "TYPE %s", $2); }

attr            :     ID EQUAL expression {  $$ = (char *)malloc(sizeof(char)); sprintf( $$, "%s = %d", $1, $3); }

call            :     ID OPAREN CPAREN { printf("ID OPAREN CPAREN\n"); }

expression      :     NUMBER { $$ = $1; }

%%

int main (void) {
	return yyparse ( );
}

int yyerror (char *s) {fprintf (stderr, "%s\n", s);}
