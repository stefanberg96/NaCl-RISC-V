#include <stdio.h>
#include <stdint.h>

extern void onetime_authloopasm(const unsigned char *in, int inlen,
                             unsigned int *h, unsigned int *r, unsigned int *c);
extern void addasm(unsigned int h[17], const unsigned int c[17]);
extern void add226asm(unsigned int h[9], const unsigned int c[9]);
extern void toradix28asm(unsigned int h[17]);
extern void squeeze226asm(unsigned int h[9]);
extern void mulmod216asm(unsigned int h[9], unsigned int r[9]);
extern unsigned int* getsp();


int crypto_onetimeauth(unsigned char *out, const unsigned char *in,
                       unsigned long long inlen, const unsigned char *k); 
