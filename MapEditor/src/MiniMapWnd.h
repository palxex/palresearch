////////////////////////////////////////////////////////////////////////////////
//
//                              
//
////////////////////////////////////////////////////////////////////////////////
//
//	文件名：
//		MiniMapWnd.h
//
//	说明：
//		
//
//	函数：
//		
//
//////////////////////////////////////////////////////////////////////////////////
#ifndef _MINIMAPWND_H_
#define _MINIMAPWND_H_


BOOL MiniMapWnd_Create(HWND hWndParent);

VOID MiniMapWnd_Show(int nShow);
VOID MiniMapWnd_Move(LONG x, LONG y);

VOID MiniMapWnd_SetCameraPos(LONG x, LONG y);
VOID MiniMapWnd_Paint(LONG x, LONG y);
VOID MiniMapWnd_Paint(VOID);



#endif //_MINIMAPWND_H_