////////////////////////////////////////////////////////////////////////////////
//
//                              地图编辑窗口模块
//
////////////////////////////////////////////////////////////////////////////////
//
//	文件名：
//		MapEditWnd.cpp
//
//	说明：
//		地图编辑功能：
//
//		1、选择Tile
//		2、使用被选择的图块编辑地图Tile
//		3、使用模板编辑地图
//		4、清除地图Tile的数据
//		5、设置障碍Tile
//		
//		为反映地图的遮挡情况，在当前选择的Tile上加了
//	一个人物对象。
//		
//		垂直滚动条的范围是0 - 127
//		水平滚动条的范围是0 - 63，把它乘以2就是0 - 126，且为偶数
//
//////////////////////////////////////////////////////////////////////////////////
#include <windows.h>
#include <commctrl.h>
#include "resource.h"

#include "Map.h"
#include "MapEx.h"
#include "ImageSelWnd.h"
#include "Document.h"
#include "ToolBar.h"
#include "Menu.h"
#include "MiniMapWnd.h"
#include "TileAttributeDialog.h"
#include "StatusBar.h"

#include "MapEditWnd.h"

// 来自WinMain.cpp
extern WORD		g_MapData[ 128 ][ 128 ][ 2 ];

extern HDC		g_hDCTileImage[ 512 ];

extern HDC		g_hDCMiniTileImage[ 512 ];

extern DWORD		g_dwTemplateCount;
extern DRAWTILESTRUCT	g_Template[ 1024 ];

extern CStatusBar	g_StatusBar;

extern BOOL		g_bAITemplatePaster;

////////////////////////////////////////////////////////////////////////////////
// 内部变量
////////////////////////////////////////////////////////////////////////////////

// 窗口是否处于激活状态
BOOL		MEW_bActive			= FALSE;

// 视口左上角Tile在地图上的坐标
LONG		MEW_lxCamera			= 0;
LONG		MEW_lyCamera			= 0;

// 鼠标所指的Tile的坐标
LONG		MEW_lxMouseAtTile		= 0;
LONG		MEW_lyMouseAtTile		= 0;

// 当前选择的Tile的坐标
LONG		MEW_lxCurSelTile		= 0;
LONG		MEW_lyCurSelTile		= 0;	

// 编辑状态
// IDCMD_EDIT_SELECT		- 选择状态
// IDCMD_EDIT_PEN		- 编辑状态
// IDCMD_EDIT_TEMPLATE		- 使用模板
// IDCMD_EDIT_ERASE		- 清除数据
// IDCMD_EDIT_BARRIER		- 设置障碍
DWORD		MEW_dwStatus			= IDCMD_EDIT_SELECT;

// 当前编辑的图层
DWORD		MEW_dwCurEditLayer		= IDCMD_EDIT_LAYER0;

// 鼠标左键是否被按下
BOOL		MEW_bMouseLBDown		= FALSE;

// 是否显示人物对象
BOOL		MEW_bShowObject			= FALSE;

// 是否标示障碍Tile
BOOL		MEW_bShowBarrier		= FALSE;

// 图像
HDC		MEW_hDCMouseAtTile		= NULL;
HDC		MEW_hDCCurSelTile		= NULL;
HDC		MEW_hDCBarrier			= NULL;
HDC		MEW_hDCObject			= NULL;

// 后台屏幕
HDC		MEW_hDCBack			= NULL;

HWND		MEW_hMapEditWnd			= NULL;

const LPCSTR	MAPEDITWNDCLASS			= "MapEditWndClass";
const LPCSTR	MEW_ErrorString			= "创建地图编辑窗口失败！";

////////////////////////////////////////////////////////////////////////////////
//
//                       窗口各个消息的处理函数
//
//	MapEditWnd_OnCreate
//	MapEditWnd_OnDestroy
//	MapEditWnd_OnCommand
//	MapEditWnd_OnTimer
//
//	MapEditWnd_OnMouseMove
//	MapEditWnd_OnLButtonDown
//	MapEditWnd_OnLButtonUp
//	MapEditWnd_OnRButtonDown
//	MapEditWnd_OnRButtonUp
//
//	MapEditWnd_OnVScroll
//	MapEditWnd_OnHScroll
//
//
//	这些函数由MapEditWnd_WindowProc调用
//
////////////////////////////////////////////////////////////////////////////////
LRESULT CALLBACK MapEditWnd_WindowProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam);

LRESULT MapEditWnd_OnCreate(HWND hWnd, WPARAM wParam, LPARAM lParam);
LRESULT MapEditWnd_OnClose(HWND hWnd, WPARAM wParam, LPARAM lParam);
LRESULT MapEditWnd_OnDestroy(HWND hWnd, WPARAM wParam, LPARAM lParam);
LRESULT MapEditWnd_OnCommand(HWND hWnd, WPARAM wParam, LPARAM lParam);
LRESULT MapEditWnd_OnTimer(HWND hWnd, WPARAM wParam, LPARAM lParam);

LRESULT MapEditWnd_OnMouseMove(HWND hWnd, WPARAM wParam, LPARAM lParam);
LRESULT MapEditWnd_OnLButtonDown(HWND hWnd, WPARAM wParam, LPARAM lParam);
LRESULT MapEditWnd_OnLButtonUp(HWND hWnd, WPARAM wParam, LPARAM lParam);
LRESULT MapEditWnd_OnRButtonDown(HWND hWnd, WPARAM wParam, LPARAM lParam);
LRESULT MapEditWnd_OnRButtonUp(HWND hWnd, WPARAM wParam, LPARAM lParam);

LRESULT MapEditWnd_OnVScroll(HWND hWnd, WPARAM wParam, LPARAM lParam);
LRESULT MapEditWnd_OnHScroll(HWND hWnd, WPARAM wParam, LPARAM lParam);

LRESULT MapEditWnd_OnMDIActivate(HWND hWnd, WPARAM wParam, LPARAM lParam);

VOID MapEditWnd_UpdateCommandUI(VOID);


////////////////////////////////////////////////////////////////////////////////
//
//				函数定义
//
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	BOOL MapEditWnd_Create(HWND hWndParent)
//
// 描述  :
//	创建地图编窗口
//
// 返回值:
//	
// 参数  :
//	HWND hWndParent - 父窗口句柄，必须为MDI客户窗口
//
////////////////////////////////////////////////////////////////////////////////
BOOL MapEditWnd_Create(HWND hWndParent)
{
	MDICREATESTRUCT		MDICreate;
	HINSTANCE		hInstance	= NULL;
	WNDCLASSEX		stWndClass;
	ATOM			atom;

	hInstance = (HINSTANCE)::GetWindowLong(hWndParent, GWL_HINSTANCE);

	////////////////////////////////////////////////////////////////////////////////
	// 注册地图编辑窗口类
	////////////////////////////////////////////////////////////////////////////////
	stWndClass.cbSize = sizeof(WNDCLASSEX);
	stWndClass.style = CS_HREDRAW | CS_VREDRAW;
	stWndClass.lpfnWndProc = MapEditWnd_WindowProc;
	stWndClass.cbClsExtra = 0;
	stWndClass.cbWndExtra = 0;
	stWndClass.hInstance = hInstance;
	stWndClass.hIcon = ::LoadIcon(hInstance, MAKEINTRESOURCE(IDI_ICON_MAPEDIT));
	stWndClass.hCursor = ::LoadCursor(NULL, (LPCTSTR)IDC_ARROW);
	stWndClass.hbrBackground = ::GetSysColorBrush(COLOR_BTNFACE);
	stWndClass.lpszMenuName = NULL;
	stWndClass.lpszClassName = MAPEDITWNDCLASS;
	stWndClass.hIconSm = NULL;

	atom = RegisterClassEx(&stWndClass);
	if (atom == 0)
	{
		return FALSE;
	}

	////////////////////////////////////////////////////////////////////////////////
	// 创建地图编辑窗口
	////////////////////////////////////////////////////////////////////////////////
	MDICreate.cx      = 320;
	MDICreate.cy      = 200;
	MDICreate.x       = 0;
	MDICreate.y       = 0;
	MDICreate.hOwner  = hInstance;
	MDICreate.lParam  = 0;
	MDICreate.style   = 0;
	MDICreate.szClass = MAPEDITWNDCLASS;
	MDICreate.szTitle = "地图";

	MEW_hMapEditWnd = (HWND)::SendMessage(hWndParent, WM_MDICREATE, 0, (LPARAM)&MDICreate);

	if (MEW_hMapEditWnd == NULL)
	{
		::MessageBox(hWndParent, MEW_ErrorString, NULL, MB_OK);
		return FALSE;
	}

	return TRUE;
}

////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	LRESULT CALLBACK MapEditWnd_WindowProc(
//				       HWND hWnd,
//				       UINT uMsg,
//				       WPARAM wParam,
//				       LPARAM lParam)
//
// 描述  :
//	地图编辑窗口消息处理函数
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
LRESULT CALLBACK MapEditWnd_WindowProc(
				       HWND hWnd,
				       UINT uMsg,
				       WPARAM wParam,
				       LPARAM lParam)
{
	switch (uMsg)
	{
	case WM_CREATE:
		return MapEditWnd_OnCreate(hWnd, wParam, lParam);
		break;
	case WM_DESTROY:
		return MapEditWnd_OnDestroy(hWnd, wParam, lParam);
		break;
	case WM_CLOSE:
		return MapEditWnd_OnClose(hWnd, wParam, lParam);
		break;
	case WM_COMMAND:
		return MapEditWnd_OnCommand(hWnd, wParam, lParam);
		break;
	case WM_TIMER:
		return MapEditWnd_OnTimer(hWnd, wParam, lParam);
		break;
	case WM_MOUSEMOVE:
		return MapEditWnd_OnMouseMove(hWnd, wParam, lParam);
		break;
	case WM_LBUTTONDOWN:
		return MapEditWnd_OnLButtonDown(hWnd, wParam, lParam);
		break;
	case WM_LBUTTONUP:
		return MapEditWnd_OnLButtonUp(hWnd, wParam, lParam);
		break;
	case WM_RBUTTONDOWN:
		return MapEditWnd_OnRButtonDown(hWnd, wParam, lParam);
		break;
	case WM_RBUTTONUP:
		return MapEditWnd_OnRButtonUp(hWnd, wParam, lParam);
		break;
	case WM_HSCROLL:
		return MapEditWnd_OnHScroll(hWnd, wParam, lParam);
		break;
	case WM_VSCROLL:
		return MapEditWnd_OnVScroll(hWnd, wParam, lParam);
		break;
	case WM_MDIACTIVATE:
		return MapEditWnd_OnMDIActivate(hWnd, wParam, lParam);
		break;
	default:
		return ::DefMDIChildProc(hWnd, uMsg, wParam, lParam);
	}
}

////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	VOID MapEditWnd_OnCreate(HWND hWnd, WPARAM wParam, LPARAM lParam)
//
// 描述  :
//	WM_CREATE消息处现函数
//
// 返回值:
//	
// 参数  :
//	hWnd -
//	wParam -
//	lParam -
//
////////////////////////////////////////////////////////////////////////////////
LRESULT MapEditWnd_OnCreate(HWND hWnd, WPARAM wParam, LPARAM lParam)
{
	LONG		lStyleEx		= 0;
	HDC		hDCScreen		= NULL;
	HBRUSH		hBrush			= NULL;
	HBITMAP		hBitmap			= NULL;
	HINSTANCE	hInstance		= NULL;

	// 增加客户边框风格
	lStyleEx = ::GetWindowLong(hWnd, GWL_EXSTYLE);
	lStyleEx |= WS_EX_CLIENTEDGE;
	::SetWindowLong(hWnd, GWL_EXSTYLE, lStyleEx);

	// 设置滚动条
	::SetScrollRange(hWnd, SB_VERT, 0, 127, TRUE);	// 垂直
	::SetScrollRange(hWnd, SB_HORZ, 0, 63, TRUE);	// 水平

	// 创建黑色的后台屏幕
	hDCScreen	= ::GetDC(NULL);
	MEW_hDCBack = ::CreateCompatibleDC(hDCScreen);

	hBitmap = ::CreateCompatibleBitmap(hDCScreen, 1024, 768);
	::SelectObject(MEW_hDCBack, hBitmap);
	::DeleteObject(hBitmap);

	hBrush = (HBRUSH)::GetStockObject(BLACK_BRUSH);
	::SelectObject(MEW_hDCBack, hBrush);
	::DeleteObject(hBrush);

	// 载入表示3种Tile的图标
	hInstance = (HINSTANCE)::GetWindowLong(hWnd, GWL_HINSTANCE);

	// 绿色，表示当前鼠标所在Tile
	hBitmap = (HBITMAP)::LoadImage(hInstance, MAKEINTRESOURCE(IDB_BITMAP1), IMAGE_BITMAP, 0, 0, 0);
	MEW_hDCMouseAtTile = ::CreateCompatibleDC(hDCScreen);
	::SelectObject(MEW_hDCMouseAtTile, hBitmap);
	::DeleteObject(hBitmap);

	// 蓝色，表示当前选择的Tile
	hBitmap = (HBITMAP)::LoadImage(hInstance, MAKEINTRESOURCE(IDB_BITMAP2), IMAGE_BITMAP, 0, 0, 0);
	MEW_hDCCurSelTile = ::CreateCompatibleDC(hDCScreen);
	::SelectObject(MEW_hDCCurSelTile, hBitmap);
	::DeleteObject(hBitmap);

	// 红色，表示障碍Tile
	hBitmap = (HBITMAP)::LoadImage(hInstance, MAKEINTRESOURCE(IDB_BITMAP3), IMAGE_BITMAP, 0, 0, 0);
	MEW_hDCBarrier = ::CreateCompatibleDC(hDCScreen);
	::SelectObject(MEW_hDCBarrier, hBitmap);
	::DeleteObject(hBitmap);

	// 地图上的人物对像，用于反映地图的遮挡关系
	hBitmap = (HBITMAP)::LoadImage(hInstance, MAKEINTRESOURCE(IDB_BITMAP4), IMAGE_BITMAP, 0, 0, 0);
	MEW_hDCObject = ::CreateCompatibleDC(hDCScreen);
	::SelectObject(MEW_hDCObject, hBitmap);
	::DeleteObject(hBitmap);

	::ReleaseDC(NULL, hDCScreen);

	// 设置菜单、工具栏按钮为可用
	BOOL bEnable = TRUE;
	ToolBar_Enable(IDCMD_FILE_SAVE, bEnable);

	ToolBar_Enable(IDCMD_EDIT_SELECT, bEnable);
	ToolBar_Enable(IDCMD_EDIT_PEN, bEnable);
	ToolBar_Enable(IDCMD_EDIT_TEMPLATE, bEnable);
	ToolBar_Enable(IDCMD_EDIT_ERASE, bEnable);
	ToolBar_Enable(IDCMD_EDIT_BARRIER, bEnable);

	ToolBar_Enable(IDCMD_EDIT_LAYER0, bEnable);
	ToolBar_Enable(IDCMD_EDIT_LAYER1, bEnable);

	ToolBar_Enable(IDCMD_VIEW_BARRIER, bEnable);

	ToolBar_Enable(IDCMD_WINDOW_MAPEDITWND, bEnable);
	ToolBar_Enable(IDCMD_WINDOW_TEMPLATEEDITWND, bEnable);

	Menu_Enable(IDCMD_FILE_SAVE, bEnable);

	Menu_Enable(IDCMD_EDIT_SELECT, bEnable);
	Menu_Enable(IDCMD_EDIT_PEN, bEnable);
	Menu_Enable(IDCMD_EDIT_TEMPLATE, bEnable);
	Menu_Enable(IDCMD_EDIT_ERASE, bEnable);
	Menu_Enable(IDCMD_EDIT_BARRIER, bEnable);

	Menu_Enable(IDCMD_EDIT_LAYER0, bEnable);
	Menu_Enable(IDCMD_EDIT_LAYER1, bEnable);

	Menu_Enable(IDCMD_VIEW_BARRIER, bEnable);
	Menu_Enable(IDCMD_VIEW_OBJECT, bEnable);

	Menu_Enable(IDCMD_WINDOW_MAPEDITWND, bEnable);
	Menu_Enable(IDCMD_WINDOW_TEMPLATEEDITWND, bEnable);

	Menu_Enable(IDCMD_TEMPLATE_CLEAR, bEnable);
	Menu_Enable(IDCMD_TEMPLATE_AIPASTER, bEnable);

	::MapEditWnd_UpdateCommandUI();

	return 0;
}

LRESULT MapEditWnd_OnClose(HWND hWnd, WPARAM wParam, LPARAM lParam)
{
	return 0;
}

////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	VOID MapEditWnd_OnDestroy(HWND hWnd, WPARAM wParam, LPARAM lParam)
//
// 描述  :
//	WM_DESTROY消息处理函数
//	窗口关闭前释放DC
//
// 返回值:
//	
// 参数  :
//	hWnd -
//	wParam -
//	lParam -
//
////////////////////////////////////////////////////////////////////////////////
LRESULT MapEditWnd_OnDestroy(HWND hWnd, WPARAM wParam, LPARAM lParam)
{
	::DeleteDC(MEW_hDCMouseAtTile);
	::DeleteDC(MEW_hDCCurSelTile);
	::DeleteDC(MEW_hDCBarrier);
	::DeleteDC(MEW_hDCObject);
	::DeleteDC(MEW_hDCBack);

	return ::DefMDIChildProc(hWnd, WM_DESTROY, wParam, lParam);
}

////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	VOID MapEditWnd_OnCommand(HWND hWnd, WPARAM wParam, LPARAM lParam)
//
// 描述  :
//	WM_COMMAND消息处理函数
//	改变编辑状态和显示标志，并更新工具栏、菜单的状态
//
// 返回值:
//	
// 参数  :
//	hWnd -
//	wParam -
//	lParam -
//
////////////////////////////////////////////////////////////////////////////////
LRESULT MapEditWnd_OnCommand(HWND hWnd, WPARAM wParam, LPARAM lParam)
{
	switch (LOWORD(wParam))
	{
	case IDCMD_EDIT_LAYER0:
	case IDCMD_EDIT_LAYER1:
		MEW_dwCurEditLayer = LOWORD(wParam);
		break;

	case IDCMD_EDIT_SELECT:
	case IDCMD_EDIT_PEN:
	case IDCMD_EDIT_TEMPLATE:
	case IDCMD_EDIT_ERASE:
		MEW_dwStatus = LOWORD(wParam);
		break;
	case IDCMD_EDIT_BARRIER:
		MEW_dwStatus = LOWORD(wParam);
		MEW_bShowBarrier = TRUE;
		break;
	case IDCMD_VIEW_BARRIER:
		MEW_bShowBarrier = !MEW_bShowBarrier;
		break;
	case IDCMD_VIEW_OBJECT:
		MEW_bShowObject = !MEW_bShowObject;
		break;
	}
	MapEditWnd_UpdateCommandUI();

	return 0;
}

////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	VOID MapEditWnd_OnTimer(HWND hWnd, WPARAM wParam, LPARAM lParam)
//
// 描述  :
//	WM_TIMER消息处理函数
//	刷新窗口画面
//
// 返回值:
//	
// 参数  :
//	hWnd -
//	wParam -
//	lParam -
//
////////////////////////////////////////////////////////////////////////////////
LRESULT MapEditWnd_OnTimer(HWND hWnd, WPARAM wParam, LPARAM lParam)
{
	HDC hDC;
	DRAWTILESTRUCT	DrawTile;

	int cxScreen = ::GetSystemMetrics(SM_CXSCREEN);
	int cyScreen = ::GetSystemMetrics(SM_CYSCREEN);

	POINT	pt;
	::GetCursorPos(&pt);
	if (pt.x == cxScreen - 1)
	{
		::SendMessage(hWnd, WM_HSCROLL, MAKEWPARAM(SB_LINERIGHT, 0), 0);
	}
	if (pt.x == 0)
	{
		::SendMessage(hWnd, WM_HSCROLL, MAKEWPARAM(SB_LINELEFT, 0), 0);
	}
	if (pt.y == 0)
	{
		::SendMessage(hWnd, WM_VSCROLL, MAKEWPARAM(SB_LINEUP, 0), 0);
	}
	if (pt.y == cyScreen - 1)
	{
		::SendMessage(hWnd, WM_VSCROLL, MAKEWPARAM(SB_LINEDOWN, 0), 0);
	}

	// 清屏
	::Rectangle(MEW_hDCBack, 0, 0, 800, 600);

	MapEx_Draw(MEW_hDCBack, 45, 30, (LPWORD)g_MapData, (HDC*)g_hDCTileImage, MEW_lxCamera, MEW_lyCamera);

	if (MEW_bShowObject)
	{
		::MapEx_ViewObject(
			MEW_hDCBack,
			MEW_lxCurSelTile,
			MEW_lyCurSelTile,
			MEW_hDCObject,
			(LPWORD)g_MapData,
			g_hDCTileImage,
			MEW_lxCamera,
			MEW_lyCamera
			);
	}

	if (MEW_dwStatus == IDCMD_EDIT_TEMPLATE)
	{
		MapEx_DrawTemplate(MEW_hDCBack, (LPWORD)g_MapData, MEW_lxMouseAtTile, MEW_lyMouseAtTile, g_Template, g_dwTemplateCount, MEW_lxCamera, MEW_lyCamera, g_bAITemplatePaster);
	}

	if (MEW_bShowBarrier)
	{
		MapEx_MarkBarrier(MEW_hDCBack, 45, 30, (LPWORD)g_MapData, MEW_hDCBarrier, MEW_lxCamera, MEW_lyCamera);
	}

	memset(&DrawTile, 0, sizeof(DRAWTILESTRUCT));

	DrawTile.lxOrigin = MEW_lxCamera;
	DrawTile.lyOrigin = MEW_lyCamera;
	DrawTile.lxTile = MEW_lxMouseAtTile;
	DrawTile.lyTile = MEW_lyMouseAtTile;
	DrawTile.hDCMark = MEW_hDCMouseAtTile;

	Map_MarkTile(MEW_hDCBack, &DrawTile);

	memset(&DrawTile, 0, sizeof(DRAWTILESTRUCT));

	DrawTile.lxOrigin = MEW_lxCamera;
	DrawTile.lyOrigin = MEW_lyCamera;
	DrawTile.lxTile = MEW_lxCurSelTile;
	DrawTile.lyTile = MEW_lyCurSelTile;
	DrawTile.hDCMark = MEW_hDCCurSelTile;

	Map_MarkTile(MEW_hDCBack, &DrawTile);

//	MapEx_DrawMiniMap(MEW_hDCBack, (LPWORD)g_MapData, g_hDCMiniTileImage);

	hDC = ::GetDC(hWnd);

	::BitBlt(hDC, 0, 0, 1024, 768, MEW_hDCBack, 0, 0, SRCCOPY);

	::ReleaseDC(hWnd, hDC);

	return 0;
}

////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	VOID MapEditWnd_OnMouseMove(HWND hWnd, WPARAM wParam, LPARAM lParam)
//
// 描述  :
//	WM_MOUSEMOVE消息处理函数
// 返回值:
//	
// 参数  :
//	hWnd -
//	wParam -
//	lParam -
//
////////////////////////////////////////////////////////////////////////////////
LRESULT MapEditWnd_OnMouseMove(HWND hWnd, WPARAM wParam, LPARAM lParam)
{
	LONG	lCurSelImage	= -1;
	LONG	lLayer		= 0;

	LONG	xt		= 0;
	LONG	yt		= 0;

	// 根据鼠标坐标计算鼠标当前所指的Tile
	Map_CalcXYTileToPixel(MEW_lxCamera, MEW_lyCamera, &xt, &yt);
	
	xt += LOWORD(lParam) + 32;
	yt += HIWORD(lParam) + 16;

	Map_CalcXYPixelToTile(xt, yt, &MEW_lxMouseAtTile, &MEW_lyMouseAtTile);

	g_StatusBar.SetXY(MEW_lxMouseAtTile, MEW_lyMouseAtTile);

	if (MEW_dwCurEditLayer == IDCMD_EDIT_LAYER0)
	{
		lLayer = 0;
	}
	else
	{
		if (MEW_dwCurEditLayer == IDCMD_EDIT_LAYER1)
		{
			lLayer = 1;
		}
	}

	if (!Map_Assert(MEW_lxMouseAtTile, MEW_lyMouseAtTile))
	{
		return 0;
	}

	if (MEW_bMouseLBDown)
	{
		switch (MEW_dwStatus)
		{
		case IDCMD_EDIT_PEN:
			lCurSelImage = ImageSelWnd_GetSelImage();
			if (lCurSelImage < 0)
			{
				return 0;
			}
			Map_SetLayerImage((DWORD*)&g_MapData[ MEW_lyMouseAtTile ][ MEW_lxMouseAtTile ][ lLayer ], lCurSelImage + lLayer);
			MiniMapWnd_Paint(MEW_lxMouseAtTile, MEW_lyMouseAtTile);
			Document_SetEditFlag(TRUE);
			break;

		case IDCMD_EDIT_ERASE:
			g_MapData[ MEW_lyMouseAtTile ][ MEW_lxMouseAtTile ][ lLayer ] = 0;
			Document_SetEditFlag(TRUE);
			break;

		case IDCMD_EDIT_BARRIER:
			Map_SetTileBarrier((DWORD*)&g_MapData[ MEW_lyMouseAtTile ][ MEW_lxMouseAtTile ][ 0 ], !Map_IsBarrier(g_MapData[ MEW_lyCurSelTile ][ MEW_lxCurSelTile ][ 0 ]));
			Document_SetEditFlag(TRUE);
			break;
		}
	}

	return 0;
}

////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	VOID MapEditWnd_OnLButtonDown(HWND hWnd, WPARAM wParam, LPARAM lParam)
//
// 描述  :
//	WM_LBUTTONDOWN消息处理函数
//
// 返回值:
//	
// 参数  :
//	hWnd -
//	wParam -
//	lParam -
//
////////////////////////////////////////////////////////////////////////////////
LRESULT MapEditWnd_OnLButtonDown(HWND hWnd, WPARAM wParam, LPARAM lParam)
{
	LONG	lCurSelImage	= -1;
	LONG	lLayer		= 0;

	LONG	xt		= 0;
	LONG	yt		= 0;

	// 根据鼠标坐标计算鼠标当前所指的Tile
	Map_CalcXYTileToPixel(MEW_lxCamera, MEW_lyCamera, &xt, &yt);
	
	xt += LOWORD(lParam) + 32;
	yt += HIWORD(lParam) + 16;

	Map_CalcXYPixelToTile(xt, yt, &MEW_lxMouseAtTile, &MEW_lyMouseAtTile);

	MEW_lxCurSelTile = MEW_lxMouseAtTile;
	MEW_lyCurSelTile = MEW_lyMouseAtTile;

	if (MEW_dwCurEditLayer == IDCMD_EDIT_LAYER0)
	{
		lLayer = 0;
	}
	else
	{
		if (MEW_dwCurEditLayer == IDCMD_EDIT_LAYER1)
		{
			lLayer = 1;
		}
	}

	if (!Map_Assert(MEW_lxCurSelTile, MEW_lyCurSelTile))
	{
		return 0;
	}

	switch (MEW_dwStatus)
	{
	case IDCMD_EDIT_PEN:
		lCurSelImage = ImageSelWnd_GetSelImage();
		if (lCurSelImage < 0)
		{
			return 0;
		}
		MEW_bMouseLBDown = TRUE;
		::SetCapture(hWnd);
		Map_SetLayerImage((DWORD*)&g_MapData[ MEW_lyCurSelTile ][ MEW_lxCurSelTile ][ lLayer ], lCurSelImage + lLayer);
		MiniMapWnd_Paint(MEW_lxCurSelTile, MEW_lyCurSelTile);
		Document_SetEditFlag(TRUE);
		break;

	case IDCMD_EDIT_ERASE:
		MEW_bMouseLBDown = TRUE;
		::SetCapture(hWnd);
		g_MapData[ MEW_lyCurSelTile ][ MEW_lxCurSelTile ][ lLayer ] = 0;
		Document_SetEditFlag(TRUE);
		break;

	case IDCMD_EDIT_BARRIER:
		MEW_bMouseLBDown = TRUE;
		::SetCapture(hWnd);
		Map_SetTileBarrier((DWORD*)&g_MapData[ MEW_lyCurSelTile ][ MEW_lxCurSelTile ][ 0 ], !Map_IsBarrier(g_MapData[ MEW_lyCurSelTile ][ MEW_lxCurSelTile ][ 0 ]));
		Document_SetEditFlag(TRUE);
		break;

	case IDCMD_EDIT_TEMPLATE:
		MapEx_PasterTemplate((LPWORD)g_MapData, MEW_lxCurSelTile, MEW_lyCurSelTile, g_Template, g_dwTemplateCount, g_bAITemplatePaster);
		Document_SetEditFlag(TRUE);
		break;
	}

	TileAttributeDialog_Update(&g_MapData[ MEW_lyCurSelTile ][ MEW_lxCurSelTile ][ 0 ], &g_MapData[ MEW_lyCurSelTile ][ MEW_lxCurSelTile ][ 1 ]);
	return 0;
}

////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	VOID MapEditWnd_OnLButtonUp(HWND hWnd, WPARAM wParam, LPARAM lParam)
//
// 描述  :
//	WM_LBUTTONUP消息处理函数
//
// 返回值:
//	
// 参数  :
//	hWnd -
//	wParam -
//	lParam -
//
////////////////////////////////////////////////////////////////////////////////
LRESULT MapEditWnd_OnLButtonUp(HWND hWnd, WPARAM wParam, LPARAM lParam)
{
	if (MEW_bMouseLBDown == TRUE)
	{
		MEW_bMouseLBDown = FALSE;
		::ReleaseCapture();
	}
	return 0;
}

////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	VOID MapEditWnd_OnRButtonDown(HWND hWnd, WPARAM wParam, LPARAM lParam)
//
// 描述  :
//	WM_RBUTTONUP消息处理函数
//
// 返回值:
//	
// 参数  :
//	hWnd -
//	wParam -
//	lParam -
//
////////////////////////////////////////////////////////////////////////////////
LRESULT MapEditWnd_OnRButtonDown(HWND hWnd, WPARAM wParam, LPARAM lParam)
{
	LONG	xt		= 0;
	LONG	yt		= 0;

	// 根据鼠标坐标计算鼠标当前所指的Tile
	Map_CalcXYTileToPixel(MEW_lxCamera, MEW_lyCamera, &xt, &yt);
	
	xt += LOWORD(lParam) + 32;
	yt += HIWORD(lParam) + 16;

	Map_CalcXYPixelToTile(
		xt,
		yt,
		&MEW_lxMouseAtTile,
		&MEW_lyMouseAtTile);

	MEW_lxCurSelTile = MEW_lxMouseAtTile;
	MEW_lyCurSelTile = MEW_lyMouseAtTile;

	TileAttributeDialog_Update(&g_MapData[ MEW_lyCurSelTile ][ MEW_lxCurSelTile ][ 0 ], &g_MapData[ MEW_lyCurSelTile ][ MEW_lxCurSelTile ][ 1 ]);
	return 0;
}

////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	VOID MapEditWnd_OnRButtonUp(HWND hWnd, WPARAM wParam, LPARAM lParam)
//
// 描述  :
//	WM_RBUTTONUP消息处理函数
//	暂时没用
//
// 返回值:
//	
// 参数  :
//	hWnd -
//	wParam -
//	lParam -
//
////////////////////////////////////////////////////////////////////////////////
LRESULT MapEditWnd_OnRButtonUp(HWND hWnd, WPARAM wParam, LPARAM lParam)
{

	// 右击菜单
/*	HINSTANCE hInstance;
	HMENU hPopupMenu, g_hMenu;
	UINT uFlags;
	POINT Point;

	Point.x = 0;
	Point.y = 0;
	::ClientToScreen(hWnd, &Point);

	uFlags = TPM_LEFTALIGN | TPM_TOPALIGN | TPM_NONOTIFY | TPM_LEFTBUTTON;
	hInstance = (HINSTANCE)::GetWindowLong(g_hWnd, GWL_HINSTANCE);
	g_hMenu = ::LoadMenu(hInstance, MAKEINTRESOURCE(IDR_MENU_POPUP));
	hPopupMenu = GetSubMenu(g_hMenu, 0); 
   	::TrackPopupMenu(hPopupMenu, uFlags, Point.x + LOWORD(lParam), Point.y + HIWORD(lParam), 0, g_hWnd, NULL);
	::DestroyMenu(g_hMenu);
	*/

	return 0;
}

////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	VOID MapEditWnd_OnVScroll(HWND hWnd, WPARAM wParam, LPARAM lParam)
//
// 描述  :
//	WM_VSCROLL消息处理函数
//	垂直滚动条消息处理函数
//
// 返回值:
//	
// 参数  :
//	hWnd -
//	wParam -
//	lParam -
//
////////////////////////////////////////////////////////////////////////////////
LRESULT MapEditWnd_OnVScroll(HWND hWnd, WPARAM wParam, LPARAM lParam)
{
	int nPos;
	switch (LOWORD(wParam))
	{
	case SB_LINEUP:
		nPos = ::GetScrollPos(hWnd, SB_VERT);
		if (nPos > 0)
		{
			nPos--;
			MEW_lyCamera = nPos;
			::SetScrollPos(hWnd, SB_VERT, nPos, TRUE);
		}
		break;
	case SB_LINEDOWN:
		nPos = ::GetScrollPos(hWnd, SB_VERT);
		if (nPos < 127)
		{
			nPos++;
			MEW_lyCamera = nPos;
			::SetScrollPos(hWnd, SB_VERT, nPos, TRUE);
		}
		break;
	case SB_THUMBTRACK:
		nPos = HIWORD(wParam);
		MEW_lyCamera = nPos;
		::SetScrollPos(hWnd, SB_VERT, HIWORD(wParam), TRUE);
		break;
	case SB_PAGEUP:
		nPos = ::GetScrollPos(hWnd, SB_VERT);
		nPos--;
		MEW_lyCamera = nPos;
		::SetScrollPos(hWnd, SB_VERT, nPos, TRUE);
		break;
	case SB_PAGEDOWN:
		nPos = ::GetScrollPos(hWnd, SB_VERT);
		nPos++;
		::SetScrollPos(hWnd, SB_VERT, nPos, TRUE);
		MEW_lyCamera = nPos;
		break;
	}

	::MiniMapWnd_SetCameraPos(MEW_lxCamera, MEW_lyCamera);
	return 0;
}

////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	VOID MapEditWnd_OnHScroll(HWND hWnd, WPARAM wParam, LPARAM lParam)
//
// 描述  :
//	WM_HSCROLL消息处理函数
//	水平滚动条消息处理函数
//
// 返回值:
//	
// 参数  :
//	hWnd -
//	wParam -
//	lParam -
//
////////////////////////////////////////////////////////////////////////////////
LRESULT MapEditWnd_OnHScroll(HWND hWnd, WPARAM wParam, LPARAM lParam)
{
	int nPos;
	switch (LOWORD(wParam))
	{
	case SB_LINELEFT:
		nPos = ::GetScrollPos(hWnd, SB_HORZ);
		if (nPos > 0)
		{
			nPos--;
			MEW_lxCamera = nPos * 2;
			::SetScrollPos(hWnd, SB_HORZ, nPos, TRUE);
		}
		break;
	case SB_LINERIGHT:
		nPos = ::GetScrollPos(hWnd, SB_HORZ);
		if (nPos < 63)
		{
			nPos++;
			::SetScrollPos(hWnd, SB_HORZ, nPos, TRUE);
			MEW_lxCamera = nPos * 2;
		}
		break;
	case SB_THUMBTRACK:
		nPos = HIWORD(wParam);
		::SetScrollPos(hWnd, SB_HORZ, HIWORD(wParam), TRUE);
		MEW_lxCamera = nPos * 2;
		break;
	case SB_PAGELEFT:
		nPos = ::GetScrollPos(hWnd, SB_HORZ);
		nPos--;
		::SetScrollPos(hWnd, SB_HORZ, nPos, TRUE);
		MEW_lxCamera = nPos * 2;
		break;
	case SB_PAGERIGHT:
		nPos = ::GetScrollPos(hWnd, SB_HORZ);
		nPos++;
		::SetScrollPos(hWnd, SB_HORZ, nPos, TRUE);
		MEW_lxCamera = nPos * 2;
		break;
	}

	::MiniMapWnd_SetCameraPos(MEW_lxCamera, MEW_lyCamera);
	return 0;
}

LRESULT MapEditWnd_OnMDIActivate(HWND hWnd, WPARAM wParam, LPARAM lParam)
{
	if ((HWND)lParam == hWnd)
	{
		::SetTimer(hWnd, 0, 40, NULL);
		MEW_bActive = TRUE;

		::MiniMapWnd_SetCameraPos(MEW_lxCamera, MEW_lyCamera);
		TileAttributeDialog_Update(&g_MapData[ MEW_lyCurSelTile ][ MEW_lxCurSelTile ][ 0 ], &g_MapData[ MEW_lyCurSelTile ][ MEW_lxCurSelTile ][ 1 ]);
		MapEditWnd_UpdateCommandUI();
	}
	else
	{
		::KillTimer(hWnd, 0);
		MEW_bActive = FALSE;
	}

	return ::DefMDIChildProc(hWnd, WM_MDIACTIVATE, wParam, lParam);
}

////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	VOID MapEditWnd_SetCameraPos(LONG x, LONG y)
//
// 描述  :
//	设置编辑窗口的视口位置
//
// 返回值:
//	
// 参数  :
//	x -
//	y -
//
////////////////////////////////////////////////////////////////////////////////
VOID MapEditWnd_SetCameraPos(LONG x, LONG y)
{
	// x 是0 - 126的偶数，要除以2才是滚动条的范围
	if (Map_Assert(x / 2, y))
	{
		::SendMessage(MEW_hMapEditWnd, WM_HSCROLL, MAKEWPARAM(SB_THUMBTRACK, x / 2), 0);
		::SendMessage(MEW_hMapEditWnd, WM_VSCROLL, MAKEWPARAM(SB_THUMBTRACK, y), 0);
	}
}

////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	VOID MapEditWnd_UpdateCommandUI(HWND hWnd)
//
// 描述  :
//	更新命令界面（工具栏、菜单）的态状
//
// 返回值:
//	
// 参数  :
//	HWND hWnd -
//
////////////////////////////////////////////////////////////////////////////////
VOID MapEditWnd_UpdateCommandUI(VOID)
{
	ToolBar_Check(IDCMD_EDIT_SELECT, FALSE);
	ToolBar_Check(IDCMD_EDIT_PEN, FALSE);
	ToolBar_Check(IDCMD_EDIT_TEMPLATE, FALSE);
	ToolBar_Check(IDCMD_EDIT_ERASE, FALSE);
	ToolBar_Check(IDCMD_EDIT_BARRIER, FALSE);

	ToolBar_Check(IDCMD_EDIT_LAYER0, FALSE);
	ToolBar_Check(IDCMD_EDIT_LAYER1, FALSE);

	ToolBar_Check(IDCMD_VIEW_BARRIER, FALSE);

	Menu_Check(IDCMD_EDIT_SELECT, FALSE);
	Menu_Check(IDCMD_EDIT_PEN, FALSE);
	Menu_Check(IDCMD_EDIT_TEMPLATE, FALSE);
	Menu_Check(IDCMD_EDIT_ERASE, FALSE);
	Menu_Check(IDCMD_EDIT_BARRIER, FALSE);

	Menu_Check(IDCMD_EDIT_LAYER0, FALSE);
	Menu_Check(IDCMD_EDIT_LAYER1, FALSE);

	Menu_Check(IDCMD_VIEW_BARRIER, FALSE);

	Menu_Check(IDCMD_VIEW_OBJECT, FALSE);


	ToolBar_Check(MEW_dwStatus, TRUE);
	Menu_Check(MEW_dwStatus, TRUE);

	ToolBar_Check(MEW_dwCurEditLayer, TRUE);
	Menu_Check(MEW_dwCurEditLayer, TRUE);

	if (MEW_bShowBarrier)
	{
		ToolBar_Check(IDCMD_VIEW_BARRIER, TRUE);
		Menu_Check(IDCMD_VIEW_BARRIER, TRUE);
	}

	if (MEW_bShowObject)
	{
		Menu_Check(IDCMD_VIEW_OBJECT, TRUE);
	}
}

VOID MapEditWnd_Show(int nShow)
{
	::ShowWindow(MEW_hMapEditWnd, nShow);
}

VOID MapEditWnd_SetActive(VOID)
{
	::SetActiveWindow(MEW_hMapEditWnd);
}

VOID MapEditWnd_SetTitle(LPCSTR lpstrTitle)
{
	if (lpstrTitle != NULL)
	{
		::SetWindowText(MEW_hMapEditWnd, lpstrTitle);
	}
}

BOOL MapEditWnd_IsActive(VOID)
{
	return MEW_bActive;
}