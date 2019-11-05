#include <stdint.h>
#include <stdio.h>
#include <string.h>
#define FIELD_SIZEOF(t, f) (sizeof(((t *)0)->f))
extern uint32_t getcycles();
extern uint32_t securemul(unsigned char a, unsigned char b);
extern void onetime_authloop(const unsigned char *in, int inlen,
                             unsigned int *h, unsigned int *r, unsigned int *c);
extern void addasm(unsigned int h[17], const unsigned int c[17]);
extern int getsp();

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

typedef struct params {
  unsigned char output[16];
  unsigned char message[131];
  int messageLen;
  unsigned char key[32];
} Params;

void createTestCases(Params *testCases) {
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

   unsigned int sp =getsp();  
   printf("%x\n", sp);

  testCases[0].messageLen = 131;
  memcpy(testCases[0].message, c, FIELD_SIZEOF(Params, message));
  memcpy(testCases[0].key, rs, FIELD_SIZEOF(Params, key));

  testCases[1].messageLen = 131;
  memcpy(testCases[1].message, c, FIELD_SIZEOF(Params, message));
  //  testCases[1].message[115] = 0x00;
  memcpy(testCases[1].key, rs, FIELD_SIZEOF(Params, key));
  
/*
  testCases[2].messageLen = 131;
  memcpy(testCases[2].message, c, FIELD_SIZEOF(Params, message));
  memcpy(testCases[2].key, rs, FIELD_SIZEOF(Params, key));**/
}

void dobenchmark(uint64_t *timings, Params *testCases, int testCasesCount) {

  unsigned int sp =getsp();  
  printf("%x\n", sp);

  uint32_t oldcount, newcount;
  for (int i = 0; i < testCasesCount; i++) {
    Params testCase = testCases[i];
    oldcount = getcycles();
    crypto_onetimeauth(&testCase.output[0], &testCase.message[0],
                       testCase.messageLen, &testCase.key[0]);
    newcount = getcycles();
    timings[i] = newcount - oldcount;
  }
  return;
}

int main() {
  unsigned int sp =getsp();  
  printf("%x\n", sp);
  Params testCases[1];

  uint64_t timing[1];
  createTestCases(&testCases[0]);

  dobenchmark(&timing[0], &testCases[0], 1);
  dobenchmark(&timing[0], &testCases[0], 1);
  dobenchmark(&timing[0], &testCases[0], 1);
  for (int i = 0; i < 1; i++) {
    printf("This took %llu cycles\n", timing[i]);
  }
  return 0;
}