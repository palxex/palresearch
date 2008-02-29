//$ Id: yj1.cpp 1.02 2006-05-24 14:34:50 +8:00 $

/*
 * PAL(DOS) Compress Library
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
 *《仙剑奇侠传》DOS版(YJ_1)版压缩文件格式处理库
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
/*
YJ_1编码 & 解码程序 Version 1.0, Copyright by Lou Yihua
YJ_1解码程序根据鲁痴兄的Deyj1.h修改而来
YJ_1编码程序根据文件末尾附带的“YJ_1编码详解”编写

YJ_1编码过程：
1、将输入数据流按0x4000(16K)大小进行分块；
2、对每一块进行LZSS编码；
3、使用整个输入数据流中所有末经LZSS编码的字节构建Huffman编码树；
4、使用此Huffman编码树对所有未经LZSS编码的字节进行编码；
5、将Huffman编码树、LZSS特征信息及编码后的数据流输出。

YJ_1解码过程：
1、构造Huffman编码树；
2、对于每一个16K的块，根据输入数据进行Huffman或者LZSS解码。
*/

#include <stdio.h>
#include <memory.h>

#include "pallibrary.h"
using namespace PalLibrary;

typedef struct _TreeNode
{
	unsigned char	value;
	bool			leaf;
	unsigned short	level;
	unsigned int	weight;

	struct _TreeNode	*parent;
	struct _TreeNode	*left;
	struct _TreeNode	*right;

} TreeNode;

typedef struct _TreeNodeList
{
	TreeNode	*node;
	struct _TreeNodeList	*next;
} TreeNodeList;

typedef struct _YJ_1_FILEHEADER
{
	unsigned int	Signature;		//YJ_1文件标识'YJ_1'
	unsigned int	UncompressedLength;	//压缩前长度
	unsigned int	CompressedLength;	//压缩后长度
	unsigned short	BlockCount;		//划分为16K块的数目
	unsigned char	Unknown;		//未知数据，可能仅为填充使用
	unsigned char	HuffmanTreeLength;	//HUFFMAN编码树的长度，为实际存储长度的1/2
} YJ_1_FILEHEADER, *PYJ_1_FILEHEADER;

typedef struct _YJ_1_BLOCKHEADER
{
	unsigned short	UncompressedLength;		//本块压缩前长度，最大为0x4000
	unsigned short	CompressedLength;		//本块压缩后长度，含块头
	unsigned short	LZSSRepeatTable[4];		//LZSS重复次数表
	unsigned char	LZSSOffsetCodeLengthTable[4];	//LZSS偏移量编码长度表
	unsigned char	LZSSRepeatCodeLengthTable[3];	//LZSS重复次数编码长度表
	unsigned char	CodeCountCodeLengthTable[3];	//同类编码的编码数的编码长度表
	unsigned char	CodeCountTable[2];		//同类编码的编码数表
} YJ_1_BLOCKHEADER, *PYJ_1_BLOCKHEADER;

static inline unsigned int get_bits(const void *src, unsigned int &bitptr, unsigned int count)
{
	unsigned short *temp = ((unsigned short *)src) + (bitptr >> 4);
	unsigned int bptr = bitptr & 0xf;
	unsigned short mask;
	bitptr += count;
	if (count > 16 - bptr)
	{
		count = count + bptr - 16;
		mask = 0xffff >> bptr;
		return ((*temp & mask) << count) | (temp[1] >> (16 - count));
	}
	else
		return ((unsigned short)(*temp << bptr)) >> (16 - count);
}

static inline unsigned short get_loop(const void *src, unsigned int &bitptr, PYJ_1_BLOCKHEADER header)
{
	if (get_bits(src, bitptr, 1))
		return header->CodeCountTable[0];
	else
	{
		unsigned int temp = get_bits(src, bitptr, 2);
		if (temp)
			return get_bits(src, bitptr, header->CodeCountCodeLengthTable[temp - 1]);
		else
			return header->CodeCountTable[1];
	}
}

static inline unsigned short get_count(const void *src, unsigned int &bitptr, PYJ_1_BLOCKHEADER header)
{
	unsigned short temp;
	if (temp = get_bits(src, bitptr, 2))
	{
		if (get_bits(src, bitptr, 1))
			return get_bits(src, bitptr, header->LZSSRepeatCodeLengthTable[temp - 1]);
		else
			return header->LZSSRepeatTable[temp];
	}
	else
		return header->LZSSRepeatTable[0];
}

PalLibrary::DataBuffer PalLibrary::DecodeYJ_1(const void *Source)
{
	PYJ_1_FILEHEADER hdr = (PYJ_1_FILEHEADER)Source;
	unsigned char *src = (unsigned char *)Source;
	unsigned char *dest;
	unsigned int i;
	TreeNode *root, *node;
	DataBuffer buf = {NULL, 0};

	if (hdr->Signature != '1_JY')
		return buf;
	buf.data = dest = new unsigned char [hdr->UncompressedLength];
	buf.length = hdr->UncompressedLength;

	do
	{
		unsigned short tree_len = ((unsigned short)hdr->HuffmanTreeLength) << 1;
		unsigned int bitptr = 0;
		unsigned char *flag = (unsigned char *)src + 16 + tree_len;

		node = root = new TreeNode [tree_len + 1];
		root[0].leaf = false;
		root[0].value = 0;
		root[0].left = root + 1;
		root[0].right = root + 2;
		for(i = 1; i <= tree_len; i++)
		{
			root[i].leaf = !get_bits(flag, bitptr, 1);
			root[i].value = src[15 + i];
			if (root[i].leaf)
				root[i].left = root[i].right = NULL;
			else
			{
				root[i].left =  root + (root[i].value << 1) + 1;
				root[i].right = root[i].left + 1;
			}
		}
		src += 16 + tree_len + (((tree_len & 0xf) ? (tree_len >> 4) + 1 : (tree_len >> 4)) << 1);
	} while(0);

	for(i = 0; i < hdr->BlockCount; i++)
	{
		unsigned int bitptr;
		PYJ_1_BLOCKHEADER header;

		header = (PYJ_1_BLOCKHEADER)src; src += 4;
		if (!header->CompressedLength)
		{
			while(--header->UncompressedLength)
				*dest++ = *src++;
			continue;
		}
		src += 20; bitptr = 0;
		for(;;)
		{
			unsigned short loop;
			if ((loop = get_loop(src, bitptr, header)) == 0)
				break;

			while(loop--)
			{
				node = root;
				for(; !node->leaf;)
				{
					if (get_bits(src, bitptr, 1))
						node = node->right;
					else
						node = node->left;
				}
				*dest++ = node->value;
			}

			if ((loop = get_loop(src, bitptr, header)) == 0)
				break;

			while(loop--)
			{
				unsigned int pos, count;
				count = get_count(src, bitptr, header);
				pos = get_bits(src, bitptr, 2);
				pos = get_bits(src, bitptr, header->LZSSOffsetCodeLengthTable[pos]);
				while(count--)
				{
					*dest = *(dest - pos);
					dest++;
				}
			}
		}
		src = ((unsigned char *)header) + header->CompressedLength;
	}
	delete [] root;
	return buf;
}

static inline unsigned short get_bit_count(unsigned int word)
{
	unsigned short bits = 0;
	while(word)
	{
		bits++;
		word >>= 1;
	}
	return bits;
}

static inline unsigned int lz_analysize(unsigned char *base, unsigned short *result, unsigned int block_len, unsigned int freq[])
{
	int	head[0x100], prev[0x4000];
	unsigned int ptr, dptr, baseptr;

	memset(head, 0xff, 0x100 * sizeof(int));
	memset(prev, 0xff, 0x4000 * sizeof(int));
	for(ptr = 0; ptr < block_len - 1; ptr++)
	{
		unsigned char hash = base[ptr] ^ base[ptr + 1];
		if (head[hash] >= 0)
			prev[ptr] = head[hash];
		head[hash] = ptr;
	}

	result[0] = 0; dptr = 1;
	for(baseptr = ptr = 0; ptr < block_len;)
	{
		unsigned short match_len;
		int prv, tmp;

		match_len = 0; tmp = ptr;
		while((tmp = prev[tmp]) >= 0)
		{
			unsigned short match_len_t = 0;
			int prv_t, cur_t;

			prv_t = tmp; cur_t = ptr;
			while(base[prv_t++] == base[cur_t++] && match_len_t + ptr < block_len)
				match_len_t++;
			if (match_len_t > 1 && match_len < match_len_t)
			{
				match_len = match_len_t;
				prv = tmp;
			}
		}
		if (match_len > 1 && match_len < 5)
		{
			unsigned short bit_count = 5 + get_bit_count(match_len) + get_bit_count(ptr - prv);
			if (bit_count > (match_len << 3))
				match_len = 1;
		}
		if (match_len > 1)
		{
			if (result[baseptr] > 0x8000 && result[baseptr] < 0xffff)
				result[baseptr]++;
			else
			{
				baseptr = dptr++;
				result[baseptr] = 0x8001;
			}
			result[dptr++] = match_len;
			result[dptr++] = ptr - prv;
			ptr += match_len;
		}
		else
		{
			if (!result[baseptr])
				result[baseptr] = 0x1;
			else if (result[baseptr] < 0x7fff)
				result[baseptr]++;
			else
			{
				baseptr = dptr++;
				result[baseptr] = 0x1;
			}
			freq[base[ptr++]]++;
		}
	}
	return dptr << 1;
}

static inline unsigned int cb_analysize(PYJ_1_BLOCKHEADER header, unsigned short block[], unsigned int cb_len)
{
	int i, j, min, max, total, total_min, total_bits, count_len[15], total_len[15];
	unsigned int ptr;

	do
	{
		unsigned int count[0x100];
		unsigned char max1, max2;
		memset(count, 0, 0x100 * sizeof(int));
		memset(count_len, 0, 15 * sizeof(int));
		memset(total_len, 0, 15 * sizeof(int));
		max1 = max2 = 0;
		for(ptr = 0; ptr < (cb_len >> 1); ptr++)
		{
			unsigned short temp = block[ptr] & 0x7fff;
			if (temp < 0x100)
			{
				count[temp]++;
				if (count[max1] < count[temp])
				{
					max2 = max1;
					max1 = (unsigned char)temp;
				}
				else if (count[max2] < count[temp] && temp != max1)
					max2 = (unsigned char)temp;
			}
			count_len[get_bit_count(temp)]++;
			if (block[ptr] & 0x8000)
				ptr += temp << 1;
		}
		header->CodeCountTable[0] = max1;
		if (max2)
			header->CodeCountTable[1] = max2;
		else
			header->CodeCountTable[1] = max1;
		total_bits = count[max1] + count[max2] * 3;
		count_len[get_bit_count(max1)] -= count[max1];
		count_len[get_bit_count(max2)] -= count[max2];
		for(max = 14; !count_len[max] && max > 0; max--);
		for(min = 1; !count_len[min] && min < 15; min++);
		if (max < min)
		{
			header->CodeCountCodeLengthTable[0] =
			header->CodeCountCodeLengthTable[1] =
			header->CodeCountCodeLengthTable[2] = 0;
			break;
		}
		for(i = min; i <= max; i++)
			total_len[i] = total_len[i - 1] + count_len[i];
		header->CodeCountCodeLengthTable[0] = min;
		header->CodeCountCodeLengthTable[1] =
		header->CodeCountCodeLengthTable[2] = max;
		total_min = total_len[min] * min + (total_len[max] - total_len[min]) * max;
		for(i = min; i < max - 1; i++)
			if (count_len[i])
			{
				for(j = i + 1; j < max; j++)
					if (count_len[j])
					{
						total = total_len[i] * i + (total_len[j] - total_len[i]) * j + (total_len[max] - total_len[j]) * max;
						if (total < total_min)
						{
							total_min = total;
							header->CodeCountCodeLengthTable[0] = i;
							header->CodeCountCodeLengthTable[1] = j;
						}
					}
			}
		total_bits += total_min + total_len[max] * 3;
	} while(0);

	do
	{
		unsigned int count[0x4000], tmp, maxs[4];
		memset(maxs, 0, 4 * sizeof(int));
		memset(count, 0, 0x4000 * sizeof(int));
		memset(count_len, 0, 15 * sizeof(int));
		memset(total_len, 0, 15 * sizeof(int));
		for(ptr = 0; ptr < (cb_len >> 1);)
		{
			unsigned short temp = block[ptr] & 0x7fff;
			if (block[ptr++] & 0x8000)
				for(i = 0; i < temp; i++)
				{
					tmp = block[ptr++]; ptr++; count[tmp]++;
					count_len[get_bit_count(tmp)]++;
					if (count[maxs[0]] < count[tmp])
					{
						for(j = 1; j < 4; j++)
							if (tmp == maxs[j])
							{
								maxs[j] = maxs[0];
								maxs[0] = tmp;
								break;
							}
						if (j == 4)
						{
							maxs[3] = maxs[2]; maxs[2] = maxs[1];
							maxs[1] = maxs[0]; maxs[0] = tmp;
						}
					}
					else if (count[maxs[1]] < count[tmp] && tmp != maxs[0])
					{
						for(j = 2; j < 4; j++)
							if (tmp == maxs[j])
							{
								maxs[j] = maxs[1]; maxs[1] = tmp;
								break;
							}
						if (j == 4)
						{
							maxs[3] = maxs[2]; maxs[2] = maxs[1]; maxs[1] = tmp;
						}
					}
					else if (count[maxs[2]] < count[tmp] && tmp != maxs[0] && tmp != maxs[1])
					{
						maxs[3] = maxs[2]; maxs[2] = tmp;
					}
					else if (count[maxs[3]] < count[tmp] && tmp != maxs[0] && tmp != maxs[1] && tmp != maxs[2])
						maxs[3] = tmp;
				}
		}
		total_bits += (count[maxs[0]] << 1) + (count[maxs[1]] + count[maxs[2]] + count[maxs[3]]) * 3;
		do
		{
			int lastmax = maxs[0];
			for(i = 0; i < 4; i++)
			{
				if (maxs[i])
				{
					count_len[get_bit_count(maxs[i])] -= count[maxs[i]];
					header->LZSSRepeatTable[i] = maxs[i];
					lastmax = maxs[i];
				}
				else
					header->LZSSRepeatTable[i] = lastmax;
			}
		} while(0);
		for(max = 14; !count_len[max] && max > 0; max--);
		for(min = 1; !count_len[min] && min < 15; min++);
		if (max < min)
		{
			header->LZSSRepeatCodeLengthTable[0] =
			header->LZSSRepeatCodeLengthTable[1] =
			header->LZSSRepeatCodeLengthTable[2] = 0;
			break;
		}
		for(i = min; i <= max; i++)
			total_len[i] = total_len[i - 1] + count_len[i];
		header->LZSSRepeatCodeLengthTable[0] = min;
		header->LZSSRepeatCodeLengthTable[1] =
		header->LZSSRepeatCodeLengthTable[2] = max;
		total_min = total_len[min] * min + (total_len[max] - total_len[min]) * max;
		for(i = min; i < max - 1; i++)
			if (count_len[i])
			{
				for(j = i + 1; j < max; j++)
					if (count_len[j])
					{
						total = total_len[i] * i + (total_len[j] - total_len[i]) * j + (total_len[max] - total_len[j]) * max;
						if (total < total_min)
						{
							total_min = total;
							header->LZSSRepeatCodeLengthTable[0] = i;
							header->LZSSRepeatCodeLengthTable[1] = j;
						}
					}
			}
		total_bits += total_min + total_len[max] * 3;
	} while(0);

	do
	{
		int k, tmp;
		memset(count_len, 0, 15 * sizeof(int));
		memset(total_len, 0, 15 * sizeof(int));
		for(ptr = 0; ptr < (cb_len >> 1);)
		{
			unsigned short temp = block[ptr] & 0x7fff;
			if (block[ptr++] & 0x8000)
				for(i = 0; i < temp; i++)
				{
					ptr++; tmp = block[ptr++];
					count_len[get_bit_count(tmp)]++;
				}
		}
		for(max = 14; !count_len[max] && max > 0; max--);
		for(min = 1; !count_len[min] && min < 15; min++);
		if (max < min)
		{
			header->LZSSOffsetCodeLengthTable[0] =
			header->LZSSOffsetCodeLengthTable[1] =
			header->LZSSOffsetCodeLengthTable[2] =
			header->LZSSOffsetCodeLengthTable[3] = 0;
			break;
		}
		for(i = min; i <= max; i++)
			total_len[i] = total_len[i - 1] + count_len[i];
		header->LZSSOffsetCodeLengthTable[0] = min;
		header->LZSSOffsetCodeLengthTable[2] =
		header->LZSSOffsetCodeLengthTable[3] = max;
		for(i = min + 1; i < max; i++)
			if (count_len[i])
			{
				header->LZSSOffsetCodeLengthTable[1] = i;
				break;
			}
		if (i < max)
			total_min = total_len[min] * min + (total_len[i] - total_len[min]) * i + (total_len[max] - total_len[i]) * max;
		else
		{
			header->LZSSOffsetCodeLengthTable[1] = min;
			total_min = total_len[min] * min + (total_len[max] - total_len[min]) * max;
		}
		for(i = min; i < max - 2; i++)
			if (count_len[i])
			{
				for(j = i + 1; j < max - 1; j++)
					if (count_len[j])
					{
						for(k = j + 1; k < max; k++)
							if (count_len[k])
							{
								total = total_len[i] * i + (total_len[j] - total_len[i]) * j +
									(total_len[k] - total_len[j]) * k + (total_len[max] - total_len[k]) * max;
								if (total < total_min)
								{
									total_min = total;
									header->LZSSOffsetCodeLengthTable[0] = i;
									header->LZSSOffsetCodeLengthTable[1] = j;
									header->LZSSOffsetCodeLengthTable[2] = k;
								}
							}
					}
			}
		total_bits += total_min + total_len[max] * 2;
	} while(0);

	return total_bits;
}

static inline void list_insert(TreeNodeList *&head, TreeNode *node)
{
	TreeNodeList *list, *temp;
	if (!head)
	{
		head = new TreeNodeList;
		head->next = NULL;
		head->node = node;
		return;
	}

	for(list = head; list->next; list = list->next)
		if (list->node->weight <= node->weight && list->next->node->weight > node->weight)
		{
			temp = new TreeNodeList;
			temp->next = list->next;
			list->next = temp;
			temp->node = node;
			break;
		}
	if (!list->next)
	{
		list->next = new TreeNodeList;
		list->next->next = NULL;
		list->next->node = node;
	}
}

static inline void list_delete(TreeNodeList *&head, TreeNode *node)
{
	TreeNodeList *list, *temp;
	if (!head || !node)
		return;

	if (head->node == node)
	{
		temp = head;
		head = head->next;
		delete temp;
		return;
	}

	for(list = head; list->next; list = list->next)
	{
		if (list->next->node == node)
		{
			temp = list->next;
			list->next = temp->next;
			list = NULL;
			delete temp;
			break;
		}
	}
}

static inline TreeNode *build_tree(unsigned int freq[])
{
	TreeNode	*root, *node;
	TreeNodeList	*head = NULL;
	unsigned int i;

	for(i = 0; i < 0x100; i++)
		if (freq[i])
		{
			node = new TreeNode;
			node->leaf = true;
			node->value = (unsigned char)i;
			node->weight = freq[i];
			node->left = node->right = NULL;
			list_insert(head, node);
		}

	if (!head)
		return NULL;

	if (!head->next)
	{
		root = new TreeNode;
		root->left = head->node;
		root->right = new TreeNode;
		root->right->leaf = true;
		root->right->left = root->right->right = NULL;
		root->leaf = false;
		root->value = 0;
		root->right->value = ~head->node->value;
		root->left->parent = root->right->parent = root;
		root->parent = NULL;
		delete head;
		return root;
	}

	for(; head->next;)
	{
		node = new TreeNode;
		node->left = head->node;
		node->right = head->next->node;
		node->weight = node->left->weight + node->right->weight;
		node->leaf = false;
		node->value = 0;
		node->left->parent = node->right->parent = node;
		list_delete(head, node->left);
		list_delete(head, node->right);
		list_insert(head, node);
	}
	root = head->node;
	root->parent = NULL;
	delete head;

	return root;
}

static inline void traverse_tree(TreeNode *root, unsigned int level, unsigned int &nodes)
{
	if (!level)
		nodes = 0;
	else
		nodes++;
	root->level = level;

	if (root->leaf)
		return;

	traverse_tree(root->left, level + 1, nodes);
	traverse_tree(root->right, level + 1, nodes);
}

static inline unsigned int traverse_tree(TreeNode *root, unsigned int level, unsigned int *freq)
{
	if (root->leaf)
		return level * freq[root->value];

	return traverse_tree(root->left, level + 1, freq) + traverse_tree(root->right, level + 1, freq);
}

static inline void set_bit(void *dest, unsigned int &bitptr, bool bit)
{
	unsigned short *temp = ((unsigned short *)dest) + (bitptr >> 4);
	unsigned int bptr = 15 - (bitptr & 0xf);
	unsigned short mask = 1 << bptr;
	if (bit)
		*temp |= mask;
	else
		*temp &= ~mask;
	bitptr++;
}

static inline void set_bits(void *dest, unsigned int &bitptr, unsigned int data, unsigned int count)
{
	unsigned short *temp = ((unsigned short *)dest) + (bitptr >> 4), tmp;
	unsigned int bptr = bitptr & 0xf, cnt;
	unsigned short mask;
	bitptr += count;
	if (count > 16 - bptr)
	{
		cnt = count + bptr - 16;
		mask = 0xffff << (16 - bptr);
		*temp = (*temp & mask) | ((unsigned short)(data >> cnt) & (unsigned short)(0xffff >> bptr));
		temp[1] = (temp[1] & (unsigned short)(0xffff >> cnt)) | (unsigned short)(data << (16 - cnt));
	}
	else
	{
		cnt = 16 - count - bptr;
		tmp = (data & (0xffff >> (16 - count))) << cnt;
		*temp = (*temp & (unsigned short)(~((0xffff >> bptr) & (0xffff << cnt)))) | tmp;
	}
}

static void set_loop(void *dest, unsigned int &ptr, unsigned int count, PYJ_1_BLOCKHEADER header)
{
	if (count == header->CodeCountTable[0])
		set_bit(dest, ptr, 1);
	else
	{
		set_bit(dest, ptr, 0);
		if (count == header->CodeCountTable[1])
			set_bits(dest, ptr, 0, 2);
		else
		{
			unsigned short cnt = get_bit_count(count);
			unsigned int j;
			for(j = 0; j < 3; j++)
				if (cnt <= header->CodeCountCodeLengthTable[j])
				{
					set_bits(dest, ptr, j + 1, 2);
					set_bits(dest, ptr, count, header->CodeCountCodeLengthTable[j]);
					return;
				}
		}
	}
}

static void set_count(void *dest, unsigned int &ptr, unsigned int match_len, PYJ_1_BLOCKHEADER header)
{
	unsigned int k;
	unsigned short cnt;
	for(k = 0; k < 4; k++)
		if (match_len == header->LZSSRepeatTable[k])
		{
			set_bits(dest, ptr, k, 2);
			if (k > 0)
				set_bit(dest, ptr, 0);
			return;
		}
	cnt = get_bit_count(match_len);
	for(k = 0; k < 3; k++)
		if (cnt <= header->LZSSRepeatCodeLengthTable[k])
		{
			set_bits(dest, ptr, k + 1, 2);
			set_bit(dest, ptr, 1);
			set_bits(dest, ptr, match_len, header->LZSSRepeatCodeLengthTable[k]);
			return;
		}
}

PalLibrary::DataBuffer PalLibrary::EncodeYJ_1(const void *Source, unsigned int SourceLength)
{
	YJ_1_FILEHEADER hdr;
	PYJ_1_BLOCKHEADER header;
	unsigned short code[0x100][0x10];
	unsigned int freq[0x100];
	unsigned int *cb_len, *lz_len, **bfreq;
	unsigned int tree_nodes;
	unsigned char **block;
	unsigned char *src = (unsigned char *)Source, *dest;
	int srclen = SourceLength;
	TreeNode	*root, *leaf[0x100];
	DataBuffer	buf;

	hdr.Signature = '1_JY';
	hdr.UncompressedLength = srclen;
	hdr.CompressedLength = 0;
	hdr.BlockCount = (srclen & 0x3fff) ? (srclen >> 14) + 1 : (srclen >> 14);
	hdr.Unknown = 0xff;
	hdr.HuffmanTreeLength = 0;

	memset(freq, 0, 0x100 * sizeof(int));
	memset(code, 0, 0x100 * 0x10 * sizeof(short));
	memset(leaf, 0, 0x100 * sizeof(TreeNode*));
	bfreq = new unsigned int * [hdr.BlockCount];
	block = new unsigned char * [hdr.BlockCount];
	cb_len = new unsigned int [hdr.BlockCount];
	lz_len = new unsigned int [hdr.BlockCount];
	header = new YJ_1_BLOCKHEADER [hdr.BlockCount];

	for(int i = 0; i < hdr.BlockCount; i++)
	{
		unsigned int	baseptr, j;
		unsigned char	*base;

		baseptr = i << 14; base = (unsigned char *)src + baseptr;
		header[i].UncompressedLength = (srclen - baseptr < 0x4000) ? srclen - baseptr : 0x4000;
		header[i].CompressedLength = sizeof(YJ_1_BLOCKHEADER);
		bfreq[i] = new unsigned int [0x100];
		block[i] = new unsigned char [0xa000];
		memset(bfreq[i], 0, 0x100 * sizeof(int));
		cb_len[i] = lz_analysize(base, (unsigned short *)block[i], header[i].UncompressedLength, bfreq[i]);
		lz_len[i] = cb_analysize(header + i, (unsigned short *)block[i], cb_len[i]);
		for(j = 0; j < 0x100; j++)
			freq[j] += bfreq[i][j];

		base = block[i];
		block[i] = new unsigned char [cb_len[i]];
		memcpy(block[i], base, cb_len[i]);
		delete [] base;
	}

	root = build_tree(freq);
	traverse_tree(root, 0, tree_nodes);
	hdr.HuffmanTreeLength = tree_nodes >> 1;
	hdr.CompressedLength = sizeof(YJ_1_FILEHEADER) + tree_nodes;
	if (tree_nodes & 0xf)
	{
		unsigned short _tmp = (tree_nodes >> 4) + 1;
		hdr.CompressedLength += _tmp << 1;
	}
	else
		hdr.CompressedLength += tree_nodes >> 3;
	for(int i = 0; i < hdr.BlockCount; i++)
	{
		unsigned int len = lz_len[i] + traverse_tree(root, 0, bfreq[i]);
		len += header[i].CodeCountCodeLengthTable[0] + 3;
		if (len & 0xf)
			len = (len >> 4) + 1;
		else
			len >>= 4;
		header[i].CompressedLength += len << 1;
		hdr.CompressedLength += header[i].CompressedLength;
	}

	buf.length = hdr.CompressedLength;
	buf.data = dest = new unsigned char [hdr.CompressedLength];
	memcpy(dest, &hdr, sizeof(YJ_1_FILEHEADER));
	dest += sizeof(YJ_1_FILEHEADER);
	do
	{
		unsigned int head = 0, tail = 0, ptr = 0, i;
		unsigned char *dst = dest + tree_nodes;
		TreeNode *queue[0x200], *node;

#define	put_in(v)	\
	if (tail < 0x1ff)	\
		queue[tail++] = (v);	\
	else	\
		queue[tail = 0] = (v)
#define	get_out(v)	\
	if (head < 0x1ff)	\
		(v) = queue[head++];	\
	else	\
		(v) = queue[head = 0]

		put_in(root->left);
		put_in(root->right);
		for(i = 0; i < tree_nodes;i++)
		{
			get_out(node);
			if (node->leaf)
			{
				leaf[node->value] = node;
				*dest++ = node->value;
			}
			else
			{
				*dest++ = tail >> 1;
				put_in(node->left);
				put_in(node->right);
			}
			set_bit(dst, ptr, !node->leaf);
		}

#undef	get_out
#undef	put_in

		if (ptr & 0xf)
		{
			i = ((ptr >> 4) + 1) << 4;
			for(; ptr < i;)
				set_bit(dst, ptr, 0);
		}
		dest += ptr >> 3;

		for(i = 0; i < 0x100; i++)
			if (leaf[i])
			{
				unsigned int k = 0;
				unsigned int hcode[0x8] = {0, 0, 0, 0, 0, 0, 0, 0};
				node = leaf[i];
				while(node->parent)
				{
					hcode[k >> 5] <<= 1;
					if (node == node->parent->right)
						hcode[k >> 5] |= 1;
					k++; node = node->parent;
				}
				for(k = 0; k < leaf[i]->level; k++)
				{
					code[i][k >> 4] <<= 1;
					code[i][k >> 4] |= hcode[k >> 5] & 0x1;
					hcode[k >> 5] >>= 1;
				}
			}

	} while(0);
	
	for(unsigned int i = 0; i < hdr.BlockCount; i++)
	{
		unsigned short *bptr = (unsigned short *)block[i], count, match_len, pos;
		unsigned char *base = (unsigned char *)src + (i << 14);
		unsigned char *dst = dest;
		unsigned int sptr = 0, ptr = 0, j;
		TreeNode *node;
		memcpy(dest, header + i, sizeof(YJ_1_BLOCKHEADER));
		dest += sizeof(YJ_1_BLOCKHEADER);
		while(sptr < header[i].UncompressedLength)
		{
			set_loop(dest, ptr, *bptr & 0x7fff, header + i);
			count = *bptr++;
			if (count & 0x8000)
			{
				count &= 0x7fff;
				for(j = 0; j < count; j++)
				{
					match_len = *bptr++;
					pos = *bptr++;
					sptr += match_len;
					set_count(dest, ptr, match_len, header + i);
					do
					{
						unsigned int k;
						unsigned short cnt = get_bit_count(pos);
						for(k = 0; k < 4; k++)
							if (cnt <= header[i].LZSSOffsetCodeLengthTable[k])
							{
								set_bits(dest, ptr, k, 2);
								set_bits(dest, ptr, pos, header[i].LZSSOffsetCodeLengthTable[k]);
								break;
							}
					} while(0);
				}
			}
			else
			{
				unsigned char val;
				unsigned int maxl;
				for(j = 0; j < count; j++)
				{
					val = base[sptr++];
					node = leaf[val];
					maxl = node->level >> 4;
					if (node->level & 0xf)
						set_bits(dest, ptr, code[val][maxl], node->level & 0xf);
					while(maxl--)
						set_bits(dest, ptr, code[val][maxl], 16);
				}
			}
		}
		set_loop(dest, ptr, 0, header + i);
		if (ptr & 0xf)
			set_bits(dest, ptr, 0, 16 - (ptr & 0xf));
		ptr >>= 3;
		dest += ptr;
	}

	for(int i = 0; i < hdr.BlockCount; i++)
	{
		delete [] block[i];
		delete [] bfreq[i];
	}
	delete [] block;
	delete [] lz_len;
	delete [] cb_len;
	delete [] header;
	return buf;
}
