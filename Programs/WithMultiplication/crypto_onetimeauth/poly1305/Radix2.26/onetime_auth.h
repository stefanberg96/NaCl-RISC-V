#include <stdio.h>
#include <stdint.h>

extern void addasm(unsigned int h[17], const unsigned int c[17]);
extern void add226asm(unsigned int h[5], const unsigned int c[5]);
extern void add226asm_wo_squeeze(unsigned int h[5], const unsigned int c[5]);
extern void toradix28asm(unsigned int h[17]);
extern void squeeze226asm(unsigned int h[5]);
extern void mulmod226asm(unsigned int h[5], unsigned int r[5]);
extern int onetimeauth_loop(const unsigned char *in , int inlen, unsigned int *h,
                      unsigned int *r, unsigned int *c);
int crypto_onetimeauth(unsigned char *out, const unsigned char *in,
                       unsigned long long inlen, const unsigned char *ki); 
