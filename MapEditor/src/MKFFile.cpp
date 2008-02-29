////////////////////////////////////////////////////////////////////////////////
//
//                            MKF文件相关处理
//
////////////////////////////////////////////////////////////////////////////////
//
//	文件名：
//		MKFFile.cpp
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

#include "MKFFile.h"

// 错误提示
const	LPCSTR	MKF_ErrorString1	= "读取MKF记录号超界。";
const	LPCSTR	MKF_ErrorString2	= "读取MKF记录缓冲区不足。";

////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	DWORD MKF_GetRecordCount(FILE *fp)
//
// 描述  :
//	获取mkf文件中的记录总数
//	
// 返回值:
//	mkf文件中的记录总数
//	
// 参数  :
//	FILE *fp - mkf文件指针
//
////////////////////////////////////////////////////////////////////////////////
DWORD MKF_GetRecordCount(FILE *fp)
{
	DWORD dwRecordCount	=	0;
	if (fp == NULL)
	{
		return 0;
	}

	fseek(fp, 0, SEEK_SET);
	fread(&dwRecordCount, sizeof(DWORD), 1, fp);

	dwRecordCount = (dwRecordCount - 4) / 4;

	return dwRecordCount;
}

////////////////////////////////////////////////////////////////////////////////
//
// 函数名:
//	LONG MKF_ReadRecord(LPBYTE lpBuffer, DWORD dwBufferLength, DWORD dwRecord, FILE *fp)
//
// 描述  :
//	从文件中读取一条记录，放入lpBuffer中
//
// 返回值:
//	返回大于等于0，表示记录的长度
//	返回-1，表示参数有错误，
//	返回-2，表示缓冲区不足。
//	
// 参数  :
//	lpBuffer -		缓冲区指针
//	dwBufferLength -	缓冲区字节单位长度
//	dwRecord -		零基记录号
//	*fp -			文件指针
//
////////////////////////////////////////////////////////////////////////////////
LONG MKF_ReadRecord(LPBYTE lpBuffer, DWORD dwBufferLength, DWORD dwRecord, FILE *fp)
{
	DWORD dwOffset       = 0;
	DWORD dwNextOffset   = 0;
	DWORD dwRecordCount  = 0;
	DWORD dwRecordLen    = 0;

	if (lpBuffer == NULL ||	fp == NULL || dwBufferLength == 0)
	{
		return -1;
	}

	// 计算记录数
	dwRecordCount = MKF_GetRecordCount(fp);

	if (dwRecord >= dwRecordCount)
	{
		::MessageBox(::GetActiveWindow(), MKF_ErrorString1, NULL, MB_OK);
		return -1;
	}

	// 读取记录的地址
	fseek(fp, 4 * dwRecord, SEEK_SET);
	fread(&dwOffset, 4, 1, fp);
	fread(&dwNextOffset, 4, 1, fp);

	// 记录长度
	dwRecordLen = dwNextOffset - dwOffset;

	if (dwRecordLen > dwBufferLength)
	{
		::MessageBox(::GetActiveWindow(), MKF_ErrorString2, NULL, MB_OK);
		return -2;
	}

	if (dwRecordLen != 0)
	{
		memset(lpBuffer, 0, dwBufferLength);
		fseek(fp, dwOffset, SEEK_SET);
		fread(lpBuffer, dwRecordLen, 1, fp);
	}
	return dwRecordLen;
}