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

void seekmkf(FILE* fp,int n)
{
	long offset;
	fseek(fp,4*n,SEEK_SET);
	offset=fget32(fp);
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
	int len;
	int vx,vy;
	char filename[12];
			
	BITMAP* bmp=create_bitmap(1,1);
	PALETTE pal;
	
	FILE* fp=fopen(argv[1],"rb");
	FILE* fppat=fopen("pat.mkf","rb");
	
	if((fp==NULL)||(fppat==NULL))	
	{
		printf("Usage:rle *.mkf");
		exit(-1);
	}
	
	maps=fget32(fp)/4-1,pats=fget32(fppat)/4-1;	
	
	argv[1][strlen(argv[1])-4]='\0';

	allegro_init();
	set_gfx_mode(GFX_VGA,320,200,0,0);
	install_keyboard();
	atexit(allegro_exit);

	while(running)
	{		
		//render a frame
		if(mapchg)
		{
			
			seekmkf(fp,map);
			fseek(fp,4,SEEK_CUR);
			width=fget16(fp),height=fget16(fp);
			vx=(320-width)/2,vy=(200-height)/2;
			destroy_bitmap(bmp);
			bmp=create_bitmap(width,height);
			clear(screen);
			for(i=0;i<width*height;)
			{
				data=fget8(fp);
				rle0=data>0x80?1:0;
				t=i;
				if(rle0)
					for(;i<t+data-0x80;i++)
						putpixel(bmp,i%width,i/width,0);
				else
					for(;i<t+data;i++)
						putpixel(bmp,i%width,i/width,fget8(fp));
			}
			blit(bmp, screen, 0, 0, vx, vy, width, height);
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
		case KEY_S:
			sprintf(filename,"%s-%d.bmp",argv[1],map);
			save_bmp(filename,bmp,pal);
			break;
		}
	}
	//finalize
	destroy_bitmap(bmp);
	fclose(fp);fclose(fppat);
	return 0;
}