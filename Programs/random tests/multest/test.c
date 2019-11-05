#include <stdint.h>
#include <stdio.h>

extern uint32_t getcycles();
extern uint32_t securemul(unsigned char a, unsigned char b);
extern uint32_t add();
extern uint32_t mul320(unsigned char a);
extern unsigned int bench();

uint32_t dobenchmark(){
   unsigned char a = 10;
   unsigned char b = 2;
   uint32_t result;
   uint32_t oldcount, newcount;

   oldcount = getcycles();
   securemul(a,b);
   newcount = getcycles();
   return newcount-oldcount;
}

int main() {
  uint32_t oldcount, newcount, x;
  x = bench();
  x = bench();
  x = bench();
  x = bench();
  printf("This took %u cycles\n",x);
  return 0;
}
