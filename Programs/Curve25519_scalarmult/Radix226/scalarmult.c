/*
version 20081011
Matthew Dempsky
Public domain.
Derived from public domain code by D. J. Bernstein.
*/

#include "scalarmult.h"

// addition of a and b
// possible need to squeeze for the karatsuba
static void add(unsigned int out[32], const unsigned int a[32],
                const unsigned int b[32]) {
  unsigned int j;
  unsigned int u;
  u = 0;
  for (j = 0; j < 31; ++j) {
    u += a[j] + b[j];
    out[j] = u & 255;
    u >>= 8;
  }
  u += a[31] + b[31];
  out[31] = u;
}

// subtraction of a and b (TODO check if negative numbers are expected, since
// this could screw with my karatsuba mult)
static void sub(unsigned int out[32], const unsigned int a[32],
                const unsigned int b[32]) {
  unsigned int j;
  unsigned int u;
  u = 218;
  for (j = 0; j < 31; ++j) {
    u += a[j] + 65280 - b[j];
    out[j] = u & 255;
    u >>= 8;
  }
  u += a[31] - b[31];
  out[31] = u;
}

// handle overflow (TODO possibly use overflow from the karatsuba assembly)
static void squeeze(unsigned int a[32]) {
  unsigned int j;
  unsigned int u;
  u = 0;
  for (j = 0; j < 31; ++j) {
    u += a[j];
    a[j] = u & 255;
    u >>= 8;
  }
  u += a[31];
  a[31] = u & 127;
  u = 19 * (u >> 7);
  for (j = 0; j < 31; ++j) {
    u += a[j];
    a[j] = u & 255;
    u >>= 8;
  }
  u += a[31];
  a[31] = u;
}

static const unsigned int minusp[32] = {19, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,
                                        0,  0, 0, 0, 0, 0, 0, 0, 0, 0,  0,
                                        0,  0, 0, 0, 0, 0, 0, 0, 0, 128};

// no idea but only runs once so no need to optimize the shit out of it.
static void freeze(unsigned int a[32]) {
  unsigned int aorig[32];
  unsigned int j;
  unsigned int negative;

  for (j = 0; j < 32; ++j)
    aorig[j] = a[j];
  add(a, a, minusp);
  negative = -((a[31] >> 7) & 1);
  for (j = 0; j < 32; ++j)
    a[j] ^= negative & (aorig[j] ^ a[j]);
}

// multiplication of a and b with handling overflow
// TODO make into karatsuba with split 130 125 using modified assembly from
// poly1305
static void mult(unsigned int out[32], const unsigned int a[32],
                 const unsigned int b[32]) {
  unsigned int i;
  unsigned int j;
  unsigned int u;

  for (i = 0; i < 32; ++i) {
    u = 0;
    for (j = 0; j <= i; ++j)
      u += a[j] * b[i - j];
    for (j = i + 1; j < 32; ++j)
      u += 38 * a[j] * b[i + 32 - j];
    out[i] = u;
  }
  squeeze(out);
}

// multiplication by 121665
// make optimized version in base 2^26
static void mult121665(unsigned int out[32], const unsigned int a[32]) {
  unsigned int j;
  unsigned int u;

  u = 0;
  for (j = 0; j < 31; ++j) {
    u += 121665 * a[j];
    out[j] = u & 255;
    u >>= 8;
  }
  u += 121665 * a[31];
  out[31] = u & 127;
  u = 19 * (u >> 7);
  for (j = 0; j < 31; ++j) {
    u += out[j];
    out[j] = u & 255;
    u >>= 8;
  }
  u += out[j];
  out[j] = u;
}

// square a with overflow handling
// reuse karatsuba and find out why it does u*2 and on addition on even
static void square(unsigned int out[32], const unsigned int a[32]) {
  unsigned int i;
  unsigned int j;
  unsigned int u;

  for (i = 0; i < 32; ++i) {
    u = 0;
    for (j = 0; j < i - j; ++j)
      u += a[j] * a[i - j];
    for (j = i + 1; j < i + 32 - j; ++j)
      u += 38 * a[j] * a[i + 32 - j];
    u *= 2;
    if ((i & 1) == 0) {
      u += a[i / 2] * a[i / 2];
      u += 38 * a[i / 2 + 16] * a[i / 2 + 16];
    }
    out[i] = u;
  }
  squeeze(out);
}

// if b==1 return p as s and q as r otherwise it is flipped
static void crypto_select(unsigned int p[64], unsigned int q[64],
                          const unsigned int r[64], const unsigned int s[64],
                          unsigned int b) {
  unsigned int j;
  unsigned int t;
  unsigned int bminus1;

  bminus1 = b - 1;
  for (j = 0; j < 64; ++j) {
    t = bminus1 & (r[j] ^ s[j]);
    p[j] = s[j] ^ t;
    q[j] = r[j] ^ t;
  }
}

// main loop of basic operations
// work is the group element and e is the scalar
static void mainloop(unsigned int work[64], const unsigned char e[32]) {
  unsigned int xzm1[64];
  unsigned int xzm[64];
  unsigned int xzmb[64];
  unsigned int xzm1b[64];
  unsigned int xznb[64];
  unsigned int xzn1b[64];
  unsigned int a0[64];
  unsigned int a1[64];
  unsigned int b0[64];
  unsigned int b1[64];
  unsigned int c1[64];
  unsigned int r[32];
  unsigned int s[32];
  unsigned int t[32];
  unsigned int u[32];
  unsigned int i;
  unsigned int j;
  unsigned int b;
  int pos;

  for (j = 0; j < 32; ++j)
    xzm1[j] = work[j];
  xzm1[32] = 1;
  for (j = 33; j < 64; ++j)
    xzm1[j] = 0;

  xzm[0] = 1;
  for (j = 1; j < 64; ++j)
    xzm[j] = 0;

  for (pos = 254; pos >= 0; --pos) {
    // select each bit from e
    b = e[pos / 8] >> (pos & 7);
    b &= 1;
    // if b==1 then xzmb = xzm xzm1b = xzm1 else
    //              xzmb= xzm1 xzmb1= xzmb
    crypto_select(xzmb, xzm1b, xzm, xzm1, b);

    add(a0, xzmb, xzmb + 32);
    sub(a0 + 32, xzmb, xzmb + 32);
    add(a1, xzm1b, xzm1b + 32);
    sub(a1 + 32, xzm1b, xzm1b + 32);
    square(b0, a0);
    square(b0 + 32, a0 + 32);
    mult(b1, a1, a0 + 32);
    mult(b1 + 32, a1 + 32, a0);
    add(c1, b1, b1 + 32);
    sub(c1 + 32, b1, b1 + 32);
    square(r, c1 + 32);
    sub(s, b0, b0 + 32);
    mult121665(t, s);
    add(u, t, b0);
    mult(xznb, b0, b0 + 32);
    mult(xznb + 32, s, u);
    square(xzn1b, c1);

    mult(xzn1b + 32, r, work);
    // if b==1 then xzmb = xzm xzm1b = xzm1 else
    //              xzmb= xzm1 xzmb1= xzmb
    crypto_select(xzm, xzm1, xznb, xzn1b, b);
  }

  for (j = 0; j < 64; ++j)
    work[j] = xzm[j];
}

// no idea what this does
static void recip(unsigned int out[32], const unsigned int z[32]) {
  unsigned int z2[32];
  unsigned int z9[32];
  unsigned int z11[32];
  unsigned int z2_5_0[32];
  unsigned int z2_10_0[32];
  unsigned int z2_20_0[32];
  unsigned int z2_50_0[32];
  unsigned int z2_100_0[32];
  unsigned int t0[32];
  unsigned int t1[32];
  int i;

  /* 2 */ square(z2, z);
  /* 4 */ square(t1, z2);
  /* 8 */ square(t0, t1);
  /* 9 */ mult(z9, t0, z);
  /* 11 */ mult(z11, z9, z2);
  /* 22 */ square(t0, z11);
  /* 2^5 - 2^0 = 31 */ mult(z2_5_0, t0, z9);

  /* 2^6 - 2^1 */ square(t0, z2_5_0);
  /* 2^7 - 2^2 */ square(t1, t0);
  /* 2^8 - 2^3 */ square(t0, t1);
  /* 2^9 - 2^4 */ square(t1, t0);
  /* 2^10 - 2^5 */ square(t0, t1);
  /* 2^10 - 2^0 */ mult(z2_10_0, t0, z2_5_0);

  /* 2^11 - 2^1 */ square(t0, z2_10_0);
  /* 2^12 - 2^2 */ square(t1, t0);
  /* 2^20 - 2^10 */ for (i = 2; i < 10; i += 2) {
    square(t0, t1);
    square(t1, t0);
  }
  /* 2^20 - 2^0 */ mult(z2_20_0, t1, z2_10_0);

  /* 2^21 - 2^1 */ square(t0, z2_20_0);
  /* 2^22 - 2^2 */ square(t1, t0);
  /* 2^40 - 2^20 */ for (i = 2; i < 20; i += 2) {
    square(t0, t1);
    square(t1, t0);
  }
  /* 2^40 - 2^0 */ mult(t0, t1, z2_20_0);

  /* 2^41 - 2^1 */ square(t1, t0);
  /* 2^42 - 2^2 */ square(t0, t1);
  /* 2^50 - 2^10 */ for (i = 2; i < 10; i += 2) {
    square(t1, t0);
    square(t0, t1);
  }
  /* 2^50 - 2^0 */ mult(z2_50_0, t0, z2_10_0);

  /* 2^51 - 2^1 */ square(t0, z2_50_0);
  /* 2^52 - 2^2 */ square(t1, t0);
  /* 2^100 - 2^50 */ for (i = 2; i < 50; i += 2) {
    square(t0, t1);
    square(t1, t0);
  }
  /* 2^100 - 2^0 */ mult(z2_100_0, t1, z2_50_0);

  /* 2^101 - 2^1 */ square(t1, z2_100_0);
  /* 2^102 - 2^2 */ square(t0, t1);
  /* 2^200 - 2^100 */ for (i = 2; i < 100; i += 2) {
    square(t1, t0);
    square(t0, t1);
  }
  /* 2^200 - 2^0 */ mult(t1, t0, z2_100_0);

  /* 2^201 - 2^1 */ square(t0, t1);
  /* 2^202 - 2^2 */ square(t1, t0);
  /* 2^250 - 2^50 */ for (i = 2; i < 50; i += 2) {
    square(t0, t1);
    square(t1, t0);
  }
  /* 2^250 - 2^0 */ mult(t0, t1, z2_50_0);

  /* 2^251 - 2^1 */ square(t1, t0);
  /* 2^252 - 2^2 */ square(t0, t1);
  /* 2^253 - 2^3 */ square(t1, t0);
  /* 2^254 - 2^4 */ square(t0, t1);
  /* 2^255 - 2^5 */ square(t1, t0);
  /* 2^255 - 21 */ mult(out, t1, z11);
}

void convert_to_radix226(unsigned int *r, unsigned char *k) {
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
}

int crypto_scalarmult(unsigned char *q, const unsigned char *n,
                      const unsigned char *p) {
  unsigned int work[96];
  unsigned char e[32];
  unsigned int i;
  for (i = 0; i < 32; ++i)
    e[i] = n[i];
  e[0] &= 248;
  e[31] &= 127;
  e[31] |= 64;

  unsigned int er[10];
  convert_to_radix226(er, e);

  for(int i2=0;i2<10;++i2){
    printf("%x, ", er[i2]);
  }
  printf("\n");

  for (i = 0; i < 32; ++i)
    work[i] = p[i];
  printf("before mainloop\n");
  mainloop(work, e);
  printf("passed mainloop\n");
  recip(work + 32, work + 32);
  mult(work + 64, work, work + 32);
  freeze(work + 64);
  for (i = 0; i < 32; ++i)
    q[i] = work[64 + i];
  return 0;
}
