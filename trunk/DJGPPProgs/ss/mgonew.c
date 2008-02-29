#include <stdio.h>
#include <stdlib.h>
#include <algif.h>

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
	a<<=8;
	return a|b;
}
inline unsigned long fget32(FILE* fp)
{	
	unsigned long a=fget16(fp)<<16;
	unsigned long b=fget16(fp);
	return a|b;
}
inline unsigned short mget16(byte* x)
{
	word16 a=(*x)<<8;
	word16 b=*(x+1);
	return a|b;
}

long seekmkf(FILE* fp,int n)
{
	long offset,length;
	fseek(fp,2*n,SEEK_SET);
	offset=fget16(fp);
	length=fget16(fp)-offset;fseek(fp,-2,SEEK_CUR);
	offset*=0x800;
	fseek(fp,offset,SEEK_SET);
	return 0; 
}
byte* seeksub(byte* x,int n,int *max,int *width,int *height)
{
	int r=0,i=0,o=0,f=0,no,t;
	while((no=mget16(x+r))<0x100&&no)
		if(i+no<=n){
			r+=2;
			for(t=i;i<t+no;i++,r+=4)
				o+=mget16(x+r)*mget16(x+r+2);
		}
		else if(f){
			i+=no;
			r+=2;
			r+=no*4;
		}
		else{
			r+=2;
			for(t=i;i<n;i++,r+=4)
				o+=mget16(x+r)*mget16(x+r+2);
			*width=mget16(x+r);
			*height=mget16(x+r+2);
			r+=4*(t+no-n);
			i+=t+no-n;
			f=1;
		}
	*max=i;
	//printf("r:%x,o:%x,w:%x,h:%x,max:%x\n",r,o,*width,*height,i);exit(0);
	return x+o+r;
}

int main(int argc,char* argv[])
{	
	int map=0,pat=1,mapgroup=0;
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
	char prefix[8];
	char tosay[100];
	byte *buf=(byte*)malloc(0x200000),
	     *here;
	
	GIF_ANIMATION *gif;
	static BITMAP *bmp[0x200];
	BITMAP *tb=create_bitmap(320,200);
	PALETTE pal;
	
	FILE* fp=fopen("mgo.new","rb");
	FILE* fppat=fopen("alldat.new","rb");
	
	if((fp==NULL)||(fppat==NULL))
	{
		printf("Usage:rle *.mkf");
		exit(-1);
	}
	
	strncpy(prefix,/*strrchr(argv[1],'\\')*/argv[1],8);
	*(strrchr(prefix,'.'))='\0';
	
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
				pmaps=maps;
				maps=mget16(buf);
				map=0;
				mapchg=1;
				mapgroupchg=0;
				for(j=0;j<maps;j++)
				{
					if((here=seeksub(buf,j,&maps,&width[j],&height[j]))==NULL)
					{
						/*maps=j-1;*/break;
					}
					/*width[j]=*(short*)(here),height[j]=*(short*)(here+2);
					if(width[j]>maxw) maxw=width[j];
					if(height[j]>maxh) maxh=height[j];
					here+=4;*/
					vx[j]=(320-width[j])/2,vy[j]=(200-height[j])/2;
					if(j<=pmaps) destroy_bitmap(bmp[j]);
					bmp[j]=create_bitmap(width[j],height[j]);
					for(i=0;i<width[j]*height[j];i++)
						_putpixel(bmp[j],i%width[j],i/width[j],*here++);
				}
				blit(tb,screen,0,0,0,0,320,200);
			}
		}
		
		//change a palette
		if(patchg)
		{
			fseek(fppat,0x200*pat,SEEK_SET);
			for(i=0;i<256;i++)
			{
				unsigned long t=fget16(fppat);
				pal[i].b=(((t>>10)&0x1f)<<1);
				pal[i].g=(((t>>5)&0x1f)<<1);
				pal[i].r=(((t>>0)&0x1f)<<1);
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
		
		textprintf_ex(screen,font,0,0,0xFF,0,"group:%x,id:%x,max:%x,width:%x,height:%x",mapgroup,map,maps,width[map],height[map]);			

		//Event handling
		while(!keypressed())	rest(12);
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
		/*case KEY_S:
			gif=algif_create_raw_animation(maps+1);
			gif->width=maxw;
			gif->height=maxh;
			gif->loop=0;
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
				here=seeksub(buf,i,max,&width[i],&height[i]);
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
			sprintf(filename,"%s-%d.gif",prefix,mapgroup);
			algif_save_raw_animation (filename,gif);
			algif_destroy_raw_animation (gif);
			sprintf(filename,"");
			break;*/
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
