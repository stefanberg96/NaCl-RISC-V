#include <stdio.h>
#include <stdlib.h>

int main(){

  system("make");
  system("timeout 1m make upload");
  return 0;
}
