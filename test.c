#include <stdio.h>
#include "test.h"

void test(HsStablePtr m) {
  char *name;
  char *bye;

  output(m, "Hello, world!");
  name = input(m);
  sprintf(bye, "Goodbye, %s!", name);
  output(m, bye);
}
