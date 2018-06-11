CC = cc
FLAGS = -lm
EXEDIR = ./bin
OUTPUT = $(EXEDIR)/cage

FLEXYACCDIR = ./generated
HASHTBLDIR = ./ourhash
STACKDIR = ./stack

LEX = $(FLEXYACCDIR)/lex.yy.c
TABC = $(FLEXYACCDIR)/y.tab.c
TABH = $(FLEXYACCDIR)/y.tab.h

HASHTBL = $(HASHTBLDIR)/hash_table.c $(HASHTBLDIR)/table_entry.c
STACKC = $(STACKDIR)/Stack.c
STACK = $(STACKDIR)/Stack.o

LEXFILE = lexer.l
YACC = parser.y
GLIB = `pkg-config --cflags --libs glib-2.0`

all :       $(OUTPUT)

new :       clean $(OUTPUT)

$(LEX) :    $(LEXFILE)
						flex -o $(LEX) $(LEXFILE)

$(TABH) :   $(TABC)

$(TABC) :   $(YACC)
						yacc -b $(FLEXYACCDIR)/y --defines=$(TABH) $(YACC)

$(STACK) :  $(STACKC)
						cc -c $(STACKC) $(GLIB)
						mv Stack.o $(STACKDIR)

$(OUTPUT) : $(LEX) $(TABC) $(TABH) $(STACK)
						cc $(LEX) $(TABC) -I $(FLEXYACCDIR) -I $(HASHTBLDIR) -I $(STACKDIR) $(HASHTBL) $(STACK) -lm $(GLIB) -o $(OUTPUT)

clean :
						rm $(LEX) $(TABC) $(TABH) $(STACK) $(OUTPUT)
