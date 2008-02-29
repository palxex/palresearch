/***********************************************
* PAL95压缩算法——By louyihua(SuperMouse)     *
* 简要说明：                                   *
* PAL95的压缩算法是一种修改的ZIP压缩算法，该算 *
* 法的压缩过程分两步进行：                     *
* 1、使用LZ77算法对原始数据进行压缩；          *
* 2、在此基础上，使用Huffman算法对其进行二次编 *
* 码，与GZIP不同的是，它使用的Huffman树是在压  *
* 缩或解压缩过程中动态构造的。                 *
* 关于压缩算法的一些说明：                     *
* 这里给出的压缩算法压缩后的数据与PAL95中的源  *
* 数据略有不同，但是同样可以使用解压缩函数正确 *
* 解出，压缩率比之有略微提高。                 *
* 由于时间限制，没有能够对目前PAL95中所有的数  *
* 进行测试，如果大家有时间请帮忙做些测试，如果 *
* 发现任何问题请通知我。                       *
************************************************/

//需要使用解压缩函数时请在头文件中包含下面这行
//int decompress(const unsigned char *src, unsigned char *dest);
//需要使用压缩函数时请在头文件中包含下面这行
//int compress(const unsigned char *src, unsigned char *dest, const int srclen);
#include <stdlib.h>
#include <memory.h>

typedef struct _TreeNode
{
	unsigned short		weight;
	unsigned short		value;
	struct _TreeNode	*parent;
	struct _TreeNode	*left;
	struct _TreeNode	*right;
} TreeNode;

typedef struct _Tree
{
	TreeNode			*node;
	TreeNode			**list;
} Tree;

static Tree build_tree(void);
static void adjust_tree(Tree tree, unsigned short value);

static inline bool bt(const void *data, unsigned int pos);
static inline void bit(void *data, unsigned int pos, bool set);

static unsigned char data1[0x100] =
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
static unsigned char data2[0x10] =
{
0x08,0x05,0x06,0x04,0x07,0x05,0x06,0x03,0x07,0x05,0x06,0x04,0x07,0x04,0x05,0x03
};
static unsigned char data3[0x40] =
{
0x07,0x0d,0x0b,0x03,0x1e,0x19,0x15,0x11,0x0e,0x09,0x05,0x01,0x3a,0x36,0x32,0x2a,
0x26,0x22,0x1a,0x16,0x12,0x0a,0x06,0x02,0x7c,0x78,0x74,0x6c,0x68,0x64,0x5c,0x58,
0x54,0x4c,0x48,0x44,0x3c,0x38,0x34,0x2c,0x28,0x24,0x1c,0x18,0x14,0x0c,0x08,0x04,
0xf0,0xe0,0xd0,0xc0,0xb0,0xa0,0x90,0x80,0x70,0x60,0x50,0x40,0x30,0x20,0x10,0x00
};
static unsigned char data4[0x40] =
{
0x03,0x04,0x04,0x04,0x05,0x05,0x05,0x05,0x05,0x05,0x05,0x05,0x06,0x06,0x06,0x06,
0x06,0x06,0x06,0x06,0x06,0x06,0x06,0x06,0x07,0x07,0x07,0x07,0x07,0x07,0x07,0x07,
0x07,0x07,0x07,0x07,0x07,0x07,0x07,0x07,0x07,0x07,0x07,0x07,0x07,0x07,0x07,0x07,
0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08,0x08
};

#include <stdio.h>

/****************************************************
 * 功能描述：解压缩主函数                           *
 * 参    数：src ---- 压缩后数据的首指针            *
 *           dest --- 存放解压缩后数据的首指针      *
 * 返 回 值：解压缩后数据的长度                     *
 ****************************************************/
int decompress(const unsigned char *src, unsigned char *dest)
{
	int len = 0, ptr = 0, max;
	Tree tree;
	TreeNode *node;
	tree = build_tree();
	max = *((unsigned int *)src); src += 4;

	while(1)
	{
		unsigned short val;
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
			int i;
			for(i = 0; i < 0x141; i++)
				if (tree.list[i]->weight & 0x1)
					adjust_tree(tree, i);
			for(i = 0; i <= 0x280; i++)
				tree.node[i].weight >>= 1;
		}
		adjust_tree(tree, val);
		if (val > 0xff)
		{
			unsigned int temp, tmp, pos;
			unsigned char *pre;
			temp = *((unsigned int *)(src + (ptr >> 3)));
			temp >>= (ptr & 0x7);
			tmp = temp & 0xff;
			temp >>= data2[tmp & 0xf];
			pos = (temp & 0x3f) | ((unsigned int)data1[tmp] << 6);
			if (pos == 0xfff)
				break;
			ptr += 6 + data2[tmp & 0xf];
			pre = dest - pos - 1;
			for(int i = 0; i < val - 0xfd; i++)
			{
				*dest++ = *pre++;
			}
			len += val - 0xfd;
		}
		else
		{
			*dest++ = (unsigned char)val;
			len++;
		}
	}
	free(tree.list);
	free(tree.node);
	return len;
}

/****************************************************
 * 功能描述：压缩主函数                             *
 * 参    数：src ---- 压缩前数据的首指针            *
 *           dest --- 存放压缩后数据的首指针，如果  *
 *                    dest为NULL，则只计算压缩后数  *
 *                    据的长度，不存放实际压缩结果  *
 *           srclen - 压缩前数据的长度              *
 * 返 回 值：压缩后数据的长度                       *
 ****************************************************/
int compress(const unsigned char *src, unsigned char *dest, int srclen)
{
	int match, match_len, len, ptr, pos, table, top;
	int head[0x100], _prev[0x2000], *prev, *pre;
	unsigned long dptr = 0;
	bool code[0x140];
	Tree tree;
	TreeNode *node;

	if (dest)
	{
		*((int *)dest) = srclen;
		dest += 4;
	}
	pre = prev = _prev;
	memset(head, 0xff, 0x100 * sizeof(int));
	memset(prev, 0xff, 0x2000 * sizeof(int));
	prev += 0x1000;
	for(ptr = 0; ptr < srclen - 2 && ptr < 0x1000; ptr++)
	{
		unsigned char hash = src[ptr] ^ src[ptr + 1] ^ src[ptr + 2];
		if (head[hash] >= 0)
			prev[ptr] = head[hash];
		head[hash] = ptr;
	}
	tree = build_tree();
	ptr = 0; top = 0x1000;
	while(ptr < srclen)
	{
		unsigned short val = src[ptr];
		int temp = ptr, prv, cur, match_len_t;
		match = 0; match_len = 1;
		if (ptr >= top)
		{
			int pre1, pre2;
			for(pre1 = 0, pre2 = 0x1000; pre1 < 0x1000; pre1++, pre2++)
				pre[pre1] = pre[pre2];
			prev -= 0x1000; top += 0x1000;
			for(ptr = top - 0x1000; ptr < srclen - 2 && ptr < top; ptr++)
			{
				unsigned char hash = src[ptr] ^ src[ptr + 1] ^ src[ptr + 2];
				if (head[hash] >= 0 && ptr - head[hash] < 0x1000)
					prev[ptr] = head[hash];
				head[hash] = ptr;
			}
			ptr = temp;
		}
		while((prv = prev[temp]) >= 0 && ptr - prev[temp] < 0x1000)
		{
			cur = ptr; match_len_t = 0;
			while(src[prv++] == src[cur++] && match_len_t < 67)
				match_len_t++;
			if (match_len_t >= 3 && match_len < match_len_t)
			{
				match_len = match_len_t;
				match = ptr - prev[temp] - 1;
				if (match_len == 67)
					break;
			}
			temp = prev[temp];
		}
		if (match_len >= 3)
		{
			val = match_len + 0xfd;
		}
		else
		{
			match_len = 1;
		}
		node = tree.list[val]; pos = 0;
		while(node->value != 0x280)
		{
			if (node->parent->left == node)
				code[pos++] = false;
			else
				code[pos++] = true;
			node = node->parent;
		}
		if (dest)
		{
			while(pos > 0)
				bit(dest, dptr++, code[--pos]);
		}
		else
			dptr += pos;
		adjust_tree(tree, val);
		if (val > 0xff)
		{
			unsigned int *temp = (unsigned int *)(dest + (dptr >> 3));
			int shift = dptr & 0x7;
			unsigned int tmp = (match >> 6) & 0x3f;
			table = ((match << data4[tmp]) & 0xff) | data3[tmp];
			if (dest)
			{
				tmp = table | (((match & 0x3f) >> (8 - data2[table & 0xf])) << 8);
				*temp = (*temp & (0xff >> (8 - shift))) | (tmp << shift);
			}
			dptr += data2[table & 0xf] + 6;
		}
		ptr += match_len;
	}	
	node = tree.list[0x140]; pos = 0; table = 0;
	while(node->value != 0x280)
	{
		if (node->parent->left == node)
			code[pos++] = false;
		else
			code[pos++] = true;
		node = node->parent;
	}
	if (dest)
	{
		while(pos > 0)
			bit(dest, dptr++, code[--pos]);
		for(int i = 0; i < 8; i++)
			bit(dest, dptr++, 0);
		for(int i = 0; i < 6; i++)
			bit(dest, dptr++, 1);
	}
	else
		dptr += pos + 14;
	len = dptr >> 3;
	if (dptr & 0x7)
		len++;
	if (len & 0x1)
		len++;
	len += 4;
	free(tree.list);
	free(tree.node);
	return len;
}

/****************************************************
 * 功能描述：每次压缩/解压缩后调整该Huffman树       *
 * 参    数：tree ---- Tree结构的变量               *
 *           value --- 需要调整的叶子结点的值       *
 * 返 回 值：无                                     *
 ****************************************************/
void adjust_tree(Tree tree, unsigned short value)
{
	TreeNode *node = tree.list[value];
	TreeNode tmp, *tmp1, *temp;
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

/****************************************************
 * 功能描述：建立并初始化用于压缩/解压缩的Huffman树 *
 * 参    数：无                                     *
 * 返 回 值：Tree结构                               *
 ****************************************************/
Tree build_tree(void)
{
	int i, ptr;
	Tree tree;
	TreeNode **list;
	TreeNode *node;
	tree.list = list = (TreeNode **)malloc(321 * sizeof(TreeNode *));
	tree.node = node = (TreeNode *)malloc(641 * sizeof(TreeNode));
	memset(list, 0, 321 * sizeof(TreeNode *));
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
	return tree;
}

#pragma pack(1)
typedef struct _BitField
{
	unsigned char	b0:	1;
	unsigned char	b1:	1;
	unsigned char	b2:	1;
	unsigned char	b3:	1;
	unsigned char	b4:	1;
	unsigned char	b5:	1;
	unsigned char	b6:	1;
	unsigned char	b7:	1;
} BitField;
#pragma pack()

bool bt(const void *data, unsigned int pos)
{
	BitField *bit = (BitField *)((unsigned char *)data + (pos >> 3));
	switch(pos & 0x7)
	{
	case 0:
		return bit->b0;
	case 1:
		return bit->b1;
	case 2:
		return bit->b2;
	case 3:
		return bit->b3;
	case 4:
		return bit->b4;
	case 5:
		return bit->b5;
	case 6:
		return bit->b6;
	case 7:
		return bit->b7;
	}
	return 0;
}

void bit(void *data, unsigned int pos, bool set)
{
	BitField *bit = (BitField *)((unsigned char *)data + (pos >> 3));
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
/*
bool bt(void *data, unsigned int pos)
{
	__asm
	{
		xor		eax, eax
		mov		edx, data
		mov		ecx, pos
		bt		[edx], ecx
		setc	al
	}
}

void bit(void *data, unsigned int pos, bool set)
{
	if (set)
		__asm
		{
			mov		eax, data
			mov		ecx, pos
			bts		[eax], ecx
		}
	else
		__asm
		{
			mov		eax, data
			mov		ecx, pos
			btr		[eax], ecx
		}
}
*/
