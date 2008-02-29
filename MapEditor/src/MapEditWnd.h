////////////////////////////////////////////////////////////////////////////////
//
//                              
//
////////////////////////////////////////////////////////////////////////////////
//
//	文件名：
//		MapEditWnd.h
//
//	说明：
//		
//
//
//////////////////////////////////////////////////////////////////////////////////
#ifndef _MAPEDITWND_H_
#define _MAPEDITWND_H_


BOOL MapEditWnd_Create(HWND hWndParent);

VOID MapEditWnd_Show(int nShow);
VOID MapEditWnd_SetActive(VOID);

VOID MapEditWnd_SetCameraPos(LONG x, LONG y);

VOID MapEditWnd_SetTitle(LPCSTR lpstrTitle);

BOOL MapEditWnd_IsActive(VOID);

#endif //_MAPEDITWND_H_