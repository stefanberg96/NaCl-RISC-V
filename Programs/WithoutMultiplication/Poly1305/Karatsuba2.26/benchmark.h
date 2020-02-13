#include <stdint.h>
#include "onetime_auth.h"

extern uint32_t getcycles();
void dobenchmark(uint64_t *timings, unsigned char output[16]);
