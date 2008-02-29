////////////////////////////////////////////////////////////////////////////////
//
//                              小地图
//
////////////////////////////////////////////////////////////////////////////////
//
//	文件名：
//		MiniMapWnd.cpp
//
//	说明：
//		128 x 128像素，1个像素代表一个Tile
//
//	函数：
//		
//
//////////////////////////////////////////////////////////////////////////////////
#include <windows.h>

#include "Map.h"
#include "MapEx.h"
#include "MapEditWnd.h"
#include "TemplateEditWnd.h"

#include "MiniMapWnd.h"

// 来自WinMain.cpp
extern WORD		g_MapData[ 128 ][ 128 ][ 2 ];
extern HDC		g_hDCMiniTileImage[ 512 ];


HWND		MMW_hMiniMapWnd		= NULL;
HDC		MMW_hDCMiniMap		= NULL;

// 意义和MapEditWnd.cpp的MEW_lxCamera、MEW_lyCamera相同
SHORT		MMW_nx			= 0;
SHORT		MMW_ny			= 0;

const LPCSTR	MINIMAPWNDCLASS		= "MiniMapWndClass";

////////////////////////////////////////////////////////////////////////////////
//
//                              函数声明
//
////////////////////////////////////////////////////////////////////////////////
LRESULT CALLBACK MiniMapWnd_WindowProc(
				       HWND hWnd,
				       UINT uMsg,
				       WPARAM wParam,
				       LPARAM lParam);

LRESULT MiniMapWnd_OnCreate(HWND hWnd, WPARAM wParam, LPARAM lParam);
LRESULT MiniMapWnd_OnClose(HWND hWnd, WPARAM wParam, LPARAM lParam);
LRESULT MiniMapWnd_OnDestroy(HWND hWnd, WPARAM wParam, LPARAM lParam);
LRESULT MiniMapWnd_OnPaint(HWND hWnd, WPARAM wParam, LPARAM lParam);
LRESULT MiniMapWnd_OnLButtonDown(HWND hWnd, WPARAM wParam, LPARAM lParam);

LRESULT MiniMapWnd_OnNcActivate(HWND hWnd, WPARAM wParam, LPARAM lParam);

VOID MiniMapWnd_DrawSelectRect();

////////////////////////////////////////////////////////////////////////////////
//
//                              函数定义
//
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	BOOL MiniMapWnd_Create(HWND hWndParent)
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
BOOL MiniMapWnd_Create(HWND hWndParent)
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
	stWndClass.lpfnWndProc = MiniMapWnd_WindowProc;
	stWndClass.cbClsExtra = 0;
	stWndClass.cbWndExtra = 0;
	stWndClass.hInstance = hInstance;
	stWndClass.hIcon = NULL;
	stWndClass.hCursor = ::LoadCursor(NULL, (LPCTSTR)IDC_ARROW);
	stWndClass.hbrBackground = ::GetSysColorBrush(COLOR_BTNFACE);
	stWndClass.lpszMenuName = NULL;
	stWndClass.lpszClassName = MINIMAPWNDCLASS;
	stWndClass.hIconSm = NULL;

	// 注册浮动窗口类
	atom = RegisterClassEx(&stWndClass);
	if (atom == 0)
	{
		return FALSE;
	}

	MMW_hMiniMapWnd = ::CreateWindowEx(
		0x180,
		MINIMAPWNDCLASS,
		"小地图",
		WS_CLIPSIBLINGS | WS_DLGFRAME |
		WS_OVERLAPPED |
		0x3B00 | WS_POPUPWINDOW |
		WS_CAPTION | WS_VISIBLE,
		600, 200, 134, 150,
		hWndParent,
		NULL,
		hInstance,
		NULL);

	if (MMW_hMiniMapWnd == NULL)
	{
		::MessageBox(hWndParent, "创建小地图窗口失败！", NULL, MB_OK);
		return FALSE;
	}
	return TRUE;
}

////////////////////////////////////////////////////////////////////////////////
//
//  MiniMapWnd_WindowProc
//
//      窗口消息处理函数
//
//
////////////////////////////////////////////////////////////////////////////////
LRESULT CALLBACK MiniMapWnd_WindowProc(
				       HWND hWnd,
				       UINT uMsg,
				       WPARAM wParam,
				       LPARAM lParam)
{
	switch (uMsg)
	{
	case WM_CREATE:
		return MiniMapWnd_OnCreate(hWnd, wParam, lParam);
		break;

	case WM_DESTROY:
		return MiniMapWnd_OnDestroy(hWnd, wParam, lParam);
		break;

	case WM_CLOSE:
		return MiniMapWnd_OnClose(hWnd, wParam, lParam);
		break;

	case WM_PAINT:
		return MiniMapWnd_OnPaint(hWnd, wParam, lParam);
		break;

	case WM_LBUTTONDOWN:
		return MiniMapWnd_OnLButtonDown(hWnd, wParam, lParam);
		break;

	case WM_NCACTIVATE:
		return MiniMapWnd_OnNcActivate(hWnd, wParam, lParam);
		break;

	default:
		return ::DefWindowProc(hWnd, uMsg, wParam, lParam);
	}
}

LRESULT MiniMapWnd_OnCreate(HWND hWnd, WPARAM wParam, LPARAM lParam)
{
	HDC	hDCScreen		= NULL;

	HBITMAP	hBitmap			= NULL;

	hDCScreen = ::GetDC(NULL);
	
	MMW_hDCMiniMap = ::CreateCompatibleDC(hDCScreen);

	hBitmap = ::CreateCompatibleBitmap(hDCScreen, 128, 128);
	::SelectObject(MMW_hDCMiniMap, hBitmap);
	::DeleteObject(hBitmap);

	::ReleaseDC(NULL, hDCScreen);

	return 0;
}

LRESULT MiniMapWnd_OnClose(HWND hWnd, WPARAM wParam, LPARAM lParam)
{
	return 0;
}

LRESULT MiniMapWnd_OnDestroy(HWND hWnd, WPARAM wParam, LPARAM lParam)
{
	::DeleteDC(MMW_hDCMiniMap);

	return ::DefWindowProc(hWnd, WM_DESTROY, wParam, lParam);
}

LRESULT MiniMapWnd_OnPaint(HWND hWnd, WPARAM wParam, LPARAM lParam)
{
	PAINTSTRUCT ps;
	HBRUSH	hBrush			= NULL;
	HPEN	hPen			= NULL;
	HBRUSH	hOldBrush		= NULL;
	HPEN	hOldPen			= NULL;

	HDC hdc = ::BeginPaint(hWnd, &ps);

	////////////////////////////////////////////////////////////////////////////////
	// 画小地图
	::BitBlt(hdc, 0, 0, 128, 128, MMW_hDCMiniMap, 0, 0, SRCCOPY);

	////////////////////////////////////////////////////////////////////////////////
	// 画矩形框

	// 空画刷，这样画出来的矩形就是空心的
	hBrush = (HBRUSH)::GetStockObject(NULL_BRUSH);
	// 白色线
	hPen = (HPEN)::GetStockObject(WHITE_PEN);

	hOldBrush = (HBRUSH)::SelectObject(hdc, hBrush);
	hOldPen = (HPEN)::SelectObject(hdc, hPen);

	::Rectangle(hdc, MMW_nx, MMW_ny, MMW_nx + 21, MMW_ny + 15);

	::SelectObject(hdc, hOldBrush);
	::SelectObject(hdc, hOldPen);

	::DeleteObject(hBrush);
	::DeleteObject(hPen);

	::EndPaint(hWnd, &ps);

	return ::DefWindowProc(hWnd, WM_PAINT, wParam, lParam);
}

LRESULT MiniMapWnd_OnLButtonDown(HWND hWnd, WPARAM wParam, LPARAM lParam)
{
	MMW_nx = LOWORD(lParam) - 10;
	MMW_ny = HIWORD(lParam) - 7;

	MMW_nx = MMW_nx < 0 ? 0 : MMW_nx;
	MMW_ny = MMW_ny < 0 ? 0 : MMW_ny;

	// MMW_nx必须为偶数
	MMW_nx = MMW_nx - MMW_nx % 2;

	if (MapEditWnd_IsActive())
	{
		MapEditWnd_SetCameraPos(MMW_nx, MMW_ny);
	}
	else
	{
		if (TemplateEditWnd_IsActive())
		{
			TemplateEditWnd_SetCameraPos(MMW_nx, MMW_ny);
		}
	}
	// 令窗口重画
	::InvalidateRect(hWnd, NULL, FALSE);

	return 0;
}


////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	LRESULT MiniMapWnd_OnNcActivate(HWND hWnd, WPARAM wParam, LPARAM lParam)
//
// 描述  :
//	令窗口的标题栏始终是蓝色，不会变灰
// 返回值:
//	
// 参数  :
//	Wnd -
//	wParam -
//	lParam -
//
////////////////////////////////////////////////////////////////////////////////
LRESULT MiniMapWnd_OnNcActivate(HWND hWnd, WPARAM wParam, LPARAM lParam)
{
	::DefWindowProc(hWnd, WM_NCACTIVATE, TRUE, 0);
	return 1;
}



VOID MiniMapWnd_Show(int nShow)
{
	::ShowWindow(MMW_hMiniMapWnd, nShow);
}

VOID MiniMapWnd_Move(LONG x, LONG y)
{
	::SetWindowPos(MMW_hMiniMapWnd, NULL, x, y, 0, 0, SWP_NOSIZE);
}

////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	VOID MiniMapWnd_SetCameraPos(LONG x, LONG y)
//
// 描述  :
//	设置镜头矩形框的位置
//
// 返回值:
//	
// 参数  :
//	x -
//	y -
//
////////////////////////////////////////////////////////////////////////////////
VOID MiniMapWnd_SetCameraPos(LONG x, LONG y)
{
	MMW_nx = (SHORT)x;
	MMW_ny = (SHORT)y;

	::InvalidateRect(MMW_hMiniMapWnd, NULL, FALSE);
}


////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	VOID MiniMapWnd_Paint(VOID)
//
// 描述  :
//	画整幅小地图的图像
//
// 返回值:
//	
// 参数  :
//
////////////////////////////////////////////////////////////////////////////////
VOID MiniMapWnd_Paint(VOID)
{
	MapEx_DrawMiniMap(MMW_hDCMiniMap, (LPWORD)g_MapData, (HDC*)g_hDCMiniTileImage);
	::InvalidateRect(MMW_hMiniMapWnd, NULL, FALSE);
}

////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	VOID MiniMapWnd_Paint(LONG x, LONG y)
//
// 描述  :
//	画地图上的一个Tile的图像，实际上就是一个像素
//
// 返回值:
//	
// 参数  :
//	x -
//	y -
//
////////////////////////////////////////////////////////////////////////////////
VOID MiniMapWnd_Paint(LONG x, LONG y)
{
	MapEx_UpdateMiniMap(MMW_hDCMiniMap, x, y, (LPWORD)g_MapData, (HDC*)g_hDCMiniTileImage);
	::InvalidateRect(MMW_hMiniMapWnd, NULL, FALSE);
}