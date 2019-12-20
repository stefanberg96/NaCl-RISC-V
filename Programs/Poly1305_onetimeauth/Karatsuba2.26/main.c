#include "benchmark.h"
#include "onetime_auth.h"

void printarray(unsigned int * in, int inlen){

    for(int i =0;i< inlen;i++){
        printf("%02x, ", in[i]);
    }
    printf("\n");
}

void printchararray(unsigned char * in, int inlen){

    for(int i =0;i< inlen;i++){
        printf("%02x", in[i]);
    }
    printf("\n");
}

unsigned char expectedResult[16] = {0xf3, 0xff, 0xc7, 0x70, 0x3f, 0x94,
                                    0x00, 0xe5, 0x2a, 0x7d, 0xfb, 0x4b,
                                    0x3d, 0x33, 0x05, 0xd9};

void checkCorrectness() {
    unsigned char rs[32] = {0xee, 0xa6, 0xa7, 0x25, 0x1c, 0x1e, 0x72, 0x91,
                            0x6d, 0x11, 0xc2, 0xcb, 0x21, 0x4d, 0x3c, 0x25,
                            0x25, 0x39, 0x12, 0x1d, 0x8e, 0x23, 0x4e, 0x65,
                            0x2d, 0x65, 0x1f, 0xa4, 0xc8, 0xcf, 0xf8, 0x80};


    unsigned char c[131] = {
            0x8e, 0x99, 0x3b, 0x9f, 0x48, 0x68, 0x12, 0x73, 0xc2, 0x96, 0x50, 0xba,
            0x32, 0xfc, 0x76, 0xce, 0x48, 0x33, 0x2e, 0xa7, 0x16, 0x4d, 0x96, 0xa4,
            0x47, 0x6f, 0xb8, 0xc5, 0x31, 0xa1, 0x18, 0x6a, 0xc0, 0xdf, 0xc1, 0x7c,
            0x98, 0xdc, 0xe8, 0x7b, 0x4d, 0xa7, 0xf0, 0x11, 0xec, 0x48, 0xc9, 0x72,
            0x71, 0xd2, 0xc2, 0x0f, 0x9b, 0x92, 0x8f, 0xe2, 0x27, 0x0d, 0x6f, 0xb8,
            0x63, 0xd5, 0x17, 0x38, 0xb4, 0x8e, 0xee, 0xe3, 0x14, 0xa7, 0xcc, 0x8a,
            0xb9, 0x32, 0x16, 0x45, 0x48, 0xe5, 0x26, 0xae, 0x90, 0x22, 0x43, 0x68,
            0x51, 0x7a, 0xcf, 0xea, 0xbd, 0x6b, 0xb3, 0x73, 0x2b, 0xc0, 0xe9, 0xda,
            0x99, 0x83, 0x2b, 0x61, 0xca, 0x01, 0xb6, 0xde, 0x56, 0x24, 0x4a, 0x9e,
            0x88, 0xd5, 0xf9, 0xb3, 0x79, 0x73, 0xf6, 0x22, 0xa4, 0x3d, 0x14, 0xa6,
            0x59, 0x9b, 0x1f, 0x65, 0x4c, 0xb4, 0x5a, 0x74, 0xe3, 0x55, 0xa5};
    unsigned char a[16];

    crypto_onetimeauth(a, c, 131, rs);
    int theSame = 0;
    for (int i = 0; i < 16; i++) {
        if (expectedResult[i] != a[i])
            theSame = 1;
    }
    if (theSame) {
        int i;
        printf("They were not the same\n");
        printf("Expected result:\n");
        for (i = 0; i < 16; ++i) {
            printf(",0x%02x", (unsigned int) expectedResult[i]);
            if (i % 8 == 7)
                printf("\n");
        }
        printf("Result:\n");
        for (i = 0; i < 16; ++i) {
            printf(",0x%02x", (unsigned int) a[i]);
            if (i % 8 == 7)
                printf("\n");
        }
    } else {
        printf("They were the same\n");
    }
}

extern void karatsuba226_3asm(unsigned int res[5], unsigned int a[3], unsigned int b[3]);
extern uint64_t securemul226(unsigned int a, unsigned int b);
void printbyte(unsigned int x){

	printf("%x\n",x);
}

int main() {


  unsigned int out[17]={0};
  unsigned int a[3]={0x150e0fd, 0x23e4427, 0x3fa42bc};
  unsigned int b[3]={0x38ec9da, 0x235b7aa, 0x358d90e};
  karatsuba226_3asm(out,a,b);
  toradix28(out);
  printarray(out,17); 

//  uint64_t timing[2];
//  unsigned char output[16];
//  dobenchmark(&timing[0], output);
 // dobenchmark(&timing[1], output);
//  printf("This took %llu cycles\n", timing[1]);
//  printarray(output, 16);
printf("\n\n\n\n");
  return 0;
}
