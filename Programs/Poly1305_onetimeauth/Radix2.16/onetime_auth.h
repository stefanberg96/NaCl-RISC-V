#include <stdio.h>
#include <stdint.h>


int crypto_onetimeauth(unsigned char *out, const unsigned char *in,
                       unsigned long long inlen, const unsigned char *k); 
