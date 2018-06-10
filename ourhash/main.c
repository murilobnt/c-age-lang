#include <stdio.h>

#include "hash_table.h"
#include "table_entry.h"
#include "type_en.h"

int main() {
  hash_table* ht = hash_table_new();
  value_un val;
  val.in_val = 5;

  ht_insert(ht, "x", in, val, 0);
  table_entry* entry = ht_search(ht, "x");

  if(entry == NULL){
    printf("Entry is null. RIP.\n");
  } else {
    printf("Entry is not null. PROFIT.\n");
    printf("Entry's ID: %s\nEntry's type: %d\nEntry's value: %d\n", entry->id, entry->type, entry->value.in_val);
  }

  delete_table(ht);
}
