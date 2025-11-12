#include <stdio.h>
int check(int a){
  if(a==1234) printf("ok\n");
  else printf("no\n");
}
int main(){ check(5678); return 0; }