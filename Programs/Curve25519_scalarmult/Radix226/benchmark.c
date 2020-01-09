#include "benchmark.h"

    void printarrayinv(unsigned int *in, int inlen){
        for(int i =inlen-1;i>=0;i--){
            printf("%02x", in[i]);
        }
        printf("\n");
    }

    void dobenchmark() {

        unsigned int a[10];
        unsigned int b[10];
    
        static unsigned char a_bytes[32] = {0x6e, 0x21, 0x85, 0x6c, 0xee, 0x47, 0x18, 0xb1, 0xed, 0x19, 0xb6, 0x98, 0x72, 0xd9, 0xd, 0x15, 0xda, 0x8b, 0xfb, 0x19, 0x4a, 0xce, 0xd3, 0x66, 0x14, 0x52, 0xab, 0xe2, 0x9a, 0xa, 0xc8, 0x4a};
        static unsigned char b_bytes[32] = {0xff, 0x57, 0x63, 0xed, 0xd9, 0x1d, 0x19, 0x2a, 0xe4, 0xb1, 0xb5, 0x31, 0x4c, 0xd5, 0xdf, 0x5, 0xe8, 0xaf, 0x66, 0x81, 0xd1, 0xda, 0x11, 0x3d, 0xba, 0xb2, 0x75, 0xa8, 0x47, 0x4e, 0x78, 0x59};


        convert_to_radix226(a, a_bytes);
        convert_to_radix226(b,b_bytes);

        printf("A: %x, %x, %x, %x, %x, %x, %x, %x, %x, %x\n", a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9]);
        printf("B: %x, %x, %x, %x, %x, %x, %x, %x, %x, %x\n", b[0], b[1], b[2], b[3], b[4], b[5], b[6], b[7], b[8], b[9]);

        uint32_t timings[21];
        unsigned int out[32];
        for(int i =0;i<21;i++){
            timings[i]=getcycles();
            karatsuba226(out, a,b);
        }

        for(int i=1;i<21;i++){
            printf("%d, ",timings[i]-timings[i-1]);
        }
        printf("\n");

        printf("R: %x, %x, %x, %x, %x, %x, %x, %x, %x, %x\n", out[0], out[1], out[2], out[3], out[4], out[5], out[6], out[7], out[8], out[9]);

        toradix28(out);
        printarrayinv(out,32);
        printf("\n");
    }

    void print6(unsigned int a0, unsigned int a1, unsigned int a2, unsigned int a3, unsigned int a4, unsigned int a5, unsigned int a6){
	printf("%x, %x, %x, %x, %x\n", a2, a3, a4, a5, a6);
    }
