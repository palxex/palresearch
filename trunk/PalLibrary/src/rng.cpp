/*
 * PAL RNG format library
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
 *《仙剑奇侠传》RNG格式处理库
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

#include <stdlib.h>
#include <memory.h>

#include "pallib.h"
using namespace Pal::Tools;

palerrno_t Pal::Tools::DecodeRNG(const void* Source, void* PrevFrame)
{
	sint32 ptr = 0, dst_ptr = 0;
	uint8 data;
	uint16 wdata;
	uint32 rep, i;
	uint8* src = (uint8*)Source;
	uint8* dest = (uint8*)PrevFrame;

	if (Source == NULL || PrevFrame == NULL)
		return PAL_EMPTY_POINTER;

	while(1)
	{
		data = *(src + ptr++);
		switch(data)
		{
		case 0x00:
		case 0x13:
			//0x1000411b
			return PAL_OK;
		case 0x01:
		case 0x05:
			break;
		case 0x02:
			dst_ptr += 2;
			break;
		case 0x03:
			data = *(src + ptr++);
			dst_ptr += ((uint32)data + 1) << 1;
			break;
		case 0x04:
			wdata = *(uint16 *)(src + ptr);
			ptr += 2;
			dst_ptr += ((uint32)wdata + 1) << 1;
			break;
		case 0x0a:
			*(uint16 *)(dest + dst_ptr) = *(uint16 *)(src + ptr);
			ptr += 2; dst_ptr += 2;
		case 0x09:
			*(uint16 *)(dest + dst_ptr) = *(uint16 *)(src + ptr);
			ptr += 2; dst_ptr += 2;
		case 0x08:
			*(uint16 *)(dest + dst_ptr) = *(uint16 *)(src + ptr);
			ptr += 2; dst_ptr += 2;
		case 0x07:
			*(uint16 *)(dest + dst_ptr) = *(uint16 *)(src + ptr);
			ptr += 2; dst_ptr += 2;
		case 0x06:
			*(uint16 *)(dest + dst_ptr) = *(uint16 *)(src + ptr);
			ptr += 2; dst_ptr += 2;
			break;
		case 0x0b:
			data = *(src + ptr++);
			rep = data; rep++;
			for(i = 0; i < rep; i++)
			{
				*(uint16 *)(dest + dst_ptr) = *(uint16 *)(src + ptr);
				ptr += 2; dst_ptr += 2;
			}
			break;
		case 0x0c:
			wdata = *(uint16 *)(src + ptr);
			ptr += 2; rep = wdata; rep++;
			for(i = 0; i < rep; i++)
			{
				*(uint16 *)(dest + dst_ptr) = *(uint16 *)(src + ptr);
				ptr += 2; dst_ptr += 2;
			}
			break;
		case 0x0d:
			wdata = *(uint16 *)(src + ptr);	ptr += 2;
			*(uint16 *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			*(uint16 *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			break;
		case 0x0e:
			wdata = *(uint16 *)(src + ptr);	ptr += 2;
			*(uint16 *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			*(uint16 *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			*(uint16 *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			break;
		case 0x0f:
			wdata = *(uint16 *)(src + ptr);	ptr += 2;
			*(uint16 *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			*(uint16 *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			*(uint16 *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			*(uint16 *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			break;
		case 0x10:
			wdata = *(uint16 *)(src + ptr);	ptr += 2;
			*(uint16 *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			*(uint16 *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			*(uint16 *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			*(uint16 *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			*(uint16 *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			break;
		case 0x11:
			data = *(src + ptr++);
			rep = data; rep++;
			wdata = *(uint16 *)(src + ptr);	ptr += 2;
			for(i = 0; i < rep; i++)
			{
				*(uint16 *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			}
			break;
		case 0x12:
			wdata = *(uint16 *)(src + ptr);
			rep = wdata; rep++; ptr += 2;
			wdata = *(uint16 *)(src + ptr);	ptr += 2;
			for(i = 0; i < rep; i++)
			{
				*(uint16 *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			}
			break;
		}
	}
	return PAL_OK;
}

static uint16 encode_1(uint16 *&start, uint16 *&data, uint8 *&dest)
{
	uint16 length = (uint16)(data - start - 1);
	uint16 len;
	if (length > 0xff)
	{
		*dest++ = 0x04;
		*((uint16 *)dest) = length;
		dest += 2;
		len = 3;
	}
	else if (length > 0)
	{
		*dest++ = 0x03;
		*dest++ = (uint8)length;
		len = 2;
	}
	else
	{
		*dest++ = 0x02;
		len = 1;
	}
	return len;
}

static uint16 encode_2(uint16 *&start, uint16 *&data, uint8 *&dest)
{
	uint16* temp;
	uint16 length = (uint16)(data - start - 1);
	uint16 len = (length + 1) << 1;
	if (length > 0xff)
	{
		*dest++ = 0xc;
		*((uint16 *)dest) = length;
		dest += 2;
		len += 3;
	}
	else if (length > 0x4)
	{
		*dest++ = 0xb;
		*dest++ = (uint8)length;
		len += 2;
	}
	else
	{
		*dest++ = 0x6 + (uint8)length;
		len++;
	}
	temp = (uint16 *)dest;
	for(sint32 i = 0; i <= length; i++)
		*temp++ = *start++;
	dest = (uint8 *)temp;
	start = data;
	return len;
}

static uint16 encode_3(uint16 *&start, uint16 *&data, uint8 *&dest)
{
	uint16* temp;
	uint16 length = (uint16)(data - start - 1);
	uint16 len = 2;
	if (length > 0xff)
	{
		*dest++ = 0x12;
		*((uint16 *)dest) = length;
		dest += 2;
		len += 3;
	}
	else if (length > 0x4)
	{
		*dest++ = 0x11;
		*dest++ = (uint8)length;
		len += 2;
	}
	else
	{
		*dest++ = 0xc + (uint8)length;
		len++;
	}
	temp = (uint16 *)dest;
	*temp++ = *start;
	dest = (uint8 *)temp;
	start = data;
	return len;
}

palerrno_t Pal::Tools::EncodeRNG(const void *PrevFrame, const void *CurFrame, void*& Destination, uint32& Length)
{
	sint32 len = 0, status = 0;
	uint16* data = (uint16*)CurFrame;
	uint16* prev = (uint16*)PrevFrame;
	uint16* start = data;
	uint16* end = data + 0x7d00;
	uint8* dest;
	uint8* dst;
	void* pNewData;

	if (PrevFrame == NULL || CurFrame == NULL)
		return PAL_EMPTY_POINTER;
	if ((dst = dest = (uint8*)malloc(0x10000)) == NULL)
		return PAL_OUT_OF_MEMORY;

	while(data < end)
	{
		switch(status)
		{
		case 0:
			if (prev)
				if (*prev == *data)
				{
					status = 1; start = data;
					data++; break;
				}
			if (data < end - 1)
				if (*data == *(data + 1))
					if (prev)
						if (*(data + 1) == *(prev + 1))
							status = 2;
						else
							status = 3;
					else
						status = 3;
				else
					status = 2;
			else
				status = 2;
			start = data; data++;
			break;
		case 1:
			if (*prev == *data)
				data++;
			else
			{
				len += encode_1(start, data, dest);
				status = 0;
			}
			break;
		case 2:
			if (prev)
				if (*prev == *data)
				{
					len += encode_2(start, data, dest);
					status = 0; break;
				}
			if (data < end - 1)
				if (*data != *(data + 1))
					data++;
				else
				{
					if (prev)
						if (*(data + 1) == *(prev + 1))
						{
							data++; break;
						}
					len += encode_2(start, data, dest);
					status = 0;
				}
			else
				data++;
			break;
		case 3:
			if (prev)
				if (*prev == *data)
				{
					len += encode_3(start, data, dest);
					status = 0; break;
				}
			if (data < end - 1)
				if (*data == *(data + 1))
					data++;
				else
				{
					data++; if (prev) prev++;
					len += encode_3(start, data, dest);
					status = 0;
				}
			else
				data++;
			break;
		}
		if (status && prev)
			prev++;
	}
	switch(status)
	{
	case 1: len += encode_1(start, data, dest); break;
	case 2: len += encode_2(start, data, dest); break;
	case 3: len += encode_3(start, data, dest); break;
	}
	len++; *dest++ = 0;
	if (len & 0x1)
	{
		*dest++ = 0;
		len++;
	}

	if ((pNewData = realloc(dst, len)) == NULL)
	{
		free(dst);
		return PAL_OUT_OF_MEMORY;
	}
	Destination = pNewData;
	Length = len;
	return PAL_OK;
}
