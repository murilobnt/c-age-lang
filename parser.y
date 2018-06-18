%{
#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include <gmodule.h>

#include "hash_table.h"
#include "Stack.h"
#include "operandinfo.h"
#include "bool.h"
#include "compatibility.h"

#define GLOBAL "global"

int yylex(void);
int yyerror(char *s);
int intlen(int i);
table_entry* look_for(char * id);
char* type_on_accesses(char * the_type);
char* accesses_to_type(char * the_type);
compatibility type_compatible(char* op1, char* op2, bool has_order);

extern int yylineno;
extern char * yytext;

Stack * scope_stack;
hash_table * ht;

int nested_level;
int num_accesses;

int cumulator=65;

char* hello = "ola mundo";

%}

%union{
        operandinfo opinfo;
        char  *     sValue;
        char        cValue;
        int         iValue;
};

%token <sValue> ID
%token <sValue> NUMBER_LIT
%token <sValue> STRING_LIT
%token <sValue> BOOL_LIT
%token <sValue> NUMBER
%token <sValue> TYPE
%token <sValue> CHAR_LIT

%token STATIC CONST RETURN BREAK PROCEDURE CONTAINER
%token IF ELSE WHILE
%token OPAREN CPAREN OBRACE CBRACE OBRACKET CBRACKET
%token SEMICOLON COMMA
%token OPERATOR
%token EQUAL

%type <sValue> global_scope globals global global_var static_init func proc bloc_scope func_parameters block_body return_stmt block_stmts block_dec cond_params
%type <sValue> block_stmt if_stmt while_stmt init attr operator declaration decl_scope decl_list p_type
%type <sValue> if_else_stmt else_stmt type_val pointer_scope pointers expr_scope expr_list break_stmt accesses regis
%type <opinfo> operand call array_access expr

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
                        global_scope { scope_stack = pop(scope_stack); printf("%s\n", $2); }

global_scope    :     { $$ = ""; }
                |     globals { $$ = $1; }

globals         :     global { $$ = $1; }
                |     globals global { $$ = (char *)malloc(sizeof(char) * (strlen($1)+strlen($2)+15)); sprintf($$, "%s\n%s", $1, $2); }

global          :     global_var SEMICOLON { $$ = (char *)malloc(sizeof(char) * (strlen($1)+15)); sprintf($$, "%s;", $1); }
                |     func { $$ = $1; }
                |     proc { $$ = $1; }
                |     regis { $$ = $1; }

regis           :     CONTAINER ID OBRACE decl_list CBRACE { $$ = ""; }

global_var      :     init { $$ = $1; }
                |     attr { $$ = $1; }
                |     static_init { $$ = $1; }

static_init     :     STATIC init { $$ = ""; }

func            :     type_val ID {
                                    subinfo scope = top(scope_stack, 0);
                                    char * hash_id = (char *)malloc(sizeof(char)*(strlen(scope.subp)+strlen($2)+3));
                                    sprintf(hash_id, "%s.%s", scope.subp, $2);
                                    ht_insert(ht, hash_id, $1);

                                    subinfo newsubf;
                                    newsubf.subp = $2;
                                    newsubf.type = $1;
                                    scope_stack = push(scope_stack, newsubf);
                                  }
                        func_parameters
                        block_body { scope_stack = pop(scope_stack); $$ = (char *)malloc(sizeof(char) * (strlen($2)+strlen($4)+strlen($5)+15)); sprintf($$, "%s %s %s %s", $1, $2, $4, $5); }

proc            :     PROCEDURE ID {
                                      subinfo scope = top(scope_stack, 0);
                                      char * hash_id = (char *)malloc(sizeof(char)*(strlen(scope.subp)+strlen($2)+3));
                                      sprintf(hash_id, "%s.%s", scope.subp, $2);
                                      ht_insert(ht, hash_id, "proc");

                                      subinfo newsubf;
                                      newsubf.subp = $2;
                                      newsubf.type = "proc";
                                      scope_stack = push(scope_stack, newsubf);
                                   }
                      func_parameters block_body { scope_stack = pop(scope_stack); $$ = (char *)malloc(sizeof(char) * (strlen($2)+strlen($4)+strlen($5)+13)); sprintf($$, "procedure %s %s %s", $2, $4, $5); }

func_parameters :     OPAREN decl_scope CPAREN { $$ = (char *)malloc(sizeof(char) * (strlen($2)+15)); sprintf($$, "(%s)", $2); }

decl_scope      :     { $$ = ""; }
                |     decl_list { $$ = $1; }

decl_list       :     declaration { $$ = $1; }
                |     declaration COMMA decl_list { $$ = (char *)malloc(sizeof(char) * (strlen($1) + strlen($3) + 15)); sprintf($$, "%s, %s", $1, $3); }

bloc_scope      :     { $$ = ""; }
                |     block_stmts { $$ = $1; }

return_stmt     :     RETURN expr SEMICOLON { $$ = ""; }
                |     RETURN SEMICOLON { $$ = "return;\n"; }

block_body      :     OBRACE bloc_scope CBRACE { $$ = (char *)malloc(sizeof(char) * (strlen($2)+15)); sprintf($$, "{\n%s}", $2); }

block_stmts     :     block_stmt { $$ = $1; }
                |     block_stmts block_stmt { $$ = (char *)malloc(sizeof(char) * (strlen($1)+strlen($2)+15)); sprintf($$, "%s%s", $1, $2); }

block_stmt      :     block_dec SEMICOLON { $$ = (char *)malloc(sizeof(char) * (strlen($1)+15)); sprintf($$, "%s;\n", $1); }
                |     if_stmt { $$ = $1; $$ = strcat($$,"endif:\n");}
                |     if_else_stmt { $$ = $1; }
                |     while_stmt { $$ = $1; }
                |     return_stmt { $$ = $1; }
                |     break_stmt { $$ = $1; }

break_stmt      :     BREAK SEMICOLON { $$ = "break;\n"; }

if_stmt         :     IF {  subinfo newsubf;
                            newsubf.subp = (char*)malloc(sizeof(char) * (intlen(nested_level) + 4));
                            sprintf(newsubf.subp, "if.%d", nested_level++);
                            newsubf.type = "if";
                            scope_stack = push(scope_stack, newsubf);
                            }
                            cond_params block_body { scope_stack = pop(scope_stack); --nested_level; $$ = (char *)malloc(sizeof(char) * (strlen($3)+strlen($4)+30)); sprintf($$, "if goto BEGIN%c;\n BEGIN%c:%s %s\n",(char)cumulator,(char)cumulator, $3, $4); cumulator++;}

if_else_stmt    :     if_stmt { 
                                subinfo newsubf;
                                newsubf.subp = "else";
                                newsubf.type = "else";
                                scope_stack = push(scope_stack, newsubf);
                              } else_stmt { scope_stack = pop(scope_stack); $$ = (char *)malloc(sizeof(char) * (strlen($1)+strlen($3)+15)); sprintf($$, "%s%s", $1, $3); }

else_stmt       :     ELSE block_body { $$ = (char *)malloc(sizeof(char) * (strlen($2)+15)); sprintf($$, "else %s\n", $2); }

while_stmt      :     WHILE { subinfo newsubf;
                            newsubf.subp = (char*)malloc(sizeof(char) * (intlen(nested_level) + 7));
                            sprintf(newsubf.subp, "while.%d", nested_level++);
                            newsubf.type = "while";
                            scope_stack = push(scope_stack, newsubf);
                            } cond_params block_body { scope_stack = pop(scope_stack); --nested_level; $$ = (char *)malloc(sizeof(char) * (strlen($3)+strlen($4)+15)); sprintf($$, "while %s %s\n", $3, $4); }

cond_params     :     OPAREN expr CPAREN { $$ = ""; }

block_dec       :     init { $$ = $1; }
                |     attr { $$ = $1; }
                |     call { $$ = ""; }

declaration     :     type_val ID { subinfo scope = top(scope_stack, 0);
                                    char * hash_id = (char *)malloc(sizeof(char)*(strlen(scope.subp)+strlen($2)+3));
                                    sprintf(hash_id, "%s.%s", scope.subp, $2);
                                    ht_insert(ht, hash_id, $1);
                                    }
                |     type_val ID accesses { subinfo scope = top(scope_stack, 0);
                                             char * hash_id = (char *)malloc(sizeof(char)*(strlen(scope.subp)+strlen($2)+strlen($3)+4));
                                             sprintf(hash_id, "%s.%s%s", scope.subp, $2, $3);
                                             char* real_type = accesses_to_type($1);
                                             ht_insert(ht, hash_id, real_type);
                                             num_accesses = 0;
                                           }

init            :     declaration { $$ = $1; }
                |     type_val ID EQUAL expr {  table_entry* looking_for = look_for($2);

                                                if(looking_for != NULL){
                                                 printf("ERROR: VARIABLE %s HAVE ALREADY BEEN DECLARED!!!\n", $2);
                                                 $$ = "";
                                                } else {
                                                  compatibility comp = type_compatible($1, $4.type, true);
                                                  if(comp.isCompatible){
                                                    subinfo scope = top(scope_stack, 0);
                                                    char * hash_id = (char *)malloc(sizeof(char)*(strlen(scope.subp)+strlen($2)+3));
                                                    sprintf(hash_id, "%s.%s", scope.subp, $2);
                                                    ht_insert(ht, hash_id, $1);
                                                  } else {
                                                    if(strcmp($4.type, "error") != 0)
                                                      printf("ERROR: ATTRIBUTION FAILED DUE TO DIFFERENT TYPES.\n");
                                                    $$ = "";
                                                  }
                                                }
                                             }
                |     type_val ID accesses EQUAL expr { compatibility comp = type_compatible($1, $5.type, true);
                                                        if(comp.isCompatible){
                                                          subinfo scope = top(scope_stack, 0);
                                                          char * hash_id = (char *)malloc(sizeof(char)*(strlen(scope.subp)+strlen($2)+3));
                                                          sprintf(hash_id, "%s.%s", scope.subp, $2);
                                                          ht_insert(ht, hash_id, $1);
                                                        } else {
                                                          if(strcmp($5.type, "error") != 0)
                                                          printf("ERROR: ATTRIBUTION FAILED DUE TO DIFFERENT TYPES.\n");
                                                          $$ = "";
                                                        }
                                                        num_accesses = 0;
                                                     }

attr            :     ID EQUAL expr { table_entry* looking_for = look_for($1);
                                      if(looking_for == NULL){
                                         printf("ERROR: VARIABLE %s NOT FOUND!!!\n", $1);
                                         $$ = "";
                                      } else {
                                         compatibility comp = type_compatible(looking_for->type, $3.type, true);
                                         if(comp.isCompatible){
                                            $$ = (char*)malloc(sizeof(char)* (strlen($1)+strlen($3.value)+5));
                                            sprintf($$,"%s = %s", $1,$3.value);
                                         } else {
                                            if(strcmp($3.type, "error") != 0)
                                              printf("ERROR: ATTRIBUTION FAILED DUE TO DIFFERENT TYPES.\n");
                                            $$ = "";
                                         }
                                      }
                                      }
                |     ID accesses {num_accesses = 0;} EQUAL expr {  table_entry* looking_for = look_for($1);
                                                if(looking_for == NULL){
                                                   printf("ERROR: VARIABLE %s NOT FOUND!!!\n", $1);
                                                   $$ = "";
                                                } else {
                                                   char * var_name = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+2)); sprintf(var_name, "%s%s", $1, $2);
                                                   $$ = var_name;
                                                }
                                                num_accesses = 0;
                                                }

call            :     ID OPAREN expr_scope CPAREN { table_entry* looking_for = look_for($1);
                                                    if(looking_for == NULL){
                                                       printf("ERROR: FUNCTION/PROCEDURE %s NOT FOUND!!!\n", $1);
                                                       $$ = (operandinfo){"foo", "error"};
                                                    }
                                                    else {
                                                       char * fname = (char *)malloc(sizeof(char) * (strlen($1)+strlen($3)+4)); sprintf(fname, "%s(%s)", $1, $3);
                                                       $$ = (operandinfo) {fname, looking_for->type};
                                                    }
                                                  }

expr_scope      :     { $$ = ""; }
                |     expr_list { $$ = $1; }

expr_list       :     expr { $$ = ""; }
                |     expr COMMA expr_list { $$ = ""; }

expr            :     operand { $$ = $1; }
                |     operand operator expr { compatibility comp = type_compatible($1.type, $3.type, false);
                                              if(comp.isCompatible){
                                                char * expr_text = (char *)malloc(sizeof(char) * (strlen($1.value)+strlen($2)+strlen($3.value)+5)); sprintf( expr_text, "%s %s %s", $1.value, $2, $3.value );
                                                $$ = (operandinfo) {expr_text, comp.type};
                                              } else {
                                                printf("ERROR: INCOMPATIBLE TYPES IN EXPRESSION: %s AND %s.\n", $1.type, $3.type);
                                                $$ = (operandinfo){"foo", "error"};
                                              }
                                              }

operand         :     NUMBER { $$ = (operandinfo){$1, "int"}; }
                |     CHAR_LIT { $$ = (operandinfo){$1, "char"}; }
                |     STRING_LIT { $$ = (operandinfo){$1, "char*"}; }
                |     NUMBER_LIT { $$ = (operandinfo){$1, "double"}; }
                |     BOOL_LIT { $$ = (operandinfo){$1, "bool"}; }
                |     ID { table_entry* looking_for = look_for($1);

                           if(looking_for == NULL){
                             printf("ERROR: VARIABLE %s WAS NOT FOUND!!!\n", $1);
                             $$ = (operandinfo){"foo", "error"};
                           } else {
                             $$ = (operandinfo){$1, looking_for->type};
                           }
                         }
                |     array_access { $$ = $1; }
                |     call { $$ = $1; }

array_access    :     ID accesses { table_entry* looking_for = look_for($1);
                                    if(looking_for == NULL){
                                       printf("ERROR: ARRAY %s NOT FOUND!!!\n", $1);
                                       $$ = (operandinfo){"foo", "error"};
                                    }
                                    else {
                                       char * array_text = (char *)malloc(sizeof(char) * (strlen($1)+strlen($2)+2)); sprintf(array_text, "%s%s", $1, $2);
                                       char * f_type = type_on_accesses(looking_for->type);
                                       $$ = (operandinfo) {array_text, f_type};
                                    }
                                    num_accesses = 0;
                                    }

accesses        :     OBRACKET expr CBRACKET { ++num_accesses; $$ = ""; }
                |     OBRACKET expr CBRACKET accesses { ++num_accesses; $$ = ""; }

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
  nested_level = 1;
  num_accesses = 0;
  init(scope_stack);
  ht = hash_table_new();
  return yyparse ( );
  delete_table(ht);
}

int intlen(int i){
  if(i == 0)
    return 1;
  else
    return floor(log10(abs(i))) + 1;
}

table_entry* look_for(char * id){
    int i = 0;
    table_entry* looking_for = NULL;

    for(i = 0; i < getSize(); ++i){
       subinfo currentScope = top(scope_stack, i);

       char * search_for = (char *)malloc(sizeof(char) * (strlen(id)+strlen(currentScope.subp)+3));
       sprintf(search_for, "%s.%s", currentScope.subp, id);

       looking_for = ht_search(ht, search_for);
       free(search_for);

       if(looking_for != NULL)
           break;
    }

    return looking_for;
}

char* type_on_accesses(char * the_type){
  if(num_accesses >= strlen(the_type))
     return "error";

  char* result = (char*)malloc(sizeof(char) * (strlen(the_type)-num_accesses+1));
  strncpy(result, the_type, (strlen(the_type)-num_accesses));
  result[strlen(the_type)-num_accesses] = '\0';

  return result;
}

char* accesses_to_type(char * the_type){
  char* ats = (char*)malloc(sizeof(char) * (num_accesses+1));
  memset (ats,'*',num_accesses);

  char* dst = (char*)malloc(sizeof(char) * (strlen(the_type)+num_accesses+1));
  sprintf(dst, "%s%s", the_type, ats);

  return dst;
}

compatibility type_compatible(char* op1, char* op2, bool has_order){
   // Equal types. They are compatible.
   if(strcmp(op1, op2) == 0){
      return (compatibility) {true, op1};
   }

   // Float to int compatibility.
   if((strcmp(op1, "double") == 0) && (strcmp(op2, "int") == 0)){
      return (compatibility) {true, "double"};
   }
   if((strcmp(op2, "double") == 0) && (strcmp(op1, "int") == 0)){
      return (compatibility) {true, (has_order ? "int" : "double") };
   }

   if(op1[strlen(op1)-1] == '&')
      return (compatibility) {true, op2};

    if(op2[strlen(op2)-1] == '&')
       return (compatibility) {true, op1};

   return (compatibility) {false, "foo"};
}

int yyerror (char *s) {fprintf (stderr, "%s\n", s);}
