#include "benchmark.h"
    extern void icachemisses();
    static int runs=31;

    void printresult(unsigned char *in, int inlen){
        for(int i =0;i<inlen;i++){
            printf("%02x", in[i]);
            fflush(stdout);
        }
        printf("\n");
    }

    void printresultreverse(unsigned char *in, int inlen){
        for(int i =inlen-1;i>=0;i--){
            printf("%02x", in[i]);
        }
        printf("\n");
    }


    void printintarray(unsigned int *in, int inlen){
        for(int i =0;i<inlen;i++){
            printf("0x%02x, ", in[i]);
        }
        printf("\n");
    }

    void printchararray(unsigned char *in, int inlen){
        for(int i =0;i<inlen;i++){
            printf("0x%02x, ", in[i]);
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

    
        static unsigned char n_bytes[32] = {0x50, 0x5b, 0xbf, 0xe8, 0xd7, 0xcd, 0xe4, 0x1d, 0x3a, 0x80, 0x1f, 0xa8, 0xea, 0xbe, 0xc8, 0x52, 0xf5, 0x9c, 0x82, 0xfd, 0x54, 0xe3, 0x7b, 0xbc, 0x54, 0xb8, 0x6e, 0x90, 0x0e, 0x3f, 0xa9, 0x55};
        static unsigned char g_bytes[32] = {0xb8, 0x66, 0x45, 0x9c, 0xda, 0x10, 0xf0, 0x43, 0xa6, 0x6e, 0x26, 0x2b, 0xd8, 0xd2, 0x86, 0xcd, 0xbe, 0xa5, 0x35, 0x6e, 0x51, 0x7b, 0xb8, 0x23, 0xe9, 0xa2, 0x67, 0x80, 0xc8, 0x47, 0xee, 0x4b};
unsigned char q[32];


        unsigned int counters[3*runs];
        icachemisses();

        uint32_t timings[21];
        for(int i =0;i<runs;i++){
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
        printresult(q, 32);
        printf("\n\n");

    }
