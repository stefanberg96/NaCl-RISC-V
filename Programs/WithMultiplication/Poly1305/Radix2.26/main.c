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
        printf("0x%02x, ", in[i]);
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

void printparams(unsigned int *a, unsigned int *b){
    printf("A=[");
    printarray(a,5);
    printf("]\n");
    printf("B=[");
    printarray(b,5);
    printf("]\n");

}

void printkarresult(unsigned int *a){
    printf("R=[");
    printarray(a,5);
    printf("]\n");

    printf("A=sum(A[i]*2^(26*i) for i in range(5))\n");
    printf("B=sum(B[i]*2^(26*i) for i in range(5))\n");
    printf("R=sum(R[i]*2^(26*i) for i in range(5))\n");
    printf("R==lift(mod(A*B, 2^130-5))\n");
}
