#include "benchmark.h"

    void printarrayinv(unsigned int *in, int inlen){
        for(int i =inlen-1;i>=0;i--){
            printf("%02x", in[i]);
        }
        printf("\n");
    }

 void convert_to_radix226_test(unsigned int *r, unsigned char *k) {
  r[0] = k[0] + (k[1] << 8) + (k[2] << 16) + ((k[3] & 3) << 24);
  r[1] = (k[3] >> 2) + (k[4] << 6) + (k[5] << 14) + ((k[6] & 15) << 22);
  r[2] = (k[6] >> 4) + (k[7] << 4) + (k[8] << 12) + ((k[9] & 63) << 20);
  r[3] = (k[9] >> 6) + (k[10] << 2) + ((k[11]) << 10) + (k[12] << 18);
  r[4] = k[13] + (k[14] << 8) + (k[15] << 16) + ((k[16]&3) << 24);
  r[5] = (k[16] >> 2) + (k[17] << 6) + (k[18] << 14) + ((k[19] & 15) << 22);
  r[6] = (k[19] >> 4) + (k[20] << 4) + (k[21] << 12) + ((k[22] & 63) << 20);
  r[7] = (k[22] >> 6) + (k[23] << 2) + ((k[24]) << 10) + (k[25] << 18);
  r[8] = k[26] + (k[27] << 8) + (k[28] << 16) + ((k[29]&3) << 24);
  r[9] = (k[29] >> 2) + (k[30] << 6) + (k[31] << 14);
  r[10] = k[32] + (k[33] << 8) + (k[34] << 16) + ((k[35] & 3) << 24);
  r[11] = (k[35] >> 2) + (k[36] << 6) + (k[37] << 14) + ((k[38] & 15) << 22);
  r[12] = (k[38] >> 4) + (k[39] << 4) + (k[40] << 12) + ((k[41] & 63) << 20);
  r[13] = (k[41] >> 6) + (k[42] << 2) + ((k[43]) << 10) + (k[44] << 18);
  r[14] = k[45] + (k[46] << 8) + (k[47] << 16) + ((k[48]&3) << 24);
  r[15] = (k[48] >> 2) + (k[49] << 6) + (k[50] << 14) + ((k[51] & 15) << 22);
  r[16] = (k[51] >> 4) + (k[52] << 4) + (k[53] << 12) + ((k[54] & 63) << 20);
  r[17] = (k[54] >> 6) + (k[55] << 2) + ((k[56]) << 10) + (k[57] << 18);
  r[18] = k[58] + (k[59] << 8) + (k[60] << 16) + ((k[61]&3) << 24);
  r[19] = (k[61] >> 2) + (k[62] << 6) + (k[63] << 14);
}  

    void dobenchmark() {

        unsigned int a[20];
        unsigned int b[20];
    
        static unsigned char a_bytes[64] = {0x42, 0x43, 0xc2, 0xa1, 0x6b, 0xb6, 0xf4, 0xdc, 0x8b, 0x82, 0xf8, 0x2d, 0xd, 0xc9, 0xf8, 0x62, 0x4a, 0x7d, 0xc2, 0x65, 0x7d, 0xf5, 0xda, 0xdc, 0x8, 0x39, 0x23, 0x6b, 0x56, 0xf0, 0xcb, 0x7,0xd3, 0xaa, 0xd4, 0x75, 0x48, 0x28, 0x98, 0x8a, 0x84, 0x2a, 0x7b, 0x6c, 0x5b, 0xf, 0x6b, 0x7e, 0x78, 0xf, 0xcc, 0x4a, 0xa0, 0xb6, 0x5e, 0x0, 0x83, 0x73, 0x71, 0x3a, 0xf4, 0xaa, 0xba, 0x2};
        static unsigned char b_bytes[64] = {0xd3, 0xaa, 0xd4, 0x75, 0x48, 0x28, 0x98, 0x8a, 0x84, 0x2a, 0x7b, 0x6c, 0x5b, 0xf, 0x6b, 0x7e, 0x78, 0xf, 0xcc, 0x4a, 0xa0, 0xb6, 0x5e, 0x0, 0x83, 0x73, 0x71, 0x3a, 0xf4, 0xaa, 0xba, 0x2,0x42, 0x43, 0xc2, 0xa1, 0x6b, 0xb6, 0xf4, 0xdc, 0x8b, 0x82, 0xf8, 0x2d, 0xd, 0xc9, 0xf8, 0x62, 0x4a, 0x7d, 0xc2, 0x65, 0x7d, 0xf5, 0xda, 0xdc, 0x8, 0x39, 0x23, 0x6b, 0x56, 0xf0, 0xcb, 0x7,0xd3};


        convert_to_radix226(a, a_bytes);
        convert_to_radix226(b,b_bytes);

        printf("A: %x, %x, %x, %x, %x, %x, %x, %x, %x, %x\n", a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9]);
        printf("B: %x, %x, %x, %x, %x, %x, %x, %x, %x, %x\n", b[0], b[1], b[2], b[3], b[4], b[5], b[6], b[7], b[8], b[9]);

        uint32_t timings[21];
        unsigned int out[32];
	unsigned int p[64];
	unsigned int q[64];
        for(int i =0;i<21;i++){
            timings[i]=getcycles();
            crypto_select_asm(p, q, a, b, 1);
        }

        for(int i=1;i<21;i++){
            printf("%d, ",timings[i]-timings[i-1]);
        }
        printf("\n");
	printf("%x, %x, %x, %x, %x, %x, %x, %x, %x, %x\n", out[0], out[1], out[2], out[3], out[4], out[5], out[6], out[7], out[8], out[9]);
        toradix28(p);
        printintarray(p,64);
	toradix28(q);
	printintarray(q,64);
        printf("\n");
    }
