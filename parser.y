%{
#include <stdio.h>

int yylex(void);
int yyerror(char *s);
extern int yylineno;
extern char * yytext;

#define YYSTYPE char *

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

%type <sValue> blocks func block_stmts block_stmt init attr expression

%left PLUS MINUS
%left TIMES DIVIDE MOD
%left EQUAL DIFFERENT

%start start_stm

%%

start_stm       :     blocks { printf("%s", $1); }

blocks          :     func { $$ = $1; }
                |     blocks func { printf("blocks func\n"); }

func            :     TYPE ID func_parameters block_body { $$ = $1; }

func_parameters :     OPAREN CPAREN { printf("()\n"); }

block_body      :     OBRACE block_stmts CBRACE { printf("OBRACE block_stm CBRACE\n"); }

block_stmts     :     block_stmt SEMICOLON { printf("block_stmt SEMICOLON\n"); }
                |     block_stmt SEMICOLON block_stmts { printf("block_stmt SEMICOLON block_stmts\n"); }

block_stmt      :     init { printf("init\n"); }
                |     attr { printf("attr\n"); }
                |     call { printf("call\n"); }
                |     if_stmt { printf("if\n"); }
                |     while_stmt { printf("while\n"); }

if_stmt         :     IF cond_params block_body { printf("IF if_parameters block_body\n"); }

while_stmt      :     WHILE cond_params block_body { printf("IF if_parameters block_body\n"); }

cond_params     :     OPAREN CPAREN { printf("OPAREN CPAREN\n"); }

init            :     TYPE ID { printf("TYPE ID\n"); }
                |     TYPE attr { printf("TYPE attr\n"); }

attr            :     ID EQUAL expression { printf("ID EQUAL expression\n"); }

call            :     ID OPAREN CPAREN { printf("ID OPAREN CPAREN\n"); }

expression      :     NUMBER { $$ = "todo"; }

%%

int main (void) {
	return yyparse ( );
}

int yyerror (char *s) {fprintf (stderr, "%s\n", s);}
