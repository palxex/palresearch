/*
 * PAL MOV format library
 * 
 * Author: Yihua Lou <louyihua@21cn.com>
 *
 * Copyright 2007 Yihua Lou
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
 *《仙剑奇侠传》MOV 格式处理库
 *
 * 作者： 楼奕华 <louyihua@21cn.com>
 *
 * 版权所有 2007 楼奕华
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

#include <stdlib.h>
#include <memory.h>

#include "pallib.h"
using namespace Pal::Tools;

palerrno_t Pal::Tools::DecodeMov(const void* pSrcMov, void* pDestFrame, int nDestWidth, int nDestHeight)
{
	const uint8* src = reinterpret_cast<const uint8*>(pSrcMov);
	uint8* dest = reinterpret_cast<uint8*>(pDestFrame);
	uint8 code, data_byte;
	uint16* dest_word;
	uint16 data_word;
	uint32 length;

	if (NULL == pSrcMov || NULL == pDestFrame)
		return PAL_EMPTY_POINTER;
	if (0 == nDestWidth || 0 == nDestHeight)
		return PAL_OK;
	src += 4;

	for(;;)
	{
		code = *src++;
		switch(code)
		{
		case 0:
			return PAL_OK;

		case 0xF1:
			dest += *src++ + 33;
			break;
		case 0xF2:
			dest += *reinterpret_cast<const uint16*>(src) + 289; src += 2;
			break;

		case 0xF3:
			length = *src++ + 33;
			for(uint32 i = 0; i < length; i++)
				*dest++ = *src++;
			break;
		case 0xF4:
			length = *reinterpret_cast<const uint16*>(src) + 289; src += 2;
			for(uint32 i = 0; i < length; i++)
				*dest++ = *src++;
			break;

		case 0xF5:
			length = *src++ + 34;
			data_byte = *src++;
			for(uint32 i = 0; i < length; i++)
				*dest++ = data_byte;
			break;
		case 0xF6:
			length = *reinterpret_cast<const uint16*>(src) + 290; src += 2;
			data_byte = *src++;
			for(uint32 i = 0; i < length; i++)
				*dest++ = data_byte;
			break;

		case 0xF7:
			length = *src++ + 34;
			data_word = *reinterpret_cast<const uint16*>(src); src += 2;
			dest_word = reinterpret_cast<uint16*>(dest);
			for(uint32 i = 0; i < length; i++)
				*dest_word++ = data_word;
			dest = reinterpret_cast<uint8*>(dest_word);
			break;
		case 0xF8:
			length = *reinterpret_cast<const uint16*>(src) + 290; src += 2;
			data_word = *reinterpret_cast<const uint16*>(src); src += 2;
			dest_word = reinterpret_cast<uint16*>(dest);
			for(uint32 i = 0; i < length; i++)
				*dest_word++ = data_word;
			dest = reinterpret_cast<uint8*>(dest_word);
			break;

		default:
			if (code >= 0x01 && code <= 0x20)
				dest += code;
			else if (code >= 0x21 && code <= 0x40)
				for(uint8 i = 0x20; i < code; i++)
					*dest++ = *src++;
			else if (code >= 0x41 && code <= 0x60)
			{
				data_byte = *src++;
				for(uint8 i = 0x3F; i < code; i++)
					*dest++ = data_byte;
			}
			else if (code >= 0x61 && code <= 0x80)
			{
				data_word = *reinterpret_cast<const uint16*>(src); src += 2;
				dest_word = reinterpret_cast<uint16*>(dest);
				for(uint8 i = 0x5F; i < code; i++)
					*dest_word++ = data_word;
				dest = reinterpret_cast<uint8*>(dest_word);
			}
			else
				return PAL_INVALID_DATA;
			break;
		}
	}
}

#define	ENCODE_TYPE_SKIP	0
#define	ENCODE_TYPE_COPY	1
#define	ENCODE_TYPE_REPEATB	2
#define	ENCODE_TYPE_REPEATW	3

static inline uint32 Encode_GetCodeLength(int type, uint32 count, uint8* code, uint32* length)
{
	switch(type)
	{
	case ENCODE_TYPE_SKIP:
		if (count < 0x21)
			*code = static_cast<uint8>(count), *length = 1;
		else if (count < 0x121)
			*code = 0xF1, *length = 2;
		else
			*code = 0xF2, *length = 3;
		return count;
	case ENCODE_TYPE_COPY:
		if (count < 0x21)
			*code = static_cast<uint8>(count) + 0x20, *length = count + 1;
		else if (count < 0x121)
			*code = 0xF3, *length = count + 2;
		else
			*code = 0xF4, *length = count + 3;
		return count;
	case ENCODE_TYPE_REPEATB:
		if (count < 0x22)
			*code = static_cast<uint8>(count) + 0x3F, *length = 2;
		else if (count < 0x122)
			*code = 0xF5, *length = 3;
		else
			*code = 0xF6, *length = 4;
		return count;
	case ENCODE_TYPE_REPEATW:
		if (count < 0x22)
			*code = static_cast<uint8>(count) + 0x5F, *length = 3;
		else if (count < 0x122)
			*code = 0xF7, *length = 4;
		else
			*code = 0xF8, *length = 5;
		return count << 1;
	default:
		return 0;
	}
}

static inline bool Encode_GenerateCode(const void* pSrcFrame, const void* pBaseFrame, const void* pSrcUpper, uint32* u_count, int* type, uint32* count)
{
	uint32 cnt, u_cnt = 0;
	const uint8* pSrc = reinterpret_cast<const uint8*>(pSrcFrame);
	const uint8* pBase = reinterpret_cast<const uint8*>(pBaseFrame);

	while(pSrc < pSrcUpper)
	{
		if (pBaseFrame)
		{
			const uint8* src = reinterpret_cast<const uint8*>(pSrc);
			const uint8* base = reinterpret_cast<const uint8*>(pBase);
			cnt = 0;
			while(src < pSrcUpper && cnt < 0x10120 && *src++ == *base++)
				cnt++;
			if (cnt)
			{
				if (u_cnt && cnt == 1)
					goto GenerateCode_SetCopy;
				else
				{
					*type = ENCODE_TYPE_SKIP;
					*count = cnt;
					break;
				}
			}
		}
		cnt = 1;

		const uint8* src_b = reinterpret_cast<const uint8*>(pSrc);
		uint8 data_b = *src_b++;
		while(src_b < pSrcUpper && cnt < 0x10121 && data_b == *src_b++)
			cnt++;
		if (cnt > 1)
		{
			if (u_cnt && cnt == 2)
				goto GenerateCode_SetCopy;
			else
			{
				*type = ENCODE_TYPE_REPEATB;
				*count = cnt;
				break;
			}
		}

		const uint16* src_w = reinterpret_cast<const uint16*>(pSrc);
		uint16 data_w = *src_w++;
		while(src_w < pSrcUpper && cnt < 0x10121 && data_w == *src_w++)
			cnt++;
		if (cnt > 1)
		{
			*type = ENCODE_TYPE_REPEATW;
			*count = cnt;
			break;
		}

GenerateCode_SetCopy:
		pSrc++; pBase++;
		*type = ENCODE_TYPE_COPY;
		*count = ++u_cnt;
	}

	*u_count = u_cnt;
	return (u_cnt != 0);
}

static inline bool Encode_WriteCode(uint8*& dest, uint32& ptr, uint32 nDestMaxLen, uint8 code, uint32 length, uint32 count, const uint8* src)
{
	if (ptr + length > nDestMaxLen)
		return false;
	*dest++ = code; ptr += length;
	switch(code)
	{
	case 0xF1:
	case 0xF3:
		*dest++ = static_cast<uint8>(count - 0x21);
		break;
	case 0xF5:
	case 0xF7:
		*dest++ = static_cast<uint8>(count - 0x22);
		break;
	case 0xF2:
	case 0xF4:
		*reinterpret_cast<uint16*>(dest) = static_cast<uint16>(count - 0x121); dest += 2;
		break;
	case 0xF6:
	case 0xF8:
		*reinterpret_cast<uint16*>(dest) = static_cast<uint16>(count - 0x122); dest += 2;
		break;
	}
	if (code >= 0x21 && code <= 0x40 || code == 0xF3 || code == 0xF4)
		for(uint32 i = 0; i < count; i++)
			*dest++ = *src++;
	else if (code >= 0x41 && code <= 0x60 || code == 0xF5 || code == 0xF6)
		*dest++ = *src;
	else if (code >= 0x61 && code <= 0x80 || code == 0xF7 || code == 0xF8)
	{
		*reinterpret_cast<uint16*>(dest) = *reinterpret_cast<const uint16*>(src); dest += 2;
	}
	return true;
}

palerrno_t Pal::Tools::EncodeMov(const void* pSrcFrame, const void* pBaseFrame, int nSrcWidth, int nSrcHeight, void* pDestMov, uint32& nDestLen)
{
	uint32 ptr, nSrcLen;
	const uint8* src = reinterpret_cast<const uint8*>(pSrcFrame);
	const uint8* base = reinterpret_cast<const uint8*>(pBaseFrame);
	uint8* dest = reinterpret_cast<uint8*>(pDestMov);
	const uint8* src_upper;

	if (NULL == pSrcFrame)
		return PAL_EMPTY_POINTER;
	if (pDestMov && !nDestLen)
		return PAL_NOT_ENOUGH_SPACE;
	if (0 == nSrcWidth || 0 == nSrcHeight)
	{
		nDestLen = 0;
		return PAL_OK;
	}
	nSrcLen = nSrcWidth * nSrcHeight;
	src_upper = src + nSrcLen; ptr = 0;

	if (pDestMov)
	{
		uint8 code;
		int type;
		uint32 count, count1, cnt, length, nDestMaxLen = nDestLen;

		while(src < src_upper)
		{
			if (Encode_GenerateCode(src, base, src_upper, &cnt, &type, &count))
			{
				Encode_GetCodeLength(ENCODE_TYPE_COPY, cnt, &code, &length);
				if (!Encode_WriteCode(dest, ptr, nDestMaxLen, code, length, cnt, src))
					break;
				src += cnt;
				if (base)
					base += cnt;
			}
			if (type != ENCODE_TYPE_COPY)
			{
				count1 = Encode_GetCodeLength(type, count, &code, &length);
				if (!Encode_WriteCode(dest, ptr, nDestMaxLen, code, length, count, src))
					break;
				src += count1;
				if (base)
					base += count1;
			}
		}
		if (src < src_upper)
			return PAL_NOT_ENOUGH_SPACE;
		else if (ptr < nDestMaxLen)
			*dest++ = 0, ptr++;
	}
	else
	{
		uint8 code;
		int type;
		uint32 count, cnt, length;

		while(src < src_upper)
		{
			if (Encode_GenerateCode(src, base, src_upper, &cnt, &type, &count))
			{
				Encode_GetCodeLength(ENCODE_TYPE_COPY, cnt, &code, &length);
				ptr += length;
				src += cnt;
				if (base)
					base += cnt;
			}
			if (type != ENCODE_TYPE_COPY)
			{
				count = Encode_GetCodeLength(type, count, &code, &length);
				ptr += length;
				src += count;
				if (base)
					base += count;
			}
		}
		ptr++;
	}
	nDestLen = ptr;

	return PAL_OK;
}