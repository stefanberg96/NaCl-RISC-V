#include "benchmark.h"
    extern void icachemisses();
    static int runs=51;

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

    
        static unsigned char n_bytes[32] = {0xf8, 0x56, 0xb6, 0x2d, 0xf0, 0xc1, 0xf1, 0xe8, 0x93, 0x29, 0x47, 0x52, 0x76, 0xac, 0x52, 0x74, 0x00, 0x4e, 0x65, 0x09, 0x5c, 0x87, 0xb5, 0xc7, 0x8a, 0x7b, 0xdc, 0xb0, 0x3a, 0x90, 0x2d, 0x56};
        static unsigned char g_bytes[32] = {0xd8, 0x4c, 0x0c, 0xcd, 0x3d, 0x6e, 0x0c, 0x7c, 0xb3, 0x06, 0x2c, 0x33, 0x57, 0xb1, 0xe5, 0x2d, 0xd8, 0xd4, 0x2b, 0x74, 0x3e, 0x5e, 0x35, 0x19, 0x2a, 0x89, 0x20, 0x5f, 0x3a, 0xb7, 0x93, 0x7d};
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

        printf("Icache busy:    ");
        printcounters(counters, 2);

        printf("Result: ");
        printresult(q, 32);
        printf("\n\n");

    }
