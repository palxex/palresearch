/*
 * PAL library common include file
 * 
 * Author: Yihua Lou <louyihua@21cn.com>
 *
 * Copyright 2006 - 2007 Yihua Lou
 *
 * This file is part of PAL library.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

 *
 *���ɽ����������⹫��ͷ�ļ�
 *
 * ���ߣ� ¥�Ȼ� <louyihua@21cn.com>
 *
 * ��Ȩ���� 2006 - 2007 ¥�Ȼ�
 *
 * ���ļ��ǡ��ɽ������������һ���֡�
 *
 * �������������������������������������������GNU��ͨ�ù������֤��
 * �����޸ĺ����·�����һ���򡣻��������֤2.1�棬���ߣ��������ѡ������
 * �ν��µİ汾��������һ���Ŀ����ϣ�������ã���û���κε���������û���ʺ�
 * �ض�Ŀ�������ĵ���������ϸ����������GNU��ͨ�ù������֤��
 * 
 * ��Ӧ���Ѿ��Ϳ�һ���յ�һ��GNU��ͨ�ù������֤�Ŀ����������û�У�д�Ÿ�
 * �����������᣺51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
*/

#pragma once

#ifndef	PAL_LIBRARY_H
#	define	PAL_LIBRARY_H
#endif

#include <errno.h>
#define errno_t error_t

#include "config.h"
//#include "grf.h"

#define	PAL_OK					0
#define	PAL_OUT_OF_MEMORY		ENOMEM
#define	PAL_INVALID_PARAMETER	EINVAL
#define	PAL_INVALID_DATA		1024
#define	PAL_EMPTY_POINTER		1025
#define	PAL_NOT_ENOUGH_SPACE	1026
#define	PAL_INVALID_FORMAT		1027

#if	defined(__cplusplus)

namespace Pal
{
	namespace Tools
	{

		/* ��������DecodeRleCallback
		   �����ܣ�����ÿ�����صĻ���
		   ��������srcVal ---------- Դ����ֵ��Ϊ -1 ʱ��ʾ��͸����
				   pOutVal --------- Ŀ������
				   pUserData ------- �û�����
		   ����ֵ������ true ��ʾ�ɺ�������������� false ��ʾ����Ĭ����Ϊ
		*/
		typedef	bool (*PDECODERLECALLBACK)(int srcVal, uint8* pOutVal, void* pUserData);

		palerrno_t DecodeRle(const void* pSrcRle,			// ָ�� RLE ͼ���Դָ��
							 void* pDest,					// ָ��Ŀ����������ָ��
							 int nDestWidth,				// Ŀ������Ŀ�ȣ����أ�
							 int nDestHeight,				// Ŀ������ĸ߶ȣ����أ�
							 int x,							// ���� RLE ͼ������Ͻǣ����أ�
							 int y,							// ���� RLE ͼ������Ͻǣ����أ�
							 PDECODERLECALLBACK pCallback,	// �û�����Ļص����������ڴ������
							 void* pUserData);				// �û���������ݣ������ݱ��������ص�����

		/* ��������EncodeRleCallback
		   �����ܣ�����ÿ�����صĻ���
		   ��������srcVal ---------- Դ����ֵ
			       x --------------- ��ǰ��ĺ�����
				   y --------------- ��ǰ���������
				   pUserData ------- �û�����
		   ����ֵ������ true ��ʾ�õ�͸�������� false �õ㲻͸��
		*/
		typedef	bool (*PENCODERLECALLBACK)(uint8 srcVal, int x, int y, void* pUserData);

		palerrno_t EncodeRle(const void* pSrc,				// ָ��Դͼ���Դָ��
							 int nSrcWidth,					// Դͼ��Ŀ�ȣ����أ�
							 int nSrcHeight,				// Դͼ��ĸ߶ȣ����أ�
							 void* pDestRle,				// ָ��Ŀ�� RLE ���ݵ�ָ�룬��Ϊ NULL ʱ��ʾֻ���㳤��
							 uint32& nDestLen,				// ����ʱΪĿ���������󳤶ȣ����ʱΪʵ�����ĳ��ȣ����ɹ�����ʱ��
							 PENCODERLECALLBACK pCallback,	// �û�����Ļص����������ڴ������
							 void* pUserData);				// �û���������ݣ������ݱ��������ص�����

		palerrno_t DecodeMov(const void* pSrcMov,		// ָ���������ݵ�ָ��
							 void* pDestFrame,			// ָ��Ŀ��ͼ�����ݵ�ָ��
							 int nDestWidth,			// Ŀ��ͼ��Ŀ�ȣ����أ�
							 int nDestHeight);			// Ŀ��ͼ��ĸ߶ȣ����أ�
		palerrno_t EncodeMov(const void* pSrcFrame,		// ��Ҫ�����֡
							 const void* pBaseFrame,	// �ο�֡
							 int nSrcWidth,				// ֡��ȣ����أ�
							 int nSrcHeight,			// ֡�߶ȣ����أ�
							 void* pDestMov,			// Ŀ��ָ�룬��Ϊ NULL ʱ��ʾֻ���㳤��
							 uint32& nDestLen);			// ����ʱΪĿ���������󳤶ȣ����ʱΪʵ�����ĳ��ȣ����ɹ�����ʱ��

		palerrno_t DecodeYJ1(const void* Source, void*& Destination, uint32& Length);
		palerrno_t EncodeYJ1(const void* Source, uint32 SourceLength, void*& Destination, uint32& Length);
		palerrno_t DecodeYJ2(const void* Source, void*& Destination, uint32& Length);
		palerrno_t EncodeYJ2(const void* Source, uint32 SourceLength, void*& Destination, uint32& Length, bool bCompatible = true);
		palerrno_t DecodeRNG(const void* Source, void* PrevFrame);
		palerrno_t EncodeRNG(const void* PrevFrame, const void* CurFrame, void*& Destination, uint32& Length);
		errno_t DecodeRLE(const void* Rle, void* Destination, sint32 Stride, sint32 Width, sint32 Height, sint32 x, sint32 y);
		errno_t EncodeRLE(const void* Source, const void *Base, sint32 Stride, sint32 Width, sint32 Height, void*& Destination, uint32& Length);
		errno_t EncodeRLE(const void* Source, uint8 TransparentColor, sint32 Stride, sint32 Width, sint32 Height, void*& Destination, uint32& Length);

/*
		errno_t DecodeYJ1StreamInitialize(void*& pvState, uint32 uiGrowBy = 0x10000);
		errno_t DecodeYJ1StreamInput(void* pvState, const void* Source, uint32 SourceLength);
		errno_t DecodeYJ1StreamOutput(void* pvState, void* Destination, uint32 Length, uint32& ActualLength);
		bool DecodeYJ1StreamFinished(void* pvState, uint32& AvailableLength);
		errno_t DecodeYJ1StreamFinalize(void* pvState);
		errno_t DecodeYJ1StreamReset(void* pvState);

		errno_t DecodeYJ2StreamInitialize(void*& pvState, uint32 uiGrowBy = 0x10000);
		errno_t DecodeYJ2StreamInput(void* pvState, const void* Source, uint32 SourceLength);
		errno_t DecodeYJ2StreamOutput(void* pvState, void* Destination, uint32 Length, uint32& ActualLength);
		bool DecodeYJ2StreamFinished(void* pvState, uint32& AvailableLength);
		errno_t DecodeYJ2StreamFinalize(void* pvState);
		errno_t DecodeYJ2StreamReset(void* pvState);

		errno_t EncodeYJ2StreamInitialize(void*& pvState, uint32 uiSourceLength, uint32 uiGrowBy = 0x10000, bool bCompatible = true);
		errno_t EncodeYJ2StreamInput(void* pvState, const void* Source, uint32 SourceLength, bool bFinished = false);
		errno_t EncodeYJ2StreamOutput(void* pvState, void* Destination, uint32 Length, uint32& ActualLength, uint32& Bits);
		bool EncodeYJ2StreamFinished(void* pvState);
		errno_t EncodeYJ2StreamFinalize(void* pvState);

		namespace GRF
		{
			errno_t GRFopen(const char* grffile, const char* base, bool create, bool truncate, GRFFILE*& stream);
			errno_t GRFclose(GRFFILE* stream);
			errno_t GRFflush(GRFFILE* stream);
			errno_t GRFgettype(GRFFILE* stream, int& type);
			errno_t GRFenumname(GRFFILE* stream, const char* prevname, char*& nextname);
			errno_t GRFerror(GRFFILE* stream);
			void GRFclearerr(GRFFILE* stream);

			//ֻ�ṩ�������汾�� GRF �ļ�ʹ��
			errno_t GRFgetfilename(GRFFILE* stream, const char* name, char*& filename, bool& forcenew);
			errno_t GRFopenfile(GRFFILE* stream, const char* name, const char* mode, FILE*& fpout);
			errno_t GRFappendfile(GRFFILE* stream, const char* name);
			errno_t GRFremovefile(GRFFILE* stream, const char* name);
			errno_t GRFrenamefile(GRFFILE* stream, const char* oldname, const char* newname);
			errno_t GRFgetfileattr(GRFFILE* stream, const char* name, int attr, void* value);
			errno_t GRFsetfileattr(GRFFILE* stream, const char* name, int attr, const void* value);

			//ֻ�ṩ�����ɰ汾�� GRF �ļ�ʹ��
			errno_t GRFseekfile(GRFFILE* stream, const char* name);
			errno_t GRFeof(GRFFILE* stream);
			errno_t GRFseek(GRFFILE* stream, long offset, int origin, long& newpos);
			errno_t GRFtell(GRFFILE* stream, long& pos);
			errno_t GRFread(GRFFILE* stream, void* buffer, uint32 size, uint32& actual);
			errno_t GRFgetattr(GRFFILE* stream, int attr, void* value);

			errno_t GRFPackage(const char* pszGRF, const char* pszBasePath, const char* pszNewFile);
			errno_t GRFExtract(const char* pszGRF, const char* pszNewFile, const char* pszBasePath);
		}
*/
	}
}

#else

//���º��������Է��ط� 0 ��ʾ����

errno_t decodeyj1(const void* Source, void** Destination, uint32* Length);
errno_t encodeyj1(const void* Source, uint32 SourceLength, void** Destination, uint32* Length);
errno_t decodeyj2(const void* Source, void** Destination, uint32* Length);
errno_t encodeyj2(const void* Source, uint32 SourceLength, void** Destination, uint32* Length, errno_t bCompatible);
errno_t decoderng(const void* Source, void* PrevFrame);
errno_t encoderng(const void* PrevFrame, const void* CurFrame, void** Destination, uint32* Length);
errno_t decoderle(const void* Rle, void* Destination, sint32 Stride, sint32 Width, sint32 Height, sint32 x, sint32 y);
errno_t encoderle(const void* Source, const void *Base, sint32 Stride, sint32 Width, sint32 Height, void** Destination, uint32* Length);
errno_t encoderlet(const void* Source, uint8 TransparentColor, sint32 Stride, sint32 Width, sint32 Height, void** Destination, uint32* Length);

errno_t decodeyj1streaminitialize(void** pvState, uint32 uiGrowBy);
errno_t decodeyj1streaminput(void* pvState, const void* Source, uint32 SourceLength);
errno_t decodeyj1streamoutput(void* pvState, void* Destination, uint32 Length, uint32* ActualLength);
int decodeyj1streamfinished(void* pvState, uint32* AvailableLength);
errno_t decodeyj1streamfinalize(void* pvState);
errno_t decodeyj1streamreset(void* pvState);

errno_t decodeyj2streaminitialize(void** pvState, uint32 uiGrowBy);
errno_t decodeyj2streaminput(void* pvState, const void* Source, uint32 SourceLength);
errno_t decodeyj2streamoutput(void* pvState, void* Destination, uint32 Length, uint32* ActualLength);
int decodeyj2streamfinished(void* pvState, uint32* AvailableLength);
errno_t decodeyj2streamfinalize(void* pvState);
errno_t decodeyj2streamreset(void* pvState);

errno_t encodeyj2streaminitialize(void** pvState, uint32 uiSourceLength, uint32 uiGrowBy, int bCompatible);
errno_t encodeyj2streaminput(void* pvState, const void* Source, uint32 SourceLength, int bFinished);
errno_t encodeyj2streamoutput(void* pvState, void* Destination, uint32 Length, uint32* ActualLength, uint32* Bits);
int encodeyj2streamfinished(void* pvState);
errno_t encodeyj2streamfinalize(void* pvState);

errno_t grfopen(const char* grffile, const char* base, int create, int truncate, GRFFILE** grf);
errno_t grfclose(GRFFILE* stream);
errno_t grfflush(GRFFILE* stream);
errno_t grfgettype(GRFFILE* stream, int* type);
errno_t grfenumname(GRFFILE* stream, const char* prevname, char** nextname);
errno_t grferror(GRFFILE* stream);
void grfclearerr(GRFFILE* stream);

errno_t grfopenfile(GRFFILE* stream, const char* name, const char* mode, FILE** fp);
errno_t grfappendfile(GRFFILE* stream, const char* name);
errno_t grfremovefile(GRFFILE* stream, const char* name);
errno_t grfrenamefile(GRFFILE* stream, const char* oldname, const char* newname);
errno_t grfgetfileattr(GRFFILE* stream, const char* name, int attr, void* value);
errno_t grfsetfileattr(GRFFILE* stream, const char* name, int attr, const void* value);

errno_t grfseekfile(GRFFILE* stream, const char* name);
errno_t grfeof(GRFFILE* stream);
errno_t grfseek(GRFFILE* stream, long offset, int origin, long pos);
errno_t grftell(GRFFILE* stream, long pos);
errno_t grfread(GRFFILE* stream, void* buffer, long size, long len);
errno_t grfgetattr(GRFFILE* stream, int attr, void* value);

errno_t grfpackage(const char* pszGRF, const char* pszBasePath, const char* pszNewFile);
errno_t grfextract(const char* pszGRF, const char* pszBasePath, const char* pszNewFile);

#endif
