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
    
        static unsigned char a_bytes[18] = {0x2a, 0x22, 0x67, 0x45, 0x8a, 0xb, 0x8f, 0xf1, 0x64, 0xd9, 0x2, 0xb5, 0x5c, 0xd8, 0x98, 0xc6, 0x1};
        static unsigned char b_bytes[18] = {0xc8, 0x22, 0xe8, 0xeb, 0x22, 0x21, 0x85, 0xe2, 0x48, 0xb6, 0x83, 0x57, 0xa4, 0x7b, 0xc, 0xea, 0x2};


        convert_to_radix226(a, a_bytes);
        convert_to_radix226(b,b_bytes);

        printf("A: %x, %x, %x, %x, %x\n", a[0], a[1], a[2], a[3], a[4]);
        printf("B: %x, %x, %x, %x, %x\n", b[0], b[1], b[2], b[3], b[4]);

        uint32_t timings[21];
        unsigned int out[17];
        for(int i =0;i<1;i++){
            timings[i]=getcycles();
            karatsuba226asm(out, a,b);
        }

        for(int i=1;i<21;i++){
            printf("%d, ",timings[i]-timings[i-1]);
        }
        printf("\n");
        squeeze226asm(out);
	printf("%x, %x, %x, %x, %x\n", out[0], out[1], out[2], out[3], out[4]);
        toradix28(out);
        printarrayinv(out,17);
        printf("\n");
    }
