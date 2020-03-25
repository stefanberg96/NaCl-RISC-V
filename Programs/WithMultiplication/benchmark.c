#include "benchmark.h"
    extern void icachemisses();
    static int runs=21;

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

    
        static unsigned char n_bytes[32] = {0xa8, 0x26, 0xfa, 0x54, 0xbb, 0x82, 0xe7, 0x8d, 0xb2, 0x66, 0xed, 0xe7, 0x4b, 0xd4, 0xf7, 0x04, 0x42, 0x09, 0x22, 0x12, 0x8c, 0xd1, 0xab, 0x82, 0x59, 0x96, 0x73, 0x69, 0x2b, 0x50, 0x56, 0x73};
        static unsigned char g_bytes[32] = {0xc8, 0x84, 0xc8, 0x9d, 0x0d, 0x96, 0x15, 0xab, 0xec, 0x8d, 0x69, 0x69, 0x4e, 0xde, 0x77, 0xab, 0x05, 0x48, 0xa0, 0x9b, 0x3e, 0xa6, 0xb6, 0xe2, 0xf0, 0xbb, 0x82, 0xb4, 0xd2, 0x5b, 0x11, 0x48};
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
