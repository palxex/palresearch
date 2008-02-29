////////////////////////////////////////////////////////////////////////////////
//
//                        主框架窗口模块
//
////////////////////////////////////////////////////////////////////////////////
//
//	文件名：
//		FrameWnd.cpp
//
//	说明：
//
//
//
//////////////////////////////////////////////////////////////////////////////////
#pragma comment(lib, "comctl32.lib")
#pragma comment(lib, "msimg32.lib")

#include <windows.h>
#include <commctrl.h>
#include <stdio.h>
#include "resource.h"

#include "Menu.h"
#include "ToolBar.h"
#include "ImageSelWnd.h"
#include "Document.h"
#include "MapEditWnd.h"
#include "TemplateEditWnd.h"
#include "MiniMapWnd.h"
#include "TileAttributeWnd.h"
#include "StatusBar.h"

#include "FrameWnd.h"

extern CStatusBar	g_StatusBar;

// 模板粘帖模式
BOOL			g_bAITemplatePaster = TRUE;

////////////////////////////////////////////////////////////////////////////////
// 内部变量
////////////////////////////////////////////////////////////////////////////////
BOOL	FW_bShowToolBar			= TRUE;
BOOL	FW_bShowStatusBar		= TRUE;
BOOL	FW_bShowMiniMapWnd		= TRUE;
BOOL	FW_bShowTileAttributeWnd	= TRUE;
BOOL	FW_bShowImageSelWnd		= TRUE;

HWND	FW_hFrameWnd		= NULL;
HWND	FW_hMDIClientWnd	= NULL;

DWORD	ID_MDICLIENTWND		= 202;

BOOL	FW_bOpenMapEditWnd		= FALSE;
BOOL	FW_bOpenTemplateEditWnd		= FALSE;

// 错误提示
const CHAR	FRAMEWNDCLASS[]		= "FrameWndClass";

////////////////////////////////////////////////////////////////////////////////
//
//                       函数声明
//
//	FrameWnd_OnCreate
//	FrameWnd_OnCommand
//	FrameWnd_OnNotify
//	FrameWnd_OnSize
//
//	这些函数由FrameWnd_WindowProc调用
//
////////////////////////////////////////////////////////////////////////////////
LRESULT CALLBACK FrameWnd_WindowProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam);
LRESULT FrameWnd_OnCreate(HWND hWnd);
LRESULT FrameWnd_OnCommand(HWND hWnd, WPARAM wParam, LPARAM lParam);
LRESULT FrameWnd_OnNotify(HWND hWnd, WPARAM wParam, LPARAM lParam);
LRESULT FrameWnd_OnSize(HWND hWnd, WPARAM wParam, LPARAM lParam);
LRESULT FrameWnd_OnClose(HWND hWnd, WPARAM wParam, LPARAM lParam);
LRESULT FrameWnd_OnDestroy(HWND hWnd, WPARAM wParam, LPARAM lParam);

VOID FrameWnd_OnFileOpen(HWND hWnd);

////////////////////////////////////////////////////////////////////////////////
//
//                        函数定义
//
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	BOOL FrameWnd_Create(HINSTANCE hInstance)
//
// 描述  :
//	创建主窗口
//
// 返回值:
//	
// 参数  :
//	HINSTANCE hInstance -
//
////////////////////////////////////////////////////////////////////////////////
BOOL FrameWnd_Create(HINSTANCE hInstance)
{
	ATOM atom;
	WNDCLASSEX stWndClass;

	////////////////////////////////////////////////////////////////////////////////
	// 注册主框架窗口类
	////////////////////////////////////////////////////////////////////////////////
	stWndClass.cbSize = sizeof(WNDCLASSEX);
	stWndClass.style = CS_HREDRAW | CS_VREDRAW;
	stWndClass.lpfnWndProc = FrameWnd_WindowProc;
	stWndClass.cbClsExtra = 0;
	stWndClass.cbWndExtra = 0;
	stWndClass.hInstance = hInstance;
	stWndClass.hIcon = ::LoadIcon(hInstance, MAKEINTRESOURCE(IDI_ICON));
	stWndClass.hCursor = ::LoadCursor(NULL, (LPCTSTR)IDC_ARROW);
	stWndClass.hbrBackground = ::GetSysColorBrush(COLOR_BTNFACE);
	stWndClass.lpszMenuName = NULL;
	stWndClass.lpszClassName = FRAMEWNDCLASS;
	stWndClass.hIconSm = NULL;

	atom = RegisterClassEx(&stWndClass);
	if (atom == 0)
	{
		return FALSE;
	}

	FW_hFrameWnd = ::CreateWindowEx(
		0,
		FRAMEWNDCLASS,
		"仙剑奇侠传一代地图编辑器",
		WS_OVERLAPPEDWINDOW,
		0,
		0,
		800,
		600,
		NULL,
		NULL,
		hInstance,
		NULL);

	if (FW_hFrameWnd == NULL)
	{
		return FALSE;
	}

	::ShowWindow(FW_hFrameWnd, SW_MAXIMIZE);
	::UpdateWindow(FW_hFrameWnd);

	return TRUE;
}

////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	LRESULT CALLBACK FrameWnd_WindowProc(
//				    HWND hWnd,
//				    UINT uMsg,
//				    WPARAM wParam,
//				    LPARAM lParam)
//
// 描述  :
//	主框架窗口消息处理函数
//
// 返回值:
//	
// 参数  :
//	hWnd -
//	uMsg -
//	wParam -
//	lParam -
//
////////////////////////////////////////////////////////////////////////////////
LRESULT CALLBACK FrameWnd_WindowProc(
				    HWND hWnd,
				    UINT uMsg,
				    WPARAM wParam,
				    LPARAM lParam)
{

	switch (uMsg)
	{
	case WM_CREATE:
		return FrameWnd_OnCreate(hWnd);
		break;
	case WM_CLOSE:
		return FrameWnd_OnClose(hWnd, wParam, lParam);
		break;
	case WM_DESTROY:
		return FrameWnd_OnDestroy(hWnd, wParam, lParam);
		break;
	case WM_SIZE:
		return FrameWnd_OnSize(hWnd, wParam, lParam);
	case WM_COMMAND:
		return FrameWnd_OnCommand(hWnd, wParam, lParam);
		break;
	case WM_NOTIFY:
		return FrameWnd_OnNotify(hWnd, wParam, lParam);
		break;
	default:
		return ::DefFrameProc(hWnd, FW_hMDIClientWnd, uMsg, wParam, lParam);
	}
}

////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	VOID FrameWnd_OnCreate(HWND hWnd)
//
// 描述  :
//	WM_CREATE消息处理函数
//	创建停靠窗口、工具栏、状态栏、图块选择窗口、多文档界面客户窗口
//
// 返回值:
//	
// 参数  :
//	HWND hWnd -
//
////////////////////////////////////////////////////////////////////////////////
LRESULT FrameWnd_OnCreate(HWND hWnd)
{
	////////////////////////////////////////////////////////////////////////////////
	// 创建菜单
	////////////////////////////////////////////////////////////////////////////////
	if (!Menu_Create(hWnd))
	{
		return -1;
	}

	////////////////////////////////////////////////////////////////////////////////
	// 创建工具栏
	////////////////////////////////////////////////////////////////////////////////
	if (!ToolBar_Create(hWnd))
	{
		return -1;
	}

	////////////////////////////////////////////////////////////////////////////////
	// 创建状态栏
	////////////////////////////////////////////////////////////////////////////////
	if (!g_StatusBar.Create(hWnd))
	{
		return -1;
	}

	////////////////////////////////////////////////////////////////////////////////
	// 创建图块选择窗口
	////////////////////////////////////////////////////////////////////////////////
	if (!ImageSelWnd_Create(hWnd))
	{
		return -1;
	}

	////////////////////////////////////////////////////////////////////////////////
	// 创建多文档界面客户窗口
	////////////////////////////////////////////////////////////////////////////////
	HINSTANCE hInstance	= NULL;
	CLIENTCREATESTRUCT ClientCreate;

	::memset(&ClientCreate, 0, sizeof(CLIENTCREATESTRUCT));

	hInstance = (HINSTANCE)::GetWindowLong(hWnd, GWL_HINSTANCE);

	FW_hMDIClientWnd = ::CreateWindowEx(
		WS_EX_CLIENTEDGE,
		"MDICLIENT",
		NULL,
		WS_CHILD | WS_CLIPCHILDREN | WS_VISIBLE,
		0,
		0,
		0,
		0,
		hWnd,
		(HMENU)ID_MDICLIENTWND,
		hInstance,
		&ClientCreate
		);

	if (FW_hMDIClientWnd == NULL)
	{
		return -1;
	}

	////////////////////////////////////////////////////////////////////////////////
	// 创建小地图窗口
	////////////////////////////////////////////////////////////////////////////////
	if (!MiniMapWnd_Create(hWnd))
	{
		return -1;
	}

	////////////////////////////////////////////////////////////////////////////////
	// 创建Tile属性窗口
	////////////////////////////////////////////////////////////////////////////////
	if (!TileAttributeWnd_Create(hWnd))
	{
		return -1;
	}

	////////////////////////////////////////////////////////////////////////////////
	// 初始化文档
	////////////////////////////////////////////////////////////////////////////////
	Document_Init();
	return 0;
}

////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	VOID FrameWnd_OnCommand(HWND hWnd, WPARAM wParam, LPARAM lParam)
//
// 描述  :
//	WM_COMMAND消息处理函数
//
// 返回值:
//	
// 参数  :
//	hWnd -
//	wParam -
//	lParam -
//
////////////////////////////////////////////////////////////////////////////////
LRESULT FrameWnd_OnCommand(HWND hWnd, WPARAM wParam, LPARAM lParam)
{
	switch (LOWORD(wParam))
	{
	case IDCMD_FILE_OPEN:
		FrameWnd_OnFileOpen(hWnd);
		break;
	case IDCMD_FILE_SAVE:
		Document_SaveFile();
		break;

	case IDCMD_APP_EXIT:
		::PostMessage(hWnd, WM_CLOSE, 0, 0);
		break;
	case IDCMD_APP_ABOUT:
		break;

	case IDCMD_TEMPLATE_CLEAR:
		TemplateEditWnd_ClearTemplate();
		break;
	case IDCMD_TEMPLATE_AIPASTER:
		g_bAITemplatePaster = !g_bAITemplatePaster;
		Menu_Check(IDCMD_TEMPLATE_AIPASTER, g_bAITemplatePaster);
		break;

	case IDCMD_VIEW_MINIMAPWND:
		{
			int nShow	= 0;
			FW_bShowMiniMapWnd = !FW_bShowMiniMapWnd;
			nShow = FW_bShowMiniMapWnd ? SW_SHOW : SW_HIDE;
			MiniMapWnd_Show(nShow);
			Menu_Check(IDCMD_VIEW_MINIMAPWND, FW_bShowMiniMapWnd);
		}
		break;
	case IDCMD_VIEW_TILEATTRIBUTEWND:
		{
			int nShow	= 0;
			FW_bShowTileAttributeWnd = !FW_bShowTileAttributeWnd;
			nShow = FW_bShowTileAttributeWnd ? SW_SHOW : SW_HIDE;
			TileAttributeWnd_Show(nShow);
			Menu_Check(IDCMD_VIEW_TILEATTRIBUTEWND, FW_bShowTileAttributeWnd);
		}
		break;
	case IDCMD_WINDOW_MAPEDITWND:
		MapEditWnd_Show(SW_SHOWMAXIMIZED);
		break;
	case IDCMD_WINDOW_TEMPLATEEDITWND:
		TemplateEditWnd_Show(SW_SHOWMAXIMIZED);
		break;
	default:
		// 其它消息(IDCMD_EDIT_...)传给地图窗口或模板窗口
		HWND hWndActive = NULL;
		hWndActive = (HWND)::SendMessage(FW_hMDIClientWnd, WM_MDIGETACTIVE, 0, 0);
		if (::IsWindow(hWndActive))
		{
			::SendMessage(hWndActive, WM_COMMAND, wParam, lParam);
		}
	}
	return ::DefFrameProc(hWnd, FW_hMDIClientWnd, WM_COMMAND, wParam, lParam);
}

////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	VOID FrameWnd_OnNotify(HWND hWnd, WPARAM wParam, LPARAM lParam)
//
// 描述  :
//	WM_NOTIFY消息处理函数
//
// 返回值:
//	
// 参数  :
//	lParam -
//	lParam -
//
///////////////////////////////////////////////////////////////////////////////
LRESULT FrameWnd_OnNotify(HWND hWnd, WPARAM wParam, LPARAM lParam)
{
	LPNMTTDISPINFO lpNMTT = (LPNMTTDISPINFO)lParam;

	switch (lpNMTT->hdr.code)
	{
	case TTN_GETDISPINFO:
		{
			lpNMTT->lpszText = MAKEINTRESOURCE(lpNMTT->hdr.idFrom);
			break; 
		}
		break;
	}

	return ::DefFrameProc(hWnd, FW_hMDIClientWnd, WM_NOTIFY, wParam, lParam);
}

////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	VOID FrameWnd_OnSize(HWND hWnd, WPARAM wParam, LPARAM lParam)
//
// 描述  :
//	WM_SIZE消息处理函数
//	调整各子窗口的布局
//
// 返回值:
//	
// 参数  :
//	Wnd -
//	wParam -
//	lParam -
//
////////////////////////////////////////////////////////////////////////////////
LRESULT FrameWnd_OnSize(HWND hWnd, WPARAM wParam, LPARAM lParam)
{
	RECT	rc;
	POINT	pt;

	// 总的客户区空间
	::GetClientRect(hWnd, &rc);

	ToolBar_SizeParent(&rc);
	g_StatusBar.SizeParent(&rc);

	ImageSelWnd_SizeParent(&rc);


	// 剩下的空间就给多文档界面客户窗口
	::MoveWindow(FW_hMDIClientWnd, rc.left, rc.top, rc.right - rc.left, rc.bottom - rc.top, TRUE);

	// 移动小地图
	pt.x = rc.right - 128 - 6 - 2 - 16;
	pt.y = rc.bottom - 128 - 3 - 19 - 16 - 2;
	::ClientToScreen(hWnd, &pt);
	MiniMapWnd_Move(pt.x, pt.y);

	// 移动Tile属性窗口
	pt.x = rc.right - 84 - 6 - 2 - 16;
	pt.y = rc.top + 2;
	::ClientToScreen(hWnd, &pt);

	TileAttributeWnd_Move(pt.x, pt.y);
	return 0;
}

LRESULT FrameWnd_OnClose(HWND hWnd, WPARAM wParam, LPARAM lParam)
{
	if (!Document_CloseFile(hWnd))
	{
		return 0;
	}
	else
	{
		return ::DefFrameProc(hWnd, FW_hMDIClientWnd, WM_CLOSE, wParam, lParam);
	}
}

LRESULT FrameWnd_OnDestroy(HWND hWnd, WPARAM wParam, LPARAM lParam)
{
	Document_Release();
	::PostQuitMessage(0);
	return ::DefFrameProc(hWnd, FW_hMDIClientWnd, WM_DESTROY, wParam, lParam);
}

////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	VOID FrameWnd_OnFileOpen(HWND hWnd)
//
// 描述  :
//	
// 返回值:
//	
// 参数  :
//	HWND hWnd -
//
////////////////////////////////////////////////////////////////////////////////
VOID FrameWnd_OnFileOpen(HWND hWnd)
{
	CHAR	Buffer[ MAX_PATH ];

	if (Document_OpenFile(hWnd))
	{
		// 更新图块选择窗口的图块列表
		ImageSelWnd_Update();

		// 重画小地图
		MiniMapWnd_Paint();

		if (FW_bOpenTemplateEditWnd == FALSE)
		{
			if (TemplateEditWnd_Create(FW_hMDIClientWnd))
			{
				FW_bOpenTemplateEditWnd = TRUE;
			}
		}

		if (FW_bOpenMapEditWnd == FALSE)
		{
			if (MapEditWnd_Create(FW_hMDIClientWnd))
			{
				FW_bOpenMapEditWnd = TRUE;
			}
		}
	
		sprintf(Buffer, "地图 - %s", Document_GetFileName());
		MapEditWnd_SetTitle(Buffer);

		sprintf(Buffer, "模板 - %s", Document_GetFileName());
		TemplateEditWnd_SetTitle(Buffer);

		TemplateEditWnd_ClearTemplate();
	}
}