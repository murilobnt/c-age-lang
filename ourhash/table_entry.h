#ifndef TABLE_ENTRY_H
#define TABLE_ENTRY_H

#include <stdlib.h>
#include <string.h>
#include "type_en.h"
#include "value_un.h"

typedef struct {
  char* id;
  type_en type;
  value_un value;
  int scope;

} table_entry;

table_entry* new_table_entry(const char * id, const type_en type, const value_un value, const int scope);
void delete_entry(table_entry* entry);

#endif
