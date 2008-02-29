////////////////////////////////////////////////////////////////////////////////
//
//                              Tile属性窗口
//
////////////////////////////////////////////////////////////////////////////////
//
//	文件名：
//		TileAttributeWnd.cpp
//
//	说明：
//		作为Tile属性对话框的容器
//
//	函数：
//		
//
//////////////////////////////////////////////////////////////////////////////////
#include <windows.h>

#include "Map.h"
#include "MapEx.h"
#include "MapEditWnd.h"
#include "TileAttributeDialog.h"

#include "TileAttributeWnd.h"


HWND		TAW_hTileAttributeWnd		= NULL;

const LPCSTR	TILEATTRIBUTEWNDCLASS		= "TileAttributeWndClass";

////////////////////////////////////////////////////////////////////////////////
//
//                              函数声明
//
////////////////////////////////////////////////////////////////////////////////
LRESULT CALLBACK TileAttributeWnd_WindowProc(
				       HWND hWnd,
				       UINT uMsg,
				       WPARAM wParam,
				       LPARAM lParam);

LRESULT TileAttributeWnd_OnCreate(HWND hWnd, WPARAM wParam, LPARAM lParam);
LRESULT TileAttributeWnd_OnClose(HWND hWnd, WPARAM wParam, LPARAM lParam);
LRESULT TileAttributeWnd_OnMove(HWND hWnd, WPARAM wParam, LPARAM lParam);
LRESULT TileAttributeWnd_OnNcActivate(HWND hWnd, WPARAM wParam, LPARAM lParam);

////////////////////////////////////////////////////////////////////////////////
//
//                              函数定义
//
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	BOOL TileAttributeWnd_Create(HWND hWndParent)
//
// 描述  :
//	创建小地图浮动窗口
//
// 返回值:
//	
// 参数  :
//	HWND hWndParent -
//
////////////////////////////////////////////////////////////////////////////////
BOOL TileAttributeWnd_Create(HWND hWndParent)
{
	HINSTANCE hInstance	= NULL;

	ATOM atom;
	WNDCLASSEX stWndClass;

	hInstance = (HINSTANCE)::GetWindowLong(hWndParent, GWL_HINSTANCE);
	////////////////////////////////////////////////////////////////////////////////
	// 注册小地图浮动窗口类
	////////////////////////////////////////////////////////////////////////////////
	stWndClass.cbSize = sizeof(WNDCLASSEX);
	stWndClass.style = CS_HREDRAW | CS_VREDRAW;
	stWndClass.lpfnWndProc = TileAttributeWnd_WindowProc;
	stWndClass.cbClsExtra = 0;
	stWndClass.cbWndExtra = 0;
	stWndClass.hInstance = hInstance;
	stWndClass.hIcon = NULL;
	stWndClass.hCursor = ::LoadCursor(NULL, (LPCTSTR)IDC_ARROW);
	stWndClass.hbrBackground = ::GetSysColorBrush(COLOR_BTNFACE);
	stWndClass.lpszMenuName = NULL;
	stWndClass.lpszClassName = TILEATTRIBUTEWNDCLASS;
	stWndClass.hIconSm = NULL;

	// 注册窗口类
	atom = RegisterClassEx(&stWndClass);
	if (atom == 0)
	{
		return FALSE;
	}

	TAW_hTileAttributeWnd = ::CreateWindowEx(
		0x180,
		TILEATTRIBUTEWNDCLASS,
		"Tile属性",
		WS_CLIPSIBLINGS | WS_DLGFRAME |
		WS_OVERLAPPED |
		0x3B00 | WS_POPUPWINDOW |
		WS_CAPTION | WS_VISIBLE,
		0, 0, 84 + 6, 150 + 19 + 3,
		hWndParent,
		NULL,
		hInstance,
		NULL);

	if (TAW_hTileAttributeWnd == NULL)
	{
		::MessageBox(hWndParent, "创建Tile属性窗口失败！", NULL, MB_OK);
		return FALSE;
	}
	return TRUE;
}

////////////////////////////////////////////////////////////////////////////////
//
//  TileAttributeWnd_WindowProc
//
//      窗口消息处理函数
//
//
////////////////////////////////////////////////////////////////////////////////
LRESULT CALLBACK TileAttributeWnd_WindowProc(
				       HWND hWnd,
				       UINT uMsg,
				       WPARAM wParam,
				       LPARAM lParam)
{
	switch (uMsg)
	{
	case WM_CREATE:
		return TileAttributeWnd_OnCreate(hWnd, wParam, lParam);
		break;

	case WM_CLOSE:
		return TileAttributeWnd_OnClose(hWnd, wParam, lParam);
		break;

	case WM_NCACTIVATE:
		return TileAttributeWnd_OnNcActivate(hWnd, wParam, lParam);
		break;
	case WM_MOVE:
		return TileAttributeWnd_OnMove(hWnd, wParam, lParam);
		break;
	default:
		return ::DefWindowProc(hWnd, uMsg, wParam, lParam);
	}
}

LRESULT TileAttributeWnd_OnCreate(HWND hWnd, WPARAM wParam, LPARAM lParam)
{
	if (!TileAttributeDialog_Create(hWnd))
	{
		return -1;
	}
	return 0;
}

LRESULT TileAttributeWnd_OnClose(HWND hWnd, WPARAM wParam, LPARAM lParam)
{
	return 0;
}

LRESULT TileAttributeWnd_OnNcActivate(HWND hWnd, WPARAM wParam, LPARAM lParam)
{
	::DefWindowProc(hWnd, WM_NCACTIVATE, TRUE, 0);
	return 1;
}

LRESULT TileAttributeWnd_OnMove(HWND hWnd, WPARAM wParam, LPARAM lParam)
{
	POINT	pt;

	pt.x = 0;
	pt.y = 0;
	::ClientToScreen(hWnd, &pt);

	TileAttributeDialog_Move(pt.x, pt.y);
	return 0;
}






VOID TileAttributeWnd_Show(int nShow)
{
	::ShowWindow(TAW_hTileAttributeWnd, nShow);
	TileAttributeDialog_Show(nShow);
}

VOID TileAttributeWnd_Move(LONG x, LONG y)
{
	::SetWindowPos(TAW_hTileAttributeWnd, NULL, x, y, 0, 0, SWP_NOSIZE);
}