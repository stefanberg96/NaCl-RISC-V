#include <stdio.h>
#include <stdint.h>

void karatsuba226_2(unsigned int out[4], const unsigned int a[2], const unsigned int b[2]);

extern unsigned int* getsp();
int crypto_onetimeauth(unsigned char *out, const unsigned char *in,
                       unsigned long long inlen, const unsigned char *k); 
