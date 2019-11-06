#include "onetime_auth.h"

extern void onetime_authloop(const unsigned char *in, int inlen,
                             unsigned int *h, unsigned int *r, unsigned int *c);
extern void addasm(unsigned int h[17], const unsigned int c[17]);
extern void add216asm(unsigned int h[9], const unsigned int c[9]);
extern int getsp();
extern void squeeze216asm(unsigned int h[9]);

// add the two numbers together without reduction
static void add(unsigned int h[17], const unsigned int c[17]) {
  unsigned int j;
  unsigned int u;
  u = 0;
  for (j = 0; j < 17; ++j) {
    u += h[j] + c[j];
    h[j] = u & 255;
    u >>= 8;
  }
}

// add the two numbers together without reduction
static void add216(unsigned int h[9], const unsigned int c[9]) {
  unsigned int j;
  unsigned int u;
  u = 0;
  for (j = 0; j < 17; ++j) {
    u += h[j] + c[j];
    h[j] = u & 0xFFFF;
    u >>= 16;
  }
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
  add(h, minusp);
  negative = -(h[16] >> 7);
  for (j = 0; j < 17; ++j)
    h[j] ^= negative & (horig[j] ^ h[j]);
}

static void mulmod216(unsigned int h[9], const unsigned int r[9]) {
  unsigned int hr[9];
  unsigned int i;
  unsigned int j;
  int64_t u = 0;

  for (i = 0; i < 9; ++i) {
    for (j = 0; j <= i; ++j)
      u += h[j] * r[i - j];
    for (j = i + 1; j < 9; ++j) {
      uint64_t tmp = h[j] * r[i + 9 - j];
      tmp *= 81920;
      u += tmp; // 81920 * h[j] * r[i + 9 - j];
    }
    hr[i] = u & 0xFFFF;
    u >>= 16;
  }
  hr[8] += u << 16;
  for (i = 0; i < 9; ++i)
    h[i] = hr[i];
  squeeze216asm(h);
}

static void toradix216int(unsigned int *out, const unsigned int *in,
                          int inlen) {
  int i = 0;
  while (inlen >= 2) {
    out[i] = in[2 * i];
    out[i] += in[2 * i + 1] << 8;
    inlen -= 2;
    i++;
  }

  if (inlen == 1)
    out[i] = in[2 * i];
  return;
}

static void toradix28(unsigned int *in) {

  in[16] = in[8];
  for (int i = 7; i >= 0; i--) {
    in[i * 2 + 1] = in[i] >> 8;
    in[i * 2] = in[i] & 0xFF;
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
  //these computations are all in radix 2.16
  while (inlen > 0) {
    for (j = 0; j < 9; ++j)
      c[j] = 0; // set c to 0
    for (j = 0; (j < 8) && (inlen > 2); ++j, inlen -= 2) {
      c[j] = in[2 * j]; // fill c with a chunk of 16 bytes from the in param
      c[j] += in[2 * j + 1] << 8;
    }

    if (inlen == 1 && j != 8) {
      c[j] = in[2 * j];
      c[j] += 1 << 8;
      inlen--;
    } else {
      c[j] = 1;
    }
    in += 2 * j;
    add216(h, c); // c to the state
    mulmod216(h, r); // multiply state with the secret key modulo 2^130-5
  }

  // go back from radix 2^16 to 2^8
  // h
  toradix28(&h[0]);

  freeze(h); // calculate mod 2^130-5

  for (j = 0; j < 16; ++j)
    c[j] = k[j + 16];
  c[16] = 0;
  add(h, c); // add S to the state (which is the last 16 bytes of the key)
  for (j = 0; j < 16; ++j)
    out[j] = h[j]; // output the state modulo 2^128 (the last 16 bytes)
  return 0;
}
