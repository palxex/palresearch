/*******************************************************************************
                           C S T A T U S B A R

	Name:       StatusBar.h

    Description:
		×´Ì¬À¸´°¿ÚÀà

*******************************************************************************/
#ifndef _STATUSBAR_H_
#define _STATUSBAR_H_

class CStatusBar
{
public:
	CStatusBar();
	~CStatusBar();

public:
	BOOL Create(HWND hWndParent);
	VOID SetHead(LPCSTR lpsz);
	VOID SetXY(LONG x, LONG y);
	VOID SizeParent(RECT *lpRect);

private:
	VOID SetText(UINT uIndex, LPCSTR lpsz, UINT uStyle);

private:
	HWND m_hWnd;
};

#endif //_STATUSBAR_H_