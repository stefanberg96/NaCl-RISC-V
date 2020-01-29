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

    
        static unsigned char g_bytes[32] = {0x50, 0xe9, 0x7e, 0x2a, 0x89, 0xe1, 0x8a, 0xcc, 0xb5, 0x8c, 0xe7, 0x38, 0xb0, 0x99, 0x6c, 0xb1, 0xe4, 0x79, 0x96, 0x25, 0x42, 0x61, 0x84, 0x2e, 0x54, 0xc3, 0x59, 0x74, 0xbc, 0xb0, 0xdc, 0x4c};
        static unsigned char n_bytes[32] = {0xc8, 0xfb, 0xab, 0x4d, 0x33, 0x42, 0xae, 0x77, 0xfd, 0x15, 0x28, 0x97, 0xe5, 0x1a, 0xf8, 0x20, 0xca, 0xd6, 0xaf, 0xf2, 0xa4, 0x4c, 0x1d, 0x4a, 0xcb, 0xd0, 0x65, 0xed, 0x13, 0x1f, 0xbf, 0x69};


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
