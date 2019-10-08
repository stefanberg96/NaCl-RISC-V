#include <stdint.h>
#include <stdio.h>

extern uint32_t getcycles();
extern uint32_t securemul(unsigned char a, unsigned char b);
extern uint32_t mul320(uint32_t a);
extern void squeezeasm(unsigned int h[17]);
extern void mulmodasm(unsigned int h[17], unsigned int r[17]);
extern void onetime_authloop(const unsigned char *in, int inlen,
                             unsigned int *h, unsigned int *r, unsigned int *c);
extern void addasm(unsigned int h[17], const unsigned int c[17]);

void aliveprint() {
  printf("ITS ALIVE!!\n");
  return;
}

void print32bytes(uint32_t x) {
  printf("%x\n", x);
  return;
}

// add the two numbers together without reduction
static void addfunc(unsigned int h[17], const unsigned int c[17]) {
  unsigned int j;
  unsigned int u;
  u = 0;
  for (j = 0; j < 17; ++j) {
    u += h[j] + c[j];
    h[j] = u & 255;
    u >>= 8;
  }
  return;
}

// used in mulmod
static void squeeze(unsigned int h[17]) {
  unsigned int j;
  unsigned int u;
  u = 0;
  for (j = 0; j < 16; ++j) {
    u += h[j];
    h[j] = u & 255;
    u >>= 8;
  }
  u += h[16];
  h[16] = u & 3;
  u >>= 2;
  u = 5 * u;

  for (j = 0; j < 16; ++j) {
    u += h[j];
    h[j] = u & 255;
    u >>= 8;
  }
  u += h[16];
  h[16] = u;
  return;
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
  return;
}

// does multiplication modulo 2^130-5 and result is
// placed in h
static void mulmod(unsigned int h[17], const unsigned int r[17]) {
  unsigned int hr[17];
  unsigned int i;
  unsigned int j;
  unsigned int u;

  for (i = 0; i < 17; ++i) {
    u = 0;
    for (j = 0; j <= i; ++j)
      u += securemul(h[j], r[i - j]);
    for (j = i + 1; j < 17; ++j) {
      unsigned int t = securemul(h[j], r[i + 17 - j]);
      u += mul320(t);
    }
    printf("%x\n", u);
    hr[i] = u;
  }
  for (i = 0; i < 17; ++i)
    h[i] = hr[i];
  squeezeasm(h);
  return;
}

void authloop(unsigned char *in, unsigned long long inlen, unsigned int *h,
              unsigned int *r, unsigned int *c) {
  unsigned int j;
  while (inlen > 0) {
    for (j = 0; j < 17; ++j)
      c[j] = 0; // set c to 0
    for (j = 0; (j < 16) && (j < inlen); ++j)
      c[j] = in[j]; // fill c with a chunk of 16 bytes from the in param
    c[j] = 1;       // append the 1 byte to the chunk
    in += j;
    inlen -= j;      // update loop variants (inlen and increment in pointer)
    addasm(h, c);    // c to the state
    mulmodasm(h, r); // multiply state with the secret key modulo 2^130-5
  }
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
  // authloop(in, inlen, h, r, c);

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

unsigned char rs[32] = {0xee, 0xa6, 0xa7, 0x25, 0x1c, 0x1e, 0x72, 0x91,
                        0x6d, 0x11, 0xc2, 0xcb, 0x21, 0x4d, 0x3c, 0x25,
                        0x25, 0x39, 0x12, 0x1d, 0x8e, 0x23, 0x4e, 0x65,
                        0x2d, 0x65, 0x1f, 0xa4, 0xc8, 0xcf, 0xf8, 0x80};

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

unsigned char expectedResult[16] = {0xf3, 0xff, 0xc7, 0x70, 0x3f, 0x94,
                                    0x00, 0xe5, 0x2a, 0x7d, 0xfb, 0x4b,
                                    0x3d, 0x33, 0x05, 0xd9};
void checkCorrectness() {
  crypto_onetimeauth(a, c, 131, rs);
  int theSame = 0;
  for (int i = 0; i < 16; i++) {
    if (expectedResult[i] != a[i])
      theSame = 1;
  }
  if (theSame) {
    int i;
    printf("They were not the same\n");
    printf("Expected result:\n");
    for (i = 0; i < 16; ++i) {
      printf(",0x%02x", (unsigned int)expectedResult[i]);
      if (i % 8 == 7)
        printf("\n");
    }
    printf("Result:\n");
    for (i = 0; i < 16; ++i) {
      printf(",0x%02x", (unsigned int)a[i]);
      if (i % 8 == 7)
        printf("\n");
    }
  } else {
    printf("They were the same\n");
  }
}

void test() {
  unsigned int test1[17] = {0x2f, 0xf3, 0x24, 0x4d, 0xb9, 0xe2,
                            0x6b, 0x53, 0x49, 0x50, 0x31, 0xcd,
                            0x8e, 0x0a, 0x49, 0x59, 0x76};

  unsigned int test2[17] = {0x10, 0xa3, 0x00, 0x2c, 0xef, 0x0f,
                            0xb8, 0x6a, 0x54, 0xea, 0x92, 0x92,
                            0x49, 0x79, 0x7b, 0xee, 0x1e};

  addasm(test1, test2);

  for (int i = 0; i < 17; i++) {
    printf(",0x%02x", test1[i]);
  }
  printf("\n");
}

uint64_t dobenchmark() {
  unsigned char rs[32] = {0xee, 0xa6, 0xa7, 0x25, 0x1c, 0x1e, 0x72, 0x91,
                          0x6d, 0x11, 0xc2, 0xcb, 0x21, 0x4d, 0x3c, 0x25,
                          0x25, 0x39, 0x12, 0x1d, 0x8e, 0x23, 0x4e, 0x65,
                          0x2d, 0x65, 0x1f, 0xa4, 0xc8, 0xcf, 0xf8, 0x80};

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

  //  unsigned int test1[17] = {0x8e, 0x99, 0x3b, 0x9f, 0x48, 0x68,
  //                            0x12, 0x73, 0xc2, 0x96, 0x50, 0xba,
  //                            0x32, 0xfc, 0x76, 0xce, 0x48};

  //  unsigned int test2[17] = {
  //      0x33, 0x2e, 0xa7, 0x16, 0x4d, 0x96, 0xa4, 0x47, 0x6f,
  //      0xb8, 0xc5, 0x31, 0xa1, 0x18, 0x6a, 0xc0, 0xdf,
  //  };
  uint32_t oldcount, newcount;
  unsigned char x = 5, y = 10;
  oldcount = getcycles();
  crypto_onetimeauth(a, c, 131, rs);
  newcount = getcycles();
  return newcount - oldcount;
}

int main() {
  // test();
  checkCorrectness();
  uint64_t cyclesTaken;
  cyclesTaken = dobenchmark();
  cyclesTaken = dobenchmark();
  do {
    cyclesTaken = dobenchmark();
  } while (cyclesTaken == 306);
  printf("This took %llu cycles\n", cyclesTaken);
  return 0;
}
