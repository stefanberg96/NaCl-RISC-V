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

    void convert_to_radix226(unsigned int* r, unsigned char *k){
        r[0] = k[0] + (k[1] << 8) + (k[2] << 16) + ((k[3]&3)  << 24);
        r[1] = (k[3] >> 2)  + (k[4]  << 6) + (k[5] << 14) +
            ((k[6] & 15) << 22);
        r[2] = (k[6] >> 4) + (k[7] << 4) + (k[8] << 12) +
            ((k[9] & 63) << 20);
        r[3] =
            (k[9] >> 6) + (k[10] << 2) + ((k[11] ) << 10) + (k[12] << 18);
        r[4] = k[13] + (k[14] << 8) + (k[15]  << 16 )+ (k[16]<<24);
    }

    void dobenchmark() {
        static unsigned char g_bytes[32] = {0x8, 0x1f, 0xd, 0x75, 0x3d, 0x51, 0x94, 0xdf, 0x94, 0xee, 0x67, 0x78, 0xca, 0x23, 0x82, 0x85, 0x50, 0xda, 0x33, 0xa1, 0x18, 0x62, 0xcd, 0xeb, 0xe2, 0xbd, 0x9f, 0x86, 0x26, 0x1c, 0xc4, 0x5b};
        static unsigned char n_bytes[32] = {0x78, 0xc4, 0xd0, 0x83, 0x9e, 0x64, 0xa5, 0xa1, 0x84, 0xed, 0x92, 0xf3, 0x82, 0x1f, 0x22, 0x43, 0xd9, 0x63, 0xdb, 0x36, 0x61, 0xf2, 0x8a, 0xf1, 0x40, 0x39, 0x42, 0xf6, 0xd6, 0x52, 0xe6, 0x6a};


        unsigned int counters[3*21];
        icachemisses();

        unsigned char q[32];
        for(int i =0;i<1;i++){
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
