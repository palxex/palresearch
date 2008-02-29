#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <malloc.h>
#define MAXEXT 3
char* pre;
char ext[MAXEXT+1];
char name[11];
void usage()
{
	printf("Usage:cut sam.mkf ext\n");
	exit(-1);
}
void getname(int i)
{
	char a[3];
	strcpy(name,pre);
	strcat(name,(const char *)itoa(i,a,10));
	strcat(name,".");
	strcat(name,ext);
}
main(int c,char* v[])
{
	FILE *fpsrc;FILE *fpdst;
	long ptr1,ptr2,i,length,t;
	char* tc;
	void* buf;
	if(c!=3)	usage();
	strcpy(ext,v[2]);
	if((fpsrc=fopen(v[1],"rb"))==NULL) 	usage();
	tc=strchr(v[1],'.');	*tc='\0';	pre=v[1];
	fread(&length,4,1,fpsrc);
	t=length/4;
	for(i=0;i<t-1;i++)
	{
		fseek(fpsrc,4*i,0);
		fread(&ptr1,4,1,fpsrc);
		fread(&ptr2,4,1,fpsrc);
		fseek(fpsrc,ptr1,0);
		getname(i);
		fpdst=fopen(name,"wb+");

		length=ptr2-ptr1;
		buf=(void*)malloc(length);
		fread(buf,length,1,fpsrc);
		fwrite(buf,length,1,fpdst);
		fclose(fpdst);
		free(buf);
	}
		getname(t-1);
		fpdst=fopen(name,"wb+");
		fclose(fpdst);
	fclose(fpsrc);
}