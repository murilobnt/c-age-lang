#include <stdio.h>
#include <stdlib.h>
#include <gmodule.h>

#include "Stack.h"

int main(){
	
	//Teste...

	GString * hue = NULL; // o pop retorna o dado do head que foi apagado.
	Stack * head; // A pilha...
	init(head);

	head = push(head, g_string_new("huehue1"));
	head = pop(head, hue);
	head = push(head, g_string_new("huehue2"));
	char *cat = g_string_free(top(head,0), FALSE);
	printf("%s\n", cat);
	head = pop(head,hue);
	free(hue);

	printf("%s\n", "Funcionando...");


	return 0;
}