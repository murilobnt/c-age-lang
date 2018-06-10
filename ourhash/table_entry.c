#include "table_entry.h"

table_entry* new_table_entry(const char * id, const type_en type, const value_un value, const int scope){
  table_entry* entry = malloc(sizeof(table_entry));
  entry->id = strdup(id);
  entry->type = type;
  entry->value = value;
  entry->scope = scope;
}

void delete_entry(table_entry* entry){
  free(entry->id);
  if(entry->type == st)
    free(entry->value.st_val);

  if(entry != NULL && entry->type == po)
    free(entry->value.po_val);

  free(entry);
}
