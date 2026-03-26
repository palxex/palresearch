/************************************************************/
/*                                                          */
/*     THE C SOURCE OF PLAYRIX. PROGRAMMED BY BSPAL         */
/*     USING TURBOC 2.01 IN JULY 2004                       */
/*                                                          */
/************************************************************/
#ifdef __TINY__
#error This prorgram should compiled above tiny mode
#endif

#if defined(__linux__) || defined(__APPLE__) || defined(__FreeBSD__) || defined(__NetBSD__) || defined(__OpenBSD__) || defined(__MINGW32__)
#define MODERN_POSIX 1
#else
#define MODERN_POSIX 0
#endif

#if defined(__linux__)
#define MODERN_LINUX_IO 1
#else
#define MODERN_LINUX_IO 0
#endif
/*----------------------------------------------------------*/
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#if !MODERN_POSIX
#include <dos.h>
#endif

#if MODERN_POSIX
#include <pthread.h>
#include <stdbool.h>
#if defined(__MINGW32__)
#include <conio.h>
#include <windows.h>
#else
#include <termios.h>
#include <time.h>
#include <unistd.h>
#endif
#endif

#if MODERN_LINUX_IO
#include <sys/io.h>
#endif

#define CRASH_HANDLER_DOS_IMPLEMENTATION
#include "crash_handler_dos.h"

static FILE *g_outb_log = NULL;

static void log_opl_write(unsigned short base, unsigned short reg, unsigned short value)
{
	if(g_outb_log == NULL)
	{
		g_outb_log = fopen("outb.log", "a");
	}
	if(g_outb_log != NULL)
	{
		fprintf(g_outb_log, "0x%X base write reg 0x%X with value 0x%X\n", (unsigned int)base, (unsigned int)(reg & 0xFF), (unsigned int)(value & 0xFF));
		fflush(g_outb_log);
	}
}

#ifdef __WATCOMC__
#include <conio.h>
#define enable _enable
#define disable _disable
#define getvect _dos_getvect
#define setvect _dos_setvect
#define outportb outp
#define inportb inp
#endif

#if defined(__GNUC__) && !MODERN_POSIX
#ifndef __DJGPP__ //assume ia16-elf-gcc
#ifndef __FAR
#error This prorgram only support ia16-elf-gcc
#endif
#define __GCCIA16__ 1
#define interrupt static __far
#include <conio.h>
#include <i86.h>
#define enable _enable
#define disable _disable
#define outportb outp
#define inportb inp
#define stricmp strcasecmp
void __far *getvect(int intno)
{
        unsigned short seg, off;
        asm volatile("int $0x21" :
                     "=e"(seg), "=b"(off) :
                     "Rah"((char)0x35), "Ral"((char)intno));
        return MK_FP(seg,off);
}
static inline void setvect(int intno, void __far *vect)
{
        asm volatile("int $0x21" :
                     : "Rah"((char)0x25), "Ral"((char)intno),
                       "Rds"(FP_SEG(vect)), "d"(FP_OFF(vect)));
}
#else // __DJGPP__
#define interrupt static
#include <pc.h>
#include <dpmi.h>
#include <go32.h>
typedef void (*TimerHandler)(void);
static _go32_dpmi_seginfo	oldhandler, newhandler;
TimerHandler getvect(int intno){
  _go32_dpmi_get_protected_mode_interrupt_vector(intno, &oldhandler);
  return (TimerHandler)-1;
}
void setvect(int intno, TimerHandler handler){
  if((int)handler == -1) {
  	_go32_dpmi_set_protected_mode_interrupt_vector(intno, &oldhandler);
  }else{
  	newhandler.pm_selector = _go32_my_cs();
  	newhandler.pm_offset = (unsigned long)handler;
  	_go32_dpmi_chain_protected_mode_interrupt_vector(intno, &newhandler);
  }
}
#endif
#endif

#if MODERN_LINUX_IO
#if !defined(__i386__) && !defined(__x86_64__)
#error Linux port supports x86/x86_64 only (iopl/in/out)
#endif
#define interrupt static
#define enable()
#define disable()
static inline void outportb(unsigned short port, unsigned char value)
{
	outb(value, port);
}
static inline unsigned char inportb(unsigned short port)
{
	return inb(port);
}
#define stricmp strcasecmp
#endif

#if defined(__MINGW32__)
#define interrupt static
#define enable()
#define disable()
#define INPOUT32_DYN_IMPLEMENTATION
#include "inpout32_dyn.h"

static void mingw_portio_fatal(int err)
{
	if(err == INPOUT32_DYN_ERR_DLL_NOT_FOUND)
		printf("\nInpOut DLL not found (inpoutx64.dll/inpout32.dll).\n"), exit(1);
	if(err == INPOUT32_DYN_ERR_DRIVER_NOT_LOADED)
		printf("\nInpOut driver not loaded.\n"), exit(1);
	printf("\nPort I/O failed via InpOut32.\n"), exit(1);
}

static inline void outportb(unsigned short port, unsigned char value)
{
	if(!inpout32_dyn_write_port((short)port, (short)value))
		mingw_portio_fatal(inpout32_dyn_get_last_error());
}
static inline unsigned char inportb(unsigned short port)
{
	short v = 0;
	if(!inpout32_dyn_read_port((short)port, &v))
		mingw_portio_fatal(inpout32_dyn_get_last_error());
	return (unsigned char)v;
}
#ifndef stricmp
#define stricmp _stricmp
#endif
#endif
/************************************************************/
#define ESCAPE 0x01
#define add    0x4E
#define sub		0x4A
#define pause	0x19
#define contn	0x2E
#define INT    0x08
typedef unsigned short WORD;
typedef unsigned short word;
typedef unsigned char  BYTE;
typedef unsigned char  byte;
typedef unsigned long  DWORD;
typedef unsigned long  dword;
typedef struct {BYTE v[14];}ADDT;
typedef struct {WORD v[12];}BFDT;
/************************************************************/
char progname[20];
/************************************************************/
int getkey()
{
#if MODERN_POSIX
#if defined(__MINGW32__)
	int ch = _getch();
	if(ch == 0 || ch == 224) { (void)_getch(); return 0; }
#else
	int ch = getchar();
	if(ch == EOF) return 0;
#endif
	switch(ch)
	{
		case 27: return ESCAPE;
		case 'p': case 'P': return pause;
		case 'c': case 'C': return contn;
		case '-': return sub;
		case '+': return add;
		default: return 0;
	}
#else
        union REGS reg;
        reg.x.ax = 0;
#if __GCCIA16__
        __asm__ __volatile__("int $0x16":"=a"(reg.x.ax):"a"(reg.x.ax));
#else
        int86(0x16,&reg,&reg);
#endif
        return reg.h.ah;
#endif
}
/************************************************************/
/*      global various and flags                            */
/************************************************************/
WORD default_pass = 0x388;
FILE * fp = NULL;
FILE * tfp = NULL;
char filename[260] = {0};
DWORD filelen = 0;
static DWORD I = 0;
BYTE buf_addr[32767] = {0};  /* rix files' buffer */
WORD buffer[300] = {0};
WORD mus_block = 0;
WORD ins_block = 0;
const byte adflag[18] = {0,0,0,1,1,1,0,0,0,1,1,1,0,0,0,1,1,1};
const byte reg_data[18] = {0,1,2,3,4,5,8,9,10,11,12,13,16,17,18,19,20,21};
const byte ad_C0_offs[18] = {0,1,2,0,1,2,3,4,5,3,4,5,6,7,8,6,7,8};
const byte modify[28] = {0,3,1,4,2,5,6,9,7,10,8,11,12,15,13,16,14,17,12,\
								 15,16,0,14,0,17,0,13,0};
const byte bd_reg_data[124] = {\
				0x00,0x00,0x00,0x00,0x00,0x00,0x10,0x08,0x04,0x02,0x01,\
				0x00,0x01,0x01,0x03,0x0F,0x05,0x00,0x01,0x03,0x0F,0x00,\
				0x00,0x00,0x01,0x00,0x00,0x01,0x01,0x0F,0x07,0x00,0x02,\
				0x04,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x0A,\
				0x04,0x00,0x08,0x0C,0x0B,0x00,0x00,0x00,0x01,0x00,0x00,\
				0x00,0x00,0x0D,0x04,0x00,0x06,0x0F,0x00,0x00,0x00,0x00,\
				0x01,0x00,0x00,0x0C,0x00,0x0F,0x0B,0x00,0x08,0x05,0x00,\
				0x00,0x00,0x00,0x00,0x00,0x00,0x04,0x00,0x0F,0x0B,0x00,\
				0x07,0x05,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x01,0x00,\
				0x0F,0x0B,0x00,0x05,0x05,0x00,0x00,0x00,0x00,0x00,0x00,\
				0x00,0x01,0x00,0x0F,0x0B,0x00,0x07,0x05,0x00,0x00,0x00,\
				0x00,0x00,0x00};
BYTE for40reg[18] = {0x7F,0x7F,0x7F,0x7F,0x7F,0x7F,0x7F,0x7F,0x7F,\
							0x7F,0x7F,0x7F,0x7F,0x7F,0x7F,0x7F,0x7F,0x7F};
WORD a0b0_data2[11] = {0};
BYTE a0b0_data3[18] = {0};
BYTE a0b0_data4[18] = {0};
BYTE a0b0_data5[96] = {0};
BYTE addrs_head[96] = {0};
BYTE rix_stereo = 0;
ADDT reg_bufs[18] = {0};
WORD mus_time = 0x4268;
BYTE file_flag = 0;
BYTE music_on = 0;
BYTE pause_flag = 0;
WORD insbuf[28] = {0};
WORD band = 0;
BYTE band_low = 0;
WORD e0_reg_flag = 0;
BYTE bd_modify = 0;
WORD music_pass = 0;
WORD music_spd = 0;
WORD displace[11] = {0};
int unknown1 = 0;
void interrupt(*old)(); /* save old int */

#if MODERN_POSIX
static pthread_t g_timer_thread;
static volatile int g_timer_running = 0;
static volatile unsigned long long g_tick_ns = 0;
#if !defined(__MINGW32__)
static struct termios g_old_termios;
static int g_termios_ready = 0;
#endif
#endif
/************************************************************/
/*      prototype of functions                              */
/************************************************************/
#define ad_08_reg() ad_bop(8,0)    /**/
void ad_20_reg(WORD);              /**/
void ad_40_reg(WORD);              /**/
void ad_60_reg(WORD);              /**/
void ad_80_reg(WORD);              /**/
void ad_a0b0_reg(WORD);            /**/
void ad_a0b0l_reg(WORD,WORD,WORD); /**/
void ad_bd_reg();                  /**/
void ad_bop(WORD,WORD);                     /**/
void ad_C0_reg(WORD);              /**/
void ad_E0_reg(WORD);              /**/
word ad_initial();                 /**/
word ad_test();                    /**/
void crc_trans(WORD,WORD);         /**/
void data_initial();               /* done */
void init();                       /**/
void ins_to_reg(WORD,WORD*,WORD);  /**/
void interrupt int_08h_entry();    /**/
void music_ctrl();                 /**/
void Pause();                      /**/
void prep_int();                   /**/
void prepare_a0b0(WORD,WORD);      /**/
void rix_90_pro(WORD);             /**/
void rix_A0_pro(WORD,WORD);        /**/
void rix_B0_pro(WORD,WORD);        /**/
void rix_C0_pro(WORD,WORD);        /**/
void rix_get_ins();                /**/
word rix_proc();                   /**/
void set_new_int();                /**/
void set_old_int();                /**/
void set_speed(WORD);              /**/
void set_time(word);               /**/
void switch_ad_bd(WORD);           /**/
dword strm_and_fr(WORD);               /* done */

#if MODERN_LINUX_IO
static int linux_io_init(void);
static void linux_io_deinit(void);
#endif

#if MODERN_POSIX
static void *modern_timer_loop(void *arg);
static int modern_key_init(void);
static void modern_key_deinit(void);
#endif

/************************************************************/
/*                                                          */
/*    MAIN FUNCTION OF THE PROGRAM                          */
/*                                                          */
/************************************************************/
int main(int parmn,char *parms[])
{
 init_crash_handler();
 /*-------------------------- Title ------------------------*/
 printf("PlayRix Version 1.01 ](TUBRO Version)[\n");
 printf("Program writen by Pei-Cheng Tong using assembly 1994.\n");
 printf("\n[P]:Pause [C]:Continue [+,-]:Chang Speed\n");
 printf("[ESC] ---> Stop and End.\n");
 /*-------------------------- Usage ------------------------*/
 strcpy(progname, parms[0]);
 if(parmn < 2)
  printf("\nUsage: %s [FileName].Rix [PortHex].\n", progname),exit(1);
 if(parmn >= 3)
 {
	default_pass = (word)(strtoul(parms[2], NULL, 16) & 0xFFFFUL);
 }
 /*-------------------------- Get file ---------------------*/
 if(strlen(parms[1]) >= sizeof(filename))
  printf("\nFile path too long.\n"),exit(1);
 strcpy(filename, parms[1]);
 if(strlen(filename) < 4 || stricmp(filename+(strlen(filename)-4),".rix") != 0)
 {
  if(strlen(filename) + 4 >= sizeof(filename))
	printf("\nFile path too long.\n"),exit(1);
   strcat(filename, ".rix");
 }
 /*------------------------ preparations -------------------*/
#if MODERN_LINUX_IO
 if(!linux_io_init()) exit(1);
#endif
#if MODERN_POSIX
 if(!modern_key_init()) exit(1);
#endif
 init();
 set_new_int();
 music_pass = 0x388;
 data_initial();
 /*---------------------------------------------------------*/
 while(1)
 {
  switch(getkey())
  {
	case ESCAPE: music_pass = 0; set_old_int(); music_ctrl(); exit(0);
	case pause:  Pause(); break;
	case contn:  pause_flag = 0; break;
	case sub:    mus_time += 0x32; set_time(mus_time); break;
	case add:    mus_time += 0x32; set_time(mus_time); break;
  }
 }
}
/************************************************************/
/*                                                          */
/*               IMPLENEMTS OF FUNCIONTS                    */
/*                                                          */
/************************************************************/
void set_new_int()
{
	if(!ad_initial()) {
		printf("\nNo OPL card detected on port 0x%X.\n", default_pass);
		exit(1);
	} 
	prep_int();
}
/*----------------------------------------------------------*/
void Pause()
{
	register word i;
	pause_flag = 1;
	for(i=0;i<11;i++)
	switch_ad_bd(i);
}
/*----------------------------------------------------------*/
void init()
{
	fp = fopen(filename, "rb");
	if(fp == NULL) printf("\nUsage: %s [FileName].Rix.\n", progname),exit(1);
	fseek(fp,0,SEEK_END); filelen = ftell(fp);
	if(filelen > 32767 || filelen < 0) filelen = 32767;
	fseek(fp,0,SEEK_SET);
	fread(buf_addr,1,filelen,fp);
	fclose(fp);
}
/*----------------------------------------------------------*/
void data_initial()
{
	music_spd = mus_time;
	rix_stereo = buf_addr[2];
	mus_block = (buf_addr[0x0D]<<8)+buf_addr[0x0C];
	ins_block = (buf_addr[0x09]<<8)+buf_addr[0x08];
	I = mus_block+1;
	if(rix_stereo != 0)
	{
		printf("percussion mode ON\n");
		ad_a0b0_reg(6);
		ad_a0b0_reg(7);
		ad_a0b0_reg(8);
		ad_a0b0l_reg(8,0x18,0);
		ad_a0b0l_reg(7,0x1F,0);
	}else
		printf("percussion mode OFF\n");
	bd_modify = 0;
	ad_bd_reg();
	set_speed(mus_time);
	band = 0; music_on = 1;
}
/*----------------------------------------------------------*/
void set_old_int()
{
	set_time(0);
	#if MODERN_POSIX
	g_timer_running = 0;
	pthread_join(g_timer_thread, NULL);
	#else
	setvect(INT,old);
	#endif
}
/*----------------------------------------------------------*/
word ad_initial()
{
  register word i,j,k = 0;
  for(i=0;i<25;i++) crc_trans(i,i*4);
  for(i=0;i<8;i++)
  for(j=0;j<12;j++)
  {
	 a0b0_data5[k] = i;
	 addrs_head[k] = j;
	 k++;
  }
  ad_bd_reg();
  ad_08_reg();
  for(i=0;i<9;i++) ad_a0b0_reg(i);
  e0_reg_flag = 0x20;
  for(i=0;i<18;i++) ad_bop(0xE0+reg_data[i],0);
  ad_bop(1,e0_reg_flag);
  return ad_test();
}
/*----------------------------------------------------------*/
void crc_trans(WORD index,WORD v)
{
	register word i;
	dword res; word high,low;
	res = strm_and_fr(v);
	low = res; high = res>>16;
	buffer[index*12] = (low+4)>>3;
	for(i=1;i<=11;i++)
	{
		res *= 1.06;
		buffer[index*12+i] = (res+4)>>3;
	}
}
/*----------------------------------------------------------*/
void set_time(word v)
{
	#if MODERN_POSIX
	unsigned int divisor = (v == 0) ? 65536U : (unsigned int)v;
	g_tick_ns = ((unsigned long long)divisor * 1000000000ULL) / 1193180ULL;
	#else
	disable();
	outportb(0x43,0x36);
	outportb(0x40,v&0xFF);
	outportb(0x40,v>>8);
	enable();
	#endif
}
/*----------------------------------------------------------*/
void prep_int()
{
	set_time(0);
	file_flag = 0;
	#if MODERN_POSIX
	g_timer_running = 1;
	pthread_create(&g_timer_thread, NULL, modern_timer_loop, NULL);
	#else
	old = getvect(INT);
	setvect(INT,int_08h_entry);
	#endif
}
/*----------------------------------------------------------*/
void ad_bop(WORD reg,WORD value)
{
	register int i;
	//log_opl_write(default_pass, reg, value);
	outportb(default_pass,reg&0xff);
	for(i=0;i<6;i++)
	inportb(default_pass);
	outportb(default_pass+1,value&0xff);
	for(i=0;i<35;i++)
	inportb(default_pass);
}
/*------------------------------------------------------*/
word ad_test()   /* Test the SoundCard */
{
	unsigned char result1 = 0,result2 = 0;
	register short i;
	ad_bop(0x04,0x60);
	ad_bop(0x04,0x80);
	result1 = inportb(default_pass);
	ad_bop(0x02,0xFF);
	ad_bop(0x04,0x21);
	for(i=0;i<0xC8;i++) inportb(default_pass);
	result2 = inportb(default_pass);
	ad_bop(0x04,0x60);
	ad_bop(0x04,0x80);
	if(result1&0xE0 != 0) return 0;
	if(result2&0xE0 != 0xC0) return 0;
	return 1;
}
/*--------------------------------------------------------------*/
void interrupt int_08h_entry()
{
	word temp = 1;
#if defined(__GNUC__) && !MODERN_POSIX
	outportb(0x20,0x20);
#elif !MODERN_POSIX
	old();
#endif
	while(temp)
	if(unknown1 <= 0 && file_flag == 0)
	{
		enable();
		file_flag++;
		temp = rix_proc();
		disable();
		if(temp) unknown1 += temp;
		file_flag--;
		enable();
		if(temp == 0) break;
	}
	else
	{
		if(temp) unknown1 -= 14;
		break;
	}
}
/*--------------------------------------------------------------*/
word rix_proc()
{
	byte ctrl = 0;
	if(music_on == 0||pause_flag == 1) return 0;
	band = 0;
	while(buf_addr[I] != 0x80 && I<filelen-1)
	{
		band_low = buf_addr[I-1];
		ctrl = buf_addr[I]; I+=2;
		switch(ctrl&0xF0)
		{
			case 0x90:  rix_get_ins(); rix_90_pro(ctrl&0x0F); break;
			case 0xA0:  rix_A0_pro(ctrl&0x0F,((word)band_low)<<6); break;
			case 0xB0:  rix_B0_pro(ctrl&0x0F,band_low); break;
			case 0xC0:  switch_ad_bd(ctrl&0x0F);
							if(band_low != 0) rix_C0_pro(ctrl&0x0F,band_low);
							break;
			default:    band = (ctrl<<8)+band_low; break;
		}
		if(band != 0) return band;
	}
	music_ctrl();
	if(music_pass == 0) return 0;
	else if(music_pass != 0xFFFF) music_pass--;
	set_speed(music_spd); I = mus_block+1;
	band = 0; music_on = 1;
	return 0;
}
/*--------------------------------------------------------------*/
void rix_get_ins()
{
	memcpy(insbuf,(&buf_addr[ins_block])+(band_low<<6),56);
}
/*--------------------------------------------------------------*/
void rix_90_pro(WORD ctrl_l)
{
	if(rix_stereo == 0 || ctrl_l < 6)
	{
		ins_to_reg(modify[ctrl_l*2],insbuf,insbuf[26]);
		ins_to_reg(modify[ctrl_l*2+1],insbuf+13,insbuf[27]);
		return;
	}
	else if(ctrl_l > 6)
		{
			ins_to_reg(modify[ctrl_l*2+6],insbuf,insbuf[26]);
			return;
		}
		else
		{
			ins_to_reg(12,insbuf,insbuf[26]);
			ins_to_reg(15,insbuf+13,insbuf[27]);
			return;
		}
}
/*--------------------------------------------------------------*/
void rix_A0_pro(WORD ctrl_l,WORD index)
{
	if(rix_stereo == 0 || ctrl_l <= 6)
	{
		prepare_a0b0(ctrl_l,index>0x3FFF?0x3FFF:index);
		ad_a0b0l_reg(ctrl_l,a0b0_data3[ctrl_l],a0b0_data4[ctrl_l]);
	}
	else return;
}
/*--------------------------------------------------------------*/
void prepare_a0b0(word index,word v)  /* important !*/
{
    long res = ((long)v-0x2000)*0x19/0x2000;
    long sgn=(res<0?-1:0);
    a0b0_data2[index]=sgn;
    displace[index]=(sgn>=0?(24*res):(576-(-res-1)*24));
}
/*--------------------------------------------------------------*/
void ad_a0b0l_reg(WORD index,WORD p2,WORD p3)
{
	WORD data; word i = p2+a0b0_data2[index];
	a0b0_data4[index] = p3;
	a0b0_data3[index] = p2;
	i = ((signed)i<=0x5F?i:0x5F);
	i = ((signed)i>=0?i:0);
	data = buffer[addrs_head[i]+displace[index]/2];
	ad_bop(0xA0+index,data);
	data = a0b0_data5[i]*4+(p3<1?0:0x20)+((data>>8)&3);
	ad_bop(0xB0+index,data);
}
/*--------------------------------------------------------------*/
void rix_B0_pro(WORD ctrl_l,WORD index)
{
	register int temp = 0;
	if(rix_stereo == 0 || ctrl_l < 6) temp = modify[ctrl_l*2+1];
	else
	{
		temp = ctrl_l > 6?ctrl_l*2:ctrl_l*2+1;
		temp = modify[temp+6];
	}
	for40reg[temp] = index>0x7F?0x7F:index;
	ad_40_reg(temp);
}
/*--------------------------------------------------------------*/
void rix_C0_pro(WORD ctrl_l,WORD index)
{
	register word i = index>=12?index-12:0;
	if(ctrl_l < 6 || rix_stereo == 0)
	{
		ad_a0b0l_reg(ctrl_l,i,1);
		return;
	}
	else
	{
		if(ctrl_l != 6)
		{
			if(ctrl_l == 8)
			{
				ad_a0b0l_reg(ctrl_l,i,0);
				ad_a0b0l_reg(7,i+7,0);
			}
		}
		else ad_a0b0l_reg(ctrl_l,i,0);
		bd_modify |= bd_reg_data[ctrl_l];
		ad_bd_reg();
		return;
	}
}
/*--------------------------------------------------------------*/
void switch_ad_bd(WORD index)
{

	if(rix_stereo == 0 || index < 6) ad_a0b0l_reg(index,a0b0_data3[index],0);
	else
	{
		bd_modify &= (~bd_reg_data[index]),
		ad_bd_reg();
	}
}
/*--------------------------------------------------------------*/
void ins_to_reg(WORD index,WORD* insb,WORD value)
{
	register word i;
	for(i=0;i<13;i++) reg_bufs[index].v[i] = insb[i];
	reg_bufs[index].v[13] = value&3;
	ad_bd_reg(),ad_08_reg(),
	ad_40_reg(index),ad_C0_reg(index),ad_60_reg(index),
	ad_80_reg(index),ad_20_reg(index),ad_E0_reg(index);
}
/*--------------------------------------------------------------*/
void ad_E0_reg(WORD index)
{
	WORD data = e0_reg_flag == 0?0:(reg_bufs[index].v[13]&3);
	ad_bop(0xE0+reg_data[index],data);
}
/*--------------------------------------------------------------*/
void ad_20_reg(WORD index)
{
	WORD data = (reg_bufs[index].v[9] < 1?0:0x80);
	data += (reg_bufs[index].v[10] < 1?0:0x40);
	data += (reg_bufs[index].v[5] < 1?0:0x20);
	data += (reg_bufs[index].v[11] < 1?0:0x10);
	data += (reg_bufs[index].v[1]&0x0F);
	ad_bop(0x20+reg_data[index],data);
}
/*--------------------------------------------------------------*/
void ad_80_reg(WORD index)
{
	WORD data = (reg_bufs[index].v[7]&0x0F),temp = reg_bufs[index].v[4];
	data |= (temp << 4);
	ad_bop(0x80+reg_data[index],data);
}
/*--------------------------------------------------------------*/
void ad_60_reg(WORD index)
{
	WORD data = reg_bufs[index].v[6]&0x0F,temp = reg_bufs[index].v[3];
	data |= (temp << 4);
	ad_bop(0x60+reg_data[index],data);
}
/*--------------------------------------------------------------*/
void ad_C0_reg(WORD index)
{
	WORD data = reg_bufs[index].v[2];
	if(adflag[index] == 1) return;
	data *= 2,
	data |= (reg_bufs[index].v[12] < 1?1:0);
	ad_bop(0xC0+ad_C0_offs[index],data);
}
/*--------------------------------------------------------------*/
void ad_40_reg(WORD index)
{
	DWORD res = 0;
	WORD data = 0,temp = reg_bufs[index].v[0];
	data = 0x3F - (0x3F & reg_bufs[index].v[8]),
	data *= for40reg[index],
	data *= 2,
	data += 0x7F,
	res = data;
	data = res/0xFE,
	data -= 0x3F,
	data = -data,
	data |= temp<<6;
	ad_bop(0x40+reg_data[index],data);
}
/*--------------------------------------------------------------*/
void ad_bd_reg()
{
	WORD data = rix_stereo < 1? 0:0x20;
	data |= bd_modify;
	ad_bop(0xBD,data);
}
/*--------------------------------------------------------------*/
void ad_a0b0_reg(word index)
{
	ad_bop(0xA0+index,0);
	ad_bop(0xB0+index,0);
}
/*--------------------------------------------------------------*/
void set_speed(word spd)
{
	set_time(spd);
}
/*--------------------------------------------------------------*/
void music_ctrl()
{
	register int i;
	music_on = 0;
	for(i=0;i<11;i++)
	switch_ad_bd(i);
	set_speed(0);
}
/*----------------------------------------------------------------------*/
DWORD strm_and_fr(WORD parm)
{
	return ((DWORD)parm*6+10000)*0.27461678223;
}

#if MODERN_LINUX_IO
static int linux_io_init(void)
{
	if(iopl(3) != 0)
	{
		perror("iopl(3)");
		return 0;
	}
	atexit(linux_io_deinit);
	return 1;
}

static void linux_io_deinit(void)
{
	iopl(0);
}
#endif

#if MODERN_POSIX
static void *modern_timer_loop(void *arg)
{
	#if defined(__MINGW32__)
	(void)arg;
	while(g_timer_running)
	{
		unsigned long long ns = g_tick_ns;
		DWORD ms = (DWORD)((ns + 999999ULL) / 1000000ULL);
		if(ms == 0) ms = 1;
		Sleep(ms);
		if(g_timer_running) int_08h_entry();
	}
	return NULL;
	#else
	struct timespec now;
	struct timespec next;
	
	(void)arg;
	clock_gettime(CLOCK_MONOTONIC, &now);
	next = now;

	if(g_tick_ns == 0) g_tick_ns = (65536ULL * 1000000000ULL) / 1193180ULL;

	while(g_timer_running)
	{
		unsigned long long ns = g_tick_ns;
		next.tv_nsec += (long)ns;
		while(next.tv_nsec >= 1000000000L)
		{
			next.tv_nsec -= 1000000000L;
			next.tv_sec += 1;
		}
		clock_nanosleep(CLOCK_MONOTONIC, TIMER_ABSTIME, &next, NULL);
		if(g_timer_running) int_08h_entry();
	}
	return NULL;
	#endif
}

static int modern_key_init(void)
{
	#if defined(__MINGW32__)
	return 1;
	#else
	if(tcgetattr(STDIN_FILENO, &g_old_termios) != 0)
	{
		perror("tcgetattr");
		return 0;
	}
	{
		struct termios raw = g_old_termios;
		raw.c_lflag &= ~(ICANON | ECHO);
		raw.c_cc[VMIN] = 1;
		raw.c_cc[VTIME] = 0;
		if(tcsetattr(STDIN_FILENO, TCSANOW, &raw) != 0)
		{
			perror("tcsetattr");
			return 0;
		}
	}
	g_termios_ready = 1;
	atexit(modern_key_deinit);
	return 1;
	#endif
}

static void modern_key_deinit(void)
{
	#if !defined(__MINGW32__)
	if(g_termios_ready)
	{
		tcsetattr(STDIN_FILENO, TCSANOW, &g_old_termios);
		g_termios_ready = 0;
	}
	#endif
}
#endif
