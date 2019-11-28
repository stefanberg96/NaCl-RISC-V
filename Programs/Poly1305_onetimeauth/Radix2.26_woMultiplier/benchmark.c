#include "benchmark.h"

    void dobenchmark() {
static unsigned int a = 7;
static unsigned int b = 1;

        uint32_t timings[21];
        for(int i =0;i<21;i++){
            timings[i]=getcycles();
            securemul226(a,b);
        }

        for(int i=1;i<21;i++){
            printf("%d, ",timings[i]-timings[i-1]);
        }
        printf("\n");
        uint64_t output = securemul226(a,b);
        printf("0x%llx\n", output);
    }
