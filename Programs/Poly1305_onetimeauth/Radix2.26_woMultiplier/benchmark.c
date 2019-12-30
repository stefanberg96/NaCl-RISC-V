#include "benchmark.h"

    void printarrayinv(unsigned int *in, int inlen){
        for(int i =inlen-1;i>=0;i--){
            printf("%02x", in[i]);
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

        unsigned int a[17];
        unsigned int b[5];
    
        static unsigned char a_bytes[18] = {0x5f, 0x74, 0x97, 0xc3, 0xbd, 0x2f, 0x9, 0xa1, 0x72, 0x8, 0x96, 0x25, 0x6f, 0x69, 0x7d, 0x70, 0x0};
        static unsigned char b_bytes[18] = {0xd8, 0x8b, 0x7, 0xc1, 0x6a, 0xe8, 0xda, 0xc3, 0xde, 0xaa, 0x47, 0xc6, 0xdf, 0x35, 0x7f, 0x69, 0x2};


        convert_to_radix226(a, a_bytes);
        convert_to_radix226(b,b_bytes);

        printf("A: %x, %x, %x, %x, %x\n", a[0], a[1], a[2], a[3], a[4]);
        printf("B: %x, %x, %x, %x, %x\n", b[0], b[1], b[2], b[3], b[4]);

        uint32_t timings[21];
        unsigned int out[17];
        for(int i =0;i<21;i++){
            timings[i]=getcycles();
            karatsuba226asm(out, a,b);
        }

        for(int i=1;i<21;i++){
            printf("%d, ",timings[i]-timings[i-1]);
        }
        printf("\n");
        squeeze226asm(out);
        toradix28(out);
        printarrayinv(out,17);
        printf("\n");
    }
