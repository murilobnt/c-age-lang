#ifndef VALUE_UN_H
#define VALUE_UN_H

#include "bool.h"

typedef union{
  char * st_val;
  char * po_val;
  char ch_val;
  int in_val;
  float fl_val;
  double dou_val;
  bool bo_val;

} value_un;

#endif
