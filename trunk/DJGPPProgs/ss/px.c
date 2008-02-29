#include <stdio.h>
#include <stdlib.h>
#include <allegro.h>

//#include <deyj1.h>

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
	unsigned long a=fget16(fp);
	unsigned long b=fget16(fp)<<16;
	return a|b;
}

long seekmkf(FILE* fp,int n)
{
	fseek(fp,0x10000*n,SEEK_SET);
	//long offset,length;
	//fseek(fp,4*n,SEEK_SET);
	//offset=fget32(fp);
	//length=fget32(fp)-offset;fseek(fp,-4,SEEK_CUR);
	//fseek(fp,offset,SEEK_SET);
	return 0; 
}

unsigned char *seeksub(unsigned char *x,int n)
{
	long offset;
	long t;
	offset=((unsigned short int*)x)[n]*2;
	return x+offset;
}

int main(int argc,char* argv[])
{	
	int map=0,pat=0;
	int maps,pats=20;
	int mapchg=1,patchg=1;
	int width,height;
	int rle0,data,i,j,t;
	int running=1;
	int len;	
	char filename[12];
	unsigned char *buf=(unsigned char *)malloc(0xFA00),
	     *here;
	
	BITMAP* bmp=create_bitmap(320,200);
	PALETTE pal;
	unsigned char* pix=(unsigned char*)malloc(1);
	
	FILE* fp=fopen(argv[1],"rb");
	//FILE* fppat=fopen("pat.mkf","rb");
		
	if((fp==NULL))//||(fppat==NULL))	
	{
		printf("Usage:rle *.mkf");
		exit(-1);
	}
	fseek(fp,0,SEEK_END);
	maps=ftell(fp)/0x10000;//,pats=fget32(fppat)/4-1;
	fseek(fp,0,SEEK_SET);
	
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
			fread(buf,0xfa00,1,fp);
			//deyj1(&buf);
			width=320,height=200;
			for(j=0;j<height;j++)
				for(i=0;i<width;i++)
					putpixel(bmp,i,j,buf[j*width+i]);
			blit(bmp, screen, 0, 0, 0, 0, 320, 200);
			mapchg=0;
		}
		
		//change a palette
		if(patchg)
		{
			fseek(fp,0x10000*map+0xfa00,SEEK_SET);
			for(i=0;i<256;i++)
			{
				unsigned long t=fget16(fp);
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
			map=(map+1>=maps)?map:map+1;
			mapchg=1;patchg=1;
			break;
		case KEY_RIGHT:
			pat=(pat+1>=pats)?pat:pat+1;
			patchg=1;
			break;
		case KEY_UP:
			map=(map-1<0)?0:map-1;
			mapchg=1;patchg=1;
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
	}
	//finalize
	free(buf);
	fclose(fp);//fclose(fppat);
	return 0;
}
