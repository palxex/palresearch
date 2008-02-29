////////////////////////////////////////////////////////////////////////////////
//
//                              
//
////////////////////////////////////////////////////////////////////////////////
//
//	文件名：
//		Bitmap.cpp
//
//	说明：
//		Bitmap处理
//		只处理256色的数据
//
//	函数：
//		
//
//////////////////////////////////////////////////////////////////////////////////

#include <windows.h>


////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	VOID MirrorX(LPBYTE lpImageData, DWORD dwWidth, DWORD dwHeight)
//
// 描述  :
//	把图像上下翻转
//
// 返回值:
//	
// 参数  :
//	pImageData - 256色图像数据指针
//	dwWidth - 图像宽度
//	dwHeight - 图像高度
//
////////////////////////////////////////////////////////////////////////////////
VOID MirrorX(LPBYTE lpImageData, DWORD dwWidth, DWORD dwHeight)
{
	DWORD	i		= 0;
	DWORD	dwCount		= 0;
	BYTE	Buffer[ 1024 * 4 ];

	if (dwWidth > 1024 * 4)
	{
		return;
	}
	
	dwCount	= (dwHeight - (dwHeight % 2))  / 2;

	for (i = 0; i < dwCount; i++)
	{
		::memcpy(Buffer, lpImageData + dwWidth * i, dwWidth);
		::memcpy(lpImageData + dwWidth * i, lpImageData + dwWidth * (dwHeight - i - 1), dwWidth);
		::memcpy(lpImageData + dwWidth * (dwHeight - i - 1), Buffer, dwWidth);
	}
}

////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	HBITMAP CreateBitmapFrom8Bits(LPBYTE lpImageData, DWORD dwWidth, DWORD dwHeight, RGBQUAD *pPalette)
//
// 描述  :
//	用256色的图像数据创建window位图
//
// 返回值:
//	
// 参数  :
//	pImageData -
//	dwWidth -
//	dwHeight -
//	*pPalette - window调色板指针
//
////////////////////////////////////////////////////////////////////////////////
HBITMAP CreateBitmapFrom8Bits(LPBYTE lpImageData, DWORD dwWidth, DWORD dwHeight, RGBQUAD *pPalette)
{
	if (lpImageData == NULL || pPalette == NULL)
	{
		return NULL;
	}

	HBITMAP hBitmap   = NULL;
	DWORD i           = 0;
	DWORD P           = 0;
	BYTE *pTempData   = NULL;
	DWORD dwPitch     = dwWidth;

	// 倒转图像以适应Windows
	MirrorX(lpImageData, dwWidth, dwHeight);


	if (dwWidth % 4 != 0)
	{
		P = 4 - (dwWidth % 4);
		dwPitch = dwWidth + P;

		DWORD dwLen = dwPitch * dwHeight;
		pTempData = new BYTE[ dwLen ];
		if (pTempData == NULL)
		{
			return NULL;
		}

		::memset(pTempData, 0xFF, dwLen);         // 全设为关键色

		for (i = 0; i < dwHeight; i++)
		{
			::memcpy(pTempData + i * dwPitch,  lpImageData + i * dwWidth, dwWidth);
		}
		lpImageData = pTempData;
	}

	// 创建位图
	BITMAPINFOHEADER BitmapInfoHeader;
	BYTE             *pBitmapInfo;

	::memset(&BitmapInfoHeader, 0, sizeof(BITMAPINFOHEADER));

	BitmapInfoHeader.biHeight        = dwHeight;
	BitmapInfoHeader.biWidth         = dwWidth;
	BitmapInfoHeader.biBitCount      = 8;
	BitmapInfoHeader.biPlanes        = 1;
	BitmapInfoHeader.biSizeImage     = dwHeight * dwPitch;
	BitmapInfoHeader.biXPelsPerMeter = 3780;
	BitmapInfoHeader.biYPelsPerMeter = 3780;
	BitmapInfoHeader.biSize = sizeof(BITMAPINFOHEADER);

	// bitmap信息包括bitmap信息头和调色板
	pBitmapInfo = new BYTE[sizeof(BITMAPINFOHEADER) + sizeof(RGBQUAD) * 256];

	if (pBitmapInfo == NULL)
	{
		if (pTempData != NULL)
		{
			delete [] pTempData;
		}
		return NULL;
	}

	::memcpy(pBitmapInfo,
		&BitmapInfoHeader,
		sizeof(BITMAPINFOHEADER));

	::memcpy(pBitmapInfo + sizeof(BITMAPINFOHEADER),
		pPalette,
		sizeof(RGBQUAD) * 256);

	HDC hDC = ::GetDC(NULL);
	hBitmap = ::CreateDIBitmap(
		hDC,
		&BitmapInfoHeader,
		CBM_INIT,
		lpImageData,
		(BITMAPINFO*)pBitmapInfo,
		DIB_RGB_COLORS);
	::ReleaseDC(NULL, hDC);

	delete [] pBitmapInfo;
	if (pTempData != NULL)
	{
		delete [] pTempData;
	}

	return hBitmap;
}


////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	VOID ZoomIn(HBITMAP hBitmap, DWORD dwN)
//
// 描述  :
//	放大位图
//
// 返回值:
//	
// 参数  :
//	hBitmap -	位图句柄
//	dwN -		放大倍数
//
////////////////////////////////////////////////////////////////////////////////
HBITMAP ZoomIn(HBITMAP hBitmap, DWORD dwN)
{
	DWORD		dwNewWidth	= 0;
	DWORD		dwNewHeight	= 0;

	BITMAP		Bitmap;
	HBITMAP		hBitmapNx	= NULL;
	HBITMAP		hBitmapTemp	= NULL;

	HDC		hDC		= NULL;
	HDC		hDCNx		= NULL;
	HDC		hScreenDC	= NULL;

	if (hBitmap == NULL)
	{
		return NULL;
	}

	::GetObject(hBitmap, sizeof(BITMAP), &Bitmap);

	dwNewWidth	= Bitmap.bmWidth * dwN;
	dwNewHeight	= Bitmap.bmHeight * dwN;

	hScreenDC	= ::GetDC(NULL);

	hBitmapNx	= ::CreateCompatibleBitmap(hScreenDC, dwNewWidth, dwNewHeight);
	hBitmapTemp	= ::CreateCompatibleBitmap(hScreenDC, dwNewWidth, dwNewHeight);

	hDC		= ::CreateCompatibleDC(hScreenDC);
	hDCNx		= ::CreateCompatibleDC(hScreenDC);

	if (hBitmapNx == NULL || hBitmapTemp == NULL ||
		hDC == NULL || hDCNx == NULL)
	{
		return NULL;
	}

	::SelectObject(hDC, hBitmap);

	::SelectObject(hDCNx, hBitmapNx);

	// 放大贴图
	::StretchBlt(hDCNx, 0, 0, dwNewWidth, dwNewHeight, hDC, 0, 0, Bitmap.bmWidth, Bitmap.bmHeight, SRCCOPY);

	::SelectObject(hDCNx, hBitmapTemp);


	::DeleteDC(hDC);
	::DeleteDC(hDCNx);

	::DeleteObject(hBitmapTemp);

	::ReleaseDC(NULL, hScreenDC);

	return hBitmapNx;
}
