#include "onetime_auth.h"
#include "benchmark.h"

void printchararray(unsigned char * in, int inlen){

    for(int i =0;i< inlen;i++){
        printf("%02x", in[i]);
    }
    printf("\n");
}

void printarray(unsigned int * in, int inlen){

    for(int i =0;i< inlen;i++){
        printf("%02x", in[i]);
    }
    printf("\n");
}

void printbyte(unsigned int x){
  printf("%x\n",x);
}

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
   fillstack();
  dobenchmark();
  return 0;
}

