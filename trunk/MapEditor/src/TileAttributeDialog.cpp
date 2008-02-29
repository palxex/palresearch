////////////////////////////////////////////////////////////////////////////////
//
//                              
//
////////////////////////////////////////////////////////////////////////////////
//
//	文件名：
//		TileAttributeDialog.cpp
//
//	说明：
//		
//
//	函数：
//		
//
//////////////////////////////////////////////////////////////////////////////////

#include <windows.h>
#include "resource.h"

#include "Map.h"
#include "TileAttributeDialog.h"

// 来自Document.cpp
extern HDC		g_hDCTileImage[ 512 ];

HWND		TAD_hTileAttributeDialog;

// 当前显示的Tile数据指针
LPWORD		TAD_lpwLayer0		= NULL;
LPWORD		TAD_lpwLayer1		= NULL;

// 对话框正更新显示
BOOL		TAD_bUpdateing		= FALSE;

////////////////////////////////////////////////////////////////////////////////
//
//			函数声明
//
////////////////////////////////////////////////////////////////////////////////
BOOL CALLBACK TileAttributeDialogProc(
				      HWND hWndDlg,
				      UINT uMsg,
				      WPARAM wParam,
				      LPARAM lParam
				      );

VOID TileAttributeDialog_InitDialog(HWND hWndDlg);
VOID TileAttributeDialog_OnTimer(HWND hWndDlg, WPARAM wParam, LPARAM lParam);
VOID TileAttributeDialog_OnCommand(HWND hWndDlg, WPARAM wParam, LPARAM lParam);

////////////////////////////////////////////////////////////////////////////////
//
//			函数定义
//
////////////////////////////////////////////////////////////////////////////////


BOOL TileAttributeDialog_Create(HWND hWndParent)
{
	HINSTANCE hInstance	= NULL;

	hInstance = (HINSTANCE)::GetWindowLong(hWndParent, GWL_HINSTANCE);

	TAD_hTileAttributeDialog = ::CreateDialog(hInstance, MAKEINTRESOURCE(IDD_TILEATTRIBUTEDIALOG), hWndParent, (DLGPROC)TileAttributeDialogProc);

	if (TAD_hTileAttributeDialog == NULL)
	{
		::MessageBox(hWndParent, "创建Tile属性窗口失败！", NULL, MB_OK);
		return FALSE;
	}

	::ShowWindow(TAD_hTileAttributeDialog, SW_SHOW);

	return TRUE;
}

BOOL CALLBACK TileAttributeDialogProc(
				      HWND hWndDlg,
				      UINT uMsg,
				      WPARAM wParam,
				      LPARAM lParam
				      )
{
	switch (uMsg)
	{
	case WM_INITDIALOG:
		TileAttributeDialog_InitDialog(hWndDlg);
		break;
	case WM_COMMAND:
		TileAttributeDialog_OnCommand(hWndDlg, wParam, lParam);
		break;
	case WM_TIMER:
		TileAttributeDialog_OnTimer(hWndDlg, wParam, lParam);
		break;
	}
	return FALSE;
}


VOID TileAttributeDialog_InitDialog(HWND hWndDlg)
{
	::SetTimer(hWndDlg, 0, 100, NULL);
}

VOID TileAttributeDialog_OnCommand(HWND hWndDlg, WPARAM wParam, LPARAM lParam)
{
	INT nResult;

	if (TAD_lpwLayer0 == NULL || TAD_lpwLayer1 == NULL)
	{
		return;
	}
	switch (LOWORD(wParam))
	{
	case IDC_EDIT_IMAGE0:
		if (HIWORD(wParam) == EN_CHANGE)
		{
			if (!TAD_bUpdateing)
			{
				nResult = ::GetDlgItemInt(hWndDlg, IDC_EDIT_IMAGE0, NULL, FALSE);
				Map_SetLayerImage((DWORD*)TAD_lpwLayer0, nResult);
			}
		}
		break;
	case IDC_EDIT_IMAGE1:
		if (HIWORD(wParam) == EN_CHANGE)
		{
			if (!TAD_bUpdateing)
			{
				nResult = ::GetDlgItemInt(hWndDlg, IDC_EDIT_IMAGE1, NULL, TRUE);
				Map_SetLayerImage((DWORD*)TAD_lpwLayer1, nResult + 1);
			}
		}
		break;
	case IDC_EDIT_HEIGHT0:
		if (HIWORD(wParam) == EN_CHANGE)
		{
			if (!TAD_bUpdateing)
			{
				nResult = ::GetDlgItemInt(hWndDlg, IDC_EDIT_HEIGHT0, NULL, FALSE);
				Map_SetLayerHeight((DWORD*)TAD_lpwLayer0, nResult);
			}
		}
		break;
	case IDC_EDIT_HEIGHT1:
		if (HIWORD(wParam) == EN_CHANGE)
		{
			if (!TAD_bUpdateing)
			{
				nResult = ::GetDlgItemInt(hWndDlg, IDC_EDIT_HEIGHT1, NULL, FALSE);
				::Map_SetLayerHeight((DWORD*)TAD_lpwLayer1, nResult);
			}
		}
		break;
	case IDC_CHECK_BARRIER:
		if (HIWORD(wParam) == BN_CLICKED)
		{
			HWND hWndCheck	= NULL;
			LRESULT lResult = 0;

			hWndCheck = ::GetDlgItem(hWndDlg, IDC_CHECK_BARRIER);
			if (!TAD_bUpdateing)
			{
				lResult = ::SendMessage(hWndCheck, BM_GETCHECK, 0, 0);
				if (lResult == BST_CHECKED)
				{
					Map_SetTileBarrier((LPDWORD)TAD_lpwLayer0, TRUE);
				}
				if (lResult == BST_UNCHECKED)
				{
					Map_SetTileBarrier((LPDWORD)TAD_lpwLayer0, FALSE);
				}
			}
		}
		break;
	}
}

VOID TileAttributeDialog_OnTimer(HWND hWndDlg, WPARAM wParam, LPARAM lParam)
{
	HBRUSH hBrushBlack;
	HWND hWndButton;
	HDC hDCButton;
	RECT rc;

	LONG		lImage		= 0;

	if (TAD_lpwLayer0 == NULL || TAD_lpwLayer1 == NULL)
	{
		return;
	}

	::SetRect(&rc, 0, 0, 64, 30);
	hBrushBlack = (HBRUSH)::GetStockObject(BLACK_BRUSH);
	// 第一层
	lImage = Map_GetLayerImage(*TAD_lpwLayer0);

	hWndButton = ::GetDlgItem(hWndDlg, IDC_BUTTON0);
	hDCButton = ::GetWindowDC(hWndButton);
	
	::FillRect(hDCButton, &rc, hBrushBlack);
	::BitBlt(hDCButton, 0, 0, 64, 30, g_hDCTileImage[ lImage ], 0, 0, SRCCOPY);
	::ReleaseDC(hWndButton, hDCButton);

	// 第二层
	lImage = Map_GetLayerImage(*TAD_lpwLayer1) - 1;

	hWndButton = ::GetDlgItem(hWndDlg, IDC_BUTTON1);
	hDCButton = ::GetWindowDC(hWndButton);

	::FillRect(hDCButton, &rc, hBrushBlack);
	if (lImage >= 0)
	{
		::BitBlt(hDCButton, 0, 0, 64, 30, g_hDCTileImage[ lImage ], 0, 0, SRCCOPY);
	}

	::ReleaseDC(hWndButton, hDCButton);

	::DeleteObject(hBrushBlack);
}

VOID TileAttributeDialog_Update(LPWORD lpwLayer0, LPWORD lpwLayer1)
{
	HWND		hWndCheck	= NULL;

	LONG		lImage		= 0;
	LONG		lHeight		= 0;

	if (lpwLayer0 == NULL || lpwLayer1 == NULL)
	{
		return;
	}

	TAD_lpwLayer0 = lpwLayer0;
	TAD_lpwLayer1 = lpwLayer1;

	TAD_bUpdateing = TRUE;

	//
	lImage = Map_GetLayerImage(*TAD_lpwLayer0);
	lHeight = Map_GetLayerHeight(*TAD_lpwLayer0);

	::SetDlgItemInt(TAD_hTileAttributeDialog, IDC_EDIT_IMAGE0, lImage, TRUE);
	::SetDlgItemInt(TAD_hTileAttributeDialog, IDC_EDIT_HEIGHT0, lHeight, TRUE);


	//
	lImage = Map_GetLayerImage(*TAD_lpwLayer1) - 1;
	lHeight = Map_GetLayerHeight(*TAD_lpwLayer1);

	::SetDlgItemInt(TAD_hTileAttributeDialog, IDC_EDIT_IMAGE1, lImage, TRUE);
	::SetDlgItemInt(TAD_hTileAttributeDialog, IDC_EDIT_HEIGHT1, lHeight, TRUE);

	hWndCheck = ::GetDlgItem(TAD_hTileAttributeDialog, IDC_CHECK_BARRIER);
	if (hWndCheck != NULL)
	{
		if (Map_IsBarrier(*TAD_lpwLayer0))
		{
			::SendMessage(hWndCheck, BM_SETCHECK, BST_CHECKED, 0);
		}
		else
		{
			::SendMessage(hWndCheck, BM_SETCHECK, BST_UNCHECKED, 0);
		}
	}

	TAD_bUpdateing = FALSE;
}

VOID TileAttributeDialog_Move(LONG x, LONG y)
{
	::SetWindowPos(TAD_hTileAttributeDialog, NULL, x, y, 0, 0, SWP_NOSIZE);
}

VOID TileAttributeDialog_Show(int nShow)
{
	::ShowWindow(TAD_hTileAttributeDialog, nShow);
}