#include "benchmark.h"

void printarray(unsigned char * in, int inlen){

    for(int i =0;i< inlen;i++){
        printf("%02x", in[i]);
    }
    printf("\n");
}

int main() {

  uint64_t timing[2];
  unsigned char output[16];
  dobenchmark(&timing[0], output);
  dobenchmark(&timing[1], output);
  printf("This took %llu cycles\n", timing[1]);
  printarray(output, 16);
  return 0;
}
