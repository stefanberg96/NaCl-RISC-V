#include <stdint.h>
#include <stdio.h>

extern uint64_t getcycles();
extern uint32_t securemul();
extern uint32_t add(uint32_t a, uint32_t b);
extern uint32_t mul320(unsigned char a);

int main() {
  uint64_t oldcount, newcount;
  uint32_t a = 10;
  uint32_t b = 50;
  uint32_t l;
  securemul();
  securemul();
  getcycles();
  securemul();
  getcycles();
  securemul();
  oldcount = getcycles();
  l=securemul();
  newcount = getcycles();
  printf("This took %llu cycles\n", newcount - oldcount);
  printf("the result of %d * %d = %d == %d\n", a, b, l,l);
  return 0;
}
