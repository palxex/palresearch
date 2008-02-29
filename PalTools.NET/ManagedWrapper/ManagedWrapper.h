// ManagedWrapper.h

#pragma once

#include "Library.h"

using namespace System;
using namespace System::Runtime::InteropServices;

namespace PalTools {

	public enum class MkfFile
	{
		MKF_ABC,	MKF_BALL,	MKF_DATA,	MKF_F,
		MKF_FBP,	MKF_FIRE,	MKF_GOP,	MKF_MAP,
		MKF_MGO,	MKF_MIDI,	MKF_MUS,	MKF_PAT,
		MKF_RGM,	MKF_RNG,	MKF_SOUNDS,	MKF_SSS,
		MKF_VOC
	};

	public value struct MkfBufferItem
	{
		array<unsigned char> ^Buffer;
		int Size;
	};

	public value struct MkfBufferGroup
	{
		array<MkfBufferItem> ^Item;
		int Count;
	};

	[StructLayout(LayoutKind::Explicit, Size = 70, CharSet = CharSet::Ansi)]
	public value struct PalMonsterData
	{
		[MarshalAs(UnmanagedType::ByValArray, SizeConst = 11)]
		[FieldOffset(0)]array<short> ^Attribute;
		[FieldOffset(22)]short Hp;
		[FieldOffset(24)]short Exp;
		[FieldOffset(26)]short Money;
		[FieldOffset(28)]short Level;
		[FieldOffset(30)]short Magic;
		[FieldOffset(32)]short Magic_feq;
		[FieldOffset(34)]short Thing;
		[FieldOffset(36)]short Thing_feq;
		[FieldOffset(38)]short Steal;
		[FieldOffset(40)]short Steal_num;
		[FieldOffset(42)]short Wushu;
		[FieldOffset(44)]short Lingli;
		[FieldOffset(46)]short Fangyu;
		[FieldOffset(48)]short Shengfa;
		[FieldOffset(50)]short Jiyun;
		[FieldOffset(52)]short Anti_poison;
		[FieldOffset(54)]short Anti_wind;
		[FieldOffset(56)]short Anti_thunder;
		[FieldOffset(58)]short Anti_water;
		[FieldOffset(60)]short Anti_fire;
		[FieldOffset(62)]short Anti_earth;
		[FieldOffset(64)]short Anti_physical;
		[FieldOffset(66)]short Again;
		[FieldOffset(68)]short Linghu;
	};

	[StructLayout(LayoutKind::Explicit, Size = 18, CharSet = CharSet::Ansi)]
	public value struct PalShopData
	{
		[MarshalAs(UnmanagedType::ByValArray, SizeConst = 9)]
		[FieldOffset(0)]array<short> ^Data;
	};

	[StructLayout(LayoutKind::Explicit, Size = 10, CharSet = CharSet::Ansi)]
	public value struct PalTeamData
	{
		[MarshalAs(UnmanagedType::ByValArray, SizeConst = 5)]
		[FieldOffset(0)]array<short> ^Data;
	};

	[StructLayout(LayoutKind::Explicit, Size = 14, CharSet = CharSet::Ansi)]
	public value struct PalObjectData
	{
		[StructLayout(LayoutKind::Explicit, Size = 7, CharSet = CharSet::Ansi)]
		[FieldOffset(0)]value struct PalRoleObjectData
		{
			[FieldOffset(0)]unsigned short Param0;
			[FieldOffset(2)]unsigned short Param1;
			[FieldOffset(4)]unsigned short ScriptFellowDie;
			[FieldOffset(6)]unsigned short ScrpitSelfHurt;
			[FieldOffset(8)]unsigned short Param2;
			[FieldOffset(10)]unsigned short Param3;
			[FieldOffset(12)]unsigned short Param4;
		} Role;
		[StructLayout(LayoutKind::Explicit, Size = 7, CharSet = CharSet::Ansi)]
		[FieldOffset(0)]value struct PalItemObjectData
		{
			[FieldOffset(0)]unsigned short Index;
			[FieldOffset(2)]unsigned short Price;
			[FieldOffset(4)]unsigned short ScriptUse;
			[FieldOffset(6)]unsigned short ScriptWear;
			[FieldOffset(8)]unsigned short ScriptThrow;
			[FieldOffset(10)]unsigned short Description;
			[FieldOffset(12)]unsigned short Attribute;
			static const unsigned short Useable		= 0x1;
			static const unsigned short Wearable		= 0x2;
			static const unsigned short Throwable	= 0x4;
			static const unsigned short Noconsume	= 0x8;
			static const unsigned short Noselect		= 0x10;
			static const unsigned short Sellable		= 0x20;
			static const unsigned short LiUse		= 0x40;
			static const unsigned short ZhaoUse		= 0x80;
			static const unsigned short LinUse		= 0x100;
			static const unsigned short WuUse		= 0x200;
			static const unsigned short NuUse		= 0x400;
			static const unsigned short GaiUse		= 0x800;
		} Item;
		[StructLayout(LayoutKind::Explicit, Size = 7, CharSet = CharSet::Ansi)]
		[FieldOffset(0)]value struct PalMagicObjectData
		{
			[FieldOffset(0)]unsigned short Index;
			[FieldOffset(2)]unsigned short Param0;
			[FieldOffset(4)]unsigned short ScriptAfter;
			[FieldOffset(6)]unsigned short ScriptBefore;
			[FieldOffset(8)]unsigned short Param1;
			[FieldOffset(10)]unsigned short Description;
			[FieldOffset(12)]unsigned short Attribute;
			static const unsigned short NofightUse	= 0x1;
			static const unsigned short FightUse		= 0x2;
			static const unsigned short Unknown		= 0x4;
			static const unsigned short ToEnemy		= 0x8;
			static const unsigned short Noselect		= 0x10;
		} Magic;
		[StructLayout(LayoutKind::Explicit, Size = 7, CharSet = CharSet::Ansi)]
		[FieldOffset(0)]value struct PalMonsterObjectData
		{
			[FieldOffset(0)]unsigned short Index;
			[FieldOffset(2)]unsigned short AntiAbnormal;
			[FieldOffset(4)]unsigned short ScriptBefore;
			[FieldOffset(6)]unsigned short ScriptAfter;
			[FieldOffset(8)]unsigned short ScriptFighting;
			[FieldOffset(10)]unsigned short Param0;
			[FieldOffset(12)]unsigned short Param1;
		} Monster;
		[StructLayout(LayoutKind::Explicit, Size = 7, CharSet = CharSet::Ansi)]
		[FieldOffset(0)]value struct PalPoisonObjectData
		{
			[FieldOffset(0)]unsigned short Level;
			[FieldOffset(2)]unsigned short Color;
			[FieldOffset(4)]unsigned short ScriptUs;
			[FieldOffset(6)]unsigned short Param0;
			[FieldOffset(8)]unsigned short CcriptEnemy;
			[FieldOffset(10)]unsigned short Param1;
			[FieldOffset(12)]unsigned short Param2;
		} Poison;
		[StructLayout(LayoutKind::Explicit, Size = 7, CharSet = CharSet::Ansi)]
		[FieldOffset(0)]value struct PalOriginObjectData
		{
			[FieldOffset(0)]unsigned short Param0;
			[FieldOffset(2)]unsigned short Param1;
			[FieldOffset(4)]unsigned short Param2;
			[FieldOffset(6)]unsigned short Param3;
			[FieldOffset(8)]unsigned short Param4;
			[FieldOffset(10)]unsigned short Param5;
			[FieldOffset(12)]unsigned short Param6;
		} Param;
	};

	[StructLayout(LayoutKind::Explicit, Size = 8, CharSet = CharSet::Ansi)]
	public value struct PalEventScript
	{
		[FieldOffset(0)]unsigned short Instruction;
		[FieldOffset(2)]unsigned short Parameter0;
		[FieldOffset(4)]unsigned short Parameter1;
		[FieldOffset(6)]unsigned short Parameter2;
	};


	generic<typename _Type>
	public value struct PalTypedBufferGroup
	{
		array<_Type> ^Item;
		int Count;
	};

	public ref class PalMkf
	{
	public:
		PalMkf(System::String ^path, MkfFile file);
		~PalMkf();
		int Count();
		MkfBufferItem RawData();
		MkfBufferItem RawData(int index);
		MkfBufferItem Data(int index);
		int RawLength();
		int RawLength(int index);
		int Offset(int index);
		int Length(int index);
		MkfBufferGroup Extract(int index);
		array<int> ^ExtractLength(int index);
		System::Drawing::Bitmap ^GetBitmap(int index, System::IntPtr palette);
		System::Drawing::Bitmap ^GetBitmap(int index, System::IntPtr palette, PalTools::PalMkf ^gop, int layer, bool grid);
		array<System::Drawing::Bitmap^> ^GetBitmaps(int index, System::IntPtr palette);
		array<System::Drawing::Bitmap^> ^GetMovie(int index, System::IntPtr palette);
		array<unsigned char> ^GetWave(int index);

	private:
		PAL_MKF_R	*_mkf;
		MkfFile		_file;
	};

	public ref class PalPalette
	{
	public:
		PalPalette(System::String ^path);
		~PalPalette();
		System::IntPtr GetPalette(int index);
		System::IntPtr GetPalette(int index, bool night);

	private:
		BufferItem *palette;
		int count;
	};

	public ref class PalItem
	{
	public:
		PalItem(System::String ^data_path, System::String ^sss_path, System::String ^msg_path, System::String ^word_path);
		~PalItem();
		array<System::String^> ^Message();
		System::String ^Message(int index);
		array<System::String^> ^Word();
		System::String ^Word(int index);
		PalTypedBufferGroup<PalShopData> Shop();
		PalShopData Shop(int index);
		PalTypedBufferGroup<PalTeamData> Team();
		PalTeamData Team(int index);
		PalTypedBufferGroup<PalMonsterData>Monster();
		PalMonsterData Monster(int index);
		PalTypedBufferGroup<PalObjectData> Object();
		PalObjectData Object(int index);
		PalTypedBufferGroup<PalEventScript> Script();
		PalEventScript Script(int index);

	private:
		PAL_ITEM *_item;
	};

	public ref class MultiMediaPlayer
	{
	public:
		static void PlayMidi(array<unsigned char> ^buffer);
	private:
	};
}

DWORD WINAPI EventThreadProc(LPVOID lpParameter);
class Multi_Media_Player;

typedef struct _NotifyData
{
	HANDLE hNotify;
	Multi_Media_Player *obj;
	IDirectMusicPerformance8 *pPerformance;
} NotifyData;

class Multi_Media_Player
{
public:
	Multi_Media_Player(unsigned char *buf, int len);
	~Multi_Media_Player();

private:
	IDirectMusicLoader8			*pLoader;
	IDirectMusicPerformance8	*pPerformance;
	IDirectMusicSegment8		*pSegment;
	NotifyData _notify;
	HANDLE thr;
	unsigned char *_buf;
	int _len;
};

typedef struct _WAVEFILEHEADER
{
	unsigned int	id;
	unsigned int	len;
	unsigned int	wave_id;
	unsigned int	fmt_thunk;
	unsigned int	fmt_len;
	unsigned short	wFormatTag;
	unsigned short	nChannels;
	unsigned int	nSamplesPerSec;
	unsigned int	nAvgBytesPerSec;
	unsigned short	nBlockAlign;
	unsigned short	wBitsPerSample;
	unsigned int	data_thunk;
	unsigned int	data_len;
} WAVEFILEHEADER;