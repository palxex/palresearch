/************************************************************/
/*                                                          */
/*     THE C SOURCE OF PLAYRIX. PROGRAMMED BY BSPAL         */
/*     USING TURBOC 2.01 IN JULY 2004                       */
/*                                                          */
/************************************************************/
#ifdef __TINY__
#error This prorgram should compiled above tiny mode
#endif
/*----------------------------------------------------------*/
#include <string.h>
#include <stdio.h>
#include <dos.h>
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
enum bool {false,true};
/************************************************************/
int getkey()
{
	union REGS reg;
	reg.x.ax = 0,
	int86(0x16,&reg,&reg);
	return reg.h.ah;
}
/************************************************************/
/*      global various and flags                            */
/************************************************************/
#define default_pass 0x388;
FILE * fp = NULL;
FILE * tfp = NULL;
char filename[12] = {0};
DWORD filelen = 0;
static DWORD I = 0;
BYTE buf_addr[32768] = {0};  /* rix files' buffer */
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
void ad_bop();                     /**/
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
dword strm_and_fr();               /* done */

/************************************************************/
/*                                                          */
/*    MAIN FUNCTION OF THE PROGRAM                          */
/*                                                          */
/************************************************************/
main(int parmn,char *parms[])
{
 /*-------------------------- Title ------------------------*/
 printf("PlayRix Version 1.01 ](TUBRO Version)[\n");
 printf("Program writen by Pei-Cheng Tong using assembly 1994.\n");
 printf("\n[P]:Pause [C]:Continue [+,-]:Chang Speed\n");
 printf("[CTRL] ---> Stop and End.\n");
 /*-------------------------- Get file ---------------------*/
 strcpy(filename, parms[1]);
 if(strcmp(filename+(strlen(parms[1])-4),".rix") != 0)
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
 while(true)
 {
  switch(getkey())
  {
	case ESCAPE: music_pass = 0; music_ctrl(); set_old_int(); exit(0);
	case pause:  Pause(); break;
	case contn:  pause_flag = 0; break;
	case sub:    mus_time += 0x32; set_time(mus_time); break;
	case add:    break;
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
		ad_a0b0_reg(6);
		ad_a0b0_reg(7);
		ad_a0b0_reg(8);
		ad_a0b0l_reg(8,0x18,0);
		ad_a0b0l_reg(7,0x1F,0);
	}
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
		buffer[index*12+i] = res>>3;
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
	register int i;
	outportb(0x388,reg);
	for(i=0;i<6;i++)
	inportb(0x388);
	outportb(0x389,value);
	for(i=0;i<35;i++)
	inportb(0x388);
}
/*------------------------------------------------------*/
word ad_test()   /* Test the SoundCard */
{
	unsigned char result1 = 0,result2 = 0;
	register short i;
	ad_bop(0x04,0x60);
	ad_bop(0x04,0x80);
	result1 = inportb(0x388);
	ad_bop(0x02,0xFF);
	ad_bop(0x04,0x21);
	for(i=0;i<0xC8;i++) inportb(0x388);
	result2 = inportb(0x388);
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
	old();
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
	else
	{
		if(ctrl_l > 6)
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
	short high = 0,low = 0; dword res;
	low = ((unsigned)(v-0x2000))*0x19;
	high = ((short)v)<0x2000?0xFFFF:0;
	if(low == 0xFF && high == 0) return;
	res = (((DWORD)high)|low)/0x2000;
	low = res&0xFFFF;
	if(low < 0)
	{
		low = 0x18-low; high = (signed)low<0?0xFFFF:0;
		res = high; res<<=16; res+=low;
		low = ((signed)res)/(signed)0xFFE7;
		a0b0_data2[index] = low;
		low = res;
		res = low - 0x18;
		high = (signed)res%0x19;
		low = (signed)res/0x19;
		if(high != 0) {low = 0x19; low = low-high;}
	}
	else
	{
		res = high = low;
		low = (signed)res/(signed)0x19;
		a0b0_data2[index] = low;
		res = high;
		low = (signed)res%(signed)0x19;
	}
	low = (signed)low*(signed)0x18;
	displace[index] = low;
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