#include <stdio.h>
#include <stdlib.h>
#include <algif.h>

#include <deyj1.h>

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

long seekmkf(FILE* fp,int n)
{
	fseek(fp,0x2800*n,SEEK_SET);
	//long offset,length;
	//fseek(fp,4*n,SEEK_SET);
	//offset=fget32(fp);
	//length=fget32(fp)-offset;fseek(fp,-4,SEEK_CUR);
	//fseek(fp,offset,SEEK_SET);
	return 0; 
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
        int map=1,pat=3;
	int maps=200,pats=20;
	int mapchg=1,patchg=1;
	int width,height;
	int rle0,data,i,j,t;
	int running=1;
	int len;	
	char filename[12];
	byte *buf=(byte*)malloc(0xFA00),
	     *here;
	
	GIF_ANIMATION *gif;
	BITMAP* bmp=create_bitmap(320,200);
	PALETTE pal;
	unsigned char* pix=(unsigned char*)malloc(1);
	unsigned long end;
	
        FILE* fp=fopen("rgm.joe","rb");
        FILE* fppat=fopen("alldat.new","rb");
		
	if((fp==NULL))//||(fppat==NULL))	
	{
		printf("Usage:rle *.mkf");
		exit(-1);
	}
	maps=fget32(fp)/4-1;//,pats=fget32(fppat)/4-1;	
	fseek(fp,0,SEEK_END);end=ftell(fp);fseek(fp,0,SEEK_SET);
	
	*(strrchr(argv[1],'.'))='\0';
	
	allegro_init();
	set_gfx_mode(GFX_VGA,320,200,0,0);
	install_keyboard();
	atexit(allegro_exit);

	
	while(running)
	{		
		//render a frame
		if(mapchg)
		{
			len=seekmkf(fp,map);
			if(ftell(fp)>=end)
			{	map--;
				continue;
			}
			width=fget16(fp),height=fget16(fp);
			if(width==0&&height==0)
			{
				map++;continue;
			}
                        destroy_bitmap(bmp);
                        bmp=create_bitmap(width,height);
			fread(buf,0x2800,1,fp);
			here=buf;
			//deyj1(&buf);
			for(i=0;i<width*height;)
			{
				data=*here++;
				rle0=data>0x80?1:0;
				t=i;
				if(rle0)
					for(;i<t+data-0x80;i++)
                                                _putpixel(bmp,i%width,i/width,0);
                        	else
					for(;i<t+data;i++)
						_putpixel(bmp,i%width,i/width,*here++);
			}
                        clear(screen);
			blit(bmp, screen, 0, 0, 0, 0, width,height);
			mapchg=0;
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
		textprintf_ex(screen,font,0,0,0xFF,0,"id:%x,pat:%x",map,pat);

		//Event handling
		while(!keypressed())	rest(50000);
		switch(readkey()>>8) {
		case KEY_DOWN:
			map++;
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
                        gif=algif_create_raw_animation(1);
			gif->width=width;
			gif->height=height;
			gif->loop=0;
			gif->palette.colors_count=256;
			memcpy(gif->palette.colors,pal,sizeof(PALETTE));
			for(i=0;i<256;i++)
			{
				gif->palette.colors[i].r<<=2;
				gif->palette.colors[i].g<<=2;
				gif->palette.colors[i].b<<=2;
			}
			gif->frames[0].xoff = 0;
		    	gif->frames[0].yoff = 0;
		    	gif->frames[0].duration = 5; // 0.1s 
	    		gif->frames[0].disposal_method = 2; // not dispose
		  	gif->frames[0].bitmap_8_bit = create_bitmap(width,height);
                        clear_to_color(gif->frames[0].bitmap_8_bit,0xff);
                        fseek(fp,0x2800*map,SEEK_SET);
                        fread(buf,0x2800,1,fp);
			here=buf;
			here+=4;
			for(j=0;j<width*height;)
			{
				data=*here++;
                                rle0=data>0x80?1:0;
                                t=j;
                                if(rle0)
                                         j=t+data-0x80;
                                else
                                         for(;j<t+data;j++)
                                                _putpixel(gif->frames[0].bitmap_8_bit,j%width,j/width,*here++);
				gif->frames[0].transparent_index = 0xff;
			}	
			sprintf(filename,"%s-%d.gif","rgm",map);
			algif_save_raw_animation (filename,gif);
			algif_destroy_raw_animation (gif);
			sprintf(filename,"");
			break;
		}
	}
	//finalize
	free(buf);
	fclose(fp);//fclose(fppat);
	return 0;
}
