#include <stdint.h>
#include "scalarmult.h"

extern uint32_t getcycles();
extern void icachemisses();
extern void crypto_scalarmult_asm(unsigned char *, const unsigned char*, const unsigned char*);
void dobenchmark();
