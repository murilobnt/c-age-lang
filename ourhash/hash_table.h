#ifndef HASHTABLE_H
#define HASHTABLE_H

#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "table_entry.h"

typedef struct {
  int size;
  int count;
  table_entry** entries;
} hash_table;

int ht_hash(const char* s, const int a, const int m);
int ht_get_hash(const char* s, const int num_buckets, const int attempt);

hash_table* hash_table_new();
void delete_table(hash_table* ht);

void ht_insert(hash_table* ht, const char * id, const type_en type, const value_un value, const int scope);
table_entry* ht_search(hash_table* ht, const char* id);

#endif
