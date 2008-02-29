#include "StdAfx.h"

#include "AboutDialog.h"

BOOL CALLBACK AboutDialogProc(HWND hWndDlg, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
	switch (uMsg)
	{
		case WM_COMMAND:
		{
			switch (wParam)
			{
				case IDOK:
				{
					return EndDialog(hWndDlg, IDCANCEL);
				}
			}
		}
	}
	return FALSE;
}

CAboutDialog::CAboutDialog()
{

}

CAboutDialog::~CAboutDialog()
{

}

void CAboutDialog::DoModal(HWND hWndParent)
{
	HINSTANCE hInstance = (HINSTANCE)::GetWindowLong(hWndParent, GWL_HINSTANCE);
	::DialogBox(hInstance, MAKEINTRESOURCE(IDD_ABOUTDIALOG), hWndParent, (DLGPROC)AboutDialogProc);
}