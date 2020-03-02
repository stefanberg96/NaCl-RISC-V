#include "benchmark.h"
    static int runs= 21;

    void printarray(unsigned char *in, int inlen){
        for(int i =0;i<inlen;i++){
            printf("%02x", in[i]);
        }
        printf("\n");
    }

    void printcounters(unsigned int *a, int initialoffset){

           for(int i = initialoffset+3; i < runs*3;i+=3){
               printf("%6u, ", a[i]-a[i-3]);
        }
        printf("\n");
    }


    void dobenchmark() {

    
        static unsigned char g_bytes[32] = {0x40, 0xa, 0xb7, 0xda, 0xb0, 0x54, 0x41, 0x72, 0xee, 0xc0, 0x8f, 0x53, 0x97, 0xcf, 0x5e, 0xa4, 0x6f, 0x31, 0x15, 0xa7, 0xbd, 0xbd, 0xcc, 0x28, 0xdf, 0xc4, 0xe1, 0xf5, 0xb4, 0xd, 0x4e, 0x7f};
        static unsigned char n_bytes[32] = {0xd8, 0x9f, 0x96, 0x55, 0x11, 0xfc, 0xdd, 0xa7, 0xa8, 0x57, 0xb3, 0xbe, 0xec, 0x2c, 0xc7, 0x63, 0x42, 0x2b, 0x4c, 0x15, 0x6e, 0x1a, 0x2e, 0x39, 0xee, 0x33, 0x9b, 0x47, 0xc2, 0xc, 0xf3, 0x59};

        unsigned int counters[3*runs];
        icachemisses();

        unsigned char q[32];
        for(int i =0;i<runs;i++){
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
