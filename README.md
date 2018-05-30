# c-age-lang

## Features e TO-DOS

* [ ] Definir todos os tokens e lexemas da linguagem.
* [ ] Traduzir o analisador sintático ascendente definido anteriormente.
* [x] Imprimir um programa simples pelo analisador.

## Compilação

```
$ flex lexer.l
$ yacc -d parser.y
$ cc y.tab.c lex.yy.c -lm -o drive
```
