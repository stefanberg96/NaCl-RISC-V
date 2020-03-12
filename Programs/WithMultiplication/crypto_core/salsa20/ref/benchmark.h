#include <stdint.h>

int crypto_core(unsigned char*,const unsigned char*,const unsigned char*,unsigned char*);
extern uint32_t getcycles();
extern void icachemisses();
void dobenchmark();
