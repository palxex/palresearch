////////////////////////////////////////////////////////////////////////////////
//
//                              
//
////////////////////////////////////////////////////////////////////////////////
//
//	文件名：
//		TemplateEditWnd.h
//
//	说明：
//		
//
//
//////////////////////////////////////////////////////////////////////////////////
#ifndef _TEMPLATEEDITWND_H_
#define _TEMPLATEEDITWND_H_


BOOL TemplateEditWnd_Create(HWND hWndParent);

VOID TemplateEditWnd_Show(int nShow);
VOID TemplateEditWnd_SetActive(VOID);

VOID TemplateEditWnd_SetCameraPos(LONG x, LONG y);

VOID TemplateEditWnd_SetTitle(LPCSTR lpstrTitle);

VOID TemplateEditWnd_ClearTemplate(VOID);

BOOL TemplateEditWnd_IsActive(VOID);

#endif //_TEMPLATEEDITWND_H_