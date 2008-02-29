#include <windows.h>
#include <stdio.h>
#include "MKFFile.h"


const	LPCSTR	P_ErrorString	= "打开调色板文件Pat.mkf失败！\n请确定和本程序相同目录下有Pat.mkf文件。";



////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	BOOL Palette_Init(RGBQUAD *pPalette)
//
// 描述  :
//	读取仙剑的调色板并转换成适合window的格式
//
// 返回值:
//	
// 参数  :
//	RGBQUAD *pPalette - 接收调色板数据的缓冲区的指针
//
////////////////////////////////////////////////////////////////////////////////
BOOL Palette_Init(RGBQUAD *pPalette)
{
	LONG	lResult	= 0;
	FILE	*fp	= NULL;

	// 仙剑的调色板数据
	static	BYTE	PaletteCode[ 3 * 512 ];

	if (pPalette == NULL)
	{
		return FALSE;
	}

	fp = fopen("Pat.mkf", "rb");
	if (fp == NULL)
	{
		::MessageBox(::GetActiveWindow(), P_ErrorString, NULL, MB_OK);
		return FALSE;
	}

	lResult = MKF_ReadRecord(PaletteCode, 3 * 512, 0, fp);
	fclose(fp);

	if (lResult <= 0)
	{
		return FALSE;
	}

	DWORD	i	= 0;
	FLOAT	rate	= 0.2f;
	for (i = 0; i < 255; i++)
	{
		// 把三元色从0 -- 63扩屏到0 - 255
		pPalette[ i ].rgbRed = PaletteCode[ i * 3 + 0] * 4;
		pPalette[ i ].rgbGreen = PaletteCode[ i * 3 + 1] * 4;
		pPalette[ i ].rgbBlue = PaletteCode[ i * 3 + 2] * 4;
		pPalette[ i ].rgbReserved = 0;

		// 提高一点饱和度(仙剑的图像比较深色)
		pPalette[ i ].rgbRed += (BYTE)((255 - pPalette[ i ].rgbRed) * rate);
		pPalette[ i ].rgbGreen += (BYTE)((255 - pPalette[ i ].rgbGreen) * rate);
		pPalette[ i ].rgbBlue += (BYTE)((255 - pPalette[ i ].rgbBlue) * rate);
	}

	// 关键色不变
	pPalette[ i ].rgbRed = PaletteCode[ i * 3 + 0] * 4;
	pPalette[ i ].rgbGreen = PaletteCode[ i * 3 + 1] * 4;
	pPalette[ i ].rgbBlue = PaletteCode[ i * 3 + 2] * 4;
	pPalette[ i ].rgbReserved = 0;

	return TRUE;
}