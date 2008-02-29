////////////////////////////////////////////////////////////////////////////////
//
//                              文件对话框
//
////////////////////////////////////////////////////////////////////////////////
//
//	文件名：
//		FileDialog.cpp
//
//	说明：
//		文件对话框
//
//	函数：
//		
//
//////////////////////////////////////////////////////////////////////////////////

#include <windows.h>

CHAR         FD_PathName[ MAX_PATH ];
CHAR         FD_FileName[ MAX_PATH ];

BOOL OpenFileDialog_DoModal(HWND hParentWnd)
{
	OPENFILENAME FileDialogInfo;

	::memset(&FileDialogInfo, 0, sizeof(OPENFILENAME));
	::memset(FD_FileName, 0, MAX_PATH);
	::memset(FD_PathName, 0, MAX_PATH);

	FileDialogInfo.lStructSize = sizeof(OPENFILENAME);
	FileDialogInfo.hwndOwner = hParentWnd;
	FileDialogInfo.hInstance = (HINSTANCE)::GetWindowLong(hParentWnd, GWL_HINSTANCE);
	FileDialogInfo.lpstrFilter = NULL;
	FileDialogInfo.lpstrFile = FD_PathName;
	FileDialogInfo.nMaxFile = sizeof(FD_PathName);
	FileDialogInfo.lpstrFileTitle = FD_FileName;
	FileDialogInfo.nMaxFileTitle = sizeof(FD_FileName);
	FileDialogInfo.Flags = OFN_ENABLESIZING | OFN_EXPLORER | OFN_NOCHANGEDIR | OFN_HIDEREADONLY | OFN_OVERWRITEPROMPT;
	FileDialogInfo.lpstrDefExt = NULL;

	FileDialogInfo.lpstrTitle = "打开地图";
	FileDialogInfo.lpstrInitialDir = "Map";

	return ::GetOpenFileName(&FileDialogInfo);
}

BOOL SaveFileDialog_DoModal(HWND hParentWnd, LPSTR lpstr)
{
	OPENFILENAME FileDialogInfo;

	::memset(&FileDialogInfo, 0, sizeof(OPENFILENAME));
	::memset(FD_FileName, 0, MAX_PATH);
	::memset(FD_PathName, 0, MAX_PATH);

	if (lpstr != NULL)
	{
		strcpy(FD_PathName, lpstr);
	}

	FileDialogInfo.lStructSize = sizeof(OPENFILENAME);
	FileDialogInfo.hwndOwner = hParentWnd;
	FileDialogInfo.hInstance = (HINSTANCE)::GetWindowLong(hParentWnd, GWL_HINSTANCE);
	FileDialogInfo.lpstrFilter = NULL;
	FileDialogInfo.lpstrFile = FD_PathName;
	FileDialogInfo.nMaxFile = sizeof(FD_PathName);
	FileDialogInfo.lpstrFileTitle = FD_FileName;
	FileDialogInfo.nMaxFileTitle = sizeof(FD_FileName);
	FileDialogInfo.Flags = OFN_ENABLESIZING | OFN_EXPLORER | OFN_NOCHANGEDIR | OFN_HIDEREADONLY | OFN_OVERWRITEPROMPT;
	FileDialogInfo.lpstrDefExt = NULL;
	FileDialogInfo.lpstrTitle = "保存地图";
	FileDialogInfo.lpstrInitialDir = "Map";

	return ::GetSaveFileName(&FileDialogInfo);
}


VOID FileDialog_GetPathName(LPSTR lpstr)
{
	if (lpstr != NULL)
	{
		::strcpy(lpstr, FD_PathName);
	}
}

VOID FileDialog_GetFileName(LPSTR lpstr)
{
	if (lpstr != NULL)
	{
		::strcpy(lpstr, FD_FileName);
	}
}