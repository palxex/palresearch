#include <stdio.h>
#include <stdlib.h>
#include <allegro.h>

#include "deyj1.h"

inline unsigned char fget8(FILE* fp)
{
	unsigned char a=0;
	fread((void*)&a,1,1,fp);
	return a;
}
inline unsigned short fget16(FILE* fp)
{	
	unsigned short a=fget8(fp);
	unsigned short b=fget8(fp);
	b<<=8;
	return a|b;
}
inline unsigned long fget32(FILE* fp)
{	
	unsigned long a=fget16(fp);
	unsigned long b=fget16(fp)<<16;
	return a|b;
}

long seekmkf(FILE* fp,int n)
{
	long offset,length;
	fseek(fp,4*n,SEEK_SET);
	offset=fget32(fp);
	length=fget32(fp)-offset;fseek(fp,-4,SEEK_CUR);
	fseek(fp,offset,SEEK_SET);
	return length; 
}

byte *seeksub(byte *x,int n)
{
	long offset;
	long t;
	offset=((word16*)x)[n]*2;
	return x+offset;
}

int main(int argc,char* argv[])
{	
	int map=0,pat=0;
	int maps,pats;
	int mapchg=1,patchg=1;
	int width,height;
	int rle0,data,i,j,t;
	int running=1;
	int len;	
	char filename[12];
	byte *buf=(byte*)malloc(0xA000),
	     *here;
	
	BITMAP* bmp;
	PALETTE pal;
	unsigned char* pix=(unsigned char*)malloc(1);
	
	FILE* fp=fopen("fbp.mkf","rb");
	FILE* fppat=fopen("pat.mkf","rb");
		
	if((fp==NULL)||(fppat==NULL))	
	{
		printf("Usage:rle *.mkf");
		exit(-1);
	}
	maps=fget32(fp)/4-1,pats=fget32(fppat)/4-1;	
	
	//*(strrchr(argv[1],'.'))='\0';
	
	allegro_init();
	set_gfx_mode(GFX_AUTODETECT_WINDOWED,320,200,0,0);
	install_keyboard();

	bmp=create_bitmap(320,200);
	
	while(running)
	{		
		//render a frame
		if(mapchg)
		{
			len=seekmkf(fp,map);
			fread(buf,len,1,fp);
			deyj1(&buf);
			width=320,height=200;
			for(j=0;j<height;j++)
				for(i=0;i<width;i++)
					_putpixel(bmp,i,j,buf[j*width+i]);
			blit(bmp, screen, 0, 0, 0, 0, 320, 200);
			mapchg=0;
		}
		
		//change a palette
		if(patchg)
		{
			seekmkf(fppat,pat);
			for(i=0;i<256;i++)
			{
				pal[i].r=fget8(fppat);
				pal[i].g=fget8(fppat);
				pal[i].b=fget8(fppat);
			}
			set_palette(pal);
			patchg=0;
		}
		
		//Event handling
		while(!keypressed())	rest(50000);
		switch(readkey()>>8) {
		case KEY_DOWN:
			map=(map+1>=maps)?map:map+1;
			mapchg=1;
			break;
		case KEY_RIGHT:
			pat=(pat+1>=pats)?pat:pat+1;
			patchg=1;
			break;
		case KEY_UP:
			map=(map-1<0)?0:map-1;
			mapchg=1;
			break;
		case KEY_LEFT:
			pat=(pat-1<0)?0:pat-1;
			patchg=1;
			break;
		case KEY_ESC:
			running=0;
			break;
		case KEY_S:
			sprintf(filename,"%s-%d.bmp",argv[1],map);
			save_bmp(filename,bmp,pal);
			break;
		}
		rest(10);
	}
	//finalize
	//free(buf);
	fclose(fp);fclose(fppat);
	return 0;
}
END_OF_MAIN()

