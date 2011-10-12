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
 *《仙剑奇侠传》库公共头文件
 *
 * 作者： 楼奕华 <louyihua@21cn.com>
 *
 * 版权所有 2006 - 2007 楼奕华
 *
 * 本文件是《仙剑奇侠传》库的一部分。
 *
 * 这个库属于自由软件，你可以遵照自由软件基金会出版的GNU次通用公共许可证条
 * 款来修改和重新发布这一程序。或者用许可证2.1版，或者（根据你的选择）用任
 * 何较新的版本。发布这一库的目的是希望它有用，但没有任何担保。甚至没有适合
 * 特定目的隐含的担保。更详细的情况请参阅GNU次通用公共许可证。
 * 
 * 你应该已经和库一起收到一份GNU次通用公共许可证的拷贝。如果还没有，写信给
 * 自由软件基金会：51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
*/

#pragma once

#ifndef	PAL_LIBRARY_H
#	define	PAL_LIBRARY_H
#endif

#include <errno.h>

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

		/* 　函数：DecodeRleCallback
		   　功能：控制每个像素的绘制
		   　参数：srcVal ---------- 源数据值，为 -1 时表示“透明”
				   pOutVal --------- 目的数据
				   pUserData ------- 用户数据
		   返回值：返回 true 表示由函数处理过，返回 false 表示采用默认行为
		*/
		typedef	bool (*PDECODERLECALLBACK)(int srcVal, uint8* pOutVal, void* pUserData);

		palerrno_t DecodeRle(const void* pSrcRle,			// 指向 RLE 图像的源指针
							 void* pDest,					// 指向目标填充区域的指针
							 int nDestWidth,				// 目标区域的宽度（像素）
							 int nDestHeight,				// 目标区域的高度（像素）
							 int x,							// 绘制 RLE 图像的左上角（像素）
							 int y,							// 绘制 RLE 图像的右上角（像素）
							 PDECODERLECALLBACK pCallback,	// 用户定义的回调函数，用于处理绘制
							 void* pUserData);				// 用户定义的数据，该数据被传递至回调函数

		/* 　函数：EncodeRleCallback
		   　功能：控制每个像素的绘制
		   　参数：srcVal ---------- 源数据值
			       x --------------- 当前点的横坐标
				   y --------------- 当前点的纵坐标
				   pUserData ------- 用户数据
		   返回值：返回 true 表示该点透明，返回 false 该点不透明
		*/
		typedef	bool (*PENCODERLECALLBACK)(uint8 srcVal, int x, int y, void* pUserData);

		palerrno_t EncodeRle(const void* pSrc,				// 指向源图像的源指针
							 int nSrcWidth,					// 源图像的宽度（像素）
							 int nSrcHeight,				// 源图像的高度（像素）
							 void* pDestRle,				// 指向目标 RLE 数据的指针，当为 NULL 时表示只计算长度
							 uint32& nDestLen,				// 输入时为目标区域的最大长度，输出时为实际填充的长度（仅成功编码时）
							 PENCODERLECALLBACK pCallback,	// 用户定义的回调函数，用于处理绘制
							 void* pUserData);				// 用户定义的数据，该数据被传递至回调函数

		palerrno_t DecodeMov(const void* pSrcMov,		// 指向编码后数据的指针
							 void* pDestFrame,			// 指向目的图像数据的指针
							 int nDestWidth,			// 目的图像的宽度（像素）
							 int nDestHeight);			// 目的图像的高度（像素）
		palerrno_t EncodeMov(const void* pSrcFrame,		// 需要编码的帧
							 const void* pBaseFrame,	// 参考帧
							 int nSrcWidth,				// 帧宽度（像素）
							 int nSrcHeight,			// 帧高度（像素）
							 void* pDestMov,			// 目的指针，当为 NULL 时表示只计算长度
							 uint32& nDestLen);			// 输入时为目标区域的最大长度，输出时为实际填充的长度（仅成功编码时）

		palerrno_t DecodeYJ1(const void* Source, void*& Destination, uint32& Length);
		palerrno_t EncodeYJ1(const void* Source, uint32 SourceLength, void*& Destination, uint32& Length);
		palerrno_t DecodeYJ2(const void* Source, void*& Destination, uint32& Length);
		palerrno_t EncodeYJ2(const void* Source, uint32 SourceLength, void*& Destination, uint32& Length, bool bCompatible = true);
		palerrno_t DecodeRNG(const void* Source, void* PrevFrame);
		palerrno_t EncodeRNG(const void* PrevFrame, const void* CurFrame, void*& Destination, uint32& Length);
/*
		errno_t DecodeRLE(const void* Rle, void* Destination, sint32 Stride, sint32 Width, sint32 Height, sint32 x, sint32 y);
		errno_t EncodeRLE(const void* Source, const void *Base, sint32 Stride, sint32 Width, sint32 Height, void*& Destination, uint32& Length);
		errno_t EncodeRLE(const void* Source, uint8 TransparentColor, sint32 Stride, sint32 Width, sint32 Height, void*& Destination, uint32& Length);

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

			//只提供给单独版本的 GRF 文件使用
			errno_t GRFgetfilename(GRFFILE* stream, const char* name, char*& filename, bool& forcenew);
			errno_t GRFopenfile(GRFFILE* stream, const char* name, const char* mode, FILE*& fpout);
			errno_t GRFappendfile(GRFFILE* stream, const char* name);
			errno_t GRFremovefile(GRFFILE* stream, const char* name);
			errno_t GRFrenamefile(GRFFILE* stream, const char* oldname, const char* newname);
			errno_t GRFgetfileattr(GRFFILE* stream, const char* name, int attr, void* value);
			errno_t GRFsetfileattr(GRFFILE* stream, const char* name, int attr, const void* value);

			//只提供给集成版本的 GRF 文件使用
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

//以下函数，均以返回非 0 表示错误

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
