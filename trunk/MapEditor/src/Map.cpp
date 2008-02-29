////////////////////////////////////////////////////////////////////////////////
//
//                              地图模块
//
////////////////////////////////////////////////////////////////////////////////
//
//	文件名：
//		Map.cpp
//
//	说明：
//		基本地图功能
//
//	函数：
//		
//
//////////////////////////////////////////////////////////////////////////////////

#include <windows.h>
#include <stdio.h>

#include "Map.h"

// Tile在不同y坐标下的水平切片的宽度
LONG g_HSegmentTable[ 32 ] = {
				8,	8,
				16,	16,
				24,	24,
				32,	32,
				40,	40,
				48,	48,
				56,	56,
				64,	64,
				56,	56,
				48,	48,
				40,	40,
				32,	32,
				24,	24,
				16,	16,
				8,	8,
				0,	0
				};

// Tile在不同x坐标下的垂直切片的高度
LONG g_VSegmentTable[ 64 ] = {
				2,	2,	2,	2,
				6,	6,	6,	6,
				10,	10,	10,	10,
				14,	14,	14,	14,
				18,	18,	18,	18,
				22,	22,	22,	22,
				26,	26,	26,	26,
				30,	30,	30,	30,
				30,	30,	30,	30,
				26,	26,	26,	26,
				22,	22,	22,	22,
				18,	18,	18,	18,
				14,	14,	14,	14,
				10,	10,	10,	10,
				6,	6,	6,	6,
				2,	2,	2,	2,
				};

////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	inline DWORD GetBit(DWORD dwValue, DWORD dwBit)
//
// 描述  :
//	
// 返回值:
//	
// 参数  :
//	wValue -
//	dwBit -
//
////////////////////////////////////////////////////////////////////////////////
inline DWORD GetBit(DWORD dwValue, DWORD dwBit)
{
	DWORD	Ret	= 0;

	Ret = (dwValue >> (dwBit - 1)) & 1;
	return Ret;
}


////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	inline VOID SetBit(DWORD *dwpValue, DWORD dwBit, BOOL bSet)
//
// 描述  :
//	
// 返回值:
//	
// 参数  :
//	dwpValue -
//	dwBit -
//	bSet -
//
////////////////////////////////////////////////////////////////////////////////
inline VOID SetBit(DWORD *dwpValue, DWORD dwBit, BOOL bSet)
{
	if (bSet)
	{
		*dwpValue |= 1 << (dwBit - 1);
	}
	else
	{
		*dwpValue &= ~(1 << (dwBit - 1));
	}
}

VOID Map_SetLayerImage(DWORD *dwpLayer, DWORD dwImage)
{
	// 00010000 11111111
	//    ^     ^^^^^^^^

	DWORD	i	= 0;

	for (i = 1; i <= 8; i++)
	{
		if (GetBit(dwImage, i) == 1)
		{
			SetBit(dwpLayer, i, TRUE);
		}
		else
		{
			SetBit(dwpLayer, i, FALSE);
		}
	}

	if (GetBit(dwImage, 9) == 1)
	{
		SetBit(dwpLayer, 8 + 5, TRUE);
	}
	else
	{
		SetBit(dwpLayer, 8 + 5, FALSE);
	}
}

VOID Map_SetLayerHeight(DWORD *dwpLayer, DWORD dwHeight)
{
	// 00001111 00000000
	//     ^^^^    

	DWORD	i	= 0;

	for (i = 1; i <= 4; i++)
	{
		if (GetBit(dwHeight, i) == 1)
		{
			SetBit(dwpLayer, i + 8, TRUE);
		}
		else
		{
			SetBit(dwpLayer, i + 8, FALSE);
		}
	}
}

VOID Map_SetTileBarrier(DWORD *dwpLayer, BOOL bBarrier)
{
	// 00100000 00000000
	//   ^      

	SetBit(dwpLayer, 8 + 6, bBarrier);
}


////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	DWORD GetLayerImage(DWORD dwLayer) 
//
// 描述  :
//	获取图层的图块编号
//
// 返回值:
//	图层的图块编号
//	
// 参数  :
//	DWORD dwLayer - 图层数据，实际上是WORD
//
////////////////////////////////////////////////////////////////////////////////
DWORD Map_GetLayerImage(DWORD dwLayer)
{
	// 00010000 11111111
	//    ^     ^^^^^^^^
	DWORD	dwImage	= 0;

	DWORD	i	= 0;

	for (i = 1; i <= 8; i++)
	{
		if (GetBit(dwLayer, i) == 1)
		{
			SetBit(&dwImage, i, TRUE);
		}
	}

	if (GetBit(dwLayer, 8 + 5) == 1)
	{
		SetBit(&dwImage, 9, TRUE);
	}

	return dwImage;
}

DWORD Map_GetLayerHeight(DWORD dwLayer)
{
	// 00001111 00000000
	//     ^^^^    
	DWORD	dwHeight	= 0;

	// 取高字节的低4位
	dwHeight = (dwLayer >> 8) & 0xF;

	return dwHeight;
}

BOOL Map_IsBarrier(DWORD dwLayer)
{
	// 00100000 00000000
	//   ^
	if (GetBit(dwLayer, 8 + 6) == 1)
	{
		return TRUE;
	}
	else
	{
		return FALSE;
	}
}


BOOL Map_MapIsExist(DWORD dwMapNumber)
{
	FILE	*fp	= NULL;

	CHAR MapFile[ MAX_PATH ];
	sprintf(MapFile, "Map\\Map%04d", dwMapNumber);

	fp = fopen(MapFile, "rb");

	if (fp == NULL)
	{
		return FALSE;
	}
	else
	{
		fclose(fp);
		return TRUE;
	}
}

//////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	LONG Map_CaleSegmentPointAtLine(LONG x, LONG a, LONG b)
//
// 描述  :
//	设一条直线由线段a和线段b相继连接组成，求直线上的点x在第几段上
//	坐标是从0算起的，段的编号也是从0算起。
//
// 返回值:
//	点x在第几段上
//
// 参数  :
//	x -
//	a -
//	b -
//
////////////////////////////////////////////////////////////////////////////////
LONG Map_CaleSegmentPointAtLine(LONG x, LONG a, LONG b)
{
	LONG	c		= 0;
	LONG	d		= 0;
	LONG	lSegment	= 0;

	x++;

	c = a + b;

	d = (x - (x % c)) / c;	// 计算前面有多少段a + b

	// 每段a + b就是两段
	lSegment = d * 2;

	// 如果超出了a段，也就是到了b段，再加1
	if (x % c > a)
	{
		lSegment++;
	}

	return lSegment;
}

////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	VOID Map_CalcXYPixelToTile(LONG lPixelX, LONG lPixelY, LPLONG lpTileX, LPLONG lpTileY)
//
// 描述  :
//	由像素级坐标计算出Tile级坐标
//
// 返回值:
//	
// 参数  :
//	lMouseX - 像素在地图中的x坐标
//	lMouseY - 像素在地图中的y坐标
//	lplTileX - 接收Tile X坐标的指针
//	lplTileY - 接收Tile Y坐标的指针
//
////////////////////////////////////////////////////////////////////////////////
VOID Map_CalcXYPixelToTile(LONG lPixelX, LONG lPixelY, LPLONG lplTileX, LPLONG lplTileY)
{
	LONG	a		= 0;
	LONG	b		= 0;
	LONG	xt		= 0;
	LONG	yt		= 0;

	// X
	yt = lPixelY % 32;

	a = g_HSegmentTable[ yt ];
	b = 64 - a;

	xt = lPixelX - b / 2;
	*lplTileX = Map_CaleSegmentPointAtLine(xt, a, b);

	// Y
	xt = lPixelX % 64;

	a = g_VSegmentTable[ xt ];
	b = 30 - a;
	yt = lPixelY - b / 2;

	*lplTileY = (yt - yt % 32) / 32;
}

////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	VOID Map_CalcXYTileToPixel(LONG lTileX, LONG lTileY, LPLONG lplPixelX, LPLONG lplPixelY)
//
// 描述  :
//	计算图块左上角在地图中的的像素级坐标
//
// 返回值:
//	
// 参数  :
//	lTileX - Tile的Tile级x坐标
//	lTileY - Tile的Tile级y坐标
//	lplPixelX - 用于接收Tile的像素级x坐标的指针
//	lplPixelY - 用于接收Tile的像素级y坐标的指针
//
////////////////////////////////////////////////////////////////////////////////
VOID Map_CalcXYTileToPixel(LONG lTileX, LONG lTileY, LPLONG lplPixelX, LPLONG lplPixelY)
{
	*lplPixelX = lTileX * 32;
	*lplPixelY = lTileY * 32 + (lTileX % 2) * 16;
}

////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	VOID Map_CalcXYTileBesideTile(LONG lDirection, LONG lTileX, LONG lTileY, LPLONG lplTileX, LPLONG lplTileY)
//
// 描述  :
//	计算一个Tile四个方向上邻近的Tile的坐标
//
//	右下方向为东
//	左下方向为南
//	左上方向为西
//	右上方向为北
//
// 返回值:
//	
// 参数  :
//	lDirection - 方向，1 - 东，2 - 南，3 - 西，4 - 北
//	lTileX - 源Tile x坐标
//	lTileY - 源Tile y坐标
//	lplTileX - 接收目标Tile x坐标的指针
//	lplTileY - 接收目标Tile y坐标的指针
//
////////////////////////////////////////////////////////////////////////////////
VOID Map_CalcXYTileBesideTile(LONG lDirection, LONG lTileX, LONG lTileY, LPLONG lplTileX, LPLONG lplTileY)
{
	switch (lDirection)
	{
	case 1:// 东
		if (lTileX % 2 == 0)
		{
			*lplTileX = lTileX + 1;
			*lplTileY = lTileY;
		}
		else
		{
			*lplTileX = lTileX + 1;
			*lplTileY = lTileY + 1;
		}
		break;
	case 2:// 南
		if (lTileX % 2 == 0)
		{
			*lplTileX = lTileX - 1;
			*lplTileY = lTileY;
		}
		else
		{
			*lplTileX = lTileX - 1;
			*lplTileY = lTileY + 1;
		}
		break;
	case 3: // 西
		if (lTileX % 2 == 0)
		{
			*lplTileX = lTileX - 1;
			*lplTileY = lTileY - 1;
		}
		else
		{
			*lplTileX = lTileX - 1;
			*lplTileY = lTileY;
		}
		break;
	case 4: // 北
		if (lTileX % 2 == 0)
		{
			*lplTileX = lTileX + 1;
			*lplTileY = lTileY - 1;
		}
		else
		{
			*lplTileX = lTileX + 1;
			*lplTileY = lTileY;
		}
		break;
	}
}

VOID Map_DrawTile(HDC hdcDest, LPDRAWTILESTRUCT lpDT)
{
	LONG	xo		= 0;
	LONG	yo		= 0;
	LONG	xDest		= 0;
	LONG	yDest		= 0;

	LONG	lImage		= 0;
	LONG	lHeight		= 0;

	UINT	uColorKey	= RGB(108, 88, 100);

	Map_CalcXYTileToPixel(lpDT->lxOrigin, lpDT->lyOrigin, &xo, &yo);
	Map_CalcXYTileToPixel(lpDT->lxTile, lpDT->lyTile, &xDest, &yDest);

	// 计算相对于原点Tile的像素坐标，即在窗口显示的像素级坐标
	xDest -= xo;
	yDest -= yo;

	xDest -= 32;
	yDest -= 16;

	// 第一层
	lImage = Map_GetLayerImage(lpDT->wLayer0Data);
	lHeight = Map_GetLayerHeight(lpDT->wLayer0Data);

	if (lHeight >= lpDT->lHeight0)
	{
		::TransparentBlt(hdcDest, xDest, yDest, 64, 30, lpDT->phDC[ lImage ], 0, 0, 64, 30, uColorKey);
	}

	// 第二层
	lImage = Map_GetLayerImage(lpDT->wLayer1Data);
	lHeight = Map_GetLayerHeight(lpDT->wLayer1Data);

	if (lImage > 0)
	{
		if (lHeight >= lpDT->lHeight1)
		{
			::TransparentBlt(hdcDest, xDest, yDest, 64, 30, lpDT->phDC[ lImage - 1 ], 0, 0, 64, 30, uColorKey);
		}
	}
}


////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	VOID Map_MarkTile(HDC hdcDest, LPDRAWTILESTRUCT lpDT)
//
// 描述  :
//	在Tile上打标记
//
// 返回值:
//	
// 参数  :
//	hdcDest -
//	lpDT -
//
////////////////////////////////////////////////////////////////////////////////
VOID Map_MarkTile(HDC hdcDest, LPDRAWTILESTRUCT lpDT)
{
	LONG	xo		= 0;
	LONG	yo		= 0;
	LONG	xDest		= 0;
	LONG	yDest		= 0;

	Map_CalcXYTileToPixel(lpDT->lxOrigin, lpDT->lyOrigin, &xo, &yo);
	Map_CalcXYTileToPixel(lpDT->lxTile, lpDT->lyTile, &xDest, &yDest);

	// 计算相对于原点Tile的像素坐标，即在窗口显示的像素级坐标
	xDest -= xo;
	yDest -= yo;

	xDest -= 32;
	yDest -= 16;

	::TransparentBlt(hdcDest, xDest, yDest, 64, 30, lpDT->hDCMark, 0, 0, 64, 30, 0);
}

BOOL Map_Assert(LONG x, LONG y)
{
	if (0 <= x && x <= 127 &&
		0 <= y && y <= 127)
	{
		return TRUE;
	}
	else
	{
		return FALSE;
	};
}