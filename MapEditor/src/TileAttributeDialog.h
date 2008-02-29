////////////////////////////////////////////////////////////////////////////////
//
//                              
//
////////////////////////////////////////////////////////////////////////////////
//
//	文件名：
//		TileAttributeDialog.h
//
//	说明：
//		
//
//	函数：
//		
//
//////////////////////////////////////////////////////////////////////////////////
#ifndef _TILEATTRIBUTEDIALOG_H_
#define _TILEATTRIBUTEDIALOG_H_

BOOL TileAttributeDialog_Create(HWND hWndParent);
VOID TileAttributeDialog_Move(LONG x, LONG y);
VOID TileAttributeDialog_Update(LPWORD lpwLayer0, LPWORD lpwLayer1);

VOID TileAttributeDialog_Show(int nShow);

#endif //_TILEATTRIBUTEDIALOG_H_