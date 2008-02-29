#ifndef _MAP_H_
#define _MAP_H_

const DWORD	MAX_TEMPLATE				= 1024;

// 显示一个Tile时要使用的参数
// 也用于模板
typedef struct tagDRAWTILESTRUCT
{
	LONG		lxOrigin;
	LONG		lyOrigin;
	LONG		lxTile;
	LONG		lyTile;
	LONG		lHeight0;
	LONG		lHeight1;
	WORD		wLayer0Data;
	WORD		wLayer1Data;
	HDC		*phDC;
	HDC		hDCMark;
} DRAWTILESTRUCT;

typedef DRAWTILESTRUCT far *LPDRAWTILESTRUCT;

VOID Map_SetLayerImage(DWORD *dwpLayer, DWORD dwImage);
VOID Map_SetLayerHeight(DWORD *dwpLayer, DWORD dwHeight);
VOID Map_SetTileBarrier(DWORD *dwpLayer, BOOL bBarrier);

BOOL Map_IsBarrier(DWORD dwLayer);
DWORD Map_GetLayerImage(DWORD dwLayer);
DWORD Map_GetLayerHeight(DWORD dwLayer);

BOOL Map_MapIsExist(DWORD dwMapNumber);

VOID Map_CalcXYTileBesideTile(LONG lDirection, LONG lTileX, LONG lTileY, LPLONG lplTileX, LPLONG lplTileY);
VOID Map_CalcXYPixelToTile(LONG lxPixel, LONG lyPixel, LPLONG lplxTile, LPLONG lplyTile);
VOID Map_CalcXYTileToPixel(LONG lxTile, LONG lyTile, LPLONG lplxPixel, LPLONG lplyPixel);

VOID Map_DrawTile(HDC hdcDest, LPDRAWTILESTRUCT lpDT);
VOID Map_MarkTile(HDC hdcDest, LPDRAWTILESTRUCT lpDT);

BOOL Map_Assert(LONG x, LONG y);
#endif //_MAP_H_