////////////////////////////////////////////////////////////////////////////////
//
//                              
//
////////////////////////////////////////////////////////////////////////////////
//
//	文件名：
//		ImageSelWnd.cpp
//
//	说明：
//		
//
//	函数：
//		
//
//////////////////////////////////////////////////////////////////////////////////
#include <windows.h>
#include <commctrl.h>

#include "ImageSelWnd.h"

// 来自Document.cpp
extern DWORD	g_dwImageCount;
extern HDC	g_hDCTileImage[ 512 ];


////////////////////////////////////////////////////////////////////////////////
// 内部变量
////////////////////////////////////////////////////////////////////////////////

HWND		ISW_hImageSelWnd		= NULL;
HWND		ISW_hTileImageListView		= NULL;

BOOL		ISW_bMouseOnDragBar		= FALSE;
BOOL		ISW_bDraging			= FALSE;

LONG		ISW_lMouseOldX			= 0;

const DWORD ID_IMAGESELWND		= 203;
const DWORD ID_TILEIMAGELISTVIEW	= 204;
const LPCSTR	ISW_ErrorString		= "创建图块选择窗口失败！";
const LPCSTR	IMAGESELWNDCLASS	= "ImageSelWndClass";

////////////////////////////////////////////////////////////////////////////////
//
//                              函数声明
//
////////////////////////////////////////////////////////////////////////////////

LRESULT CALLBACK ImageSelWnd_WindowProc(
					HWND hWnd,
					UINT uMsg,
					WPARAM wParam,
					LPARAM lParam);

LRESULT ImageSelWnd_OnCreate(HWND hWnd, WPARAM wParam, LPARAM lParam);
LRESULT ImageSelWnd_OnMouseMove(HWND hWnd, WPARAM wParam, LPARAM lParam);
LRESULT ImageSelWnd_OnSetCursor(HWND hWnd, WPARAM wParam, LPARAM lParam);
LRESULT ImageSelWnd_OnLButtonDown(HWND hWnd, WPARAM wParam, LPARAM lParam);
LRESULT ImageSelWnd_OnLButtonUp(HWND hWnd, WPARAM wParam, LPARAM lParam);
LRESULT ImageSelWnd_OnPaint(HWND hWnd, WPARAM wParam, LPARAM lParam);
LRESULT ImageSelWnd_OnSize(HWND hWnd, WPARAM wParam, LPARAM lParam);
LRESULT ImageSelWnd_OnNotify(HWND hWnd, WPARAM wParam, LPARAM lParam);

VOID ImageSelWnd_DrawDrag(HDC hDC, RECT *lpRect);



////////////////////////////////////////////////////////////////////////////////
//
//                              函数定义
//
////////////////////////////////////////////////////////////////////////////////

BOOL ImageSelWnd_Create(HWND hWndParent)
{
	HINSTANCE	hInstance	= NULL;

	hInstance = (HINSTANCE)::GetWindowLong(hWndParent, GWL_HINSTANCE);

	ATOM atom;
	WNDCLASSEX stWndClass;

	////////////////////////////////////////////////////////////////////////////////
	// 注册图块选择窗口类
	////////////////////////////////////////////////////////////////////////////////
	stWndClass.cbSize = sizeof(WNDCLASSEX);
	stWndClass.style = CS_HREDRAW | CS_VREDRAW;
	stWndClass.lpfnWndProc = ImageSelWnd_WindowProc;
	stWndClass.cbClsExtra = 0;
	stWndClass.cbWndExtra = 0;
	stWndClass.hInstance = hInstance;
	stWndClass.hIcon = NULL;
	stWndClass.hCursor = ::LoadCursor(NULL, (LPCTSTR)IDC_ARROW);
	stWndClass.hbrBackground = ::GetSysColorBrush(COLOR_BTNFACE);
	stWndClass.lpszMenuName = NULL;
	stWndClass.lpszClassName = IMAGESELWNDCLASS;
	stWndClass.hIconSm = NULL;

	atom = RegisterClassEx(&stWndClass);
	if (atom == 0)
	{
		::MessageBox(hWndParent, ISW_ErrorString, NULL, MB_OK);
		return FALSE;
	}

	////////////////////////////////////////////////////////////////////////////////
	// 创建图块选择窗口
	////////////////////////////////////////////////////////////////////////////////
	ISW_hImageSelWnd = ::CreateWindowEx(
		0,
		IMAGESELWNDCLASS,
		NULL,
		WS_VISIBLE | WS_CHILD,
		0,
		0,
		250,			// 要有初始宽度
		0,
		hWndParent,
		(HMENU)ID_IMAGESELWND,
		hInstance,
		NULL
		);

	if (ISW_hImageSelWnd == NULL)
	{
		::MessageBox(hWndParent, ISW_ErrorString, NULL, MB_OK);
		return FALSE;
	}

	return TRUE;
}

LRESULT CALLBACK ImageSelWnd_WindowProc(
					HWND hWnd,
					UINT uMsg,
					WPARAM wParam,
					LPARAM lParam)
{
	switch (uMsg)
	{
	case WM_CREATE:
		return ImageSelWnd_OnCreate(hWnd, wParam, lParam);
		break;
	case WM_LBUTTONDOWN:
		return ImageSelWnd_OnLButtonDown(hWnd, wParam, lParam);
		break;
	case WM_LBUTTONUP:
		return ImageSelWnd_OnLButtonUp(hWnd, wParam, lParam);
		break;
	case WM_PAINT:
		return ImageSelWnd_OnPaint(hWnd, wParam, lParam);
		break;
	case WM_SIZE:
		return ImageSelWnd_OnSize(hWnd, wParam, lParam);
		break;
	case WM_MOUSEMOVE:
		return ImageSelWnd_OnMouseMove(hWnd, wParam, lParam);
		break;
	case WM_SETCURSOR:
		return ImageSelWnd_OnSetCursor(hWnd, wParam, lParam);
		break;
	case WM_NOTIFY:
		return ImageSelWnd_OnNotify(hWnd, wParam, lParam);
		break;
	default:
		return ::DefWindowProc(hWnd, uMsg, wParam, lParam);
	}
}

LRESULT ImageSelWnd_OnCreate(HWND hWnd, WPARAM wParam, LPARAM lParam)
{
	HINSTANCE hInstance = NULL;

	hInstance = (HINSTANCE)::GetWindowLong(hWnd, GWL_HINSTANCE);

	ISW_hTileImageListView = ::CreateWindowEx(
		WS_EX_CLIENTEDGE,
		WC_LISTVIEW,
		NULL,
		WS_VISIBLE | WS_CHILD | LVS_AUTOARRANGE | LVS_ICON,
		0,
		0,
		0,
		0,
		hWnd,
		(HMENU)ID_TILEIMAGELISTVIEW,
		hInstance,
		NULL);

	if (ISW_hTileImageListView == NULL)
	{
		return -1;
	}

	ListView_SetBkColor(ISW_hTileImageListView, RGB(192, 192, 192));

	return 0;
}

LRESULT ImageSelWnd_OnMouseMove(HWND hWnd, WPARAM wParam, LPARAM lParam)
{
	DWORD		lWidth	= 0;
	DWORD		lHeight	= 0;
	HDC		hDC		= NULL;
	RECT		rc;

	static LONG	lMouseX;

	::GetWindowRect(hWnd, &rc);
	lWidth = rc.right - rc.left;
	lHeight = rc.bottom - rc.top;

	if (!ISW_bDraging)
	{
		ISW_bMouseOnDragBar =  (LOWORD(lParam) > lWidth - 4);
	}
	else
	{
		hDC = ::GetDC(NULL);
		rc.right += lMouseX - ISW_lMouseOldX;
		rc.left = rc.right - 4;

		ImageSelWnd_DrawDrag(hDC, &rc);

		::GetWindowRect(hWnd, &rc);
		lMouseX		= LOWORD(lParam);

		rc.right += lMouseX - ISW_lMouseOldX;
		rc.left = rc.right - 4;

		ImageSelWnd_DrawDrag(hDC, &rc);
		::ReleaseDC(NULL, hDC);
	}
	return 0;
}

LRESULT ImageSelWnd_OnSetCursor(HWND hWnd, WPARAM wParam, LPARAM lParam)
{
	HCURSOR		hCursor		= NULL;

	if (ISW_bMouseOnDragBar)
	{
		hCursor = LoadCursor(NULL, IDC_SIZEWE);
		SetCursor(hCursor);
		return 0;
	}
	return ::DefWindowProc(hWnd, WM_SETCURSOR, wParam, lParam);;
}

LRESULT ImageSelWnd_OnLButtonDown(HWND hWnd, WPARAM wParam, LPARAM lParam)
{
	RECT	rc;
	HDC	hDC	= NULL;

	if (ISW_bMouseOnDragBar)
	{
		ISW_lMouseOldX = LOWORD(lParam);

		hDC = ::GetDC(NULL);
		::GetWindowRect(hWnd, &rc);
		rc.left = rc.right - 4;
		ImageSelWnd_DrawDrag(hDC, &rc);
		::ReleaseDC(NULL, hDC);

		ISW_bDraging = TRUE;
		::SetCapture(hWnd);
	}
	return 0;
}

LRESULT ImageSelWnd_OnLButtonUp(HWND hWnd, WPARAM wParam, LPARAM lParam)
{
	HWND		hParentWnd	= NULL;
	HDC		hDC		= NULL;
	DWORD		lWidth		= 0;
	DWORD		lHeight		= 0;
	RECT		rc;

	::GetWindowRect(hWnd, &rc);
	lWidth = rc.right - rc.left;
	lHeight = rc.bottom - rc.top;

	LONG	lNewWidth	= 0;

	if (ISW_bDraging)
	{
		lNewWidth = lWidth + (SHORT)LOWORD(lParam) - ISW_lMouseOldX;

		lNewWidth = lNewWidth < 30 ? 30 : lNewWidth;
		::SetWindowPos(hWnd, NULL, 0, 0, lNewWidth, lHeight, SWP_NOMOVE);

		hDC = ::GetDC(NULL);
		::GetWindowRect(hWnd, &rc);
		rc.left = rc.right - 4;
		ImageSelWnd_DrawDrag(hDC, &rc);
		::ReleaseDC(NULL, hDC);

		ISW_bDraging = FALSE;
		::ReleaseCapture();

		// 通知主窗口更新
		::SendMessage(::GetParent(ISW_hImageSelWnd), WM_SIZE, 0, 0);
	}
	return 0;
}

LRESULT ImageSelWnd_OnPaint(HWND hWnd, WPARAM wParam, LPARAM lParam)
{
	PAINTSTRUCT	PS;
	RECT		rect;
	LONG		lWidth		= 0;
	LONG		lHeight		= 0;
	HDC		hDC		= NULL;


	::GetWindowRect(hWnd, &rect);
	lWidth = rect.right - rect.left;
	lHeight = rect.bottom - rect.top;


	hDC = ::BeginPaint(hWnd, &PS);

	// 右边的拖动条3D光线
	::SetRect(&rect, lWidth - 3, 0, lWidth - 4, lHeight);
	::FillRect(hDC, &rect, NULL);

	// 上边线
	::SetRect(&rect, 0, 0, lWidth, 1);
	::FillRect(hDC, &rect, (HBRUSH)(COLOR_3DSHADOW + 1));

	::SetRect(&rect, 0, 1, lWidth, 2);
	::FillRect(hDC, &rect, NULL);

	// 下边线
	::SetRect(&rect, 0, lHeight - 2, lWidth, lHeight - 1);
	::FillRect(hDC, &rect, (HBRUSH)(COLOR_3DSHADOW + 1));

	::SetRect(&rect, 0, lHeight - 1, lWidth, lHeight);
	::FillRect(hDC, &rect, NULL);




	//////////////////////////////////////////////
	// 画当前选择的图块的框线
	//////////////////////////////////////////////
	// top
	::SetRect(&rect, 5, 7, lWidth - 10, 8);
	::FillRect(hDC, &rect, (HBRUSH)(COLOR_3DSHADOW + 1));

	// bottom
	::SetRect(&rect, 5, 42, lWidth - 10, 43);
	::FillRect(hDC, &rect, NULL);

	// left
	::SetRect(&rect, 5, 7, 6, 43);
	::FillRect(hDC, &rect, (HBRUSH)(COLOR_3DSHADOW + 1));

	// right
	::SetRect(&rect, lWidth - 9, 7, lWidth - 10, 43);
	::FillRect(hDC, &rect, NULL);


	/////////////////////////////////////////////////////////
	// 画当前选择的图块
	/////////////////////////////////////////////////////////

	LONG	lCurSelImage	= ImageSelWnd_GetSelImage();

	if (lCurSelImage >= 0)
	{
		::BitBlt(hDC, (lWidth - 4 - 64) / 2, 10, 64, 30, g_hDCTileImage[ lCurSelImage ], 0, 0, SRCCOPY);
	}

	::EndPaint(hWnd, &PS);

	return 0;
}

LRESULT ImageSelWnd_OnSize(HWND hWnd, WPARAM wParam, LPARAM lParam)
{
	::MoveWindow(
		ISW_hTileImageListView,
		5,
		50,
		LOWORD(lParam) - 10 - 3 - 1,
		HIWORD(lParam) - 60,
		TRUE);

	return 0;
}

LRESULT ImageSelWnd_OnNotify(HWND hWnd, WPARAM wParam, LPARAM lParam)
{
	LPNMHDR		lpNMHDR		= NULL;

	lpNMHDR	= (LPNMHDR)lParam;

	switch (lpNMHDR->code)
	{
	case NM_CLICK:
		::InvalidateRect(hWnd, NULL, TRUE);
		break;
	}

	return 0;
}

VOID ImageSelWnd_DrawDrag(HDC hDC, RECT *lpRect)
{
	// 创建画刷
	HBRUSH hGrayBrush;
	WORD grayPattern[8];
	for (int i = 0; i < 8; i++)
	{
		grayPattern[i] = (WORD)(0x5555 << (i & 1));
	}

	HBITMAP grayBitmap = ::CreateBitmap(8, 8, 1, 1, &grayPattern);
	if (grayBitmap != NULL)
	{
		hGrayBrush = ::CreatePatternBrush(grayBitmap);
		DeleteObject(grayBitmap);
	}
	HBRUSH hOldBrush = (HBRUSH)::SelectObject(hDC, hGrayBrush);

	::PatBlt(hDC, lpRect->left, lpRect->top, lpRect->right - lpRect->left, lpRect->bottom - lpRect->top, PATINVERT);

	::SelectObject(hDC, hOldBrush);
	::DeleteObject(hGrayBrush);
}

VOID ImageSelWnd_SizeParent(RECT *lpRect)
{
	RECT rc;
	LONG	lTop		= 0;
	LONG	lLeft		= 0;
	LONG	lWidth		= 0;
	LONG	lHeight		= 0;

	// 固定停靠在左边
	// 宽度由自己决定，高度由父窗口决定
	if (lpRect == NULL)
	{
		return;
	}

	::GetWindowRect(ISW_hImageSelWnd, &rc);

	lTop	=	lpRect->top;
	lLeft	=	0;
	lWidth	=	rc.right - rc.left;
	lHeight	=	lpRect->bottom - lpRect->top;

	// 减少父窗口的矩形范围
	lpRect->left +=lWidth;

	::MoveWindow(ISW_hImageSelWnd, lLeft, lTop, lWidth, lHeight, TRUE);
}


////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	VOID ImageSelWnd_Update(VOID)
//
// 描述  :
//	更新图块列表
//
// 返回值:
//	
// 参数  :
//	
//
////////////////////////////////////////////////////////////////////////////////
VOID ImageSelWnd_Update(VOID)
{
	HIMAGELIST	hImageList	= NULL;
	HBITMAP		hBitmap		= NULL;
	HBITMAP		hBitmapOld	= NULL;
	HDC		hDCScreen	= NULL;

	DWORD		i		= 0;
	DWORD		dwCount		= 0;

	// 删除原有列表项
	::SendMessage(ISW_hTileImageListView, LVM_DELETEALLITEMS, 0, 0);
	hImageList = (HIMAGELIST)::SendMessage(ISW_hTileImageListView, LVM_GETIMAGELIST, LVSIL_NORMAL, 0);
	::ImageList_Destroy(hImageList);


	// 创建图像列表
	hImageList = ImageList_Create(64, 30, ILC_COLOR16, 0, 512);

	// 把图块加入图像列表中
	hDCScreen = ::GetDC(NULL);
	hBitmap = ::CreateCompatibleBitmap(hDCScreen, 1, 1);
	i = 0;
	while (i < g_dwImageCount)
	{
		hBitmapOld = (HBITMAP)::SelectObject(g_hDCTileImage[ i ], hBitmap);
		ImageList_Add(hImageList, hBitmapOld, NULL);

		::SelectObject(g_hDCTileImage[ i ], hBitmapOld);
		i++;
	}

	::SendMessage(ISW_hTileImageListView, LVM_SETIMAGELIST, LVSIL_NORMAL, (LPARAM)hImageList);

	LVITEM Item;
	CHAR Buffer[ MAX_PATH ];
	memset(&Item, 0, sizeof(LVITEM));
	memset(Buffer, 0, MAX_PATH);


	dwCount = i;
	for (i = 0; i < dwCount; i++)
	{
		itoa(i, Buffer, 10);
		Item.mask = LVIF_IMAGE | LVIF_TEXT;
		Item.iItem = i;
		Item.pszText = Buffer;
		Item.iImage = i;

		ListView_InsertItem(ISW_hTileImageListView, &Item);
	}
}

LONG ImageSelWnd_GetSelImage(VOID)
{
	return ::SendMessage(ISW_hTileImageListView, LVM_GETNEXTITEM, -1, MAKELPARAM(LVNI_SELECTED | LVNI_ALL ,0));
}
