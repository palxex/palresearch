#include <stdio.h>
#include <stdlib.h>
#include <allegro.h>

/*__forceinline*/ unsigned char fget8(FILE* fp)
{   
	unsigned char a=0;
	fread((void*)&a,1,1,fp);
	return a;
}
/*__forceinline*/ unsigned short fget16(FILE* fp)
{	
	unsigned short a=fget8(fp);
	unsigned short b=fget8(fp);
	b<<=8;
	return a|b;
}
/*__forceinline*/ unsigned long fget32(FILE* fp)
{	
	unsigned long a=fget16(fp);
	unsigned long b=fget16(fp)<<16;
	return a|b;
}

void seeksubmkf(FILE* fp,int n)
{
	long offset;
	long t;
	fseek(fp,2*n,SEEK_SET);
	offset=fget16(fp);
	fseek(fp,offset*2,SEEK_SET);
}

void seekmkf(FILE* fp,int n)
{
	long offset;
	long t;
	fseek(fp,4*n,SEEK_SET);
	offset=fget16(fp);
	fseek(fp,offset,SEEK_SET);
}
int main(int argc,char* argv[])
{	
	int map=0,pat=0;
	int maps,pats;
	int mapchg=1,patchg=1;
	int width,height;
	int rle0,data,i,t;
	int running=1;
	int vx=20,vy=20;
			
	PALETTE pal;
	unsigned char* pix=(unsigned char*)malloc(1);
	
	FILE* fp=fopen(argv[1],"rb");
	FILE* fppat=fopen("pat.mkf","rb");
	
	if((fp==NULL)||(fppat==NULL))
		printf("not opened"),exit(-1);
	maps=fget16(fp)-1,pats=fget32(fppat)/4-1;
	
	allegro_init();
	set_gfx_mode(GFX_VGA,320,200,0,0);
	install_keyboard();
	atexit(allegro_exit);

	while(running)
	{	
		
		//render a frame
		if(mapchg)
		{
			seeksubmkf(fp,map);
			width=fget16(fp),height=fget16(fp);
			clear(screen);
			for(i=0;i<width*height;)
			{
				data=fget8(fp);
				rle0=data>0x80?1:0;
				t=i;
				if(rle0)
					for(;i<t+data-0x80;i++)
						putpixel(screen,vx+i%width,vy+i/width,0);
				else
					for(;i<t+data;i++)
						putpixel(screen,vx+i%width,vy+i/width,fget8(fp));
			}
			mapchg=0;
		}
		
		//change a palette
		if(patchg)
		{
			seekmkf(fppat,pat);
			for(i=0;i<256;i++)
			{	pal[i].r=fget8(fppat);
				pal[i].g=fget8(fppat);
				pal[i].b=fget8(fppat);
			}
			set_palette(pal);
			patchg=0;
		}
		//Event handling
		while(!keypressed())	rest(100000);
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
		}
	}
	//finalize
	fclose(fp);fclose(fppat);
	return 0;
}