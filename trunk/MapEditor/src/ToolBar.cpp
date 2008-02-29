////////////////////////////////////////////////////////////////////////////////
//
//                              工具栏
//
////////////////////////////////////////////////////////////////////////////////
//
//	文件名：
//		ToolBar.cpp
//
//	说明：
//		工具栏，按钮要是正方形的，底色为192,192,192
//
//	函数：
//		
//
//////////////////////////////////////////////////////////////////////////////////

#include <windows.h>
#include <commctrl.h>
#include "resource.h"

#include "ToolBar.h"

////////////////////////////////////////////////////////////////////////////////
// 内部变量
////////////////////////////////////////////////////////////////////////////////

HWND	TB_hWndToolBar		= NULL;

const LPCSTR	TB_ErrorString1 = "工具栏创建失败！";


////////////////////////////////////////////////////////////////////////////////
//
//                              函数声明
//
////////////////////////////////////////////////////////////////////////////////
LRESULT CALLBACK SubClassToolBarProc(
				     HWND hWnd,
				     UINT uMsg,
				     WPARAM wParam,
				     LPARAM lParam
				     );

BOOL ToolBar_SetToolBarBitmap(HBITMAP hBitmap);
UINT ToolBar_LoadButtonID(UINT uIDResource, UINT *lpIDArray, UINT uArrayLen);
BOOL ToolBar_SetButtons(const UINT* lpIDArray, INT nIDCount);

VOID ToolBar_OnSizeParent(HWND hWndParent, RECT *pRect);



////////////////////////////////////////////////////////////////////////////////
//
//
//                              函数定义
//
//
////////////////////////////////////////////////////////////////////////////////

BOOL ToolBar_Create(HWND hWndParent)
{
	HINSTANCE	hInstance	= NULL;
	HBITMAP		hBitmap		= NULL;
	DWORD		dwButtonCount	= 0;

	UINT		uID[ 128 ];
	::memset(uID, 0, sizeof(UINT) * 128);

	hInstance = (HINSTANCE)::GetWindowLong(hWndParent, GWL_HINSTANCE);

	TB_hWndToolBar = CreateWindowEx(
		WS_EX_TOOLWINDOW,
		TOOLBARCLASSNAME,
		NULL,
		WS_CHILD |
		WS_VISIBLE |
		WS_CLIPCHILDREN |
		WS_CLIPSIBLINGS |
		TBSTYLE_TRANSPARENT |
		TBSTYLE_FLAT |
		TBSTYLE_TOOLTIPS,
		0,
		0,
		0,
		0,
		hWndParent,
		(HMENU)IDR_TOOLBAR,
		hInstance,
		NULL
		);

	if (TB_hWndToolBar == NULL)
	{
		::MessageBox(hWndParent, TB_ErrorString1, NULL, MB_OK);
		return FALSE;
	}

	::SendMessage(TB_hWndToolBar, TB_BUTTONSTRUCTSIZE, (WPARAM)sizeof(TBBUTTON), 0);
 
	// 设置工具栏的位图
	hBitmap = (HBITMAP)::LoadBitmap(hInstance, MAKEINTRESOURCE(IDR_TOOLBAR));
	ToolBar_SetToolBarBitmap(hBitmap);

	// 加入按钮
	dwButtonCount = ToolBar_LoadButtonID(IDR_TOOLBAR, uID, 128);
	ToolBar_SetButtons(uID, dwButtonCount);

	ToolBar_Enable(IDCMD_FILE_OPEN, TRUE);

	::ShowWindow(TB_hWndToolBar, SW_SHOW);
	::UpdateWindow(TB_hWndToolBar);
	return TRUE;
}

HWND ToolBar_GetHandle(VOID)
{
	return TB_hWndToolBar;
}

////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	BOOL ToolBar_SetToolBarBitmap(HBITMAP hBitmap)
//
// 描述  :
//	设置工具栏的按钮图像
//
// 返回值:
//	
// 参数  :
//	HBITMAP hBitmap - 位图句柄
//
////////////////////////////////////////////////////////////////////////////////
BOOL ToolBar_SetToolBarBitmap(HBITMAP hBitmap)
{
	BITMAP Bitmap;

	::GetObject(hBitmap, sizeof(BITMAP), &Bitmap);

	HIMAGELIST hImageList = ImageList_Create(Bitmap.bmHeight, Bitmap.bmHeight, ILC_COLOR16 | ILC_MASK, 0 , 64);

	ImageList_AddMasked(hImageList, hBitmap, RGB(192, 192, 192));

	::SendMessage(TB_hWndToolBar, TB_SETIMAGELIST, 0, (LPARAM)hImageList);

	return TRUE;
}


////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	UINT ToolBar_LoadButtonID(UINT uIDResource, UINT *lpIDArray, UINT uArrayLen)
//
// 描述  :
//	载入工具栏按钮ID
//
// 返回值:
//	返回按钮的个数
//
// 参数  :
//	IDResource	- 资源ID
//	*lpIDArray	- 接收按钮ID的缓冲区指针
//	uArrayLen	- 接收按钮ID的缓冲区的大小
//
////////////////////////////////////////////////////////////////////////////////
UINT ToolBar_LoadButtonID(UINT uIDResource, UINT *lpIDArray, UINT uArrayLen)
{
	// 获取工具栏资源信息块句柄
	HRSRC hRsrc = ::FindResource(NULL, MAKEINTRESOURCE(uIDResource), MAKEINTRESOURCE(241));
	if (hRsrc == NULL)
	{
		return 0;
	}

	// 获取资源句柄
	HGLOBAL hGlobal = ::LoadResource(NULL, hRsrc);
	if (hGlobal == NULL)
	{
		return 0;
	}

	// 获取资源数据指针
	CToolBarData *pData = (CToolBarData*)::LockResource(hGlobal);
	if (pData == NULL)
	{
		return 0;
	}

	if (pData->wItemCount > uArrayLen)
	{
		return 0;
	}

	// 获取按钮ID
	for (int i = 0; i < pData->wItemCount; i++)
	{
		lpIDArray[ i ] = pData->items()[i];
	}

	return pData->wItemCount;
}


////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	BOOL ToolBar_SetButtons(const UINT* lpIDArray, INT nIDCount)
//
// 描述  :
//	设置工具栏按钮
//
// 返回值:
//	
// 参数  :
//	pIDArray - 按钮ID数据指针
//	nIDCount - 按钮个数
//
////////////////////////////////////////////////////////////////////////////////
BOOL ToolBar_SetButtons(const UINT* lpIDArray, INT nIDCount)
{
	TBBUTTON Button;
	memset(&Button, 0, sizeof(TBBUTTON));
	Button.iString = -1;
	if (lpIDArray != NULL)
	{
		// Add new Buttons to the toolbar.
		int iImage = 0;
		for (int i = 0; i < nIDCount; i++)
		{
			if ((Button.idCommand = *lpIDArray++) == 0)
			{
				// separator
				Button.fsStyle = TBSTYLE_SEP;
				Button.iBitmap = 8;
			}
			else
			{
				// A command Button with image.
				Button.fsStyle = TBSTYLE_BUTTON;
				Button.iBitmap = iImage++;
			}
			if (!::SendMessage(
				TB_hWndToolBar,
				TB_ADDBUTTONS,
				1,
				(LPARAM)&Button)
				)
			{
				return FALSE;
			}
		}
	}
	return TRUE;
}

VOID ToolBar_Enable(UINT uButtonID, BOOL bEnable)
{
	::SendMessage(TB_hWndToolBar, TB_ENABLEBUTTON, (WPARAM)uButtonID, (LPARAM)MAKELPARAM(bEnable, 0));
}

VOID ToolBar_Check(UINT uButtonID, BOOL bCheck)
{
	::SendMessage(TB_hWndToolBar, TB_CHECKBUTTON, (WPARAM)uButtonID, MAKELPARAM(bCheck, 0));
}

////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	VOID ToolBar_SizeParent(RECT *lpRect)
//
// 描述  :
//	当主窗口的尺寸发生变化时，会调用这个函数来更新各个窗口的布局
//	
// 返回值:
//	
// 参数  :
//	RECT *lpRect - 主窗口的客户区尺寸
//
////////////////////////////////////////////////////////////////////////////////
VOID ToolBar_SizeParent(RECT *lpRect)
{
	if (lpRect == NULL)
	{
		return;
	}

	LONG	lHeight		= 0;
	RECT	rc;

	// 虽然都是0，但工具栏会自己的设置尺寸
	::MoveWindow(TB_hWndToolBar, 0, 0, 0, 0, TRUE);

	::GetWindowRect(TB_hWndToolBar, &rc);
	lHeight = rc.bottom - rc.top;

	lpRect->top += lHeight;
}