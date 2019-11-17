#include <stdint.h>
#include <stdio.h>

extern uint32_t getcycles();
extern uint32_t securemul(unsigned char a, unsigned char b);

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
  printf("This took  cycles\n");
  return 0;
}
