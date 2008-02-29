//$ Id: rng.cpp 1.02 2006-05-24 14:34:50 +8:00 $

/*
 * PAL RNG format Library
 * 
 * Author: Lou Yihua <louyihua@21cn.com>
 *
 * Copyright 2006 Lou Yihua
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
 * 作者： Lou Yihua <louyihua@21cn.com>
 *
 * 版权所有 2006 Lou Yihua
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

#include <memory.h>

#include "pallibrary.h"
using namespace PalLibrary;

PalLibrary::DataBuffer PalLibrary::DecodeRNG(const void *Source, void *PrevFrame)
{
	int ptr = 0, dst_ptr = 0;
	unsigned char data;
	unsigned short wdata;
	unsigned int rep, i;
	unsigned char *src = (unsigned char *)Source, *dest = (unsigned char *)PrevFrame;
	DataBuffer buf = {dest, 0xfa00};
	if (!dest)
		buf.data = dest = new unsigned char [0xfa00];

	while(1)
	{
		data = *(src + ptr++);
		switch(data)
		{
		case 0x00:
		case 0x13:
			//0x1000411b
			return buf;
		case 0x01:
		case 0x05:
			break;
		case 0x02:
			dst_ptr += 2;
			break;
		case 0x03:
			data = *(src + ptr++);
			dst_ptr += ((unsigned int)data + 1) << 1;
			break;
		case 0x04:
			wdata = *(unsigned short *)(src + ptr);
			ptr += 2;
			dst_ptr += ((unsigned int)wdata + 1) << 1;
			break;
		case 0x0a:
			*(unsigned short *)(dest + dst_ptr) = *(unsigned short *)(src + ptr);
			ptr += 2; dst_ptr += 2;
		case 0x09:
			*(unsigned short *)(dest + dst_ptr) = *(unsigned short *)(src + ptr);
			ptr += 2; dst_ptr += 2;
		case 0x08:
			*(unsigned short *)(dest + dst_ptr) = *(unsigned short *)(src + ptr);
			ptr += 2; dst_ptr += 2;
		case 0x07:
			*(unsigned short *)(dest + dst_ptr) = *(unsigned short *)(src + ptr);
			ptr += 2; dst_ptr += 2;
		case 0x06:
			*(unsigned short *)(dest + dst_ptr) = *(unsigned short *)(src + ptr);
			ptr += 2; dst_ptr += 2;
			break;
		case 0x0b:
			data = *(src + ptr++);
			rep = data; rep++;
			for(i = 0; i < rep; i++)
			{
				*(unsigned short *)(dest + dst_ptr) = *(unsigned short *)(src + ptr);
				ptr += 2; dst_ptr += 2;
			}
			break;
		case 0x0c:
			wdata = *(unsigned short *)(src + ptr);
			ptr += 2; rep = wdata; rep++;
			for(i = 0; i < rep; i++)
			{
				*(unsigned short *)(dest + dst_ptr) = *(unsigned short *)(src + ptr);
				ptr += 2; dst_ptr += 2;
			}
			break;
		case 0x0d:
			wdata = *(unsigned short *)(src + ptr);	ptr += 2;
			*(unsigned short *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			*(unsigned short *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			break;
		case 0x0e:
			wdata = *(unsigned short *)(src + ptr);	ptr += 2;
			*(unsigned short *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			*(unsigned short *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			*(unsigned short *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			break;
		case 0x0f:
			wdata = *(unsigned short *)(src + ptr);	ptr += 2;
			*(unsigned short *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			*(unsigned short *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			*(unsigned short *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			*(unsigned short *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			break;
		case 0x10:
			wdata = *(unsigned short *)(src + ptr);	ptr += 2;
			*(unsigned short *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			*(unsigned short *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			*(unsigned short *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			*(unsigned short *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			*(unsigned short *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			break;
		case 0x11:
			data = *(src + ptr++);
			rep = data; rep++;
			wdata = *(unsigned short *)(src + ptr);	ptr += 2;
			for(i = 0; i < rep; i++)
			{
				*(unsigned short *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			}
			break;
		case 0x12:
			wdata = *(unsigned short *)(src + ptr);
			rep = wdata; rep++; ptr += 2;
			wdata = *(unsigned short *)(src + ptr);	ptr += 2;
			for(i = 0; i < rep; i++)
			{
				*(unsigned short *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			}
			break;
		}
	}
	return buf;
}

static unsigned short encode_1(unsigned short *&start, unsigned short *&data, unsigned char *&dest)
{
	unsigned short length = (unsigned short)(data - start - 1);
	unsigned short len;
	if (length > 0xff)
	{
		*dest++ = 0x04;
		*((unsigned short *)dest) = length;
		dest += 2;
		len = 3;
	}
	else if (length > 0)
	{
		*dest++ = 0x03;
		*dest++ = (unsigned char)length;
		len = 2;
	}
	else
	{
		*dest++ = 0x02;
		len = 1;
	}
	return len;
}

static unsigned short encode_2(unsigned short *&start, unsigned short *&data, unsigned char *&dest)
{
	unsigned short *temp;
	unsigned short length = (unsigned short)(data - start - 1);
	unsigned short len = (length + 1) << 1;
	if (length > 0xff)
	{
		*dest++ = 0xc;
		*((unsigned short *)dest) = length;
		dest += 2;
		len += 3;
	}
	else if (length > 0x4)
	{
		*dest++ = 0xb;
		*dest++ = (unsigned char)length;
		len += 2;
	}
	else
	{
		*dest++ = 0x6 + (unsigned char)length;
		len++;
	}
	temp = (unsigned short *)dest;
	for(int i = 0; i <= length; i++)
		*temp++ = *start++;
	dest = (unsigned char *)temp;
	start = data;
	return len;
}

static unsigned short encode_3(unsigned short *&start, unsigned short *&data, unsigned char *&dest)
{
	unsigned short *temp;
	unsigned short length = (unsigned short)(data - start - 1);
	unsigned short len = 2;
	if (length > 0xff)
	{
		*dest++ = 0x12;
		*((unsigned short *)dest) = length;
		dest += 2;
		len += 3;
	}
	else if (length > 0x4)
	{
		*dest++ = 0x11;
		*dest++ = (unsigned char)length;
		len += 2;
	}
	else
	{
		*dest++ = 0xc + (unsigned char)length;
		len++;
	}
	temp = (unsigned short *)dest;
	*temp++ = *start;
	dest = (unsigned char *)temp;
	start = data;
	return len;
}

PalLibrary::DataBuffer PalLibrary::EncodeRNG(const void *PrevFrame, const void *CurFrame)
{
	int len = 0, status = 0;
	unsigned short *data = (unsigned short *)CurFrame;
	unsigned short *prev = (unsigned short *)PrevFrame;
	unsigned short *start = data, *end = data + 0x7d00;
	unsigned char *dest = new unsigned char [0x10000];
	unsigned char *dst = dest;
	DataBuffer buf = {0, 0};

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

	buf.length = len;
	buf.data = new unsigned char [len];
	memcpy(buf.data, dst, len);
	delete [] dst;

	return buf;
}
