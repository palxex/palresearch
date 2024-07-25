/************************************************************/
/*                                                          */
/*     DERIX262 IS AN OPEN SOURCE RIX PLAYER BASED ON       */
/*     THE C SOURCE OF PLAYRIX BY BSPAL.                    */
/*     SDLPAL TEAM, 2004-2019                               */
/*                                                          */
/************************************************************/

/*
// DERIX262 is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/



#ifdef __TINY__
#error This prorgram should compiled above tiny mode
#endif
/*----------------------------------------------------------*/
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <dos.h>
#include <math.h>

#ifdef __WATCOMC__
#include <conio.h>
#define enable _enable
#define disable _disable
#define getvect _dos_getvect
#define setvect _dos_setvect
#define outportb outp
#define inportb inp
#endif

#ifdef __GNUC__
#ifdef __DJGPP__
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
#else //assume ia16-elf-gcc
#ifndef __FAR
#error This prorgram only support ia16-elf-gcc
#endif
#define __GCCIA16__ 1
#define interrupt static __far
#define farpointer __far
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
void setvect(int intno, void __far *vect)
{
        asm volatile("int $0x21" :
                     : "Rah"((char)0x25), "Ral"((char)intno),
                       "Rds"(FP_SEG(vect)), "d"(FP_OFF(vect)));
}
#endif //DJGPP
#endif //GNUC
#ifndef farpointer
#define farpointer
#endif

#define OPL3_EXTREG_BASE    0x100
#define OPL3_4OP_REGISTER   0x104
#define OPL3_MODE_REGISTER  0x105

#define calcFNum() ((dbOriginalFreq + (dbOriginalFreq / freq_offset)) / (opl_freq * pow(2.0, iNewBlock - 20)))

#define NEWBLOCK_LIMIT  32

typedef unsigned char uint8_t;
typedef unsigned short uint16_t;

uint8_t iFMReg[32];        /* The original values of OPL registers Ax and Bx */
uint8_t iTweakedFMReg[32]; /* The modified values of OPL registers Ax and Bx */
int    percussion;        /* Is the OPL chip worked at percussion mode? */

/************************************************************/
#define ESCAPE 0x01
#define add    0x4E
#define sub		0x4A
#define pause	0x19
#define contn	0x2E
#define INT    0x08

#define chn0   0x02
#define chn1   0x03
#define chn2   0x04
#define chn3   0x05
#define chn4   0x06
#define chn5   0x07
#define chn6   0x08
#define chn7   0x09
#define chn8   0x0A
#define chn9   0x0B
#define chn10  0x0C
#define chn11  0x0D
#define chnAll 0x0E

typedef unsigned short WORD;
typedef unsigned short word;
typedef unsigned char  BYTE;
typedef unsigned char  byte;
typedef unsigned long  DWORD;
typedef unsigned long  dword;
typedef struct {BYTE v[14];}ADDT;
typedef struct {WORD v[12];}BFDT;
#ifndef __DJGPP__
enum bool {false,true};
#endif
/************************************************************/
int getkey()
{
	union REGS reg;
	reg.x.ax = 0;
#if __GCCIA16__
	__asm__ __volatile__("movw %%ax, 0; int $0x16":"=a"(reg.x.ax));
#else
	int86(0x16,&reg,&reg);
#endif
	return reg.h.ah;
}
/************************************************************/
/*      global various and flags                            */
/************************************************************/
#define default_pass 0x220
FILE * fp = NULL;
FILE * tfp = NULL;
char filename[12] = {0};
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
void interrupt(*old)() farpointer; /* save old int */

int i;
int channel_on[11];
int channel_vol[11];

/************************************************************/
/*      prototype of functions                              */
/************************************************************/
#define ad_08_reg() ad_bop(8,0)    /**/
void chn_toogle(WORD);             /**/

void ad_20_reg(WORD);              /**/
void ad_40_reg(WORD);              /**/
void ad_60_reg(WORD);              /**/
void ad_80_reg(WORD);              /**/
void ad_a0b0_reg(WORD);            /**/
void ad_a0b0l_reg(WORD,WORD,WORD); /**/
void ad_bd_reg();                  /**/
void ad_bop(WORD,WORD);                     /**/
void ad_bopw(WORD,WORD);                    /*Real ad_bop*/
int TweakFMReg(double freq_offset, double opl_freq, int reg, int val, uint8_t iFMReg[32], uint8_t iTweakedFMReg[32]);
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
void rix_B0_pro_w(WORD,WORD);      /**/
void rix_C0_pro(WORD,WORD);        /**/
void rix_get_ins();                /**/
word rix_proc();                   /**/
void set_new_int();                /**/
void set_old_int();                /**/
void set_speed(WORD);              /**/
void set_time(word);               /**/
void switch_ad_bd(WORD);           /**/
dword strm_and_fr(WORD);               /* done */

/************************************************************/
/*                                                          */
/*    MAIN FUNCTION OF THE PROGRAM                          */
/*                                                          */
/************************************************************/
main(int parmn,char *parms[])
{
 int keycode;
 /*-------------------------- Title ------------------------*/
 printf("DERIX262 Version 0.10 by SDLPal Team\n");
 printf("\nAn Open Source (GPL v3) Reimplementation of\n");
 printf("    PlayRix Version 1.01 (TUBRO Version)\n");
 printf("    Program writen by Pei-Cheng Tong using assembly 1994.\n");
 printf("\nThis program requires OPL3(YMF262) or compatible chips.\n");
 printf("Surround OPL function comes from AdPlug and SDLPal. \n");
 printf("\n[P]:Pause [C]:Continue [1] to [-]:Single Channel ON/OFF \n");
 printf("[ESC] ---> Stop and End.\n");

 /*-------------------------- Get file ---------------------*/
 strcpy(filename, parms[1]);
 if(stricmp(filename+(strlen(parms[1])-4),".rix") != 0)
	strcat(filename, ".rix\0");
 /*-------------------------- Usage ------------------------*/
 if(parmn < 2)
  printf("\nUsage: PlayRix [FileName].Rix.\n"),exit(1);
 /*------------------------ preparations -------------------*/
 init();
 set_new_int();
 music_pass = 0x388;
 data_initial();
 /*---------------------------------------------------------*/
 for (i = 0; i < 11; i++)
 {
	 channel_on[i] = 1;
	 channel_vol[i] = 0;
 }
 while(true)
 {
  switch(getkey())
  {
	case ESCAPE: music_pass = 0; music_ctrl(); set_old_int();ad_bopw(OPL3_MODE_REGISTER, 0);  exit(0);
	case pause:  Pause(); break;
	case contn:  pause_flag = 0; break;
	case sub:    mus_time += 0x32; set_time(mus_time); break;
	case add:    break;
	
	case chn0:   chn_toogle(0); break;
	case chn1:   chn_toogle(1); break;
	case chn2:   chn_toogle(2); break;
	case chn3:   chn_toogle(3); break;
	case chn4:   chn_toogle(4); break;
	case chn5:   chn_toogle(5); break;
	case chn6:   chn_toogle(6); break;
	case chn7:   chn_toogle(7); break;
	case chn8:   chn_toogle(8); break;
	case chn9:   chn_toogle(9); break;
	case chn10:  chn_toogle(10); break;
	case chnAll: break;
  }
 }
}
/************************************************************/
/*                                                          */
/*               IMPLENEMTS OF FUNCIONTS                    */
/*                                                          */
/************************************************************/
void chn_toogle(WORD channel)
{
	if (channel_on[channel] == 1)
	{
		channel_on[channel] = 0;
		rix_B0_pro_w(channel,0);
	}
	else{
		channel_on[channel] = 1;
		rix_B0_pro_w(channel,channel_vol[channel]);
	}
															  
}
/*----------------------------------------------------------*/

void set_new_int()
{
	if(!ad_initial()) exit(1);
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
	if(fp == NULL) printf("\nUsage: PlayRix [FileName].Rix.\n"),exit(1);
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
	setvect(INT,old);
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
  
  ad_bopw(OPL3_MODE_REGISTER, 1);
  ad_bopw(OPL3_4OP_REGISTER, 0);
  
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
	disable();
	outportb(0x43,0x36);
	outportb(0x40,v&0xFF);
	outportb(0x40,v>>8);
	enable();
}
/*----------------------------------------------------------*/
void prep_int()
{
	set_time(0);
	file_flag = 0;
	old = getvect(INT);
	setvect(INT,int_08h_entry);
}
/*----------------------------------------------------------*/
void ad_bop(WORD reg,WORD value)
{
/*	register int i;
	outportb(default_pass,reg&0xff);
	for(i=0;i<6;i++)
	inportb(default_pass);
	outportb(default_pass+1,value&0xff);
	for(i=0;i<35;i++)
	inportb(default_pass);
*/
	
	long group = reg >> 4;
	int iRegister = 0;


	if (group == 0xC)
	{
		if ((reg & 0xF) <= 5 || !percussion)
		{
			ad_bopw(reg, value | 0x10);                    /* Lower channels goes to left */
			ad_bopw(reg | OPL3_EXTREG_BASE, value | 0x20); /* Higher channels goes to right */
		}
		else
		{
			ad_bopw(reg, value | 0x30);                    /* Percussion channels goes to both */
		}
	}
	else
	{
		ad_bopw(reg, value);                               /* Write the original OPL data */
		if (reg != (OPL3_4OP_REGISTER  & 0xFF) &&
			reg != (OPL3_MODE_REGISTER & 0xFF) &&               /* 0x104 & 0x105 has special meanings in OPL3 */
			group != 0xA && group != 0xB &&                     /* Group 0xA & 0xB are the key to harmonic effect */
			(!percussion || (group & 0x1) == 0x0))              /* For groups 0x2-0x9 and 0xE-0xF, percussion channels */
		{                                                       /* resides in odd-group registers. */
		ad_bopw(reg | OPL3_EXTREG_BASE, value);        /* Write the same data into counterpart registers */
		}
	}
	
	if (reg == 0xBD)
	{
		/* // Bit 5 in register 0xBD controls whether percussion mode is enabled */
		percussion = ((value & 0x20) != 0);
	}
	else if ((group == 0xA || group == 0xB) && ((reg & 0xF) <= 5 || !percussion))
	{
		/* This is a register we're interested in */
		if (TweakFMReg(384, 49716, reg, value, iFMReg, iTweakedFMReg))
		{
			/* We need to adjust the upper/lower bits
			// If current reg is within [0xA0, 0xA8], we should write to [0x1B0, 0x1B8]
			// If current reg is within [0xB0, 0xB8], we should write to [0x1A0, 0x1A8] */
			iRegister = (reg | OPL3_EXTREG_BASE) + ((reg >> 4 == 0xA) ? 0x10 : -0x10);
			ad_bopw(iRegister, iTweakedFMReg[iRegister & 0x1F]);
		}

		/* Now write to the counterpart with a possibly modified value */
		ad_bopw(reg | OPL3_EXTREG_BASE, iTweakedFMReg[reg & 0x1F]);
	}
}
int TweakFMReg(double freq_offset, double opl_freq, int reg, int val, uint8_t iFMReg[32], uint8_t iTweakedFMReg[32])
{
	int iRegister = reg & 0x1F;
	int iChannel = reg & 0xF;
	
	uint8_t iBlock = 0, iNewBlock = 0;
	uint16_t iFNum = 0, iNewFNum = 0;
	double dbOriginalFreq = 0;
	double dbNewFNum = 0;
	
	unsigned char iNewB0Value = 0;
	
	/* printf("freq_offset = %#f \n", freq_offset);
	printf("iFNum = %#f \n", iFNum);
	printf("dbOriginalFreq = %#lX \n", dbOriginalFreq);
	printf("dbNewFNum = %#lX \n", dbNewFNum);
	printf("iFMReg[32] = %#lX \n", iFMReg[32]);
	printf("iTweakedFMReg[32] = %#lX \n\n", iTweakedFMReg[32]);*/

	/* Remember the FM state, so that the harmonic effect can access */
	/* previously assigned register values. */
	iFMReg[iRegister] = val;
	
	iBlock = (iFMReg[iChannel | 0x10] >> 2) & 0x07, iNewBlock = iBlock;
	iFNum = ((iFMReg[iChannel | 0x10] & 0x03) << 8) | iFMReg[iChannel], iNewFNum;
	dbOriginalFreq = opl_freq * (double)iFNum * pow(2.0, iBlock - 20);
	dbNewFNum = calcFNum();	/* Adjust the frequency and calculate the new FNum */

	/* Make sure it's in range for the OPL chip */
	if (dbNewFNum > 1023 - NEWBLOCK_LIMIT) {
		/* It's too high, so move up one block (octave) and recalculate */

		if (iNewBlock > 6) {
			/* Uh oh, we're already at the highest octave!
			//				AdPlug_LogWrite("OPL WARN: FNum %d/B#%d would need block 8+ after being transposed (new FNum is %d)\n",
			//					iFNum, iBlock, (int)dbNewFNum);
			// The best we can do here is to just play the same note out of the second OPL, so at least it shouldn't
			// sound *too* bad (hopefully it will just miss out on the nice harmonic.) */
			iNewBlock = iBlock;
			iNewFNum = iFNum;
		}
		else {
			iNewBlock++;
			iNewFNum = (uint16_t)calcFNum();
		}
	}
	else if (dbNewFNum < 0 + NEWBLOCK_LIMIT) {
		/* It's too low, so move down one block (octave) and recalculate */

		if (iNewBlock == 0) {
			/* Uh oh, we're already at the lowest octave! 
			//				AdPlug_LogWrite("OPL WARN: FNum %d/B#%d would need block -1 after being transposed (new FNum is %d)!\n",
			//					iFNum, iBlock, (int)dbNewFNum);
			// The best we can do here is to just play the same note out of the second OPL, so at least it shouldn't
			// sound *too* bad (hopefully it will just miss out on the nice harmonic.) */
			iNewBlock = iBlock;
			iNewFNum = iFNum;
		}
		else {
			iNewBlock--;
			iNewFNum = (uint16_t)calcFNum();
		}
	}
	else {
		/* Original calculation is within range, use that */
		iNewFNum = (uint16_t)dbNewFNum;
	}

	/* Sanity check */
	if (iNewFNum > 1023) {
		/* Uh oh, the new FNum is still out of range! (This shouldn't happen)
		//AdPlug_LogWrite("OPL ERR: Original note (FNum %d/B#%d is still out of range after change to FNum %d/B#%d!\n",
		//	iFNum, iBlock, iNewFNum, iNewBlock);
		// The best we can do here is to just play the same note out of the second OPL, so at least it shouldn't
		// sound *too* bad (hopefully it will just miss out on the nice harmonic.) */
		iNewBlock = iBlock;
		iNewFNum = iFNum;
	}

	if (reg >= 0xB0 && reg <= 0xB8) {
		/* Overwrite the supplied value with the new F-Number and Block. */
		iTweakedFMReg[iRegister] = (val & ~0x1F) | (iNewBlock << 2) | ((iNewFNum >> 8) & 0x03);

		if (iTweakedFMReg[iChannel] != (iNewFNum & 0xFF)) {
			/* Need to write out low bits */
			iTweakedFMReg[iChannel] = iNewFNum & 0xFF;
			return 1;
		}
	}
	else if (reg >= 0xA0 && reg <= 0xA8) {
		/* Overwrite the supplied value with the new F-Number. */
		iTweakedFMReg[iRegister] = iNewFNum & 0xFF;

		/* See if we need to update the block number, which is stored in a different register */
		iNewB0Value = (iFMReg[iChannel | 0x10] & ~0x1F) | (iNewBlock << 2) | ((iNewFNum >> 8) & 0x03);
		if ((iNewB0Value & 0x20) && /* but only update if there's a note currently playing (otherwise we can just wait */
			(iTweakedFMReg[iChannel | 0x10] != iNewB0Value)   /* until the next noteon and update it then) */
			) {
			/*AdPlug_LogWrite("OPL INFO: CH%d - FNum %d/B#%d -> FNum %d/B#%d == keyon register update!\n",
			//	iChannel, iFNum, iBlock, iNewFNum, iNewBlock);
			// The note is already playing, so we need to adjust the upper bits too */
			iTweakedFMReg[iChannel | 0x10] = iNewB0Value;
			return 1;
		} /* else the note is not playing, the upper bits will be set when the note is next played */
	} /* if (register 0xB0 or 0xA0) */

	return 0;
}
void ad_bopw(WORD reg,WORD value)
{
	register int i;
	WORD base_port = 0x388 + ((reg >> 7) & 0x2);
	outportb(base_port,reg);
	for(i=0;i<6;i++)
	inportb(base_port);
	outportb(base_port + 1,value);
	for(i=0;i<35;i++)
	inportb(base_port);
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
	for (i = 0; i < 11; i++)
	{
		if(channel_on[i] == 1)
		{
			printf("[%3d] ", channel_vol[i]);
		}else
		{
			printf(" %3d  ", channel_vol[i]);
		}
	}
	printf("\r");
#ifdef __GNUC__
	__asm__ __volatile__("cld");
	outportb(0x20,0x20);
#else
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
void rix_B0_pro_w(WORD ctrl_l,WORD index)
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
void rix_B0_pro(WORD ctrl_l,WORD index)
{
	channel_vol[ctrl_l] = index;
	if(channel_on[ctrl_l] == 1)
	{
		rix_B0_pro_w(ctrl_l, index);
	}
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