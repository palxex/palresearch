#ifndef _REG_H
#define _REG_H

typedef unsigned char byte;
typedef unsigned short word16;
typedef unsigned int dword32;

static byte *_ds,*_es;
static word16 _si,_di; 

byte _msb_n(word16* x)
{	
	int t=(*x)>>15;
	return (*x)<<=1,t;
}
byte _msb_d(dword32* x,byte* y)
{
	int t=(*x)>>31;
	(*y)-=1;
	(*x)<<=1;
	return t;
}
dword32 _shld(word16* x,dword32* y,byte* z,int n)
{	
	while(n--)
	{
		(*x)<<=1;
		(*x)|=_msb_d(y,z);
	}
	return *x;
}
#endif
