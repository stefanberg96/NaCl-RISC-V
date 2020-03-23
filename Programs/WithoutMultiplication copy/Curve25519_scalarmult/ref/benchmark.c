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

    
        static unsigned char g_bytes[32] = {0xb0, 0x5e, 0x73, 0x79, 0x7d, 0x7f, 0x1b, 0x81, 0xf8, 0xbb, 0xcf, 0x36, 0xd7, 0x81, 0xc, 0x20, 0x53, 0x19, 0x4e, 0x3d, 0x8c, 0x32, 0xdd, 0xfd, 0xfc, 0x1a, 0x3a, 0xae, 0x9e, 0xa3, 0x8, 0x5f};
        static unsigned char n_bytes[32] = {0xc8, 0x6a, 0xd6, 0x8b, 0xcb, 0x7d, 0xf5, 0x43, 0xc3, 0x53, 0xec, 0xd6, 0xf4, 0xf1, 0xb, 0x6b, 0x1e, 0xb7, 0x18, 0x20, 0x2a, 0x69, 0xa, 0x63, 0xfe, 0x8c, 0x5c, 0x7d, 0x87, 0x2b, 0x9a, 0x5f};


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
