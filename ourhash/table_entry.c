#include "table_entry.h"

table_entry* new_table_entry(const char * id, const char* type){
  table_entry* entry = malloc(sizeof(table_entry));
  entry->id = strdup(id);
  entry->type = strdup(type);
}

void delete_entry(table_entry* entry){
  free(entry->id);
  free(entry->type);

  free(entry);
}
