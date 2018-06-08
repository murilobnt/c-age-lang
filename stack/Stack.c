#include <stdio.h>
#include <stdlib.h>
#include <gmodule.h>
#include "Stack.h"

void init(Stack * head) {
    head = NULL;
}

Stack * push(Stack * head, GString * data) {
    Stack * aux = (Stack*)malloc(sizeof(Stack));
    if(aux == NULL){
        exit(0);
    }

    aux->data = data;
    aux->next = head;
    head = aux;
    
    return head;
}

Stack * pop(Stack * head, GString * element){
	if(isEmpty(head)){
		exit(0);
	}

    Stack * aux = head;
    element = head->data;
    head = head->next;
    
    free(aux);
    return head;
}

GString * top(Stack * head, unsigned int jump){
	if(isEmpty(head)){
		exit(0);
	}

	if(jump == 0){
		return head->data;
	}
	
	return top(head->next,jump-1);
}

int isEmpty(Stack * head){
    return head == NULL ? 1 : 0;
}

void erase(Stack * head){
	GString * cleaner = NULL;
	while(!isEmpty(head)){
		pop(head, cleaner);
		free(cleaner);
	}
}