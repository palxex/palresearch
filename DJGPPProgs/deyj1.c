#include <stdio.h>
#include <stdlib.h>

#include "reg.h"
extern int DecodeYJ1(const void*, void**, dword32*);
void deyj1( byte** ppbuf, unsigned long *length )
{
	void *pbuf = malloc( 0x10000 );
	DecodeYJ1( *ppbuf, &pbuf, length );
	free( *ppbuf );
	*ppbuf = pbuf;
}

int main(int argc,char* argv[])
{	
	int map=0,pat=0;
	int maps,pats;
	int mapchg=1,patchg=1;
	int width,height;
	int rle0,data,i,j,t;
	int running=1;
	int len,ext_len;	
	char filename[12];
	byte *buf=(byte*)malloc(0xA000),
	     *here;
		
	FILE* fp=fopen(argv[1],"rb");
	FILE* fpout=fopen(argv[2],"wb");
		
	if((fp==NULL)||(fpout==NULL))	
	{
		printf("Usage:deyj1 source destination\n");
		exit(-1);
	}
	fseek(fp,0,SEEK_END);
	len = ftell(fp);
	rewind(fp);
	fread(buf,len,1,fp);
	fclose(fp);
	deyj1(&buf,&ext_len);
	fwrite(buf,ext_len,1,fpout);
	fclose(fpout);
}