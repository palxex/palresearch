#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "reg.h"

#define DATA(s,type) (*(type*)(s))
#define UPDATA_IF_FLAG_LESS(x) 	if(flagnum<x) { \
																	flags|=((dword32)DATA(_ds+_si,word16))<<(0x10-flagnum); \
																	_si+=2; \
																	flagnum+=0x10; \
																}

static byte table[0x1FE];
static byte assist[0x1FE];
static byte keywords[0x14];
word16 key_0x13,key_0x14;
dword32 flags;
byte flagnum;

void analysis();
void expand();
void deyj1(byte** src)
{
	dword32 blocks,length=0;
	word16 pack_length,ext_length,prev_src_pos,prev_dst_pos;
	int first=1;
	byte* dst;
	pack_length=ext_length=key_0x13=key_0x14=flags=_si=_di=0;
	
	_ds=*src;length=DATA(_ds+4,dword32);	
	if(DATA(_ds,dword32)!=0x315F4A59)	return;//YJ_1 check		
	else dst=malloc(length);_es=dst;

	prev_src_pos=_si;prev_dst_pos=_di;
	blocks=DATA(_ds+_si+0xC,word16);

	expand();

	prev_src_pos=_si;
	_di=prev_dst_pos;

	do{
		if(!first){			
			_si=prev_src_pos+=pack_length;
			_di=prev_dst_pos+=ext_length;
		}
		first=0;

		ext_length=DATA(_ds+_si,word16);		//the length of previous packed block
		pack_length=DATA(_ds+_si+2,word16);	//the length of previous extracted block
		_si+=4;
		
		if(pack_length==0){
			pack_length=ext_length+4;
			memcpy(_es+_di,_ds+_si,ext_length);_di+=ext_length;
		}
		else{
			memcpy(keywords,_ds+_si,0x14);
	 		_si+=0x14;
	 		
			key_0x13=DATA(_ds+_si-2,byte);
			key_0x14=DATA(_ds+_si-1,byte);
			
			flags=(DATA(_ds+_si,word16)<<0x10)|DATA(_ds+_si+2,word16);
			_si+=4;flagnum=0x20;
			
			analysis();
		}
	}while(--blocks);
	
	memcpy(*src,dst,length);	//ugly hacks...sorry,I can't make any other way works
	free(dst);								//for this,you have to guess the size before you call deyj1.
														//check there first whenever deyj1 crashed!!!
}
void expand()
{
	int loop=DATA(_ds+0xF,byte),offset=0;
	word16 flags=0;
	_di=_si+=0x10;
	_si+=2*loop;
	while(loop--)
	{
		if((offset%16)==0){
			flags=DATA(_ds+_si,word16);
			_si+=2;
		}
		DATA(table+offset+0,byte)=DATA(_ds+_di,byte);
		DATA(table+offset+1,byte)=DATA(_ds+_di+1,byte);
		DATA(assist+offset+0,byte)=_msb_n(&flags);
		DATA(assist+offset+1,byte)=_msb_n(&flags);
		_di+=2;
		offset+=2;
	}
}

word16 decodeloop();
word16 decodenumbytes();
#define GET_LOOP() {	if((loop=decodeloop())==0xffff)	return; }
#define GET_NUMBYTES() { numbytes=decodenumbytes();		}
void analysis()
{
	word16 loop,numbytes;
	while(1){
		GET_LOOP();
		do{
			word16 m=0;
			UPDATA_IF_FLAG_LESS(0x10);
			do{
				m=(m<<1)|_msb_d(&flags,&flagnum);
				if(assist[m]==0)
					break;
				m=table[m];
			}while(1);
			DATA(_es+_di,byte)=table[m];
			_di++;
		}while(--loop);
		
		GET_LOOP();
		do{
			word16 m=0,n=0;
			GET_NUMBYTES();
			UPDATA_IF_FLAG_LESS(0x10);
			_shld(&m,&flags,&flagnum,2);
			_shld(&n,&flags,&flagnum,DATA(keywords+m+8,byte));
			memcpy(_es+_di,_es+_di-n,numbytes);_di+=numbytes;
		}while(--loop);
	}
}
#undef GET_LOOP
#undef GET_NUMBYTES

word16 decodeloop()
{
	word16 loop;
	UPDATA_IF_FLAG_LESS(3);
	loop=key_0x13;
	if(0==_msb_d(&flags,&flagnum))
	{
		word16 t=0;
		_shld(&t,&flags,&flagnum,2);
		loop=key_0x14;
		if(t!=0)
		{
			t=DATA(keywords+t+0xE,byte);
			UPDATA_IF_FLAG_LESS(t);
			loop=0;
			if((_shld(&loop,&flags,&flagnum,t))==0)
				return 0xffff;
		}
	}
	return loop;
}
word16 decodenumbytes()
{
	word16 numbytes;
	UPDATA_IF_FLAG_LESS(3);
	numbytes=0;
	if((_shld(&numbytes,&flags,&flagnum,2))==0)
		numbytes=DATA(keywords,word16);
	else
	{
		if(0==_msb_d(&flags,&flagnum))
			numbytes=DATA(keywords+numbytes*2,word16);
		else 
		{
			byte t=DATA(keywords+numbytes+0xB,byte);
			UPDATA_IF_FLAG_LESS(t);
			numbytes=0;
			_shld(&numbytes,&flags,&flagnum,t);
		}
	}
	return numbytes;
}
#undef DATA
#undef UPDATA_IF_FLAG_LESS
