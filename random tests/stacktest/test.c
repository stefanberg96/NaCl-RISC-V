#include <stdint.h>
#include <stdio.h>

extern void stackTest(unsigned int ta[17]);//, unsigned int tb[17]);
extern uint32_t securemul(unsigned char a, unsigned char b);

void print32bytes(unsigned int a){
   printf("%x\n",a);
}

void printalive(){
  printf("ALIVE\n");
}

int main() {
  unsigned int testArray[17]={0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16};

  stackTest(testArray);

  for(int i=0;i<17;i++){
    printf(", %d",testArray[i]);
  }

  printf("\n");
  return 0;
}
