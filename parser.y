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

%left PLUS MINUS
%left TIMES DIVIDE MOD
%left EQUAL DIFFERENT

%start start_stm

%%
start_stm       :     blocks { printf("blocks\n"); }

blocks          :     func { printf("function\n"); }
                |     blocks func { printf("blocks func\n"); }

func            :     TYPE ID func_parameters block_body { printf("TYPE ID func_parameters block_body"); }

func_parameters :     OPAREN CPAREN { printf("()"); }

block_body      :     OBRACE block_stmts CBRACE { printf("OBRACE block_stm CBRACE"); }

block_stmts     :     block_stmt { printf("block_stmt"); }
                |     block_stmts SEMICOLON block_stmt { printf("block_stmts SEMICOLON block_stmt"); }

block_stmt      :     init { printf("init"); }
                |     attr { printf("attr"); }
                |     call { printf("call"); }
                |     if_stmt { printf("if"); }
                |     while_stmt { printf("while"); }

if_stmt         :     IF cond_params block_body { printf("IF if_parameters block_body"); }

while_stmt      :     WHILE cond_params block_body { printf("IF if_parameters block_body"); }

cond_params     :     OPAREN CPAREN { printf("OPAREN CPAREN"); }

init            :     TYPE ID { printf("TYPE ID"); }
                |     TYPE attr { printf("TYPE attr"); }

attr            :     ID EQUAL expression { printf("ID EQUAL expression"); }

call            :     ID OPAREN CPAREN { printf("ID OPAREN CPAREN"); }

expression      :     NUMBER { printf("NUMBER"); }

%%

int main (void) {
	return yyparse ( );
}

int yyerror (char *s) {fprintf (stderr, "%s\n", s);}
