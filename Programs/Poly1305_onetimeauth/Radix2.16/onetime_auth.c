#include "onetime_auth.h"

static const unsigned int minusp[17] = {5, 0, 0, 0, 0, 0, 0, 0,  0,
                                        0, 0, 0, 0, 0, 0, 0, 252};

void printhello(){
  printf("Hello\n");
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
}

void crypto_onetimeauthloop(const unsigned char *in, int inlen, unsigned int *h,
                            unsigned int *r, unsigned int *c) {
  unsigned int j;
  // these computations are all in radix 2.16
  while (inlen > 0) {
    for (j = 0; j < 9; ++j)
      c[j] = 0; // set c to 0
    for (j = 0; (j < 8) && (inlen >= 2); ++j, inlen -= 2) {
      c[j] = in[2 * j]; // fill c with a chunk of 16 bytes from the in param
      c[j] += in[2 * j + 1] << 8;
    }

    if (inlen == 1 && j != 9) {
      c[j] = in[2 * j];
      c[j] += 1 << 8;
      inlen--;
    } else {
      c[j] = 1;
    }
    in += 2 * j;
    add216asm(h, c); // c to the state
    mulmod216asm(h, r); // multiply state with the secret key modulo 2^130-5
  }
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
  
  crypto_onetimeauthloop(in,inlen, h, r, c);
  // go back from radix 2^16 to 2^8
  // h
  toradix28asm(&h[0]);

  freeze(h); // calculate mod 2^130-5

  for (j = 0; j < 16; ++j)
    c[j] = k[j + 16];
  c[16] = 0;
  addasm(h, c); // add S to the state (which is the last 16 bytes of the key)
  for (j = 0; j < 16; ++j)
    out[j] = h[j]; // output the state modulo 2^128 (the last 16 bytes)
  return 0;
}
