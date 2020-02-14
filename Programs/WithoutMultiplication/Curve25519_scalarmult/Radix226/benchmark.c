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

    
        static unsigned char g_bytes[32] = {0xc0, 0xcc, 0x82, 0xf, 0x89, 0xf7, 0xd5, 0x3b, 0xd3, 0x84, 0x6, 0xf8, 0x6f, 0x69, 0x62, 0x54, 0x26, 0xde, 0x6f, 0x5a, 0x58, 0xd9, 0xc9, 0x25, 0xf9, 0x3, 0xb1, 0xe4, 0x20, 0xb6, 0x4c, 0x61};
        static unsigned char n_bytes[32] = {0x88, 0xa2, 0x5, 0x2f, 0x0, 0xa5, 0xa3, 0x3, 0x51, 0xd, 0xe9, 0xc5, 0x8a, 0x8c, 0xc, 0x6d, 0x66, 0x3e, 0x37, 0xdf, 0xa2, 0x3f, 0xb7, 0xe4, 0xc0, 0xc2, 0xd1, 0xe3, 0x9e, 0xfe, 0x2f, 0x78};


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
