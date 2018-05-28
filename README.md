# c-age-lang

## Compilação

```
$ flex lexer.l
$ yacc -d parser.y
$ cc lex.yy.c y.tab.c -o drive