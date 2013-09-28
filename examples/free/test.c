#include <stdio.h>
#include "test.h"

/* This is equivallent to this code in Haskell:
 *
 * test :: DSL ()
 * test = do
 *    output "Hello, What's your name?"
 *    name <- input
 *    output $ "Goodbye, " ++ name ++ "!"
 *
 * */
void test(HsStablePtr m) {
  char *name;
  char *bye;

  output(m, "Hello! What's your name?");
  name = input(m);
  sprintf(bye, "Goodbye, %s!", name);
  output(m, bye);
}
