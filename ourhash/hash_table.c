#include "hash_table.h"

int ht_hash(const char* s, const int a, const int m){
  long hash = 0;
  int i;
    const int len_s = strlen(s);
    for (i = 0; i < len_s; i++) {
        hash += (long)pow(a, len_s - (i+1)) * s[i];
        hash = hash % m;
    }
    return (int)hash;
}

int ht_get_hash(const char* s, const int num_buckets, const int attempt){
  int HT_PRIME_1 = 53,HT_PRIME_2=57;

  const int hash_a = ht_hash(s, HT_PRIME_1, num_buckets);
  const int hash_b = ht_hash(s, HT_PRIME_2, num_buckets);
  return (hash_a + (attempt * (hash_b + 1))) % num_buckets;
}

hash_table* hash_table_new(){
    hash_table* ht = malloc(sizeof(hash_table));

    ht->size = 53;
    ht->count = 0;
    ht->entries = calloc((size_t)ht->size, sizeof(table_entry*));

    return ht;
}

void delete_table(hash_table* ht){
  int i;
  for (i = 0; i < ht->size; i++) {
       table_entry* entry = ht->entries[i];
       if (entry != NULL) {
           delete_entry(entry);
       }
   }

   free(ht->entries);
   free(ht);
}

void ht_insert(hash_table* ht, const char * id, const char * type){
  table_entry* entry = new_table_entry(id, type);
  int index = ht_get_hash(entry->id, ht->size, 0);
  table_entry* cur_entry = ht->entries[index];
  int i = 1;
  while (cur_entry != NULL) {
      index = ht_get_hash(entry->id, ht->size, i);
      cur_entry = ht->entries[index];
      i++;
  }
  ht->entries[index] = entry;
  ht->count++;
}

table_entry* ht_search(hash_table* ht, const char* id){
  int index = ht_get_hash(id, ht->size, 0);
  table_entry* entry = ht->entries[index];
  table_entry* first_entry = ht->entries[index];
  bool first_it = true;
  int i = 1;

  while (entry != NULL && (first_it || (entry != first_entry))) {
      if(first_it) first_it = false;
      if (strcmp(entry->id, id) == 0) {
          return entry;
      }
      index = ht_get_hash(id, ht->size, i);
      entry = ht->entries[index];
      i++;
  }

  return NULL;
}
