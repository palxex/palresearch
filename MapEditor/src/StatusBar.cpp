/*******************************************************************************
                           C S T A T U S B A R

	Name:       StatusBar.cpp

    Description:
		状态栏窗口类

*******************************************************************************/

#include <windows.h>
#include <commctrl.h>
#include <stdio.h>


#include "StatusBar.h"
#include "Map.h"

CStatusBar::CStatusBar()
{
	m_hWnd	= NULL;
}

CStatusBar::~CStatusBar()
{

}

//******************************************************************************
//
//  CStatusBar::Create
//
//      创建状态栏窗口
//
//
BOOL CStatusBar::Create(HWND hWndParent)
{
	HINSTANCE hInstance = (HINSTANCE)::GetWindowLong(hWndParent, GWL_HINSTANCE);

	m_hWnd = ::CreateWindowEx(
		0,
		STATUSCLASSNAME,
		NULL,
		WS_VISIBLE | WS_CHILD | SBARS_SIZEGRIP,
		0,
		0,
		0,
		0,
		hWndParent,
		(HMENU)201,
		hInstance,
		NULL);

	if (m_hWnd == NULL)
	{
		::MessageBox(hWndParent, "创建状态栏失败！", NULL, MB_OK);
		return FALSE;
	}

	// 分两部分，第一部分显示说明，第二部分显示坐标
	INT Parts[ 2 ];
	Parts[ 0 ] = 500;
	Parts[ 1 ] = -1;
	
	LRESULT i = ::SendMessage(m_hWnd, SB_SETPARTS, 2, (LPARAM)Parts);

	SetHead("就绪");

	::ShowWindow(m_hWnd, SW_SHOW);
	::UpdateWindow(m_hWnd);

	return TRUE;
}

//******************************************************************************
//
//  CStatusBar::SetText
//
//      设置状态栏窗口文字
//
//
VOID CStatusBar::SetText(UINT uIndex, LPCSTR lpsz, UINT uStyle)
{
	BOOL b = SendMessage(m_hWnd, SB_SETTEXT, uIndex | uStyle, (LPARAM)lpsz);
}

VOID CStatusBar::SetHead(LPCSTR lpsz)
{
	SetText(0, lpsz, SBT_NOBORDERS);
}

VOID CStatusBar::SetXY(LONG xb, LONG yb)
{
	char Buffer[256];
	int x2 = xb / 2;
	int xe= xb % 2;
	int xp = x2 * 32 + xe * 16;
	int yp = yb * 16 + xe * 8;
	::sprintf(Buffer, "XBlock:%d(0x%X),YBlock:%d(0x%X),Half:%d,X:%d(0x%X), Y:%d(0x%X)", x2,x2, yb,yb, xe, xp,xp, yp,yp);
	SetText(1, Buffer, 0);
}

VOID CStatusBar::SizeParent(RECT *lpRect)
{
	RECT	rect;
	LONG	lHeight	= 0;

	::MoveWindow(m_hWnd, 0, 0, 0, 0, TRUE);

	::GetWindowRect(m_hWnd, &rect);
	lHeight = rect.bottom - rect.top;

	lpRect->bottom -= lHeight;
}