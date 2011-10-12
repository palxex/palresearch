/*
 * PAL WIN95 compress format (YJ_2) library
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
 *《仙剑奇侠传》WIN95版压缩格式(YJ_2)处理库
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
/*
PAL95编解码程序（版本: 1.1）

编码过程：
1、使用LZSS算法对输入数据流进行编码；
2、在此基础上，使用自适应的Huffman算法对其进行二次编码。

解码过程：
1、使用自适应Huffman算法对输入数据流进行解码；
2、如果解码结果是由LZSS编码后的数据，则对其进行LZSS解码。
*/

#include <stdlib.h>
#include <memory.h>
#include <string.h>

#include "pallib.h"
using namespace Pal::Tools;

typedef struct _TreeNode
{
	uint16		weight;
	uint16		value;
	struct _TreeNode*	parent;
	struct _TreeNode*	left;
	struct _TreeNode*	right;
} TreeNode;

typedef struct _Tree
{
	TreeNode*	node;
	TreeNode**	list;
} Tree;

static uint8 data1[0x100] =
{
0x3f,0x0b,0x17,0x03,0x2f,0x0a,0x16,0x00,0x2e,0x09,0x15,0x02,0x2d,0x01,0x08,0x00,
0x3e,0x07,0x14,0x03,0x2c,0x06,0x13,0x00,0x2b,0x05,0x12,0x02,0x2a,0x01,0x04,0x00,
0x3d,0x0b,0x11,0x03,0x29,0x0a,0x10,0x00,0x28,0x09,0x0f,0x02,0x27,0x01,0x08,0x00,
0x3c,0x07,0x0e,0x03,0x26,0x06,0x0d,0x00,0x25,0x05,0x0c,0x02,0x24,0x01,0x04,0x00,
0x3b,0x0b,0x17,0x03,0x23,0x0a,0x16,0x00,0x22,0x09,0x15,0x02,0x21,0x01,0x08,0x00,
0x3a,0x07,0x14,0x03,0x20,0x06,0x13,0x00,0x1f,0x05,0x12,0x02,0x1e,0x01,0x04,0x00,
0x39,0x0b,0x11,0x03,0x1d,0x0a,0x10,0x00,0x1c,0x09,0x0f,0x02,0x1b,0x01,0x08,0x00,
0x38,0x07,0x0e,0x03,0x1a,0x06,0x0d,0x00,0x19,0x05,0x0c,0x02,0x18,0x01,0x04,0x00,
0x37,0x0b,0x17,0x03,0x2f,0x0a,0x16,0x00,0x2e,0x09,0x15,0x02,0x2d,0x01,0x08,0x00,
0x36,0x07,0x14,0x03,0x2c,0x06,0x13,0x00,0x2b,0x05,0x12,0x02,0x2a,0x01,0x04,0x00,
0x35,0x0b,0x11,0x03,0x29,0x0a,0x10,0x00,0x28,0x09,0x0f,0x02,0x27,0x01,0x08,0x00,
0x34,0x07,0x0e,0x03,0x26,0x06,0x0d,0x00,0x25,0x05,0x0c,0x02,0x24,0x01,0x04,0x00,
0x33,0x0b,0x17,0x03,0x23,0x0a,0x16,0x00,0x22,0x09,0x15,0x02,0x21,0x01,0x08,0x00,
0x32,0x07,0x14,0x03,0x20,0x06,0x13,0x00,0x1f,0x05,0x12,0x02,0x1e,0x01,0x04,0x00,
0x31,0x0b,0x11,0x03,0x1d,0x0a,0x10,0x00,0x1c,0x09,0x0f,0x02,0x1b,0x01,0x08,0x00,
0x30,0x07,0x0e,0x03,0x1a,0x06,0x0d,0x00,0x19,0x05,0x0c,0x02,0x18,0x01,0x04,0x00
};
static uint8 data2[0x10] =
{
0x08,0x05,0x06,0x04,0x07,0x05,0x06,0x03,0x07,0x05,0x06,0x04,0x07,0x04,0x05,0x03
};
static uint8 data3[0x40] =
{
0x07,0x0d,0x0b,0x03,0x1e,0x19,0x15,0x11,0x0e,0x09,0x05,0x01,0x3a,0x36,0x32,0x2a,
0x26,0x22,0x1a,0x16,0x12,0x0a,0x06,0x02,0x7c,0x78,0x74,0x6c,0x68,0x64,0x5c,0x58,
0x54,0x4c,0x48,0x44,0x3c,0x38,0x34,0x2c,0x28,0x24,0x1c,0x18,0x14,0x0c,0x08,0x04,
0xf0,0xe0,0xd0,0xc0,0xb0,0xa0,0x90,0x80,0x70,0x60,0x50,0x40,0x30,0x20,0x10,0x00
};
static uint8 data4[0x40] =
{
0x03,0x04,0x04,0x04,0x05,0x05,0x05,0x05,0x05,0x05,0x05,0x05,0x06,0x06,0x06,0x06,
0x06,0x06,0x06,0x06,0x06,0x06,0x06,0x06,0x07,0x07,0x07,0x07,0x07,0x07,0x07,0x07,
0x07,0x07,0x07,0x07,0x07,0x07,0x07,0x07,0x07,0x07,0x07,0x07,0x07,0x07,0x07,0x07,
0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08
};

static void adjust_tree(Tree tree, uint16 value)
{
	TreeNode* node = tree.list[value];
	TreeNode tmp;
	TreeNode* tmp1;
	TreeNode* temp;
	while(node->value != 0x280)
	{
		temp = node + 1;
		while(node->weight == temp->weight)
			temp++;
		temp--;
		if (temp != node)
		{
			tmp1 = node->parent;
			node->parent = temp->parent;
			temp->parent = tmp1;
			if (node->value > 0x140)
			{
				node->left->parent = temp;
				node->right->parent = temp;
			}
			else
				tree.list[node->value] = temp;
			if (temp->value > 0x140)
			{
				temp->left->parent = node;
				temp->right->parent = node;
			}
			else
				tree.list[temp->value] = node;
			tmp = *node; *node = *temp; *temp = tmp;
			node = temp;
		}
		node->weight++;
		node = node->parent;
	}
	node->weight++;
}

static bool build_tree(Tree& tree)
{
	sint32 i, ptr;
	TreeNode** list;
	TreeNode* node;
	if ((tree.list = list = new TreeNode* [321]) == NULL)
		return false;
	if ((tree.node = node = new TreeNode [641]) == NULL)
	{
		delete [] list;
		return false;
	}
	memset(list, 0, 321 * sizeof(TreeNode*));
	memset(node, 0, 641 * sizeof(TreeNode));
	for(i = 0; i <= 0x140; i++)
		list[i] = node + i;
	for(i = 0; i <= 0x280; i++)
	{
		node[i].value = i;
		node[i].weight = 1;
	}
	tree.node[0x280].parent = tree.node + 0x280;
	for(i = 0, ptr = 0x141; ptr <= 0x280; i += 2, ptr++)
	{
		node[ptr].left = node + i;
		node[ptr].right = node + i + 1;
		node[i].parent = node[i + 1].parent = node + ptr;
		node[ptr].weight = node[i].weight + node[i + 1].weight;
	}
	return true;
}

#pragma pack(1)
typedef struct _BitField
{
	uint8	b0:	1;
	uint8	b1:	1;
	uint8	b2:	1;
	uint8	b3:	1;
	uint8	b4:	1;
	uint8	b5:	1;
	uint8	b6:	1;
	uint8	b7:	1;
} BitField;
#pragma pack()

static inline bool bt(const void* data, uint32 pos)
{
	BitField* bit = (BitField*)((uint8*)data + (pos >> 3));
	switch(pos & 0x7)
	{
	case 0:	return bit->b0;
	case 1:	return bit->b1;
	case 2:	return bit->b2;
	case 3:	return bit->b3;
	case 4:	return bit->b4;
	case 5:	return bit->b5;
	case 6:	return bit->b6;
	case 7:	return bit->b7;
	}
	return 0;
}

static inline void bit(void* data, uint32 pos, bool set)
{
	BitField* bit = (BitField*)((uint8*)data + (pos >> 3));
	switch(pos & 0x7)
	{
	case 0:
		bit->b0 = set;
		break;
	case 1:
		bit->b1 = set;
		break;
	case 2:
		bit->b2 = set;
		break;
	case 3:
		bit->b3 = set;
		break;
	case 4:
		bit->b4 = set;
		break;
	case 5:
		bit->b5 = set;
		break;
	case 6:
		bit->b6 = set;
		break;
	case 7:
		bit->b7 = set;
		break;
	}
}

palerrno_t Pal::Tools::DecodeYJ2(const void* Source, void*& Destination, uint32& Length)
{
	uint32 len = 0, ptr = 0;
	uint8* src = (uint8*)Source + 4;
	uint8* dest;
	Tree tree;
	TreeNode* node;

	if (Source == NULL)
		return PAL_EMPTY_POINTER;

	if (!build_tree(tree))
		return PAL_OUT_OF_MEMORY;

	if ((Destination = malloc(*((uint32*)Source))) == NULL)
	{
		delete [] tree.list;
		delete [] tree.node;
		return PAL_OUT_OF_MEMORY;
	}
	Length = *((uint32*)Source);
	dest = (uint8*)Destination;

	while(1)
	{
		uint16 val;
		node = tree.node + 0x280;
		while(node->value > 0x140)
		{
			if (bt(src, ptr))
				node = node->right;
			else
				node = node->left;
			ptr++;
		}
		val = node->value;
		if (tree.node[0x280].weight == 0x8000)
		{
			sint32 i;
			for(i = 0; i < 0x141; i++)
				if (tree.list[i]->weight & 0x1)
					adjust_tree(tree, i);
			for(i = 0; i <= 0x280; i++)
				tree.node[i].weight >>= 1;
		}
		adjust_tree(tree, val);
		if (val > 0xff)
		{
			sint32 i;
			uint32 temp, tmp, pos;
			uint8* pre;
			for(i = 0, temp = 0; i < 8; i++, ptr++)
				temp |= (uint32)bt(src, ptr) << i;
			tmp = temp & 0xff;
			for(; i < data2[tmp & 0xf] + 6; i++, ptr++)
				temp |= (uint32)bt(src, ptr) << i;
			temp >>= data2[tmp & 0xf];
			pos = (temp & 0x3f) | ((uint32)data1[tmp] << 6);
			if (pos == 0xfff)
				break;
			pre = dest - pos - 1;
			for(i = 0; i < val - 0xfd; i++)
				*dest++ = *pre++;
			len += val - 0xfd;
		}
		else
		{
			*dest++ = (uint8)val;
			len++;
		}
	}
	delete [] tree.list;
	delete [] tree.node;
	return PAL_OK;
}

palerrno_t Pal::Tools::EncodeYJ2(const void* Source, uint32 SourceLength, void*& Destination, uint32& Length, bool bCompatible)
{
	uint32 len = 0, ptr, pos, top, srclen = SourceLength;
	sint32 head[0x100], _prev[0x2000];
	sint32* prev;
	sint32* pre;
	unsigned long dptr = 0;
	uint8* src = (uint8*)Source;
	uint8* dest;
	bool code[0x140];
	Tree tree;
	TreeNode* node;
	void* pNewData;

	if (Source == NULL)
		return PAL_EMPTY_POINTER;

	if (!build_tree(tree))
		return PAL_OUT_OF_MEMORY;

	if ((pNewData = malloc(SourceLength + 260)) == NULL)
	{
		delete [] tree.list;
		delete [] tree.node;
		return PAL_OUT_OF_MEMORY;
	}
	dest = (uint8*)pNewData + 4;

	pre = prev = _prev;
	memset(head, 0xff, 0x100 * sizeof(sint32));
	memset(prev, 0xff, 0x2000 * sizeof(sint32));
	prev += 0x1000;
	for(ptr = 0; ptr + 2 < srclen && ptr < 0x1000; ptr++)
	{
		uint8 hash = src[ptr] ^ src[ptr + 1] ^ src[ptr + 2];
		if (head[hash] >= 0)
			prev[ptr] = head[hash];
		head[hash] = ptr;
	}
	ptr = 0; top = 0x1000;
	while(ptr < srclen)
	{
		uint16 val = src[ptr];
		sint32 temp = (sint32)ptr, prv, cur;
		uint32 match_len_t, table, match = 0, match_len = 1;
		if (ptr >= top)
		{
			memmove(_prev, _prev + 0x1000, 0x1000 * sizeof(sint32));
			prev -= 0x1000; top += 0x1000;
			for(ptr = top - 0x1000; ptr + 2 < srclen && ptr < top; ptr++)
			{
				uint8 hash = src[ptr] ^ src[ptr + 1] ^ src[ptr + 2];
				if (head[hash] >= 0 && ptr - head[hash] < 0x1000)
					prev[ptr] = head[hash];
				head[hash] = ptr;
			}
			ptr = temp;
		}
		while((prv = prev[temp]) >= 0 && ptr - prev[temp] < 0x1000)
		{
			cur = ptr; match_len_t = 0;
			while(match_len_t < 67 && ptr + match_len_t < srclen && src[prv++] == src[cur++])
				match_len_t++;
			if (match_len_t >= 3 && match_len < match_len_t)
			{
				match_len = match_len_t;
				match = ptr - prev[temp] - 1;
				if (match_len == 67 || ptr + match_len >= srclen)
					break;
			}
			temp = prev[temp];
		}
		if (match_len >= 3)
			val = match_len + 0xfd;
		else
			match_len = 1;
		node = tree.list[val]; pos = 0;
		while(node->value != 0x280)
		{
			if (node->parent->left == node)
				code[pos++] = false;
			else
				code[pos++] = true;
			node = node->parent;
		}
		while(pos > 0)
			bit(dest, dptr++, code[--pos]);
		if (tree.node[0x280].weight == 0x8000)
		{
			sint32 i;
			for(i = 0; i < 0x141; i++)
				if (tree.list[i]->weight & 0x1)
					adjust_tree(tree, i);
			for(i = 0; i <= 0x280; i++)
				tree.node[i].weight >>= 1;
		}
		adjust_tree(tree, val);
		if (val > 0xff)
		{
			sint32 shift = 0;
			uint32 tmp = (match >> 6) & 0x3f;
			table = ((match << data4[tmp]) & 0xff) | data3[tmp];
			tmp = table | (((match & 0x3f) >> (8 - data2[table & 0xf])) << 8);
			while(shift < data2[table & 0xf] + 6)
			{
				bit(dest, dptr++, tmp & 0x1);
				shift++; tmp >>= 1;
			}
		}
		ptr += match_len;
	}
	node = tree.list[0x140]; pos = 0;
	while(node->value != 0x280)
	{
		if (node->parent->left == node)
			code[pos++] = false;
		else
			code[pos++] = true;
		node = node->parent;
	}
	top = pos;
	while(pos > 0)
		bit(dest, dptr++, code[--pos]);
	for(sint32 i = 0; i < 8; i++)
		bit(dest, dptr++, 0);
	for(sint32 i = 0; i < 6; i++)
		bit(dest, dptr++, 1);
	len = dptr >> 3;
	if (dptr & 0x7)
	{
		for(uint32 i = dptr & 0x7; i < 8; i++)
			bit(dest + len, i, 0);
		len++;
	}
	if (bCompatible)
	{
		uint32 temp = ((dptr - top - 14) >> 3) + 4;
		for(; len < temp && len + 4 < Length; len++)
			dest[len] = 0;
	}
	len += 4;

	if ((Destination = realloc(pNewData, len)) == NULL)
	{
		free(pNewData);
		delete [] tree.list;
		delete [] tree.node;
		return PAL_OUT_OF_MEMORY;
	}
	*((uint32*)Destination) = srclen;
	Length = len;

	delete [] tree.list;
	delete [] tree.node;

	return PAL_OK;
}

//#include "yj2sd.h"
//#include "yj2se.h"
