#ifndef TABLE_ENTRY_H
#define TABLE_ENTRY_H

#include <stdlib.h>
#include <string.h>
#include "type_en.h"
#include "value_un.h"

typedef struct {
  char* id;  
  char* type;

} table_entry;

table_entry* new_table_entry(const char * id, const char* type);
void delete_entry(table_entry* entry);

#endif
