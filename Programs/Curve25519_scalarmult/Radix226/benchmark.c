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

    
        static unsigned char g_bytes[32] = {0x50, 0x12, 0x46, 0x11, 0xec, 0x3a, 0x62, 0xa6, 0x69, 0x2c, 0x1, 0xd, 0x85, 0x15, 0x8e, 0x59, 0x20, 0x9, 0x65, 0x61, 0x5d, 0x32, 0xd6, 0x57, 0x72, 0x34, 0x19, 0xfe, 0x4c, 0x56, 0x59, 0x7a};
        static unsigned char n_bytes[32] = {0xc0, 0x75, 0xc7, 0xb1, 0xed, 0xe7, 0x87, 0x26, 0xb2, 0x60, 0x65, 0xe6, 0x3c, 0x71, 0x3, 0x44, 0x67, 0x31, 0x1a, 0x5a, 0xa3, 0xf2, 0xac, 0x5d, 0x4, 0xdf, 0x32, 0xac, 0x20, 0x4a, 0x17, 0x49};


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
