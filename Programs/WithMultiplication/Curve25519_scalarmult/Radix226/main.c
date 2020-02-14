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
  printf("%x\n",x);
}

void printintarray(const unsigned int * in,const int inlen){
    printf("[");
    for(int i =0;i< inlen-1;i++){
        printf("0x%02x, ", in[i]);
    }
    printf("0x%02x]\n", in[inlen-1]);
}

int main() {
  dobenchmark();
  return 0;
}
