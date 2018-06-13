#include <stdio.h>
#include <stdlib.h>
#include <gmodule.h>
#include "Stack.h"

unsigned int stackSize = 0;

void init(Stack * head) {
    head = NULL;
}

Stack * push(Stack * head, subinfo data) {
    Stack * aux = (Stack*)malloc(sizeof(Stack));
    if(aux == NULL){
        exit(0);
    }

    aux->data = data;
    aux->next = head;
    head = aux;

    stackSize++;

    return head;
}

Stack * pop(Stack * head){
	if(isEmpty(head)){
		printf("POP en pilla vazia.\n");
		exit(0);
	}

    Stack * aux = head;
    head = head->next;

    free(aux);

    stackSize--;

    return head;
}

subinfo top(Stack * head, unsigned int jump){
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

unsigned int getSize(){
    return stackSize;
}