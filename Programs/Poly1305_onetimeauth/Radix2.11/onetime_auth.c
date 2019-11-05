#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>

#define FIELD_SIZEOF(t, f) (sizeof(((t *)0)->f))

extern uint32_t getcycles();
extern void onetime_authloop(const unsigned char *in, int inlen,
                             unsigned int *h, unsigned int *r, unsigned int *c);
extern void addasm(unsigned int h[17], const unsigned int c[17]);
extern int getsp();


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

static void squeeze216(unsigned int h[9]) {
  unsigned int j;
  int64_t u;
  u = 0;
  for (j = 0; j < 8; j++) {
    u += h[j];
    h[j] = u & 0xFFFF;
    u >>= 16;
  }
  u += h[8];
  h[8] = u & 3;

  u = 5 * (u >> 2);
  for (j = 0; j < 8; ++j) {
    u += h[j];
    h[j] = u & 0xFFFF;
    u >>= 16;
  }
  u += h[8];
  h[8] = u;
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
  squeeze216(h);
}

static void toradix216int(unsigned int *out, const unsigned int *in,
                          int inlen) {
  int i;
  for (i = 0; 2 * i < inlen; i++) {
    out[i] = in[2 * i];
    out[i] += in[2 * i + 1] << 8;
  }

  if (inlen & 1) {
    out[i] = in[2 * i];
  }
  return;
}

static void toradix216(unsigned int *out, const unsigned char *in, unsigned long long inlen) {
  int i;
  for (i = 0; 2 * i < inlen; i++) {
    out[i] = in[2 * i];
    out[i] += in[2 * i + 1] << 8;
  }

  if (inlen & 1)
    out[i] = in[inlen - 1];
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
  // set the state to 0
  for (j = 0; j < 17; ++j)
    h[j] = 0;
  unsigned int in216[(inlen >> 1) + 1];
  unsigned int* in216p = &in216[0];
  unsigned int r216[9];
  unsigned int c216[9];
  for (j = 0; j < 9; j++)
    c216[j] = 0;
  // turn into radix 2^16
  toradix216(&in216[0], in, inlen);
  toradix216int(&r216[0], &r[0], 17);

  while (inlen > 0) {
    for (j = 0; j < 9; ++j)
      c216[j] = 0; // set c to 0
    for (j = 0; (j < 8) && (inlen >2); ++j, inlen-=2)
      c216[j] = in216p[j]; // fill c with a chunk of 16 bytes from the in param

    if (inlen==1 && j!=8) {
      c216[j]=in216p[j];
      c216[j] += 1 << 8;
      inlen--;
    } else {
      c216[j] = 1;
    }
    in216p += j;
    add216(h, c216);    // c to the state
    mulmod216(h, r216); // multiply state with the secret key modulo 2^130-5
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

typedef struct params {
  unsigned char output[16];
  unsigned char message[131];
  int messageLen;
  unsigned char key[32];
} Params;

void copy(unsigned char *out, const unsigned char *in, int inlen) {
  for (int i = 0; i < inlen; i++) {
    out[i] = in[i];
  }
}

void copyint(unsigned int *out, const unsigned char *in, int inlen) {
  for (int i = 0; i < inlen; i++) {
    out[i] = in[i];
  }
}

void dobenchmark(uint64_t *timings) {
  unsigned char rs[32] = {0xee, 0xa6, 0xa7, 0x25, 0x1c, 0x1e, 0x72, 0x91,
                          0x6d, 0x11, 0xc2, 0xcb, 0x21, 0x4d, 0x3c, 0x25,
                          0x25, 0x39, 0x12, 0x1d, 0x8e, 0x23, 0x4e, 0x65,
                          0x2d, 0x65, 0x1f, 0xa4, 0xc8, 0xcf, 0xf8, 0x80};

  unsigned char c2[131] = {
      0x8e, 0x99, 0x3b, 0x9f, 0x48, 0x68, 0x12, 0x73, 0xc2, 0x96, 0x50, 0xba,
      0x32, 0xfc, 0x76, 0xce, 0x48, 0x33, 0x2e, 0xa7, 0x16, 0x4d, 0x96, 0xa4,
      0x47, 0x6f, 0xb8, 0xc5, 0x31, 0xa1, 0x18, 0x6a, 0xc0, 0xdf, 0xc1, 0x7c,
      0x98, 0xdc, 0xe8, 0x7b, 0x4d, 0xa7, 0xf0, 0x11, 0xec, 0x48, 0xc9, 0x72,
      0x71, 0xd2, 0xc2, 0x0f, 0x9b, 0x92, 0x8f, 0xe2, 0x27, 0x0d, 0x6f, 0xb8,
      0x63, 0xd5, 0x17, 0x38, 0xb4, 0x8e, 0xee, 0xe3, 0x14, 0xa7, 0xcc, 0x8a,
      0xb9, 0x32, 0x16, 0x45, 0x48, 0xe5, 0x26, 0xae, 0x90, 0x22, 0x43, 0x68,
      0x51, 0x7a, 0xcf, 0xea, 0xbd, 0x6b, 0xb3, 0x73, 0x2b, 0xc0, 0xe9, 0xda,
      0x99, 0x83, 0x2b, 0x61, 0xca, 0x01, 0xb6, 0xde, 0x56, 0x24, 0x4a, 0x9e,
      0x88, 0xd5, 0xf9, 0xb3, 0x79, 0x73, 0xf6, 0x22, 0xa4, 0x3d, 0x14, 0xa6,
      0x59, 0x9b, 0x1f, 0x65, 0x4c, 0xb4, 0x5a, 0x74, 0xe3, 0x55, 0xa5};

  unsigned char c[131] = {
      0x8e, 0x99, 0x3b, 0x9f, 0x48, 0x68, 0x12, 0x73, 0xc2, 0x96, 0x50, 0xba,
      0x32, 0xfc, 0x76, 0xce, 0x48, 0x33, 0x2e, 0xa7, 0x16, 0x4d, 0x96, 0xa4,
      0x47, 0x6f, 0xb8, 0xc5, 0x31, 0xa1, 0x18, 0x6a, 0xc0, 0xdf, 0xc1, 0x7c,
      0x98, 0xdc, 0xe8, 0x7b, 0x4d, 0xa7, 0xf0, 0x11, 0xec, 0x48, 0xc9, 0x72,
      0x71, 0xd2, 0xc2, 0x0f, 0x9b, 0x92, 0x8f, 0xe2, 0x27, 0x0d, 0x6f, 0xb8,
      0x63, 0xd5, 0x17, 0x38, 0xb4, 0x8e, 0xee, 0xe3, 0x14, 0xa7, 0xcc, 0x8a,
      0xb9, 0x32, 0x16, 0x45, 0x48, 0xe5, 0x26, 0xae, 0x90, 0x22, 0x43, 0x68,
      0x51, 0x7a, 0xcf, 0xea, 0xbd, 0x6b, 0xb3, 0x73, 0x2b, 0xc0, 0xe9, 0xda,
      0x99, 0x83, 0x2b, 0x61, 0xca, 0x01, 0xb6, 0xde, 0x56, 0x24, 0x4a, 0x9e,
      0x88, 0xd5, 0xf9, 0xb3, 0x79, 0x73, 0xf6, 0x22, 0xa4, 0x3d, 0x14, 0xa6,
      0x59, 0x9b, 0x1f, 0x65, 0x4c, 0xb4, 0x5a, 0x74, 0xe3, 0x55, 0xa5};
  unsigned char a[16];

  uint32_t oldcount, newcount;
  unsigned char x = 5, y = 10;
  oldcount = getcycles();
  crypto_onetimeauth(a, c, 131, rs);
  newcount = getcycles();
  timings[0] = newcount - oldcount;
}

int main() {
  printf("Hello\n");
  uint64_t timing[3];
  dobenchmark(&timing[0]);
  dobenchmark(&timing[1]);
  dobenchmark(&timing[2]);
  for (int i = 0; i < 3; i++) {
    printf("This took %llu cycles\n", timing[i]);
  }
  return 0;
}
