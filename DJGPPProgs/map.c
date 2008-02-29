#include <stdio.h>
#include <stdlib.h>
#include <allegro.h>

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
void mask_blit(BITMAP* bmp,byte* buf,int id,int x,int y)
{
	int i,j,width,height,rle0,t;
	byte data,*here;
	
	if((here=seeksub(buf,id,0xffff))==NULL)
		return;
	width=*(short*)(here),height=*(short*)(here+2);
	here+=4;
	for(i=0;i<width*height;)
	{
		data=*here++;
		rle0=data>0x80?1:0;
		t=i;
		if(rle0)
			i+=(data-0x80);
		else
			for(;i<t+data;i++)
				putpixel(bmp,x+i%width,y+i/width,*here++);
	}
}

int main(int argc,char* argv[])
{	
	int map=0,pat=0,mapgroup=0;
	int maps=0,pats,mapgroups,pmaps;
	int mapchg=1,patchg=1,mapgroupchg=1;
	int width[0x200],height[0x200];
	int rle0,data,i,j,t,max;
	int running=1;
	int len=0,s,lines;
	int gx=0,gy=0;
	char filename[12];
	byte fel,felp,sel,selp;
	int elem1,elem2;
	byte *buf=(byte*)malloc(0x12000),
			 *bufmap=(byte*)malloc(0x10000),
	     *here;
	
	static BITMAP *bmp[0x200];
	BITMAP *big=create_bitmap(2048,2048);
	BITMAP *towrite=create_bitmap(2032,2040);
	BITMAP *tb=create_bitmap(320,200);
	PALETTE pal;
		
	FILE* fp=fopen("gop.mkf","rb");
	FILE* fppat=fopen("pat.mkf","rb");
	FILE* fpmap=fopen("map.mkf","rb");
	
	if((fp==NULL)||(fppat==NULL))
	{
		printf("Usage:rle *.mkf");
		exit(-1);
	}
	
	mapgroups=fget32(fpmap)/4-2;pats=fget32(fppat)/4-2;lines=128;
	clear(tb);clear(big);
	
	allegro_init();
	set_gfx_mode(GFX_VGA,320,200,0,0);
	install_keyboard();
	atexit(allegro_exit);

	while(running)
	{		
		if(mapgroupchg)
		{	
			clear(big);gx=16;gy=8;
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
				max=0xffff;
				pmaps=maps;
				maps=(*(short*)(buf))-2;
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
					here+=4;
					if(j<pmaps) destroy_bitmap(bmp[j]);
					bmp[j]=create_bitmap(width[j],height[j]);
					for(i=0;i<width[j]*height[j];)
					{
						data=*here++;
						rle0=data>0x80?1:0;
						t=i;
						if(rle0)
							for(;i<t+data-0x80;i++)
								putpixel(bmp[j],i%width[j],i/width[j],0);
						else
							for(;i<t+data;i++)
								putpixel(bmp[j],i%width[j],i/width[j],*here++);
					}
				}
				
				seekmkf(fpmap,mapgroup);s=ftell(fpmap);
				seekmkf(fpmap,mapgroup+1);len=ftell(fpmap)-s;
				fseek(fpmap,s,SEEK_SET);
				fread(bufmap,len,1,fpmap);
				deyj1(&bufmap);
				//blit(tb,screen,0,0,0,0,320,200);
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
  		here=bufmap;
 		 	for(j=0;j<lines;j++)
   			for(i=0;i<0x40;i++)
   			{
  		 		fel=*here++;felp=*here++;sel=*here++;selp=*here++;
  		 		felp>>=4;selp>>=4;
  		 		felp&=1;selp&=1;
  		 		elem1=((int)felp<<8)|fel;elem2=((int)selp<<8)|sel;
  		 		elem1=(elem1>maps)?fel:elem1;elem2=(elem2-1>maps)?sel:elem2;
    			masked_blit(bmp[elem1], big, 0, 0, i*32,j*16,32, 16); 
	    		if(elem2)
      			mask_blit(big, buf, elem2-1, i*32,j*16);
    
  		 		fel=*here++;felp=*here++;sel=*here++;selp=*here++;
  		 		felp>>=4;selp>>=4;
  		 		felp&=1;selp&=1;
  		 		elem1=((int)felp<<8)|fel;elem2=((int)selp<<8)|sel;
  		 		elem1=(elem1>maps)?fel:elem1;elem2=(elem2-1>maps)?sel:elem2;
    			masked_blit(bmp[elem1], big, 0, 0, i*32+16,j*16+8,32, 16);
    			if(elem2)
      			mask_blit(big, buf, elem2-1, i*32+16,j*16+8);				 
    		}
  		blit(big,screen,gx,gy,0,0,320,200);
  		mapchg=0;
  	}

		
		textprintf(screen,font,180,0,0xFF,"map:%X,x:%X y:%X",mapgroup,(gx-16)/32,(gy-8)/16);	
		
		//Event handling
		switch(readkey()>>8) {
		case KEY_DOWN:
			gy=(gy+16>2048-200)?gy:gy+16;
			blit(big,screen,gx,gy,0,0,320,200);
			break;
		case KEY_RIGHT:
			gx=(gx+32>2048-320)?gx:gx+32;
			blit(big,screen,gx,gy,0,0,320,200);
			break;
		case KEY_PGDN:
			mapgroup=(mapgroup+1>=mapgroups)?mapgroup:mapgroup+1;
			mapgroupchg=mapchg=1;
			break;
		case KEY_END:
			pat=(pat+1>pats)?pat:pat+1;
			patchg=1;
			break;
		case KEY_UP:
			gy=(gy-16<8)?8:gy-16;
			blit(big,screen,gx,gy,0,0,320,200);
			break;
		case KEY_LEFT:
			gx=(gx-32<16)?16:gx-32;
			blit(big,screen,gx,gy,0,0,320,200);
			break;
		case KEY_PGUP:
			mapgroup=(mapgroup-1<0)?0:mapgroup-1;
			mapgroupchg=mapchg=1;
			break;
		case KEY_HOME:
			pat=(pat-1<0)?0:pat-1;
			patchg=1;
			break;
		case KEY_S:
			sprintf(filename,"%s-%d-%d.bmp","map",mapgroup,pat);
			blit(big,towrite,16,8,0,0,2032,2040);
			save_bmp(filename,towrite,pal);
			break;
		case KEY_ESC:
			running=0;
			break;
		}
		clear_keybuf();
	}
	//finalize
	destroy_bitmap(tb);
	for(i=0;i<maps;i++)
		destroy_bitmap(bmp[i]);
	fclose(fp);fclose(fppat);
	free(buf);
	return 0;
}