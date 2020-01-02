#include "benchmark.h"

    void printarrayinv(unsigned char *in, int inlen){
        for(int i =inlen-1;i>=0;i--){
            printf("%02x", in[i]);
        }
        printf("\n");
    }

    void printarray(unsigned char* in, int inlen){

	for(int i =0;i<inlen;i++){
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

   
        static unsigned char g_bytes[32] = {0xd8, 0xe4, 0x42, 0x31, 0xb1, 0xc5, 0x26, 0xbc, 0x8f, 0xc8, 0x18, 0x1a, 0x2e, 0x2e, 0xf8, 0x9e, 0xf2, 0xe5, 0xac, 0xab, 0x2b, 0xac, 0x20, 0x2b, 0x42, 0x73, 0x8, 0x55, 0xaf, 0x30, 0x2a, 0x53};
        static unsigned char n_bytes[32] = {0x50, 0x6e, 0x48, 0x61, 0x60, 0xf9, 0xeb, 0xb4, 0xbf, 0x91, 0x6f, 0x41, 0xd0, 0x45, 0x46, 0xa, 0x3d, 0x49, 0x8a, 0x62, 0xa0, 0x8e, 0x80, 0xa8, 0x51, 0xd0, 0xbf, 0xb3, 0xbd, 0x15, 0x6, 0x70};



        unsigned int counters[3*21];
        unsigned char q[32];
            crypto_scalarmult(q, n_bytes, g_bytes);

        printf("Result: ");
        printarray(q, 32);
        printf("\n\n");
    }
