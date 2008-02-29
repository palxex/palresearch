#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "pallibrary.h"

int main()
{
	const int I=0x38c;
	int file,offset=I;
	unsigned char buffer[65536],index[I];
	char name[18];
	FILE *map=fopen("map\\map.mkf","wb");
	fwrite(index,sizeof(index),1,map);
	for(file=0;file<226;file++)
	{
		fseek(map,file*4,SEEK_SET);
		fwrite(&offset,4,1,map);
		fseek(map,offset,SEEK_SET);
		sprintf(name,"map\\map%04d",file);
		FILE *fpin=fopen(name,"rb");
		int r=fread(buffer,65536,1,fpin);
		fclose(fpin);
		if(r==1){
			PalLibrary::DataBuffer buf=PalLibrary::EncodeYJ_1(buffer,65536);
			fwrite(buf.data,buf.length,1,map);
			delete [](unsigned char*)buf.data;
			offset+=buf.length;
		}
	}
	fseek(map,I-4,SEEK_SET);
	fwrite(&offset,4,1,map);
	fclose(map);
	return 0;
}
