#include "benchmark.h"

    void printarray(unsigned char *in, int inlen){
        for(int i =0;i<inlen;i++){
            printf("%02x", in[i]);
        }
        printf("\n");
    }

    void printcounters(unsigned int *a, int initialoffset){

           for(int i = initialoffset+3; i < 21*3;i+=3){
               printf("%6u, ", a[i]-a[i-3]);
        }
        printf("\n");
    }

    void dobenchmark() {

    
        static unsigned char g_bytes[32] = {0x38, 0x5d, 0x4, 0x3, 0xa2, 0x88, 0xe4, 0xe5, 0x7a, 0xb3, 0xce, 0xe1, 0x4a, 0x8f, 0xc2, 0xf3, 0xa8, 0x3c, 0x9e, 0x66, 0x45, 0x53, 0x1b, 0x13, 0x48, 0xc2, 0x44, 0xe6, 0xd8, 0x8b, 0x2a, 0x41};
        static unsigned char n_bytes[32] = {0xc8, 0x75, 0x35, 0x6, 0x49, 0x59, 0xb9, 0xb3, 0x1d, 0x8a, 0x5d, 0x5f, 0x2e, 0x8d, 0x84, 0x86, 0xa1, 0xbd, 0x26, 0xf2, 0xe2, 0x90, 0x27, 0x3, 0xe8, 0xd7, 0x39, 0x81, 0xe4, 0xd1, 0x1a, 0x68};


        unsigned int counters[3*21];
        icachemisses();

        unsigned char q[32];
        for(int i =0;i<21;i++){
            getcycles(&counters[i*3]);
            crypto_scalarmult_asm(q, n_bytes, g_bytes);
        }

        printf("Cycle counts:          ");
        printcounters(counters, 0);

        printf("Branch dir mis:        ");
        printcounters(counters, 1);

        printf("Branch target mis:    ");
        printcounters(counters, 2);

        printf("Result: ");
        printarray(q, 32);
        printf("\n\n");
    }
