#include <stdio.h>
#include <stdint.h>

extern void addasm(unsigned int h[17], const unsigned int c[17]);
extern void add226asm(unsigned int h[9], const unsigned int c[9]);
extern void toradix28asm(unsigned int h[17]);
extern void squeeze226asm(unsigned int h[9]);
extern void mulmod226asm(unsigned int h[9], unsigned int r[9]);
extern unsigned int* getsp();
extern int onetimeauth_loop(const unsigned char *in , int inlen, unsigned int *h,
                      unsigned int *r, unsigned int *c);
extern uint64_t securemul226(unsigned int y, unsigned int x);
void toradix28(unsigned int h[17]);
int crypto_onetimeauth(unsigned char *out, const unsigned char *in,
                       unsigned long long inlen, const unsigned char *k); 
extern unsigned int testasm();
