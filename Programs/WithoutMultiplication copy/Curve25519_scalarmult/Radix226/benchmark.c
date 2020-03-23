#include "benchmark.h"
#define ATTEMPTS 50

    void printarray(unsigned char *in, int inlen){
        for(int i =0;i<inlen;i++){
            printf("%02x", in[i]);
        }
        printf("\n");
    }

    void printcounters(unsigned int *a, int initialoffset){

           for(int i = initialoffset+3; i < ATTEMPTS*3;i+=3){
               printf("%6u, ", a[i]-a[i-3]);
        }
        printf("\n");
    }

    void dobenchmark() {

    
        static unsigned char g_bytes[32] = {0xc0, 0x4b, 0xe1, 0xcf, 0xc7, 0x79, 0x38, 0x58, 0x4c, 0x8, 0x87, 0xc9, 0xa, 0x71, 0xe0, 0x32, 0xa5, 0x91, 0x5c, 0x5a, 0xc3, 0xcd, 0x2c, 0x4, 0x99, 0x23, 0xd5, 0x8a, 0x10, 0xbb, 0xe3, 0x65};
        static unsigned char n_bytes[32] = {0x68, 0xb6, 0xaa, 0xa8, 0x1a, 0xd0, 0x9e, 0x98, 0x2e, 0x60, 0x8d, 0x38, 0xdd, 0xf8, 0x23, 0x9c, 0x7c, 0xd2, 0xca, 0xfe, 0xd6, 0xf9, 0x25, 0xa7, 0x10, 0x20, 0x81, 0x4, 0xf9, 0x8f, 0xc7, 0x4b};


        unsigned int counters[3*ATTEMPTS];
        icachemisses();

        unsigned char q[32];
        for(int i =0;i<ATTEMPTS;i++){
            getcycles(&counters[i*3]);
            crypto_scalarmult_asm(q, n_bytes, g_bytes);
        }

        printf("Cycle counts:          ");
        printcounters(counters, 0);

        printf("Branch mispredictions:        ");
        printcounters(counters, 1);

        printf("ICache misses:    ");
        printcounters(counters, 2);

        printf("Result: ");
        printarray(q, 32);
        printf("\n\n");
    }
