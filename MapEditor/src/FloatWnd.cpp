
/*******************************************************************************
                          C F L O A T W N D

	Name:       FloatWnd.cpp

    Description:
		浮动窗口类

*******************************************************************************/

#include "StdAfx.h"

CFloatWnd* CFloatWnd::m_pFloatWnd = NULL;

//******************************************************************************
//
//  FloatWndProc
//
//      浮动窗口消息处理函数
//
//
LRESULT CALLBACK FloatWndProc(
							   HWND hWnd,
							   UINT uMsg,
							   WPARAM wParam,
							   LPARAM lParam)
{
	if (CFloatWnd::m_pFloatWnd != NULL)
	{
		return CFloatWnd::m_pFloatWnd->WindowProc(hWnd, uMsg, wParam, lParam);
	}
	return 0;
}
 
CFloatWnd::CFloatWnd()
{
	if (m_pFloatWnd == NULL)
	{
		m_pFloatWnd = this;
	}

	m_pTileDialog = NULL;
}

CFloatWnd::~CFloatWnd()
{

}

//******************************************************************************
//
//  CFloatWnd::Create
//
//      创建状态栏窗口
//
//
BOOL CFloatWnd::Create(HWND hWndParent, UINT uID)
{
	HINSTANCE hInstance = (HINSTANCE)::GetWindowLong(hWndParent, GWL_HINSTANCE);

	ATOM atom;
	WNDCLASSEX stWndClass;

	stWndClass.cbSize = sizeof(WNDCLASSEX);
	stWndClass.style = CS_HREDRAW | CS_VREDRAW;
	stWndClass.lpfnWndProc = FloatWndProc;
	stWndClass.cbClsExtra = 0;
	stWndClass.cbWndExtra = 0;
	stWndClass.hInstance = hInstance;
	stWndClass.hIcon = NULL;
	stWndClass.hCursor = ::LoadCursor(NULL, (LPCTSTR)IDC_ARROW);
	stWndClass.hbrBackground = ::GetSysColorBrush(COLOR_BTNFACE);
	stWndClass.lpszMenuName = NULL;
	stWndClass.lpszClassName = FLOATWNDCLASS;
	stWndClass.hIconSm = NULL;

	// 注册浮动窗口类
	atom = RegisterClassEx(&stWndClass);
	if (atom == 0)
	{
		return FALSE;
	}

	m_hWnd = ::CreateWindowEx(
		0x180,
		FLOATWNDCLASS,
		"Tile属性",
		WS_CLIPSIBLINGS | WS_DLGFRAME |
		WS_OVERLAPPED |
		0x3B00 | WS_POPUPWINDOW |
		WS_CAPTION | WS_VISIBLE,
		0, 0, 0, 0,
		hWndParent,
		NULL,
		hInstance,
		NULL);

	if (m_hWnd == NULL)
		return FALSE;
	
	return TRUE;
}

void CFloatWnd::OnCreate(HWND hWnd, WPARAM wParam, LPARAM lParam)
{
	assert(m_pTileDialog != NULL);

	m_pTileDialog->Create(hWnd);
}

LRESULT CFloatWnd::OnNcActivate(WPARAM wParam, LPARAM lParam)
{
	::DefWindowProc(m_hWnd, WM_NCACTIVATE, TRUE, 0);
	return 1;
}

//******************************************************************************
//
//  CFloatWnd::SetItemData
//
//      
//
//
void CFloatWnd::SetItemData(UINT uItemID, DWORD dwData)
{
	assert(m_pTileDialog != NULL);

	m_pTileDialog->SetItemInt(uItemID, dwData);
}

//******************************************************************************
//
//  CFloatWnd::WindowProc
//
//      窗口消息处理函数
//
//
LRESULT CALLBACK CFloatWnd::WindowProc(
									   HWND hWnd,
									   UINT uMsg,
									   WPARAM wParam,
									   LPARAM lParam)
{
	switch (uMsg)
	{
	case WM_CREATE:
		OnCreate(hWnd, wParam, lParam);
		break;
	case WM_NCACTIVATE:
		return OnNcActivate(wParam, lParam);
		break;
	}
	return ::DefWindowProc(hWnd, uMsg, wParam, lParam);
}