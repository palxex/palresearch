////////////////////////////////////////////////////////////////////////////////
//
//                              
//
////////////////////////////////////////////////////////////////////////////////
//
//	文件名：
//		MapEx.cpp
//
//	说明：
//
//		模板就是一个DRAWTILESTRUCT列表，列表中每个元素
//	代表一个Tile，Tile在模板中的顺序并不重要，重要的是Tile中保存
//	的坐标，只有通过坐标才能确定模板中各各Tile的相对位置，只有通
//	过这些相对位置才能在正确的位置显示模板和粘帖模板。
//
//	函数：
//		
//
//////////////////////////////////////////////////////////////////////////////////
#include <windows.h>
#include "Map.h"



VOID MapEx_Draw(
	HDC hDCDest,
	LONG lWidth,
	LONG lHeight,
	LPWORD lpwMapData,
	HDC *phDC,
	LONG lxOrigin,
	LONG lyOrigin)
{
	DRAWTILESTRUCT	DrawTile;
	LONG		lxTile		= 0;
	LONG		lyTile		= 0;
	LONG		lx		= 0;
	LONG		ly		= 0;

	memset(&DrawTile, 0, sizeof(DRAWTILESTRUCT));

	for (ly = 0; ly < lHeight; ly++)
	{
		for (lx = 0; lx < lWidth; lx++)
		{
			// 计算出要被显示的Tile
			lxTile = lxOrigin + lx;
			lyTile = lyOrigin + ly;

			if (Map_Assert(lxTile, lyTile))
			{
				DrawTile.lxOrigin = lxOrigin;
				DrawTile.lyOrigin = lyOrigin;
				DrawTile.lxTile = lxTile;
				DrawTile.lyTile = lyTile;
				DrawTile.phDC = phDC;
				DrawTile.wLayer0Data = lpwMapData[ lyTile * 128 * 2 + lxTile * 2 ];
				DrawTile.wLayer1Data = lpwMapData[ lyTile * 128 * 2 + lxTile * 2 + 1 ];

				Map_DrawTile(hDCDest, &DrawTile);
			}
		}
	}
}

VOID MapEx_MarkBarrier(
	HDC hDCDest,
	LONG lWidth,
	LONG lHeight,
	LPWORD lpwMapData,
	HDC hDCMark,
	LONG lxOrigin,
	LONG lyOrigin)
{
	DRAWTILESTRUCT	DrawTile;
	LONG	lxTile		= 0;
	LONG	lyTile		= 0;
	LONG	lx		= 0;
	LONG	ly		= 0;

	for (ly = 0; ly < lHeight; ly++)
	{
		for (lx = 0; lx < lWidth; lx++)
		{
			// 计算出要被显示的Tile
			lxTile = lxOrigin + lx;
			lyTile = lyOrigin + ly;

			if (Map_Assert(lxTile, lyTile))
			{
				if (Map_IsBarrier(lpwMapData[ lyTile * 128 * 2 + lxTile * 2 ]))
				{
					DrawTile.lxOrigin = lxOrigin;
					DrawTile.lyOrigin = lyOrigin;
					DrawTile.lxTile = lxTile;
					DrawTile.lyTile = lyTile;
					DrawTile.hDCMark = hDCMark;
					
					Map_MarkTile(hDCDest, &DrawTile);

				}
			}
		}
	}
}

////////////////////////////////////////////////////////////////////////////////
//
// MapEx_DrawTemplate
// MapEx_PasterTemplate
//
////////////////////////////////////////////////////////////////////////////////

VOID MapEx_DrawTemplate(
	HDC hDCDest,
	LPWORD lpwMapData,
	LONG lxDestTile,
	LONG lyDestTile,
	LPDRAWTILESTRUCT lpTemplate,
	DWORD dwTileCount,
	LONG lxOrigin,
	LONG lyOrigin,
	BOOL bAI)
{
	DRAWTILESTRUCT DrawTile;

	LONG	lxBaseTile	= 0;
	LONG	lyBaseTile	= 0;
	LONG	lxOffset	= 0;
	LONG	lyOffset	= 0;

	DWORD	i		= 0;

	if (dwTileCount == 0)
	{
		return;
	}

	memset(&DrawTile, 0, sizeof(DRAWTILESTRUCT));

	// 以第一个Tile为基点
	lxBaseTile = lpTemplate[ 0 ].lxTile;
	lyBaseTile = lpTemplate[ 0 ].lyTile;

	// 列遍显示每个被选入模板的Tile
	for (i = 0; i < dwTileCount; i++)
	{
		memcpy(&DrawTile, lpTemplate + i, sizeof(DRAWTILESTRUCT));

		DrawTile.lxOrigin = lxOrigin;
		DrawTile.lyOrigin = lyOrigin;

		lxOffset = lpTemplate[ i ].lxTile - lxBaseTile;
		lyOffset = lpTemplate[ i ].lyTile - lyBaseTile;

		if (lxBaseTile % 2 == 0)
		{
			if (lxDestTile % 2 == 1 &&
				lpTemplate[ i ].lxTile % 2 == 1)
			{
				DrawTile.lxTile = lxDestTile + lxOffset;
				DrawTile.lyTile = lyDestTile + lyOffset + 1;
			}
			else
			{
				DrawTile.lxTile = lxDestTile + lxOffset;
				DrawTile.lyTile = lyDestTile + lyOffset;
			}
		}

		if (lxBaseTile % 2 == 1)
		{
			if (lxDestTile % 2 == 0 &&
				lpTemplate[ i ].lxTile % 2 == 0)
			{
				DrawTile.lxTile = lxDestTile + lxOffset;
				DrawTile.lyTile = lyDestTile + lyOffset - 1;
			}
			else
			{
				DrawTile.lxTile = lxDestTile + lxOffset;
				DrawTile.lyTile = lyDestTile + lyOffset;
			}
		}

		if (Map_Assert(DrawTile.lxTile, DrawTile.lyTile))
		{
			if (bAI)
			{
				if (Map_GetLayerHeight(DrawTile.wLayer0Data) == 0)
				{
					// 没有高度的不显示
					DrawTile.lHeight0 = 1;
				}
			}
			Map_DrawTile(hDCDest, &DrawTile);
		}
	}
}

VOID MapEx_PasterTemplate(
	LPWORD lpwMapData,
	LONG lxDestTile,
	LONG lyDestTile,
	LPDRAWTILESTRUCT lpTemplate,
	DWORD dwTileCount,
	BOOL bAI)
{
	LONG	lxBaseTile	= 0;
	LONG	lyBaseTile	= 0;
	LONG	lxOffset	= 0;
	LONG	lyOffset	= 0;
	LONG	lxTile		= 0;
	LONG	lyTile		= 0;
	WORD	wLayerData	= 0;

	DWORD	i		= 0;
	LONG	lImage		= 0;
	LONG	lHeight		= 0;
	LONG	lSrcHeight	= 0;

	if (dwTileCount == 0)
	{
		return;
	}

	lxBaseTile = lpTemplate[ 0 ].lxTile;
	lyBaseTile = lpTemplate[ 0 ].lyTile;

	for (i = 0; i < dwTileCount; i++)
	{
		lxOffset = lpTemplate[ i ].lxTile - lxBaseTile;
		lyOffset = lpTemplate[ i ].lyTile - lyBaseTile;

		if (lxBaseTile % 2 == 0)
		{
			if (lxDestTile % 2 == 1 &&
				lpTemplate[ i ].lxTile % 2 == 1)
			{
				lxTile = lxDestTile + lxOffset;
				lyTile = lyDestTile + lyOffset + 1;
			}
			else
			{
				lxTile = lxDestTile + lxOffset;
				lyTile = lyDestTile + lyOffset;
			}
		}

		if (lxBaseTile % 2 == 1)
		{
			if (lxDestTile % 2 == 0 &&
				lpTemplate[ i ].lxTile % 2 == 0)
			{
				lxTile = lxDestTile + lxOffset;
				lyTile = lyDestTile + lyOffset - 1;
			}
			else
			{
				lxTile = lxDestTile + lxOffset;
				lyTile = lyDestTile + lyOffset;
			}
		}

		if (Map_Assert(lxTile, lyTile))
		{
			if (!bAI)
			{
				//
				wLayerData = lpTemplate[ i ].wLayer0Data;
				lpwMapData[ 128 * 2 * lyTile + 2 * lxTile ] = wLayerData;

				//
				wLayerData = lpTemplate[ i ].wLayer1Data;
				lpwMapData[ 128 * 2 * lyTile + 2 * lxTile + 1] = wLayerData;
			}
			else
			{
				// 第一层
				wLayerData = lpTemplate[ i ].wLayer0Data;
				lHeight = Map_GetLayerHeight(wLayerData);

				if (lHeight >= 1)
				{
					lSrcHeight = Map_GetLayerHeight(lpwMapData[ 128 * 2 * lyTile + 2 * lxTile ]);
					if (lHeight > lSrcHeight)
					{
						lpwMapData[ 128 * 2 * lyTile + 2 * lxTile ] = wLayerData;
					}
				}

				// 第二层
				wLayerData = lpTemplate[ i ].wLayer1Data;
				lHeight = Map_GetLayerHeight(wLayerData);
				lImage = Map_GetLayerImage(wLayerData);

				if (lImage > 0)
				{
					lSrcHeight = Map_GetLayerHeight(lpwMapData[ 128 * 2 * lyTile + 2 * lxTile + 1 ]);
					if (lHeight >= lSrcHeight)
					{
						lSrcHeight = Map_GetLayerHeight(lpwMapData[ 128 * 2 * lyTile + 2 * lxTile ]);
						if (lHeight >= lSrcHeight)
						{
							lpwMapData[ 128 * 2 * lyTile + 2 * lxTile + 1] = wLayerData;
						}
					}
				}
			}
		}
	}
}

////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	
//
// 描述  :
//	重画以Tile(x, y)为中线的三列Tile
//
// 返回值:
//	
// 参数  :
//	x -
//	y -
//
////////////////////////////////////////////////////////////////////////////////
VOID MapEx_ReDrawTiles(
	HDC hDCDest,
	LONG lxTile,
	LONG lyTile,
	LPWORD lpwMapData,
	HDC *phDC,
	LONG lxOrigin,
	LONG lyOrigin)
{
	DRAWTILESTRUCT DrawTile;

	LONG	i	= 0;
	LONG	xt	= 0;
	LONG	yt	= 0;

	memset(&DrawTile, 0, sizeof(DRAWTILESTRUCT));
	// 第一列
	Map_CalcXYTileBesideTile(3, lxTile, lyTile, &xt, &yt);
	for (i = 0; i < 4; i++)
	{
		DrawTile.lxOrigin = lxOrigin;
		DrawTile.lyOrigin = lyOrigin;
		DrawTile.lxTile = xt;
		DrawTile.lyTile = yt;
		DrawTile.phDC = phDC;
		DrawTile.wLayer0Data = lpwMapData[ 128 * 2 * yt + 2 * xt ];
		DrawTile.wLayer1Data = lpwMapData[ 128 * 2 * yt + 2 * xt + 1 ];

		DrawTile.lHeight0 = DrawTile.lHeight1 = i * 2 + 2;

		Map_DrawTile(hDCDest, &DrawTile);
		yt--;
	}

	// 第二列
	xt = lxTile;
	yt = lyTile;

	for (i = 0; i < 4; i++)
	{
		DrawTile.lxOrigin = lxOrigin;
		DrawTile.lyOrigin = lyOrigin;
		DrawTile.lxTile = xt;
		DrawTile.lyTile = yt;
		DrawTile.phDC = phDC;
		DrawTile.wLayer0Data = lpwMapData[ 128 * 2 * yt + 2 * xt ];
		DrawTile.wLayer1Data = lpwMapData[ 128 * 2 * yt + 2 * xt + 1 ];

		DrawTile.lHeight0 = DrawTile.lHeight1 = i * 2 + 1;

		Map_DrawTile(hDCDest, &DrawTile);

		yt--;
	}

	// 第三列
	Map_CalcXYTileBesideTile(4, lxTile, lyTile, &xt, &yt);

	for (i = 0; i < 4; i++)
	{
		DrawTile.lxOrigin = lxOrigin;
		DrawTile.lyOrigin = lyOrigin;
		DrawTile.lxTile = xt;
		DrawTile.lyTile = yt;
		DrawTile.phDC = phDC;
		DrawTile.wLayer0Data = lpwMapData[ 128 * 2 * yt + 2 * xt ];
		DrawTile.wLayer1Data = lpwMapData[ 128 * 2 * yt + 2 * xt + 1 ];

		DrawTile.lHeight0 = DrawTile.lHeight1 = i * 2 + 2;

		Map_DrawTile(hDCDest, &DrawTile);
		yt--;
	}
}

VOID MapEx_ViewObject(
	HDC hDCDest,
	LONG lxDestTile,
	LONG lyDestTile,
	HDC hDCObject,
	LPWORD lpwMapData,
	HDC *phDC,
	LONG lxOrigin,
	LONG lyOrigin)
{
	LONG	xo		= 0;
	LONG	yo		= 0;
	LONG	xDest		= 0;
	LONG	yDest		= 0;

	UINT	uColorKey	= RGB(108, 88, 100);

	Map_CalcXYTileToPixel(lxOrigin, lyOrigin, &xo, &yo);
	Map_CalcXYTileToPixel(lxDestTile, lyDestTile, &xDest, &yDest);

	xDest -= xo;
	yDest -= yo;

	xDest -= 32;
	yDest -= 16;

	if (Map_Assert(lxDestTile, lyDestTile))
	{
		yDest = yDest - (110 - 32);
		::TransparentBlt(hDCDest, xDest, yDest, 64, 110, hDCObject, 0, 0, 64, 110, uColorKey);

		// 重画人物周围的Tile
		MapEx_ReDrawTiles(hDCDest, lxDestTile, lyDestTile, lpwMapData, phDC, lxOrigin, lyOrigin);
	}
}

VOID MapEx_DrawMiniMap(HDC hDCDest, LPWORD lpwMapData, HDC *phDC)
{
	LONG		lx		= 0;
	LONG		ly		= 0;

	LONG		lImage		= 0;

	for (ly = 0; ly < 128; ly++)
	{
		for (lx = 0; lx < 128; lx++)
		{
			lImage = Map_GetLayerImage(lpwMapData[ 128 * 2 * ly + 2 * lx ]);
			::BitBlt(hDCDest, lx, ly, 1, 1, phDC[ lImage ], 0, 0, SRCCOPY);

			lImage = Map_GetLayerImage(lpwMapData[ 128 * 2 * ly + 2 * lx + 1 ]);

			if (lImage > 0)
			{
				::BitBlt(hDCDest, lx, ly, 1, 1, phDC[ lImage - 1], 0, 0, SRCCOPY);
			}
		}
	}
}

VOID MapEx_UpdateMiniMap(HDC hDCDest, LONG lx, LONG ly, LPWORD lpwMapData, HDC *phDC)
{
	LONG	lxPixel		= 0;
	LONG	lyPixel		= 0;

	LONG	lImage		= 0;

	if (Map_Assert(lx, ly))
	{
		lxPixel = lx;
		lyPixel = ly;

		lImage = Map_GetLayerImage(lpwMapData[ 128 * 2 * ly + 2 * lx ]);
		::BitBlt(hDCDest, lxPixel, lyPixel, 1, 1, phDC[ lImage ], 0, 0, SRCCOPY);

		lImage = Map_GetLayerImage(lpwMapData[ 128 * 2 * ly + 2 * lx + 1 ]);

		if (lImage > 0)
		{
			::BitBlt(hDCDest, lxPixel, lyPixel, 1, 1, phDC[ lImage - 1], 0, 0, SRCCOPY);
		}
	}
}