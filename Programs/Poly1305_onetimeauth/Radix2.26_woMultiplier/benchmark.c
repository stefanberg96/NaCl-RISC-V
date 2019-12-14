#include "benchmark.h"
extern void icachemisses(); 

void printintarray(unsigned int *a, int initialoffset){

	for(int i = initialoffset+3; i < 21*3;i+=3){
		printf("%6u, ", a[i]-a[i-3]);
	}
	printf("\n");
}

    void dobenchmark() {

    unsigned char a[16];
        static unsigned char c[135] = {0xe8, 0x8e, 0x1b, 0x64, 0xaf, 0x59, 0x23, 0xa5, 0xa4, 0xc1, 0xc3, 0xb9, 0x18, 0x51, 0x37, 0xdc, 0x57, 0xab, 0xd9, 0x56, 0x17, 0x47, 0x21, 0x15, 0x77, 0xbf, 0xa5, 0x27, 0x75, 0xb4, 0xf7, 0x41, 0xea, 0x1b, 0xe, 0x51, 0xeb, 0x79, 0xe6, 0x32, 0xa, 0xa4, 0x42, 0x84, 0x8b, 0x6a, 0xfc, 0x3f, 0x53, 0xd4, 0xbb, 0xb4, 0x20, 0x2a, 0x94, 0xfe, 0x92, 0x12, 0x4a, 0x23, 0x3d, 0x2e, 0x32, 0xdf, 0x87, 0x3b, 0xc2, 0xb3, 0xbf, 0x3b, 0x84, 0x56, 0xbd, 0x32, 0x65, 0x3c, 0xa1, 0x41, 0x90, 0x0, 0x8f, 0x12, 0x94, 0xe6, 0x3d, 0xa8, 0xf7, 0xf1, 0xd0, 0x89, 0xd4, 0xb8, 0x66, 0x83, 0xf, 0xbf, 0xdc, 0xbb, 0x25, 0x30, 0xf1, 0x65, 0xc1, 0x48, 0x89, 0x61, 0x8c, 0x33, 0xf, 0x61, 0x76, 0x16, 0x9a, 0x22, 0x84, 0x1f, 0xb4, 0xe6, 0xcc, 0xf5, 0xd, 0x5b, 0xcf, 0x9e, 0x34, 0xfc, 0x5c, 0x3e, 0x10, 0xce, 0x6, 0x88, 0xdc, 0xb7, 0x51};
        static unsigned char rs[32] = {0x2b, 0x59, 0xb2, 0xfc, 0xab, 0xb6, 0xe2, 0x2, 0xb2, 0x3c, 0x9a, 0x94, 0xa8, 0xbc, 0x7e, 0x8b, 0x27, 0xf3, 0xa1, 0x0, 0x9c, 0xce, 0xac, 0x83, 0x4d, 0x38, 0xf2, 0xaa, 0x32, 0x16, 0x1c, 0xd2};
	unsigned int counters[3*21];
	icachemisses();

        for(int i =0;i<21;i++){
            getcycles(&counters[i*3]);
            crypto_onetimeauth(a,c,135,rs);
        }
	
	printf("Cycle counts:          ");	
	printintarray(counters, 0);

	printf("Branch dir mis:        ");
	printintarray(counters, 1);
	
	printf("Brach target mis:      ");
	printintarray(counters, 2);

	printf("Result:                ");
	printchararray(a,16);
	printf("\n\n");
    }
