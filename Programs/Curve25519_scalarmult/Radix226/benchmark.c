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
    
        static unsigned char a_bytes[32] = {0x42, 0x43, 0xc2, 0xa1, 0x6b, 0xb6, 0xf4, 0xdc, 0x8b, 0x82, 0xf8, 0x2d, 0xd, 0xc9, 0xf8, 0x62, 0x4a, 0x7d, 0xc2, 0x65, 0x7d, 0xf5, 0xda, 0xdc, 0x8, 0x39, 0x23, 0x6b, 0x56, 0xf0, 0xcb, 0x7};
        static unsigned char b_bytes[32] = {0xd3, 0xaa, 0xd4, 0x75, 0x48, 0x28, 0x98, 0x8a, 0x84, 0x2a, 0x7b, 0x6c, 0x5b, 0xf, 0x6b, 0x7e, 0x78, 0xf, 0xcc, 0x4a, 0xa0, 0xb6, 0x5e, 0x0, 0x83, 0x73, 0x71, 0x3a, 0xf4, 0xaa, 0xba, 0x2};


        convert_to_radix226(a, a_bytes);
        convert_to_radix226(b,b_bytes);

        printf("A: %x, %x, %x, %x, %x, %x, %x, %x, %x, %x\n", a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9]);
        printf("B: %x, %x, %x, %x, %x, %x, %x, %x, %x, %x\n", b[0], b[1], b[2], b[3], b[4], b[5], b[6], b[7], b[8], b[9]);

        uint32_t timings[21];
        unsigned int out[32];
        for(int i =0;i<21;i++){
            timings[i]=getcycles();
            square226_2asm(out, a);
        }

        for(int i=1;i<21;i++){
            printf("%d, ",timings[i]-timings[i-1]);
        }
        printf("\n");
	printf("%x, %x, %x, %x, %x, %x, %x, %x, %x, %x\n", out[0], out[1], out[2], out[3], out[4], out[5], out[6], out[7], out[8], out[9]);
        toradix28(out);
        printarrayinv(out,32);
        printf("\n");
    }
