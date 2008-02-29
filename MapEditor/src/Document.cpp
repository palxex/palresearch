////////////////////////////////////////////////////////////////////////////////
//
//                              文档
//
////////////////////////////////////////////////////////////////////////////////
//
//	文件名：
//		Document.cpp
//
//	说明：
//		
//
//	函数：
//		
//
//////////////////////////////////////////////////////////////////////////////////
#include <windows.h>
#include <stdio.h>

#include "ImageGroup.h"
#include "FileDialog.h"
#include "Bitmap.h"

#include "Document.h"

// 地图数据
extern WORD		g_MapData[ 128 ][ 128 ][ 2 ];

// 模板数据
extern WORD		g_TemplateData[ 128 ][ 128 ][ 2 ];

// 图块图像
extern DWORD		g_dwImageCount;
extern HDC		g_hDCTileImage[ 512 ];
extern HDC		g_hDCMiniTileImage[ 512 ];

// 调色板
extern RGBQUAD		g_Palette[ 256 ];

// 文件名
CHAR			DOC_FileName[ MAX_PATH ];

// 文件指针
FILE			*DOC_fpMap	= NULL;

// 地图是否被修改了，地图保存后设为FALSE
BOOL			DOC_bEdit	= FALSE;

const DWORD	MAP_LEN			= 1024 * 64;

////////////////////////////////////////////////////////////////////////////////
//
//                              函数声明
//
////////////////////////////////////////////////////////////////////////////////
BOOL Document_LoadImage(LPSTR lpFilePath);


////////////////////////////////////////////////////////////////////////////////
//
//                              函数定义
//
////////////////////////////////////////////////////////////////////////////////

VOID Document_Init(VOID)
{
	HBITMAP		hBitmap		= NULL;
	HDC		hDCScreen	= NULL;
	LONG		i		= 0;

	hDCScreen = ::GetDC(NULL);

	for (i = 0; i < 512; i++)
	{
		g_hDCTileImage[ i ] = ::CreateCompatibleDC(hDCScreen);

		g_hDCMiniTileImage[ i ] = ::CreateCompatibleDC(hDCScreen);

		hBitmap = (HBITMAP)::CreateCompatibleBitmap(hDCScreen, 1, 1);
		::SelectObject(g_hDCMiniTileImage[ i ], hBitmap);
		::DeleteObject(hBitmap);
	}

	::ReleaseDC(NULL, hDCScreen);
}

VOID Document_Release(VOID)
{
	LONG		i		= 0;

	for (i = 0; i < 512; i++)
	{
		::DeleteObject(g_hDCTileImage[ i ]);
		::DeleteObject(g_hDCMiniTileImage[ i ]);
	}
}

////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	VOID Document_OpenFile(HWND hWndParent)
//
// 描述  :
//	读出地图数据、创建地图图块位图
//	
// 返回值:
//	
// 参数  :
//	HWND hWndParent - 文档对话框的父窗口
//
////////////////////////////////////////////////////////////////////////////////
BOOL Document_OpenFile(HWND hWndParent)
{
	CHAR	Buffer[ MAX_PATH ];

	DWORD	dwLen		= 0;

	if (!Document_CloseFile(hWndParent))
	{
		return FALSE;
	}

	if (OpenFileDialog_DoModal(hWndParent))
	{
		FileDialog_GetPathName(Buffer);
		FileDialog_GetFileName(DOC_FileName);

		DOC_fpMap = fopen(Buffer, "rb+");
		if (DOC_fpMap == NULL)
		{
			::sprintf(Buffer, "打开文件%s，失败！", Buffer);
			::MessageBox(hWndParent, Buffer, NULL, MB_OK);
			return FALSE;
		}

		// 读地图数据
		fread(g_MapData, MAP_LEN, 1, DOC_fpMap);

		// 读模板数据
		fread(g_TemplateData, MAP_LEN, 1, DOC_fpMap);

		// 读图组
		dwLen = ::strlen(Buffer);
		::sprintf(Buffer, "Gop\\Gop%s", Buffer + dwLen - 4);
		Document_LoadImage(Buffer);

		Document_SetEditFlag(FALSE);

		return TRUE;
	}
	return FALSE;
}

BOOL Document_SaveFile(VOID)
{
	if (DOC_fpMap == NULL)
	{
		return FALSE;
	}

	fseek(DOC_fpMap, 0, SEEK_SET);
	fwrite(g_MapData, MAP_LEN, 1, DOC_fpMap);
	fwrite(g_TemplateData, MAP_LEN, 1, DOC_fpMap);

	Document_SetEditFlag(FALSE);

	return TRUE;
}

BOOL Document_CloseFile(HWND hWndParent)
{
	INT	nRet	= 0;

	if (DOC_fpMap != NULL)
	{
		if (DOC_bEdit)
		{
			nRet = ::MessageBox(hWndParent, "地图数据被改动了。\n要保存文件吗？", "关闭文件", MB_YESNOCANCEL | MB_ICONEXCLAMATION);
			switch (nRet)
			{
			case IDYES:
				if (!Document_SaveFile())
				{
					::MessageBox(hWndParent, "保存文件失败。", NULL, MB_OK);
					return FALSE;
				}
				break;
			case IDNO:
				break;
			case IDCANCEL:
				return FALSE;
				break;
			}
		}

		fclose(DOC_fpMap);
		DOC_fpMap = NULL;
	}
	return TRUE;
}

VOID Document_NewFile()
{
/*	FILE	*fpSrcMap	= NULL;
	DWORD	dwLen		= 0;

	CHAR	SrcMapFile[ MAX_PATH ];
	CHAR	NewMapFile[ MAX_PATH ];
	CHAR	MapName[ MAX_PATH ];

	::memset(SrcMapFile, 0, MAX_PATH);
	::memset(NewMapFile, 0, MAX_PATH);
	::memset(MapName, 0, MAX_PATH);

	if (lpstrName == NULL)
	{
		return FALSE;
	}

	if (dwNewMapNumber == dwSrcMapNumber)
	{
		return FALSE;
	}

	sprintf(SrcMapFile, "Map\\Map%d", dwSrcMapNumber);
	sprintf(NewMapFile, "Map\\Map%d", dwNewMapNumber);

	if (!::CopyFile(SrcMapFile, NewMapFile, FALSE))
	{
		return FALSE;
	}

	fpNewMap = fopen(NewMapFile, "rb+");
	if (fpNewMap == NULL)
	{
		return FALSE;
	}

	strcpy(MapName, lpstrName);
	fwrite(MapName, MAX_PATH, 1, fpNewMap);

	::memset(Map, 0, 1024 * 64);
	fwrite(Map, 1024 * 64, 1, fpNewMap);

	fclose(fpNewMap);*/
}

BOOL Document_LoadImage(LPSTR lpFilePath)
{
	static BYTE	ImageCode[ 1024 * 256 ];// 存放图组压缩数据
	static BYTE	TileImage[ 32 * 15 ];// 存放图块数据

	DWORD	dwImageCount	= 0;
	DWORD	dwLen		= 0;

	HBITMAP	hBitmap1x	= NULL;
	HBITMAP	hBitmap2x	= NULL;
	HBITMAP	hBitmapOld	= NULL;

	DWORD	i		= 0;
	FILE	*fpGop		= NULL;

	if (lpFilePath == NULL)
	{
		return FALSE;
	}

	fpGop = fopen(lpFilePath, "rb");

	if (fpGop == NULL)
	{
		return FALSE;
	}

	// 图组数据的长度
	fread(&dwLen, sizeof(DWORD), 1, fpGop);

	fread(ImageCode, dwLen, 1, fpGop);

	// 创建图块，放大1倍
	g_dwImageCount = ((WORD*)ImageCode)[ 0 ] - 1;
	for (i = 0; i < g_dwImageCount; i++)
	{
		GetImage(ImageCode, i, TileImage, 32 * 15);

		hBitmap1x = CreateBitmapFrom8Bits(TileImage, 32, 15, g_Palette);

		hBitmap2x = ZoomIn(hBitmap1x, 2);

		hBitmapOld = (HBITMAP)::SelectObject(g_hDCTileImage[ i ], hBitmap2x);

		::DeleteObject(hBitmap1x);
		::DeleteObject(hBitmapOld);

		// 迷你地图用的
		::BitBlt(g_hDCMiniTileImage[ i ], 0, 0, 1, 1, g_hDCTileImage[ i ], 32, 15, SRCCOPY);
	}
	return TRUE;
}


////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	VOID Document_SetEditFlag(BOOL bEdit)
//
// 描述  :
//	在地图窗口或模板窗口中修改了数据要调用这个函数，设为TRUE
//	文件被保存后要调用这个函数，设为FALSE
//
// 返回值:
//	
// 参数  :
//	BOOL bEdit -
//
////////////////////////////////////////////////////////////////////////////////
VOID Document_SetEditFlag(BOOL bEdit)
{
	DOC_bEdit = bEdit;
}


LPSTR Document_GetFileName(VOID)
{
	return DOC_FileName;
}