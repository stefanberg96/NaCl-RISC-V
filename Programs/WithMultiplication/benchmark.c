#include "benchmark.h"

void printarray(unsigned char *in, int inlen) {
  for (int i = 0; i < inlen; i++) {
    printf("%02x", in[i]);
  }
  printf("\n");
}

void printcounters(unsigned int *a, int initialoffset) {

  for (int i = initialoffset + 3; i < 21 * 3; i += 3) {
    printf("%6u, ", a[i] - a[i - 3]);
  }
  printf("\n");
}


void dobenchmark() {
  unsigned char k[32] = {0x1b, 0x27, 0x55, 0x64, 0x73, 0xe9, 0x85, 0xd4,
                         0x62, 0xcd, 0x51, 0x19, 0x7a, 0x9a, 0x46, 0xc7,
                         0x60, 0x09, 0x54, 0x9e, 0xac, 0x64, 0x74, 0xf2,
                         0x06, 0xc4, 0xee, 0x08, 0x44, 0xf6, 0x83, 0x89};
  unsigned char in[16] = {0x69, 0x69, 0x6e, 0xe9, 0x55, 0xb6, 0x2b, 0x73,
                          0xcd, 0x62, 0xbd, 0xa8, 0x75, 0xfc, 0x73, 0xd6};
  unsigned char c[16] = {0x65, 0x78, 0x70, 0x61, 0x6e, 0x64, 0x20, 0x33,
                         0x32, 0x2d, 0x62, 0x79, 0x74, 0x65, 0x20, 0x6b};

  unsigned char result[64];

  unsigned int counters[3 * 21];
  icachemisses();

  unsigned char q[32];
  for (int i = 0; i < 21; i++) {
    getcycles(&counters[i * 3]);
    crypto_core_hsalsa20(result, in, k, c);
  }

  printf("Cycle counts:          ");
  printcounters(counters, 0);

  printf("Branch dir mis:        ");
  printcounters(counters, 1);

  printf("Branch target mis:    ");
  printcounters(counters, 2);

  printf("Result: ");
  printarray(result, 32);
  printf("\n\n");
}
