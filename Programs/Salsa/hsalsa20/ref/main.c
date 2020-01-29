#include "benchmark.h"
#include "scalarmult.h"

void printchararray(unsigned char * in, int inlen){

    for(int i =0;i< inlen;i++){
        printf("%02x", in[i]);
    }
    printf("\n");
}

void printbyte(unsigned int x){
  printf("%x\n",x);
}

void printintarray(unsigned int * in, int inlen){

    for(int i =0;i< inlen;i++){
        printf("%02x", in[i]);
    }
    printf("\n");
}

int main() {
  dobenchmark();
  return 0;
}
