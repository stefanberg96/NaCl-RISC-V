#include <stdint.h>
#include <stdio.h>

extern uint32_t getcycles();
extern uint32_t securemul(unsigned char a, unsigned char b);
extern uint32_t add();
extern uint32_t mul320(unsigned char a);
   unsigned char a = 55;
   unsigned char b = 2;
uint32_t dobenchmark(){


   uint32_t result;
   uint32_t oldcount, newcount;

   oldcount = getcycles();
   result = securemul(a,b);
   newcount = getcycles();
   return newcount-oldcount;
}

int main() {
  uint32_t oldcount, newcount, x;
  x = dobenchmark();
  x = dobenchmark();
  printf("This took %u cycles\n",x);
  printf("%d\n",securemul(a,b));
  return 0;
}
