# c-age-lang

## Compilação

```
$ flex lexer.l
$ yacc -d parser.y
$ cc y.tab.c lex.yy.c -lm -o drive
```
