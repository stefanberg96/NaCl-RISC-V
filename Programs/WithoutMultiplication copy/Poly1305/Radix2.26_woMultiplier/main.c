#include "onetime_auth.h"
#include "benchmark.h"

void fillstack() {
  int i = 0;
  char *sp = getsp();
  sp -= 40;
  while ((uintptr_t)sp > 0x800012c4) {
      *sp = 42;
    sp--;
  }
  return;
}

int main() {
  dobenchmark();
  return 0;
}

void printdebug(){
  test(4);
  printf("debug\n");
}
