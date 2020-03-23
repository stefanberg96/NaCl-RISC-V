#include <stdio.h>
#include <stdint.h>

void karatsuba226(unsigned int out[5], const unsigned int a[5], const unsigned int b[5]);

extern unsigned int* getsp();
int crypto_onetimeauth(unsigned char *out, const unsigned char *in,
                       unsigned long long inlen, const unsigned char *k); 
