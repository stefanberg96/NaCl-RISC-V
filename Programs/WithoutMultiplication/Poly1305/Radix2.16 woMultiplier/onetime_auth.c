#include "onetime_auth.h"

void printhello(){
  printf("Hello\n");
}

void printbyte(unsigned int x){
  printf("x:%x\n",x);
}

void printarray(unsigned int *x, int inlen){
   for(int i=0;i<inlen;i++){
      printf("%x, ", x[i]);
   }
   printf("\n");
}

void mulmod216old(unsigned int h[9], const unsigned int r[9]) {
  unsigned int hr[9];
  unsigned int i;
  unsigned int j;
  int64_t u = 0 ;

  for (i = 0; i < 9; ++i) {
    for (j = 0; j <= i; ++j)
      u += h[j] * r[i - j];
    for (j = i + 1; j < 9; ++j){
      uint64_t tmp = h[j]*r[i+9-j];
      //tmp *= 81920;
      tmp = (tmp <<14)+(tmp<<16);
      u += tmp;//81920 * h[j] * r[i + 9 - j];
    }
    hr[i] = u & 0xFFFF;
    u >>= 16;
  }
  hr[8] += u<<16;
  for (i = 0; i < 9; ++i)
    h[i] = hr[i];
  squeeze216asm(h);
}

static const unsigned int minusp[17] = {5, 0, 0, 0, 0, 0, 0, 0,  0,
                                        0, 0, 0, 0, 0, 0, 0, 252};

// reduce the number from 2^133 to 2^130-5
static void freeze(unsigned int h[17]) {
  unsigned int horig[17];
  unsigned int j;
  unsigned int negative;
  for (j = 0; j < 17; ++j)
    horig[j] = h[j];
  addasm(h, minusp);
  negative = -(h[16] >> 7);
  for (j = 0; j < 17; ++j)
    h[j] ^= negative & (horig[j] ^ h[j]);
}

// input is in little endian
int crypto_onetimeauth(unsigned char *out, const unsigned char *in,
                       unsigned long long inlen, const unsigned char *k) {
  unsigned int j;
  unsigned int r[9];
  unsigned int h[17];
  unsigned int c[17];

  // create R from the first 16 bytes of the key
  r[0] = k[0] + (k[1] << 8);
  r[1] = k[2] + ((k[3] & 15) << 8);
  r[2] = (k[4] & 252) + (k[5] << 8);
  r[3] = k[6] + ((k[7] & 15) << 8);
  r[4] = (k[8] & 252) + (k[9] << 8);
  r[5] = k[10] + ((k[11] & 15) << 8);
  r[6] = (k[12] & 252) + (k[13] << 8);
  r[7] = k[14] + ((k[15] & 15) << 8);
  r[8] = 0;
  // set the state to 0
  for (j = 0; j < 17; ++j)
    h[j] = 0;
  
  onetime_authloopasm(in,inlen, h, r, c);
  // go back from radix 2^16 to 2^8
  // h
  toradix28asm(h);

  freeze(h); // calculate mod 2^130-5

  for (j = 0; j < 16; ++j)
    c[j] = k[j + 16];
  c[16] = 0;
  addasm(h, c); // add S to the state (which is the last 16 bytes of the key)
  for (j = 0; j < 16; ++j)
    out[j] = h[j]; // output the state modulo 2^128 (the last 16 bytes)
  return 0;
}
