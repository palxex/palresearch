/*******************************************************************************
                          C F L O A T W N D

	Name:       FloatWnd.h

    Description:
		¸¡¶¯´°¿ÚÀà

*******************************************************************************/
#ifndef _FLOATWND_
#define _FLOATWND_

#include "Wnd.h"

class CTileDialog;

LRESULT CALLBACK FloatWndProc(
							HWND hWnd,
							UINT uMsg,
							WPARAM wParam,
							LPARAM lParam);

class CFloatWnd : public CWnd
{
public:
	CFloatWnd();
	~CFloatWnd();

public:
	BOOL Create(HWND hWndParent, UINT uID);
	LRESULT CALLBACK WindowProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam);
	void OnCreate(HWND hWnd, WPARAM wParam, LPARAM lParam);
	LRESULT OnNcActivate(WPARAM wParam, LPARAM lParam);
	void SetItemData(UINT uItemID, DWORD dwData);
	void SetImageTile(HDC hDCImageTile);
	void OnTileDialog(WPARAM wParam, LPARAM lParam);

public:
	static CFloatWnd *m_pFloatWnd;
	CTileDialog      *m_pTileDialog;

private:
//	HWND              m_hWndParent;
};

#endif