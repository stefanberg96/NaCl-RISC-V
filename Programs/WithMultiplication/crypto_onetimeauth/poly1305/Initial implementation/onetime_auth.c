#include <stdint.h>
#include <stdio.h>
#include <string.h>

extern uint32_t getcycles();
extern void onetime_authloop(const unsigned char *in, int inlen,
                             unsigned int *h, unsigned int *r, unsigned int *c);
extern void addasm(unsigned int h[17], const unsigned int c[17]);

static const unsigned int minusp[17] = {5, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0, 0, 0, 0, 0, 0, 252};


 void printintarray(unsigned int * in, int inlen){
  for(int i =0;i<inlen;i++){
    printf("%x, ",in[i]);
  }
  printf("\n");

}

                                      
void printarray(unsigned char * in, int inlen){
  for(int i =0;i<inlen;i++){
    printf("%x, ",in[i]);
  }
  printf("\n");

}

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
  return;
}

// input is in little endian
int crypto_onetimeauth(unsigned char *out, const unsigned char *in,
                       unsigned long long inlen, const unsigned char *k) {
  unsigned int j;
  unsigned int r[17];
  unsigned int h[17];
  unsigned int c[17];
  // create R from the first 16 bytes of the key
  r[0] = k[0];
  r[1] = k[1];
  r[2] = k[2];
  r[3] = k[3] & 15;
  r[4] = k[4] & 252;
  r[5] = k[5];
  r[6] = k[6];
  r[7] = k[7] & 15;
  r[8] = k[8] & 252;
  r[9] = k[9];
  r[10] = k[10];
  r[11] = k[11] & 15;
  r[12] = k[12] & 252;
  r[13] = k[13];
  r[14] = k[14];
  r[15] = k[15] & 15;
  r[16] = 0;

  for (j = 0; j < 17; ++j)
    h[j] = 0;
  onetime_authloop(in, inlen, h, r, c);
  
  // set the state to 0
  freeze(h); // calculate mod 2^130-5

  for (j = 0; j < 16; ++j) // copy S into c
    c[j] = k[j + 16];
  c[16] = 0;
  addasm(h, c); // add S to the state (which is the last 16 bytes of the key)
  for (j = 0; j < 16; ++j)
    out[j] = h[j]; // output the state modulo 2^128 (the last 16 bytes)

  return 0;
}
