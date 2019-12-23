#include "benchmark.h"
extern void karatsuba226asm(unsigned int *, unsigned int *, unsigned int*);

    void convert_to_radix226(unsigned int* r, unsigned char *k){
        r[0] = k[0] + (k[1] << 8) + (k[2] << 16) + ((k[3] & 3) << 24);
        r[1] = ((k[3] >> 2) & 3) + ((k[4] & 252) << 6) + (k[5] << 14) +
            ((k[6] & 15) << 22);
        r[2] = (k[6] >> 4) + ((k[7] & 15) << 4) + ((k[8] & 252) << 12) +
            ((k[9] & 63) << 20);
        r[3] =
            (k[9] >> 6) + (k[10] << 2) + ((k[11] & 15) << 10) + ((k[12] & 252) << 18);
        r[4] = k[13] + (k[14] << 8) + ((k[15] & 15) << 16);
    }
extern void karatsuba226asm_inplace(unsigned int*, unsigned int *);
    void dobenchmark() {

        unsigned int a[17];
        unsigned int b[5];
    
        static unsigned char a_bytes[16] = {0x72, 0xa, 0x41, 0x67, 0xf2, 0x3b, 0xf2, 0xc3, 0x83, 0xe9, 0x69, 0x2b, 0xc1, 0x38, 0x4f, 0xcc};
        static unsigned char b_bytes[16] = {0x2a, 0xe1, 0xdd, 0x9a, 0xaa, 0xdb, 0x17, 0xba, 0xd4, 0x12, 0xd8, 0xbb, 0x40, 0x62, 0x37, 0x23};


        convert_to_radix226(a, a_bytes);
        convert_to_radix226(b,b_bytes);


        printf("A: %x, %x, %x, %x, %x\n", a[0], a[1], a[2], a[3], a[4]);
        printf("B: %x, %x, %x, %x, %x\n", b[0], b[1], b[2], b[3], b[4]);

        uint32_t timings[21]={0};
	unsigned int out[17]={0};
        for(int i =0;i<21;i++){
            timings[i]=getcycles();
            crypto_onetimeauth(out,a, b);
        }

        for(int i=1;i<21;i++){
            printf("%d, ",timings[i]-timings[i-1]);
        }
        printf(" %x, %x, %x, %x, %x\n", out[0], out[1], out[2], out[3], out[4]);

        toradix28(out);
        printarray(out,17);
        printf("\n");
	
    }
