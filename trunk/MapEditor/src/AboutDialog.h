/*******************************************************************************
                           C A B O U T D I A L O G

	Name:       AboutDialog.h

    Description:
		About∂‘ª∞øÚ¿‡

*******************************************************************************/

BOOL CALLBACK AboutDialogProc(
							  HWND hWndDlg,
							  UINT uMsg,
							  WPARAM wParam,
							  LPARAM lParam);

class CAboutDialog
{
public:
	CAboutDialog();
	~CAboutDialog();

	void DoModal(HWND hWndParent);
};