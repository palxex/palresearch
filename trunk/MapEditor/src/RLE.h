/********************************************************************************\
|
|	Name:
|		RLE.h
|
|	Description:
|		RLE相关处理
|
\********************************************************************************/

BOOL DecodeRLE(LPBYTE lpImageCode, LPBYTE lpBuffer, DWORD dwBufferLen);

DWORD GetWidth(LPBYTE lpImageCode);

DWORD GetHeight(LPBYTE lpImageCode);