#include <stdio.h>
#include <stdlib.h>
#include <algif.h>

#include "deyj1.h"

unsigned char fget8(FILE* fp)
{   
	unsigned char a=0;
	fread((void*)&a,1,1,fp);
	return a;
}
unsigned short fget16(FILE* fp)
{	
	unsigned short a=fget8(fp);
	unsigned short b=fget8(fp);
	b<<=8;
	return a|b;
}
unsigned long fget32(FILE* fp)
{	
	unsigned long a=fget16(fp);
	unsigned long b=fget16(fp)<<16;
	return a|b;
}

void seekmkf(FILE* fp,int n)
{
	long offset;
	long t;
	fseek(fp,4*n,SEEK_SET);
	offset=fget32(fp);
	fseek(fp,offset,SEEK_SET);
}
byte* seeksub(byte* x,int n,int max)
{
	long offset,hack=0;
	offset=((word16*)x)[n]*2;
	if(n>0)	hack=((word16*)x)[n-1]*2;
	if((offset<hack)||(offset>max))
		return NULL;
	else
		return x+offset;
}

int main(int argc,char* argv[])
{	
	int map=0,pat=0,mapgroup=0;
	int maps=-1,pats,mapgroups,pmaps;
	int mapchg=1,patchg=1,mapgroupchg=1;
	int width[0x200],height[0x200];
	int maxw=0,maxh=0;
	int px,py,pw,ph;
	int rle0,data,i,j,t;
	int running=1;
	int len=0,s;
	int max;
	int vx[0x200],vy[0x200];
	char filename[12];
	char tosay[100];
	byte *buf=(byte*)malloc(0x12000),
	     *here;
	
	GIF_ANIMATION *gif;

	static BITMAP *bmp[0x200];
	BITMAP *tb=create_bitmap(320,200);
	PALETTE pal;
	
	FILE* fp=fopen(argv[1],"rb");
	FILE* fppat=fopen("pat.mkf","rb");
	
	if((fp==NULL)||(fppat==NULL))
	{
		printf("Usage:rle *.mkf");
		exit(-1);
	}
	
	*(strrchr(argv[1],'.'))='\0';
	
	mapgroups=fget32(fp)/4-2,pats=fget32(fppat)/4-2;
	clear(tb);
	
	allegro_init();
	set_gfx_mode(GFX_VGA,320,200,0,0);
	install_keyboard();
	atexit(allegro_exit);

	while(running)
	{		
		if(mapgroupchg)
		{	
			maxw=maxh=0;
			seekmkf(fp,mapgroup);s=ftell(fp);
			seekmkf(fp,mapgroup+1);len=ftell(fp)-s;
			if(len==0)
			{
				mapgroupchg=mapchg=1;
				map=0;
				mapgroup++;
				continue;
			}
			else
			{
				fseek(fp,s,SEEK_SET);
				fread(buf,len,1,fp);
				max=*(int*)(buf+4);
				deyj1(&buf);
				pmaps=maps;
				maps=(*(short*)(buf))-1;
				map=0;
				mapchg=1;
				mapgroupchg=0;
				for(j=0;j<=maps;j++)
				{
					if((here=seeksub(buf,j,max))==NULL)
					{
						maps=j-1;break;
					}
					width[j]=*(short*)(here),height[j]=*(short*)(here+2);
					if(width[j]>maxw) maxw=width[j];
					if(height[j]>maxh) maxh=height[j];
					vx[j]=(320-width[j])/2,vy[j]=(200-height[j])/2;
					here+=4;
					if(j<=pmaps) destroy_bitmap(bmp[j]);
					bmp[j]=create_bitmap(width[j],height[j]);
					for(i=0;i<width[j]*height[j];)
					{
						data=*here++;
						rle0=data>0x80?1:0;
						t=i;
						if(rle0)
							for(;i<t+data-0x80;i++)
								_putpixel(bmp[j],i%width[j],i/width[j],0);
						else
							for(;i<t+data;i++)
								_putpixel(bmp[j],i%width[j],i/width[j],*here++);
					}
				}
				blit(tb,screen,0,0,0,0,320,200);
			}
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
		
		//render a frame
		if(mapchg)
		{
			if((vx[map]>px)||(vy[map]>py)||(width[map]<pw)||(height[map]<ph))
				blit(tb,screen,0,0,0,0,320,200);
			px=vx[map],py=vy[map],pw=width[map],ph=height[map];
			blit(bmp[map], screen, 0, 0, px, py, pw, ph);
			mapchg=0;
		}
		
		textprintf_ex(screen,font,0,0,0xFF,0,"group:%x,id:%x,pat:%x",mapgroup,map,pat);			

		//Event handling
		while(!keypressed())	rest(100000);
		switch(readkey()>>8) {
		case KEY_DOWN:
			map=(map+1)%(maps+1);
			mapchg=1;
			if(!map)	
				blit(tb,screen,0,0,0,0,320,200);
			break;
		case KEY_RIGHT:
			pat=(pat+1>pats)?pat:pat+1;
			patchg=1;
			break;
		case KEY_PGDN:
			mapgroup=(mapgroup+1>mapgroups)?mapgroup:mapgroup+1;
			mapgroupchg=1;
			break;
		case KEY_UP:
			map=(map-1<0)?maps:map-1;
			mapchg=1;
			break;
		case KEY_LEFT:
			pat=(pat-1<0)?0:pat-1;
			patchg=1;
			break;
		case KEY_PGUP:
			mapgroup=(mapgroup-1<0)?mapgroup:mapgroup-1;
			mapgroupchg=1;
			break;
		case KEY_ESC:
			running=0;
			break;
		case KEY_S:
			gif=algif_create_raw_animation(maps+1);
			gif->width=gif->height=gif->loop=0;
			gif->palette.colors_count=256;
			memcpy(gif->palette.colors,pal,sizeof(PALETTE));
			for(i=0;i<256;i++)
			{
				gif->palette.colors[i].r<<=2;
				gif->palette.colors[i].g<<=2;
				gif->palette.colors[i].b<<=2;
			}
			for(i=0;i<=maps;i++)
			{
				gif->frames[i].xoff = 0;
	    	  		gif->frames[i].yoff = 0;
	    	  		gif->frames[i].duration = 5; // 0.1s 
	    			gif->frames[i].disposal_method = 2; // not dispose
		  		gif->frames[i].bitmap_8_bit = create_bitmap(maxw,maxh);
		  	  	clear_to_color(gif->frames[i].bitmap_8_bit,0xff);
				here=seeksub(buf,i,max);
				here+=4;
				for(j=0;j<width[i]*height[i];)
				{
					data=*here++;
					rle0=data>0x80?1:0;
					t=j;
					if(rle0)
						for(;j<t+data-0x80;j++)
							_putpixel(gif->frames[i].bitmap_8_bit,j%width[i],j/width[i],0xff);					else
						for(;j<t+data;j++)
							_putpixel(gif->frames[i].bitmap_8_bit,j%width[i],j/width[i],*here++);
				}
				gif->frames[i].transparent_index = 0xff;
			}	
			sprintf(filename,"%s-%d.gif",argv[1],mapgroup);
			algif_save_raw_animation (filename,gif);
			algif_destroy_raw_animation (gif);
			sprintf(filename,"");
			break;
		}
	}
	//finalize
	destroy_bitmap(tb);
	for(i=0;i<maps;i++)
		destroy_bitmap(bmp[i]);
	fclose(fp);fclose(fppat);
	free(buf);
	return 0;
}
