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

        static unsigned char g_bytes[32] = {0x8, 0x1f, 0xd, 0x75, 0x3d, 0x51, 0x94, 0xdf, 0x94, 0xee, 0x67, 0x78, 0xca, 0x23, 0x82, 0x85, 0x50, 0xda, 0x33, 0xa1, 0x18, 0x62, 0xcd, 0xeb, 0xe2, 0xbd, 0x9f, 0x86, 0x26, 0x1c, 0xc4, 0x5b};
        static unsigned char n_bytes[32] = {0x78, 0xc4, 0xd0, 0x83, 0x9e, 0x64, 0xa5, 0xa1, 0x84, 0xed, 0x92, 0xf3, 0x82, 0x1f, 0x22, 0x43, 0xd9, 0x63, 0xdb, 0x36, 0x61, 0xf2, 0x8a, 0xf1, 0x40, 0x39, 0x42, 0xf6, 0xd6, 0x52, 0xe6, 0x6a};


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

    void printparams(unsigned int * a, unsigned int * b){

     printf("A=");
     printintarray(a,10);
     printf("B=");
     printintarray(b,10);
    }

    void printkarresult(unsigned int *r){
     printf("R=");
     printintarray(r,10);
     printf("A=sum(A[i]*(2^26)^i for i in range(10))\n");
     printf("B=sum(B[i]*(2^26)^i for i in range(10))\n");
     printf("print(sum(R[i]*(2^26)^i for i in range(10)) == lift(mod(A*B, 2^255-19)))\n");
    }

    void printaddresult(unsigned int *r){

     printf("R=");
     printintarray(r,10);
     printf("A=sum(A[i]*(2^26)^i for i in range(10))\n");
     printf("B=sum(B[i]*(2^26)^i for i in range(10))\n");
     printf("print(sum(R[i]*(2^26)^i for i in range(10)) == lift(mod(A+B, 2^255-19)))\n");

    }

    void printsubresult(unsigned int *r){

     printf("R=");
     printintarray(r,10);
     printf("A=sum(A[i]*(2^26)^i for i in range(10))\n");
     printf("B=sum(B[i]*(2^26)^i for i in range(10))\n");
     printf("print(sum(R[i]*(2^26)^i for i in range(10)) == lift(mod(A-B, 2^255-19)))\n");

    }

    void printmulresult(unsigned int *r){
       printf("R=");
       printintarray(r,10);
       printf("A= sum(A[i]*(2^26)^i for i in range(10))\n");
     printf("B=sum(B[i]*(2^26)^i for i in range(10))\n");
       printf("print(sum(R[i]*(2^26)^i for i in range(10))== lift(mod(A*121665,2^255-19)))\n");
    }
