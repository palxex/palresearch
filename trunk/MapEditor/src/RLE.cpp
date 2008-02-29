/********************************************************************************\
|
|	Name:
|		RLE.cpp
|
|	Description:
|		RLE相关处理
|
\********************************************************************************/

#include <windows.h>

/********************************************************************************\
|
|	Name:
|		BOOL DeRLE(LPBYTE lpImageCode, LPBYTE lpBuffer, DWORD dwBufferLen)
|
|	Description:
|		解压RLE
|
\********************************************************************************/

BOOL DecodeRLE(LPBYTE lpImageCode, LPBYTE lpBuffer, DWORD dwBufferLen)
{
	DWORD i           = 0;
	DWORD dwLen       = 0;
	DWORD dwWidth     = 0;
	DWORD dwHeight    = 0;
	BYTE *pDestData   = 0;

	if (lpImageCode == NULL || lpBuffer == NULL)
	{
		return FALSE;
	}

	// Gop.mkf中的图像数据格式开头是没有02 00 00 00的
	if (((DWORD*)lpImageCode)[ 0 ] == 0x00000002)
	{
		lpImageCode += 4;
	}

	dwWidth = ((WORD*)lpImageCode)[ 0 ];
	dwHeight = ((WORD*)lpImageCode)[ 1 ];
	dwLen = dwWidth * dwHeight;

	if (dwLen > dwBufferLen)
	{
		return FALSE;
	}

	::memset(lpBuffer, 0xFF, dwLen);         // 全设为关键色

	// 解
	lpImageCode += 4;
	BYTE T;
	for (i = 0; i < dwLen;)
	{
		T = *lpImageCode++;
		if (0x80 < T && T <= 0x80 + dwWidth)
		{
			i = i + (T - 0x80);
		}
		else
		{
			::memcpy(lpBuffer + i, lpImageCode, T);
			lpImageCode += T;
			i = i + T;
		}
	}

	return TRUE;
}

/********************************************************************************\
|
|	Name:
|		DWORD GetWidth(BYTE *lpImageCode)
|
|	Description:
|		获取图像的宽度
|
\********************************************************************************/

DWORD GetWidth(BYTE *lpImageCode)
{
	if (lpImageCode == NULL)
	{
		return 0;
	}

	// Gop.mkf中的图像数据格式开头是没有02 00 00 00的
	if (((DWORD*)lpImageCode)[ 0 ] == 0x00000002)
	{
		lpImageCode += 4;
	}

	return ((WORD*)lpImageCode)[ 0 ];
}

/********************************************************************************\
|
|	Name:
|		DWORD GetHeight(BYTE *lpImageCode)
|
|	Description:
|		获取图像的高度
|
\********************************************************************************/

DWORD GetHeight(LPBYTE lpImageCode)
{
	if (lpImageCode == NULL)
	{
		return 0;
	}

	// Gop.mkf中的图像数据格式开头是没有02 00 00 00的
	if (((DWORD*)lpImageCode)[ 0 ] == 0x00000002)
	{
		lpImageCode += 4;
	}

	return ((WORD*)lpImageCode)[ 1 ];
}