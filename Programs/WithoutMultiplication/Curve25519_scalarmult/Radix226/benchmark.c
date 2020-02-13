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

    
        static unsigned char g_bytes[32] = {0x40, 0x4c, 0x6e, 0x55, 0x90, 0x7c, 0xff, 0xca, 0xd4, 0x46, 0x17, 0xe, 0xc0, 0x9e, 0x8c, 0x1d, 0xdf, 0x1d, 0xa1, 0x84, 0xbb, 0xaa, 0xf8, 0x78, 0xda, 0x8, 0xf5, 0xd2, 0x93, 0xed, 0xd, 0x79};
        static unsigned char n_bytes[32] = {0x8, 0x66, 0xc4, 0xbf, 0x40, 0x8f, 0x7a, 0x29, 0x82, 0xf8, 0xdb, 0xd6, 0x58, 0x49, 0xa3, 0x90, 0x99, 0x79, 0x88, 0x76, 0xfd, 0x20, 0xdd, 0x2e, 0x5d, 0x85, 0x27, 0xb7, 0x21, 0x4, 0xc, 0x71};


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
