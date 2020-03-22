#include "benchmark.h"

void printarray(unsigned char *in, int inlen) {
  for (int i = 0; i < inlen; i++) {
    printf("%3d, ", in[i]);
  }
  printf("\n");
}

void printcounters(unsigned int *a, int initialoffset) {

  for (int i = initialoffset + 3; i < 21 * 3; i += 3) {
    printf("%6u, ", a[i] - a[i - 3]);
  }
  printf("\n");
}

void convert_to_radix226(unsigned int *r, unsigned char *k) {
  r[0] = k[0] + (k[1] << 8) + (k[2] << 16) + ((k[3] & 3) << 24);
  r[1] = (k[3] >> 2) + (k[4] << 6) + (k[5] << 14) + ((k[6] & 15) << 22);
  r[2] = (k[6] >> 4) + (k[7] << 4) + (k[8] << 12) + ((k[9] & 63) << 20);
  r[3] = (k[9] >> 6) + (k[10] << 2) + ((k[11]) << 10) + (k[12] << 18);
  r[4] = k[13] + (k[14] << 8) + (k[15] << 16) + (k[16] << 24);
}

void dobenchmark() {
  unsigned char k[32] = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216};
  unsigned char in[16] = {101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116};
  unsigned char c[16] = {101,120,112,97,110,100,32,51,50,45,98,121,116,101,32,107};

  unsigned char result[64];

  unsigned int counters[3 * 21];
  icachemisses();

  unsigned char q[32];
  for (int i = 0; i < 21; i++) {
    getcycles(&counters[i * 3]);
    crypto_core(result, in, k, c);
  }

  printf("Cycle counts:          ");
  printcounters(counters, 0);

  printf("Branch dir mis:        ");
  printcounters(counters, 1);

  printf("Branch target mis:    ");
  printcounters(counters, 2);

  printf("Result: ");
  printarray(result, 64);
  printf("\n\n");
}
