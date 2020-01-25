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

    
        static unsigned char g_bytes[32] = {0x60, 0xfe, 0x50, 0xcd, 0x37, 0xd9, 0x7, 0xb8, 0x67, 0x6a, 0x46, 0xb2, 0xeb, 0x1e, 0x9, 0x1f, 0xa5, 0xb5, 0x6b, 0xa4, 0x12, 0xfa, 0x84, 0xd2, 0xba, 0x52, 0x96, 0x34, 0xf1, 0xe5, 0x1b, 0x69};
        static unsigned char n_bytes[32] = {0x8, 0x9, 0x72, 0xa4, 0x88, 0x58, 0x1d, 0x6d, 0xf6, 0x96, 0x89, 0x4f, 0x15, 0x2e, 0x48, 0x1c, 0x30, 0xfa, 0xc3, 0x5, 0xd8, 0xd2, 0x6c, 0xbf, 0x73, 0x3a, 0xc7, 0xea, 0x6e, 0x8d, 0x75, 0x7c};


        unsigned int counters[3*21];
        icachemisses();

        unsigned char q[32];
        for(int i =0;i<21;i++){
            getcycles(&counters[i*3]);
            crypto_scalarmult(q, n_bytes, g_bytes);
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
