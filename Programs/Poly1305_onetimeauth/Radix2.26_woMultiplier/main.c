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

int main() {
  dobenchmark();
  return 0;
}
