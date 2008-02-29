#include <windows.h>
#include <stdio.h>

#include "RLE.h"
#include "ImageGroup.h"

BOOL GetImage(LPBYTE lpImageCode, DWORD dwImage, LPBYTE lpBuffer, DWORD dwBufferLen)
{
	DWORD	dwImageCount	= 0;
	DWORD	dwLen		= 0;
	DWORD	dwOffset	= 0;

	dwImageCount = ((WORD*)lpImageCode)[ 0 ] - 1;

	if (dwImage < dwImageCount)
	{
		dwOffset = ((WORD*)lpImageCode)[ dwImage ] * 2;
		return DecodeRLE(lpImageCode + dwOffset, lpBuffer, dwBufferLen);
	}

	return FALSE;
}