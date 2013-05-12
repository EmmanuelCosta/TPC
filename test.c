
#include<stdio.h>
#include<string.h>
#include<stdlib.h>
int main(void){
	char * string=NULL;
	string=malloc(sizeof(char)*15);
	if(string==NULL)return;

	printf("%s\n",string);
	free(string);
	string=NULL;
	if(string==NULL)
		printf("je suis null\n");
	return 0;
}