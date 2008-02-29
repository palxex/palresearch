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

long seekmkf(FILE* fp,int n)
{
	long offset;
	long t;
	fseek(fp,4*n,SEEK_SET);
	offset=fget32(fp);
	t=fget32(fp);
	fseek(fp,offset,SEEK_SET);
	return t-offset;
}
byte* seeksub(byte* x,int n)
{
	long offset,hack=0;
	offset=((word16*)x)[n]*2;
	if(n>0)	hack=((word16*)x)[n-1]*2;
	if((offset<hack))
		return NULL;
	else
		return x+offset;
}
byte* seeksubmkf(byte* x,int n)
{
	long offset,hack=0;
	offset=((dword32*)x)[n];
	if(n>0)	hack=((dword32*)x)[n-1];
	if((offset<hack))
		return NULL;
	else
		return x+offset;
}
void cmd_blit(BITMAP* bmp,byte* buf,int trans_color)
{
	int i=0,j,width,height;
	byte bdata,*here;
	word16 wdata;
	dword32 ddata;	
	
	
	here=buf;
	width=320;height=200;
	while(i<=64000)
	{
		bdata=*here++;
		switch(bdata)
		{
		case 0x00:
		case 0x13:
			//0x1000411b
			return;
		case 0x01:
		case 0x05:
			break;
		case 0x02:
			i += 2;
			break;
		case 0x03:
			bdata = *here++;
			i += ((unsigned int)bdata + 1) << 1;
			break;
		case 0x04:
			wdata = *(unsigned short *)here;here+=2;
			i += ((unsigned int)wdata + 1) << 1;
			break;
		case 0x06:
			wdata = *(unsigned short *)here;here+=2;
			_putpixel(bmp,i%width,i/width,(byte)wdata);i++;
			_putpixel(bmp,i%width,i/width,(byte)(wdata>>8));i++;
			break;
		case 0x07:
			ddata = *(unsigned int *)here;here+=4;
			_putpixel(bmp,i%width,i/width,(byte)ddata);i++;
			_putpixel(bmp,i%width,i/width,(byte)(ddata>>8));i++;
			_putpixel(bmp,i%width,i/width,(byte)(ddata>>16));i++;
			_putpixel(bmp,i%width,i/width,(byte)(ddata>>24));i++;
			break;
		case 0x08:
			wdata = *(unsigned short *)here;here+=2;
			_putpixel(bmp,i%width,i/width,(byte)wdata);i++;
			_putpixel(bmp,i%width,i/width,wdata>>8);i++;
			ddata = *(unsigned int *)here;here+=4;
			_putpixel(bmp,i%width,i/width,(byte)ddata);i++;
			_putpixel(bmp,i%width,i/width,(byte)(ddata>>8));i++;
			_putpixel(bmp,i%width,i/width,(byte)(ddata>>16));i++;
			_putpixel(bmp,i%width,i/width,(byte)(ddata>>24));i++;
			break;
		case 0x09:
			ddata = *(unsigned int *)here;here+=4;
			_putpixel(bmp,i%width,i/width,(byte)ddata);i++;
			_putpixel(bmp,i%width,i/width,(byte)(ddata>>8));i++;
			_putpixel(bmp,i%width,i/width,(byte)(ddata>>16));i++;
			_putpixel(bmp,i%width,i/width,(byte)(ddata>>24));i++;
			ddata = *(unsigned int *)here;here+=4;
			_putpixel(bmp,i%width,i/width,(byte)ddata);i++;
			_putpixel(bmp,i%width,i/width,(byte)(ddata>>8));i++;
			_putpixel(bmp,i%width,i/width,(byte)(ddata>>16));i++;
			_putpixel(bmp,i%width,i/width,(byte)(ddata>>24));i++;
			break;
		case 0x0a:
			ddata = *(unsigned int *)here;here+=4;
			_putpixel(bmp,i%width,i/width,(byte)ddata);i++;
			_putpixel(bmp,i%width,i/width,(byte)(ddata>>8));i++;
			_putpixel(bmp,i%width,i/width,(byte)(ddata>>16));i++;
			_putpixel(bmp,i%width,i/width,(byte)(ddata>>24));i++;
			ddata = *(unsigned int *)here;here+=4;
			_putpixel(bmp,i%width,i/width,(byte)ddata);i++;
			_putpixel(bmp,i%width,i/width,(byte)(ddata>>8));i++;
			_putpixel(bmp,i%width,i/width,(byte)(ddata>>16));i++;
			_putpixel(bmp,i%width,i/width,(byte)(ddata>>24));i++;
			wdata = *(unsigned short *)here;here+=2;
			_putpixel(bmp,i%width,i/width,(byte)wdata);i++;
			_putpixel(bmp,i%width,i/width,wdata>>8);i++;
			break;
		case 0x0b:
			bdata = *here++;
			for(j = 0; j <= bdata; j++)
			{
				wdata = *(unsigned short *)here;here+=2;
				_putpixel(bmp,i%width,i/width,(byte)wdata);i++;
				_putpixel(bmp,i%width,i/width,wdata>>8);i++;
			}
			break;
		case 0x0c:
			ddata = *(unsigned short *)here;here+=2;
			for(j = 0; j <= ddata; j++)
			{
				wdata = *(unsigned short *)here;here+=2;
				_putpixel(bmp,i%width,i/width,(byte)wdata);i++;
				_putpixel(bmp,i%width,i/width,wdata>>8);i++;
			}
			break;
		case 0x0d:
			wdata = *(unsigned short *)here;here+=2;
			_putpixel(bmp,i%width,i/width,(byte)wdata);i++;
			_putpixel(bmp,i%width,i/width,wdata>>8);i++;
			_putpixel(bmp,i%width,i/width,(byte)wdata);i++;
			_putpixel(bmp,i%width,i/width,wdata>>8);i++;
			break;
		case 0x0e:
			wdata = *(unsigned short *)here;here+=2;
			_putpixel(bmp,i%width,i/width,(byte)wdata);i++;
			_putpixel(bmp,i%width,i/width,wdata>>8);i++;
			_putpixel(bmp,i%width,i/width,(byte)wdata);i++;
			_putpixel(bmp,i%width,i/width,wdata>>8);i++;
			_putpixel(bmp,i%width,i/width,(byte)wdata);i++;
			_putpixel(bmp,i%width,i/width,wdata>>8);i++;
			break;
		case 0x0f:
			wdata = *(unsigned short *)here;here+=2;
			_putpixel(bmp,i%width,i/width,(byte)wdata);i++;
			_putpixel(bmp,i%width,i/width,wdata>>8);i++;
			_putpixel(bmp,i%width,i/width,(byte)wdata);i++;
			_putpixel(bmp,i%width,i/width,wdata>>8);i++;
			_putpixel(bmp,i%width,i/width,(byte)wdata);i++;
			_putpixel(bmp,i%width,i/width,wdata>>8);i++;
			_putpixel(bmp,i%width,i/width,(byte)wdata);i++;
			_putpixel(bmp,i%width,i/width,wdata>>8);i++;
			break;
		case 0x10:
			wdata = *(unsigned short *)here;here+=2;
			_putpixel(bmp,i%width,i/width,(byte)wdata);i++;
			_putpixel(bmp,i%width,i/width,wdata>>8);i++;
			_putpixel(bmp,i%width,i/width,(byte)wdata);i++;
			_putpixel(bmp,i%width,i/width,wdata>>8);i++;
			_putpixel(bmp,i%width,i/width,(byte)wdata);i++;
			_putpixel(bmp,i%width,i/width,wdata>>8);i++;
			_putpixel(bmp,i%width,i/width,(byte)wdata);i++;
			_putpixel(bmp,i%width,i/width,wdata>>8);i++;
			_putpixel(bmp,i%width,i/width,(byte)wdata);i++;
			_putpixel(bmp,i%width,i/width,wdata>>8);i++;
			break;
		case 0x11:
			bdata = *here++;
			wdata = *(unsigned short *)here;here+=2;
			for(j = 0; j <= bdata; j++)
			{
				_putpixel(bmp,i%width,i/width,(byte)wdata);i++;
				_putpixel(bmp,i%width,i/width,wdata>>8);i++;
			}
			break;
		case 0x12:
			ddata = *(unsigned short *)here;here+=2;
			wdata = *(unsigned short *)here;here+=2;
			for(j = 0; j <= ddata; j++)
			{
				_putpixel(bmp,i%width,i/width,(byte)wdata);i++;
				_putpixel(bmp,i%width,i/width,wdata>>8);i++;
			}
			break;
		}
	}
}
int main(int argc,char* argv[])
{	
	int rng=0,rngchg=1,rngs=0,clips=0,clipcur,pclips=0;
	long len=0,delay=10,running=1,first=1;
	int pat=0,pats=0,patchg=1;
	//int flag_save=0,flag_save_start=0;
	int i,j;
	char filename[12];
	byte *buf=(byte*)malloc(0x10000000),
			 *toex=(byte*)malloc(0x100000),
	     *here;
	
	GIF_ANIMATION *gif;
	
	PALETTE pal;
		
	FILE* fp=fopen("rng.mkf","rb");
	FILE* fppat=fopen("pat.mkf","rb");
	
	if((fp==NULL)||(fppat==NULL))
	{
		printf("Usage:rle *.mkf");
		exit(-1);
	}
	
	rngs=fget32(fp)/4-2;
	fseek(fppat,fget32(fppat)-4,SEEK_SET);pats=(fget32(fppat)-0x28)/0x300-1;
	
	allegro_init();
	algif_init();
	set_color_depth(8);
	set_gfx_mode(GFX_AUTODETECT,320,200,0,0);
	install_keyboard();
	atexit(allegro_exit);
	while(running)
	{
		//change a palette
		if(patchg)
		{
			fseek(fppat,0x28+pat*0x300,SEEK_SET);
			for(i=0;i<256;i++)
			{	pal[i].r=fget8(fppat);
				pal[i].g=fget8(fppat);
				pal[i].b=fget8(fppat);
			}
			set_palette(pal);
			patchg=0;
		}		
		//change a rng
		if(rngchg)
		{	
			//clear(screen);
			if((len=seekmkf(fp,rng))==0)
			{
				rngchg=1;
				clipcur=0;
				rng++;
				continue;
			}
			else
			{
				fread(buf,len,1,fp);
				pclips=clips;
				clips=(*(dword32*)(buf))/4-2;
				clipcur=0;
				rngchg=0;
				for(j=0;j<=clips;j++)
				{
					if((here=seeksubmkf(buf,j))==NULL)
					{
						clips=j-1;break;
					}
				}
			}
		}
		
		//render a frame
		j=clipcur;
		here=seeksubmkf(buf,j);
		memcpy(toex,here,((dword32*)buf)[j+1]-((dword32*)buf)[j]);
		deyj1(&toex);
		cmd_blit(screen,toex,0);
		textprintf_ex(screen,font,200,0,0xFF,0,"rng:%X,clip:%X",rng,clipcur);
		
		//delay...
		if(!first)
			rest(50000*delay);
		sleep(0);
		first=0;
		clipcur++;
		if(clipcur>clips)
			clipcur=clips;
				
		//Event handling	
		if(keypressed())
		{
			switch(readkey()>>8) {
			case KEY_PGDN:
				rng=(rng+1>=rngs)?rngs:rng+1;
				rngchg=1;
				break;			
			case KEY_DOWN:
				delay++;
				break;
			case KEY_RIGHT:
				pat=(pat+1>pats)?pat:pat+1;
				patchg=1;
				break;
			case KEY_PGUP:
				rng=(rng-1<0)?0:rng-1;
				rngchg=1;
				break;
			case KEY_UP:
				delay--;
				break;
			case KEY_LEFT:
				pat=(pat-1<0)?0:pat-1;
				patchg=1;
				break;
			case KEY_ESC:
				running=0;
				break;
			case KEY_ENTER:
				clipcur=0;
				break;
			case KEY_S:
				gif=algif_create_raw_animation(clips+1);
				gif->width=320;
				gif->height=200;
				gif->loop=0;
				gif->palette.colors_count=256;
				memcpy(gif->palette.colors,pal,sizeof(PALETTE));
				for(i=0;i<256;i++)
				{
					gif->palette.colors[i].r<<=2;
					gif->palette.colors[i].g<<=2;
					gif->palette.colors[i].b<<=2;
				}
				for(i=0;i<=clips;i++)
				{		
					here=seeksubmkf(buf,i);
					len=((dword32*)buf)[i+1]-((dword32*)buf)[i];
					memcpy(toex,here,len);
					deyj1(&toex);
					gif->frames[i].xoff = 0;
	    	  gif->frames[i].yoff = 0;
	    	  gif->frames[i].duration = 5; // 0.1s 
	    		gif->frames[i].disposal_method = 0; // not dispose
		  	  gif->frames[i].bitmap_8_bit = create_bitmap(320,200);
		  	  clear_to_color(gif->frames[i].bitmap_8_bit,0xff);
					cmd_blit(gif->frames[i].bitmap_8_bit,toex,0xff);
					gif->frames[i].transparent_index = 0xff;
				}				
				sprintf(filename,"Ani%d.gif",rng);
				algif_save_raw_animation (filename,gif);
				algif_destroy_raw_animation (gif);
				sprintf(filename,"");
				break;
			}
			clear_keybuf();
		}
	}
	//finalize
	fclose(fp);fclose(fppat);
	free(buf);free(toex);
	return 0;
}
END_OF_MAIN()
