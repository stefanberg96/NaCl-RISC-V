#include <stdint.h>
#include <stdio.h>
#include <metal/tty.h>
//extern int metal_tty_getc(int *c);

int main() {
  uint32_t oldcount, newcount, x;
  int y;
  char z[25];
  printf("Enter hex number\n");
  while(metal_tty_getc(&y)){

  }//fgets(&z[0],25, stdin);
  printf("This took %x cycles\n",y);
  return 0;
}
