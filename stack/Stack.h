#ifndef STACK
#define STACK

typedef struct node {
    GString * data;
    struct node * next;
} Stack;

void init(Stack * head);
Stack * push(Stack * head, GString * data);
Stack * pop(Stack * head, GString * element);
GString * top(Stack * head, unsigned int jump);
int isEmpty(Stack * head);
void erase(Stack * head);

#endif