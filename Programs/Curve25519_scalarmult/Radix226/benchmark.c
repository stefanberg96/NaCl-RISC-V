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

        static unsigned char g_bytes[32] = {0xb0, 0x5e, 0x73, 0x79, 0x7d, 0x7f, 0x1b, 0x81, 0xf8, 0xbb, 0xcf, 0x36, 0xd7, 0x81, 0xc, 0x20, 0x53, 0x19, 0x4e, 0x3d, 0x8c, 0x32, 0xdd, 0xfd, 0xfc, 0x1a, 0x3a, 0xae, 0x9e, 0xa3, 0x8, 0x5f};
        static unsigned char n_bytes[32] = {0xc8, 0x6a, 0xd6, 0x8b, 0xcb, 0x7d, 0xf5, 0x43, 0xc3, 0x53, 0xec, 0xd6, 0xf4, 0xf1, 0xb, 0x6b, 0x1e, 0xb7, 0x18, 0x20, 0x2a, 0x69, 0xa, 0x63, 0xfe, 0x8c, 0x5c, 0x7d, 0x87, 0x2b, 0x9a, 0x5f};
 
    
        static unsigned int g[32] = {0xb0, 0x5e, 0x73, 0x79, 0x7d, 0x7f, 0x1b, 0x81, 0xf8, 0xbb, 0xcf, 0x36, 0xd7, 0x81, 0xc, 0x20, 0x53, 0x19, 0x4e, 0x3d, 0x8c, 0x32, 0xdd, 0xfd, 0xfc, 0x1a, 0x3a, 0xae, 0x9e, 0xa3, 0x8, 0x5f};
        static unsigned int n[32] = {0xc8, 0x6a, 0xd6, 0x8b, 0xcb, 0x7d, 0xf5, 0x43, 0xc3, 0x53, 0xec, 0xd6, 0xf4, 0xf1, 0xb, 0x6b, 0x1e, 0xb7, 0x18, 0x20, 0x2a, 0x69, 0xa, 0x63, 0xfe, 0x8c, 0x5c, 0x7d, 0x87, 0x2b, 0x9a, 0x5f};
        unsigned int er[32];
	mult(er, n, g);

	printintarray(er, 32);

	unsigned int r[32];
	unsigned int n226[32];
	unsigned int g226[32];
	convert_to_radix226(n226, n_bytes);
	convert_to_radix226(g226, g_bytes);
		printf("%x, %x, %x, %x, %x, %x, %x, %x, %x, %x\n", n226[0], n226[1], n226[2], n226[3], n226[4], n226[5], n226[6], n226[7], n226[8], n226[9]);
	printf("%x, %x, %x, %x, %x, %x, %x, %x, %x, %x\n", g226[0], g226[1], g226[2], g226[3], g226[4], g226[5], g226[6], g226[7], g226[8], g226[9]);
	karatsuba226_5asm(r, n226, g226);
	
	printf("%x, %x, %x, %x, %x, %x, %x, %x, %x, %x\n", r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9]);
	toradix28(r);
	printintarray(r, 32);

/*
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
*/
        printf("\n\n");
    }

    void print6(unsigned int a0,unsigned int a1,unsigned int a2,unsigned int a3,unsigned int a4,unsigned int a5){
	printf("%x, %x, %x, %x, %x, %x\n", a0, a1, a2, a3, a4, a5);
    }
