#include <string.h>

typedef unsigned char byte8;
typedef unsigned short word16;
typedef unsigned int dword32;

static byte8 *_ds,*_es;
static word16 _si,_di; 

byte8 move_top(word16 &x)
{        
        byte8 t=x>>15;
        return x<<=1,t;
}
byte8 get_topflag(dword32& x,byte8& y)
{
        int t=x>>31;
        y--;
        x<<=1;
        return t;
}
dword32 trans_topflag_to(word16& x,dword32& y,byte8& z,int n)
{        
        while(n--)
        {
                x<<=1;
                x|=get_topflag(y,z);
        }
        return x;
}

#define DATA(s,type) (*(type*)(s))
#define UPDATA_IF_FLAG_LESS(x)         if(flagnum<x) { \
                                                                        flags|=((dword32)DATA(_ds+_si,word16))<<(0x10-flagnum); \
                                                                        _si+=2; \
                                                                        flagnum+=0x10; \
                                                                }

static byte8 table[0x1FE];
static byte8 assist[0x1FE];
static word16 keywordw[8];
static byte8 keywordb[12];
word16 key_0x12,key_0x13;
dword32 flags;
byte8 flagnum;

void analysis();
void expand();
byte8 *deyj1(byte8 *src)
{
        dword32 blocks,length=0;
        word16 pack_length,ext_length,prev_src_pos,prev_dst_pos;
        int first=1;
        byte8* dst;
        pack_length=ext_length=key_0x12=key_0x13=flags=_si=_di=0;
        
        _ds=src;length=DATA(_ds+4,dword32);        
        if(DATA(_ds,dword32)!=0x315F4A59)        return NULL;//YJ_1 check                
        else dst=new byte8[length];_es=dst;
        memset(dst,0,length);

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

                ext_length=DATA(_ds+_si,word16);                //the length of previous packed block
                pack_length=DATA(_ds+_si+2,word16);        //the length of previous extracted block
                _si+=4;
                
                if(pack_length==0){
                        pack_length=ext_length+4;
                        while(--ext_length) _es[_di++]=_ds[_si++];
                        ext_length=pack_length-4;
                }
                else{
                        memcpy(keywordw,_ds+_si,8);_si+=8;
                        memcpy(keywordb,_ds+_si,12);_si+=10;
                        key_0x12=_ds[_si++];
                        key_0x13=_ds[_si++];
                        
                        flags=(DATA(_ds+_si,word16)<<0x10)|DATA(_ds+_si+2,word16);
                        _si+=4;flagnum=0x20;
                        
                        analysis();
                }
        }while(--blocks);
        
        return dst;
}
void expand()
{
        int loop=_ds[0xF],offset=0;
        word16 flags=0;
        _di=_si+=0x10;
        _si+=2*loop;
        while(loop--)
        {
                if((offset%16)==0){
                        flags=DATA(_ds+_si,word16);
                        _si+=2;
                }
                table[offset+0]=_ds[_di+0];
                table[offset+1]=_ds[_di+1];
                assist[offset+0]=move_top(flags);
                assist[offset+1]=move_top(flags);
                _di+=2;
                offset+=2;
        }
}

word16 decodeloop();
word16 decodenumbytes();
#define GET_LOOP() {        if((loop=decodeloop())==0xffff)        return; }
#define GET_NUMBYTES() { numbytes=decodenumbytes();                }
void analysis()
{
        word16 loop=0,numbytes=0;
        while(1){
                GET_LOOP();
                do{
                        word16 m=0;
                        UPDATA_IF_FLAG_LESS(0x10);
                        do{
                                trans_topflag_to(m,flags,flagnum,1);
                                if(assist[m]==0)
                                        break;
                                m=table[m];
                        }while(1);
                        _es[_di++]=table[m];
                }while(--loop);
                
                GET_LOOP();
                do{
                        word16 m=0,n=0;
                        GET_NUMBYTES();
                        UPDATA_IF_FLAG_LESS(0x10);
                        trans_topflag_to(m,flags,flagnum,2);
                        trans_topflag_to(n,flags,flagnum,keywordb[m]);
                        while(numbytes--) _es[_di++]=_es[_di-n];
                }while(--loop);
        }
}
#undef GET_LOOP
#undef GET_NUMBYTES

word16 decodeloop()
{
        word16 loop;
        UPDATA_IF_FLAG_LESS(3);
        loop=key_0x12;
        if(0==get_topflag(flags,flagnum))
        {
                word16 t=0;
                trans_topflag_to(t,flags,flagnum,2);
                loop=key_0x13;
                if(t!=0)
                {
                        t=keywordb[t+6];
                        UPDATA_IF_FLAG_LESS(t);
                        loop=0;
                        if((trans_topflag_to(loop,flags,flagnum,t))==0)
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
        if((trans_topflag_to(numbytes,flags,flagnum,2))==0)
                numbytes=keywordw[0];
        else
        {
                if(0==get_topflag(flags,flagnum))
                        numbytes=keywordw[numbytes];
                else 
                {
                        byte8 t=keywordb[numbytes+3];
                        UPDATA_IF_FLAG_LESS(t);
                        numbytes=0;
                        trans_topflag_to(numbytes,flags,flagnum,t);
                }
        }
        return numbytes;
}
#undef DATA
#undef UPDATA_IF_FLAG_LESS
