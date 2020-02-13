#include "benchmark.h"
#include "scalarmult.h"
void printchararray_inv(unsigned char * in, int inlen){

    for(int i =inlen-1;i>=0;--i){
        printf("%02x", in[i]);
    }
    printf("\n");
}
void printchararray(unsigned char * in, int inlen){

    for(int i =0;i< inlen;i++){
        printf("%02x", in[i]);
    }
    printf("\n");
}

void printbyte(unsigned int x){
  printf("%x",x);
}

void printintarray(const unsigned int * in,const int inlen){

    for(int i =0;i< inlen;i++){
        printf("%02x, ", in[i]);
    }
    printf("\n");
}

int main() {
  dobenchmark();
  return 0;
}
