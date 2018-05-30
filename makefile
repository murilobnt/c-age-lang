CC = cc
FLAGS = -lm
EXEDIR = ./bin
OUTPUT = $(EXEDIR)/cage

FLEXYACCDIR = ./generated

LEX = $(FLEXYACCDIR)/lex.yy.c
TABC = $(FLEXYACCDIR)/y.tab.c
TABH = $(FLEXYACCDIR)/y.tab.h

LEXFILE = lexer.l
YACC = parser.y

all : $(OUTPUT)

$(LEX) :    $(LEXFILE)
						flex -o $(LEX) $(LEXFILE)

$(TABH) :   $(TABC)

$(TABC) :   $(YACC)
						yacc -b $(FLEXYACCDIR)/y --defines=$(TABH) $(YACC)

$(OUTPUT) : $(LEX) $(TABC) $(TABH)
						cc $(LEX) $(TABC) -I $(FLEXYACCDIR) -lm -o $(OUTPUT)

clean :
						rm $(LEX) $(TABC) $(TABH) $(OUTPUT)
