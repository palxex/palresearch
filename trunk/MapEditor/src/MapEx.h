////////////////////////////////////////////////////////////////////////////////
//
//                              
//
////////////////////////////////////////////////////////////////////////////////
//
//	文件名：
//		MapEx.h
//
//	说明：
//		
//
//	函数：
//		
//
//////////////////////////////////////////////////////////////////////////////////
#ifndef _MAPEX_H_
#define _MAPEX_H_

VOID MapEx_Draw(HDC hdcDest,
	LONG lWidth,
	LONG lHeight,
	LPWORD lpMapData,
	HDC *phDC,
	LONG lXOrigin,
	LONG lYOrigin);

VOID MapEx_MarkBarrier(
	HDC hdcDest,
	LONG lWidth,
	LONG lHeight,
	LPWORD lpMapData,
	HDC hdcMark,
	LONG lXOrigin,
	LONG lYOrigin);

VOID MapEx_DrawTemplate(
	HDC hDCDest,
	LPWORD lpwMapData,
	LONG lxDestTile,
	LONG lyDestTile,
	LPDRAWTILESTRUCT lpTemplate,
	DWORD dwTileCount,
	LONG lxOrigin,
	LONG lyOrigin,
	BOOL bAI);

VOID MapEx_PasterTemplate(
	LPWORD lpwMapData,
	LONG lxDestTile,
	LONG lyDestTile,
	LPDRAWTILESTRUCT lpTemplate,
	DWORD dwTileCount,
	BOOL bAI);

VOID MapEx_ReDrawTiles(
	HDC hDCDest,
	LONG lxTile,
	LONG lyTile,
	LPWORD lpwMapData,
	HDC *phDC,
	LONG lxOrigin,
	LONG lyOrigin);

VOID MapEx_ViewObject(
	HDC hDCDest,
	LONG lxDestTile,
	LONG lyDestTile,
	HDC hDCObject,
	LPWORD lpwMapData,
	HDC *phDC,
	LONG lxOrigin,
	LONG lyOrigin);

DWORD MapEx_GetCon(WORD wLayer0Data, WORD wLayer1Data);

VOID MapEx_DrawMiniMap(HDC hdcDest, LPWORD lpMapData, HDC *phDC);
VOID MapEx_UpdateMiniMap(HDC hdcDest, LONG x, LONG y, LPWORD lpMapData, HDC *phDC);

#endif //_MAPEX_H_