#ifndef STACK
#define STACK

#include <stdio.h>
#include "subinfo.h"

typedef struct node {
    subinfo data;
    struct node * next;
} Stack;

void init(Stack * head);
Stack * push(Stack * head, subinfo data);
Stack * pop(Stack * head);
subinfo top(Stack * head, unsigned int jump);
int isEmpty(Stack * head);

#endif
