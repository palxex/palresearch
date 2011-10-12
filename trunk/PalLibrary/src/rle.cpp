/*
 * PAL RLE format library
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
 *《仙剑奇侠传》RLE格式处理库
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

palerrno_t Pal::Tools::DecodeRle(const void* pSrcRle, void* pDest, int nDestWidth, int nDestHeight,
								 int x, int y, Pal::Tools::PDECODERLECALLBACK pCallback, void* pUserData)
{
	int sx, sy, dx, dy, maxy, maxx, offx;
	uint16 rle_width, rle_height;
	uint8  count, cnt;
	uint8* dest;
	const uint8* src;

	//检查输入参数
	if (NULL == pSrcRle || NULL == pDest || NULL == pCallback)
		return PAL_EMPTY_POINTER;

	//取 RLE 图像的宽度和高度
	rle_width = reinterpret_cast<const uint16*>(pSrcRle)[0];
	rle_height = reinterpret_cast<const uint16*>(pSrcRle)[1];
	src = reinterpret_cast<const uint8*>(pSrcRle) + 4;

	//检查 RLE 图像能否显示到指定的图像中
	if (nDestWidth <= 0 || nDestHeight <= 0 ||
		x + rle_width < 0 || x >= nDestWidth ||
		y + rle_height < 0 || y >= nDestHeight)
		return PAL_OK;

	maxy = (y + rle_height > nDestHeight) ? nDestHeight : y + rle_height;
	maxx = (x + rle_width > nDestWidth) ? nDestWidth : x + rle_width;
	offx = nDestWidth - maxx;

	//跳过由于 y < 0 导致的不能显示的部分
	for(sy = 0, dy = y; dy < 0; dy++, sy++)
		for(sx = 0; sx < rle_width;)
		{
			count = *src++;
			if (count < 0x80)
			{
				src += count;
				sx += count;
			}
			else
				sx += count & 0x7f;
		}

	// 填充目标区域
	for(dest = reinterpret_cast<uint8*>(pDest) + dy * nDestWidth; dy < maxy; dy++, sy++)
	{
		// 跳过由于 x < 0 导致的不能显示的部分
		for(count = 0, dx = x; dx < 0;)
		{
			count = *src++;
			if (count < 0x80)
			{
				src += count;
				dx += count;
			}
			else
				dx += count & 0x7f;
		}

		if (x < 0)
		{
			// 对跨越 0 点的图像进行特殊处理
			if (dx > 0)
			{
				// 进入目标区域左边界
				if (count < 0x80)
					src -= dx;
				count = (count & 0x80) | dx;
				dx = 0;
			}
			else
				count = 0;
			sx = -x;
		}
		else
			sx = 0;

		// 写入目标区域
		for(dest += dx;;)
		{
			if (count < 0x80)
			{
				// “不透明”点
				for(cnt = 0; cnt < count && dx < maxx; cnt++, sx++, dx++, dest++)
				{
					uint8 sval = *src++;
					if (!pCallback(sval, dest, pUserData))
						// 使用标准行为
						*dest = sval;
				}
			}
			else
			{
				// “透明”点
				for(cnt = 0x80; cnt < count && dx < maxx; cnt++, sx++, dx++, dest++)
					pCallback(-1, dest, pUserData);
			}
			if (dx < maxx)
				// 取重复次数
				count = *src++;
			else
			{
				if (count < 0x80)
					src += count - cnt;
				sx += count - cnt;
				dest += offx;
				break;
			}
		}

		//调整源指针，使指针指向下一行
		while(sx < rle_width)
		{
			count = *src++;
			if (count < 0x80)
			{
				src += count;
				sx += count;
			}
			else
				sx += count & 0x7f;
		}
	}

	return PAL_OK;
}

palerrno_t Pal::Tools::EncodeRle(const void* pSrc, int nSrcWidth, int nSrcHeight, void* pDestRle,
								 uint32& nDestLen, Pal::Tools::PENCODERLECALLBACK pCallback, void* pUserData)
{
	uint32 ptr;
	const uint8* src = reinterpret_cast<const uint8*>(pSrc);
	uint8* dest = reinterpret_cast<uint8*>(pDestRle);
	bool bprev, bcur;
	uint8 count;
	int x, y;

	//检查输入参数
	if (NULL == pSrc || NULL == pCallback)
		return PAL_EMPTY_POINTER;
	if (pDestRle && nDestLen < 6)
		return PAL_NOT_ENOUGH_SPACE;
	if (0 == nSrcWidth || 0 == nSrcHeight)
	{
		nDestLen = 0;
		return PAL_OK;
	}

	if (pDestRle)
	{
		uint32 nDestMaxLen = nDestLen;
		uint8* pcount;

		// 进行实际填充
		reinterpret_cast<uint16*>(pDestRle)[0] = static_cast<uint16>(nSrcWidth);
		reinterpret_cast<uint16*>(pDestRle)[1] = static_cast<uint16>(nSrcHeight);
		dest += 4; pcount = dest++; count = 0; ptr = 5;

		for(y = 0; y < nSrcHeight && ptr < nDestMaxLen; y++)
		{
			bprev = pCallback(src[0], 0, 0, pUserData);
			for(x = 0; x < nSrcWidth && ptr < nDestMaxLen; x++, src++)
			{
				bcur = pCallback(*src, x, y, pUserData);
				if (bcur == bprev)
				{
					// 相同的透明度，则增加计数
					count++;
					if (!bcur)
					{
						// 不透明，则写入目标值
						*dest++ = *src; ptr++;
					}
					if (count == 0x7f || x == nSrcWidth-1)
					{
						// 到达最大的计数值，先写入
						*pcount = bcur ? 0x80|count : count;
						count = 0; pcount = dest++; ptr++;
					}
				}
				else
				{
					*pcount = (bprev ? 0x80 : 0x00) | count;
					bprev = bcur; count = 1;
					pcount = dest++; ptr++;
					if (!bcur && ptr < nDestMaxLen)
					{
						// 不透明
						*dest++ = *src; ptr++;
					}
				}
				if(ptr == nDestMaxLen)
					// 边界情况:最后一组写入
					*pcount =  bcur ? 0x80 | count : count;
			}
		}

		if (y < nSrcHeight || x < nSrcWidth)
			return PAL_NOT_ENOUGH_SPACE;
	}
	else
	{
		// 只计算长度
		count = 0; ptr = 5;

		bprev = pCallback(src[0], 0, 0, pUserData);
		for(y = 0; y < nSrcHeight; y++)
		{
			for(x = 0; x < nSrcWidth; x++, src++)
			{
				bcur = pCallback(*src, x, y, pUserData);
				if (bcur == bprev)
				{
					// 相同的透明度，则增加计数
					count++;
					if (!bcur)
						ptr++;	// 不透明
					if (count == 0x7f || x == nSrcWidth-1)
					{
						// 到达最大的计数值
						count = 0; ptr++;
					}
				}
				else
				{
					bprev = bcur; count = 1; ptr++;
					if (!bcur)
						ptr++;	// 不透明
				}
			}
		}
	}
	nDestLen = ptr;

	return PAL_OK;
}

/*
errno_t Pal::Tools::DecodeRLE(const void *Rle, void *Destination, sint32 Stride, sint32 Width, sint32 Height, sint32 x, sint32 y)
{
	sint32 sx, sy, dx, dy, temp;
	uint16 rle_width, rle_height;
	uint8  count, cnt;
	uint8* dest;
	uint8* ptr;

	//检查输入参数
	if (Rle == NULL || Destination == NULL)
		return EINVAL;
	//取 RLE 图像的宽度和高度
	rle_width = *(uint16*)Rle;
	rle_height = *((uint16*)Rle + 1);
	ptr = (uint8*)Rle + 4;
	//检查 RLE 图像能否显示到指定的图像中
	if (Width <= 0 || Height <= 0 || x + rle_width < 0 || x >= Width || y + rle_height < 0 || y >= Height)
		return 0;

	//跳过由于 y < 0 导致的不能显示的部分
	for(sy = 0, dy = y; dy < 0; dy++, sy++)
		for(sx = 0; sx < rle_width;)
		{
			count = *ptr++;
			sx += count & 0x7f;
			if (count < 0x80)
				ptr += count;
		}
	//设置目标区域指针
	dest = (uint8*)Destination + dy * Stride;
	//填充目标区域
	for(; dy < Height && sy < rle_height; dy++, sy++, dest += Stride)
	{
		//跳过由于 x < 0 导致的不能显示的部分
		for(count = 0, dx = x; dx < 0;)
		{
			count = *ptr++;
			if (count < 0x80)
			{
				ptr += count;
				if ((dx += count) >= 0)
				{
					//不透明像素需要部分显示，将ptr和count置成正确的值
					ptr -= dx;
					count = dx;
					dx = 0;
				}
			}
			else
				dx += count & 0x7f;
		}
		//检查是否已经越过目标图像边界
		if ((temp = Width - dx) > 0)
		{
			//填充目标图像
			if (count < 0x80 && count > 0)
			{
				//不透明部分
				if (count > temp)
					cnt = temp;
				else
					cnt = count;
				//填充
				memcpy(dest + dx, ptr, cnt);
				dx += cnt;
				//调整源指针
				ptr += count;
			}
			//填充该行剩下的部分
			for(sx = dx - x; sx < rle_width && dx < Width;)
			{
				//取次数
				count = *ptr++;
				if (count < 0x80)
				{
					//不透明部分，处理同上
					if (count > Width - dx)
						cnt = Width - dx;
					else
						cnt = count;
					//填充
					memcpy(dest + dx, ptr, cnt);
					dx += cnt;
					//调整源指针和源 x 值
					ptr += count;
					sx += count;
				}
				else
				{
					//透明部分
					count &= 0x7f;
					//调整源指针和源、目标 x 值
					sx += count;
					dx += count;
				}
			}
		}
		//调整源指针，使指针指向下一行
		while(sx < rle_width)
		{
			count = *ptr++;
			if (count < 0x80)
			{
				ptr += count;
				sx += count;
			}
			else
				sx += count & 0x7f;
		}
	}
	return 0;
}

errno_t Pal::Tools::EncodeRLE(const void *Source, const void *Base, sint32 Stride, sint32 Width, sint32 Height, void*& Destination, uint32& Length)
{
	sint32 i, j, count;
	uint32 length;
	uint8* src = (uint8*)Source;
	uint8* base = (uint8*)Base;
	uint8* temp;
	uint8* ptr;

	if (Source == NULL || Base == NULL)
		return EINVAL;
	if ((ptr = temp = (uint8*)malloc(Width * Height * 2)) == NULL)
		return ENOMEM;

	for(i = 0, ptr = temp + 4; i < Height; i++)
	{
		for(j = 0; j < Width;)
		{
			for(count = 0; j < Width && *src == *base; j++, base++, src++, count++);
			while(count > 0)
			{
				*ptr++ = (count > 0x7f) ? 0xff : count;
				count -= 0x7f;
			}
			for(count = 0; j < Width && *src != *base; j++, base++, src++, count++);
			while(count > 0)
			{
				if (count > 0x7f)
				{
					*ptr++ = 0x7f;
					memcpy(src - count, ptr, 0x7f);
					ptr += 0x7f;
				}
				else
				{
					*ptr++ = count;
					memcpy(src - count, ptr, count);
					ptr += count;
				}
				count -= 0x7f;
			}
		}
		src += Stride - Width;
		base += Stride - Width;
	}
	length = (uint32)(ptr - temp);

	if ((Destination = realloc(temp, length)) == NULL)
	{
		free(temp);
		return ENOMEM;
	}
	*((uint16*)Destination) = (uint16)Width;
	*((uint16*)Destination + 1) = (uint16)Height;
	Length = length;
	return 0;
}

errno_t Pal::Tools::EncodeRLE(const void *Source, const uint8 TransparentColor, sint32 Stride, sint32 Width, sint32 Height, void*& Destination, uint32& Length)
{
	sint32 i, j, count;
	uint32 length;
	uint8* src = (uint8*)Source;
	uint8* temp;
	uint8* ptr;

	if (Source == NULL)
		return EINVAL;
	if ((ptr = temp = (uint8*)malloc(Width * Height * 2 + 4)) == NULL)
		return ENOMEM;

	for(i = 0, ptr = temp + 4; i < Height; i++)
	{
		for(j = 0; j < Width;)
		{
			for(count = 0; j < Width && *src == TransparentColor; j++, src++, count++);
			while(count > 0)
			{
				*ptr++ = (count > 0x7f) ? 0xff : count;
				count -= 0x7f;
			}
			for(count = 0; j < Width && *src != TransparentColor; j++, src++, count++);
			while(count > 0)
			{
				if (count > 0x7f)
				{
					*ptr++ = 0x7f;
					memcpy(src - count, ptr, 0x7f);
					ptr += 0x7f;
				}
				else
				{
					*ptr++ = count;
					memcpy(src - count, ptr, count);
					ptr += count;
				}
				count -= 0x7f;
			}
		}
		src += Stride - Width;
	}
	length = (uint32)(ptr - temp);

	if ((Destination = realloc(temp, length)) == NULL)
	{
		free(temp);
		return ENOMEM;
	}
	*((uint16*)Destination) = (uint16)Width;
	*((uint16*)Destination + 1) = (uint16)Height;
	Length = length;
	return 0;
}
*/
