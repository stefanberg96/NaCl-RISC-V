#include "benchmark.h"

    void dobenchmark(uint64_t *timings, unsigned char a[16]) {
        static unsigned char c[131] = {0x34, 0x3b, 0xc1, 0x49, 0x41, 0x66, 0x55, 0xd0, 0xb8, 0xb1, 0x67, 0x94, 0x76, 0xd5, 0x88, 0xf8, 0x6f, 0x82, 0xa5, 0x40, 0x27, 0xea, 0x32, 0xae, 0x7d, 0x17, 0xc6, 0x1c, 0x6f, 0x2, 0x80, 0x2d, 0x99, 0xc1, 0xde, 0xcd, 0xb2, 0x1a, 0xa5, 0xa5, 0x4, 0xe9, 0x66, 0xca, 0x87, 0xd7, 0x84, 0x2b, 0x97, 0x55, 0x86, 0x73, 0xa8, 0x44, 0x19, 0x5c, 0x9d, 0xcd, 0x96, 0xc0, 0x1f, 0xb5, 0xd, 0xc1, 0x5e, 0xb, 0x7a, 0x2b, 0x67, 0xfe, 0x42, 0xf9, 0xaf, 0x19, 0xb, 0x80, 0x3e, 0x20, 0x4, 0x83, 0xcc, 0x73, 0x9, 0xe7, 0x6, 0x8b, 0xad, 0xda, 0xa0, 0x46, 0x97, 0x25, 0x1f, 0xae, 0xbf, 0xe2, 0x6e, 0xdf, 0x76, 0xdd, 0x2b, 0xb6, 0xee, 0x12, 0x83, 0x9d, 0x56, 0xad, 0x72, 0xcd, 0xdf, 0x90, 0x9e, 0x4d, 0xd0, 0x1d, 0x19, 0x3e, 0x20, 0x39, 0x1d, 0xeb, 0x6e, 0xf4, 0x2b, 0x98, 0xdc, 0xfb, 0x53, 0x83, 0xca};
        static unsigned char rs[32] = {0x1f, 0xc3, 0xeb, 0x5e, 0xb9, 0xd8, 0x7d, 0xc6, 0xd2, 0x0, 0xef, 0x59, 0xf6, 0xcb, 0x69, 0xa0, 0x61, 0x7b, 0xfc, 0x7d, 0xce, 0x9b, 0xcf, 0x10, 0x19, 0xd, 0xa6, 0x2f, 0x95, 0xe8, 0x95, 0x2d};

        uint32_t oldcount, newcount;
        unsigned char x = 5, y = 10;
        oldcount = getcycles();
        crypto_onetimeauth(a, c, 131, rs);
        newcount = getcycles();
        timings[0] = newcount - oldcount;
    }