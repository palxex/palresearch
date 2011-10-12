/*
 * PAL WIN95 compress format (YJ_2) streaming library
 * 
 * Author: Lou Yihua <louyihua@21cn.com>
 *
 * Copyright 2007 Lou Yihua
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
 *《仙剑奇侠传》WIN95版压缩格式(YJ_2)流式处理库
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

struct YJ2_Decode_State
{
	Tree		tree;
	TreeNode*	node;
	uint8*		dest;

	uint8*		pIBuffer;
	uint32		uiILength;
	uint32		uiIGrowBy;
	uint32		uiIEnd;
	uint8*		pOBuffer;
	uint32		uiOStart;
	uint32		uiOEnd;

	uint32		ptr;
	uint32		start;
	uint32		len;
	uint32		length;

	uint16		step;
	uint16		val;
	uint32		avail;
	sint32		pos;

	bool		bInitialed;
	bool		bInput;
	bool		bFinished;
};

errno_t Pal::Tools::DecodeYJ2StreamInitialize(void*& pvState, uint32 uiGrowBy)
{
	struct YJ2_Decode_State* state;

	if (uiGrowBy < 0x100)
		uiGrowBy = 0x100;
	if ((state = new YJ2_Decode_State) == NULL)
		return ENOMEM;
	memset(state, 0, sizeof(struct YJ2_Decode_State));
	if (!build_tree(state->tree))
	{
		delete state;
		return ENOMEM;
	}
	if ((state->pIBuffer = new uint8 [uiGrowBy]) == NULL)
	{
		delete [] state->tree.list;
		delete [] state->tree.node;
		delete state;
		return ENOMEM;
	}
	if ((state->dest = state->pOBuffer = new uint8 [0x2050]) == NULL)
	{
		delete [] state->pIBuffer;
		delete [] state->tree.list;
		delete [] state->tree.node;
		delete state;
		return ENOMEM;
	}
	state->bInitialed = true;
	state->uiILength = uiGrowBy;
	state->uiIGrowBy = uiGrowBy;
	pvState = state;
	return 0;
}

errno_t Pal::Tools::DecodeYJ2StreamInput(void* pvState, const void* Source, uint32 SourceLength)
{
	struct YJ2_Decode_State* state = (struct YJ2_Decode_State*)pvState;

	if (state && state->bInitialed && !state->bFinished)
	{
		uint8* src;

		if (Source == NULL || SourceLength == 0)
			return 0;
		if (!state->bInput)
		{
			if (state->uiIEnd + SourceLength < 4)
			{
				memcpy(state->pIBuffer + state->uiIEnd, Source, SourceLength);
				state->uiIEnd += SourceLength;
				return 0;
			}
			else
				memcpy(state->pIBuffer + state->uiIEnd, Source, 4 - state->uiIEnd);
			state->length = *((uint32*)state->pIBuffer);
			SourceLength -= 4 - state->uiIEnd;
			src = (uint8*)Source + 4 - state->uiIEnd;
			state->uiIEnd = 0;
			state->bInput = true;
		}
		else
			src = (uint8*)Source;
		if (state->uiIEnd + SourceLength > state->uiILength)
		{
			uint8* pbuf;
			uint32 len = (state->uiIEnd + SourceLength) / state->uiIGrowBy + state->uiIGrowBy;
			if ((pbuf = new uint8 [state->uiILength + len]) == NULL)
				return ENOMEM;
			memcpy(pbuf, state->pIBuffer, state->uiIEnd);
			delete [] state->pIBuffer;
			state->pIBuffer = pbuf;
			state->uiILength += len;
		}
		memcpy(state->pIBuffer + state->uiIEnd, src, SourceLength);
		state->uiIEnd += SourceLength;
		return 0;
	}
	else
		return EINVAL;
}

static void DecodeYJ2StreamProcess(void* pvState)
{
	struct YJ2_Decode_State* state = (struct YJ2_Decode_State*)pvState;
	uint32 slen = state->uiIEnd << 3;

	while(state->ptr < slen)
	{
		uint32 temp, tmp;
		sint32 i;
		switch(state->step)
		{
		case 0:
			state->node = state->tree.node + 0x280;
			state->step = 1;
		case 1:
			while(state->node->value > 0x140 && state->ptr < slen)
			{
				if (bt(state->pIBuffer, state->ptr))
					state->node = state->node->right;
				else
					state->node = state->node->left;
				state->ptr++;
			}
			if (state->node->value > 0x140)
				return;
			state->val = state->node->value;
			if (state->tree.node[0x280].weight == 0x8000)
			{
				for(i = 0; i < 0x141; i++)
					if (state->tree.list[i]->weight & 0x1)
						adjust_tree(state->tree, i);
				for(i = 0; i <= 0x280; i++)
					state->tree.node[i].weight >>= 1;
			}
			adjust_tree(state->tree, state->val);
			if (state->val > 0xff)
				state->step = 2;
			else
			{
				*state->dest++ = (uint8)state->val;
				state->len++;
				state->uiOEnd++;
				state->step = 0;
				if (state->uiOEnd >= 0x2000)
					return;
				else
					break;
			}
		case 2:
			for(i = state->pos, temp = state->avail; i < 8 && state->ptr < slen; i++, state->ptr++)
				temp |= (uint32)bt(state->pIBuffer, state->ptr) << i;
			state->avail = temp;
			state->pos = i;
			if (i < 8)
				return;
			else
				state->step = 3;
		case 3:
			temp = state->avail;
			tmp = temp & 0xff;
			for(i = state->pos; i < data2[tmp & 0xf] + 6 && state->ptr < slen; i++, state->ptr++)
				temp |= (uint32)bt(state->pIBuffer, state->ptr) << i;
			state->avail = temp;
			state->pos = i;
			if (i < data2[tmp & 0xf] + 6)
				return;
			else
			{
				uint32 pos;
				uint8* pre;
				temp >>= data2[tmp & 0xf];
				pos = (temp & 0x3f) | ((uint32)data1[tmp] << 6);
				if (pos == 0xfff)
				{
					state->bInput = false;
					state->bFinished = true;
					return;
				}
				pre = state->dest - pos - 1;
				for(i = 0; i < state->val - 0xfd; i++)
					*state->dest++ = *pre++;
				state->len += state->val - 0xfd;
				state->uiOEnd += state->val - 0xfd;
				state->pos = 0;
				state->avail = 0;
				state->step = 0;
				if (state->uiOEnd >= 0x2000)
					return;
				else
					break;
			}
		}
	}
}

errno_t Pal::Tools::DecodeYJ2StreamOutput(void* pvState, void* Destination, uint32 Length, uint32& ActualLength)
{
	struct YJ2_Decode_State* state = (struct YJ2_Decode_State*)pvState;

	if (state && state->bInitialed)
	{

		uint32 count, len1, start;
		uint32 len = 0;
		uint8* dest = (uint8*)Destination;

		if (Destination == NULL || Length == 0)
		{
			ActualLength = 0;
			return 0;
		}

		while(len < Length && state->uiIEnd > 0 && !state->bFinished)
		{
			DecodeYJ2StreamProcess(state);
			if (Length - len > state->uiOEnd - state->uiOStart)
				count = state->uiOEnd - state->uiOStart;
			else
				count = Length - len;
			memcpy(dest + len, state->pOBuffer + state->uiOStart, count);
			len += count;
			state->start += count;
			state->uiOStart += count;
			if ((len1 = state->ptr >> 3) < state->uiIEnd)
			{
				memmove(state->pIBuffer, state->pIBuffer + len1, state->uiIEnd - len1);
				state->ptr &= 0x7;
				state->uiIEnd -= len1;
			}
			else
				state->ptr = state->uiIEnd = 0;
			if (state->uiOEnd >= 0x1000)
			{
				if (state->uiOStart > state->uiOEnd - 0x1000)
				{
					start = state->uiOEnd - 0x1000;
					count = 0x1000;
				}
				else
				{
					start = state->uiOStart;
					count = state->uiOEnd - state->uiOStart;
				}
				memmove(state->pOBuffer, state->pOBuffer + start, count);
				state->dest -= start;
				state->uiOStart -= start;
				state->uiOEnd -= start;
			}
		}
		ActualLength = len;
		return 0;
	}
	else
		return EINVAL;
}

bool Pal::Tools::DecodeYJ2StreamFinished(void* pvState, uint32& AvailableLength)
{
	struct YJ2_Decode_State* state = (struct YJ2_Decode_State*)pvState;

	if (state && state->bInitialed)
	{
		AvailableLength = state->len - state->start;
		return state->bFinished;
	}
	else
		return false;
}

errno_t Pal::Tools::DecodeYJ2StreamFinalize(void* pvState)
{
	struct YJ2_Decode_State* state = (struct YJ2_Decode_State*)pvState;

	if (state && state->bInitialed)
	{
		delete [] state->pOBuffer;
		delete [] state->pIBuffer;
		delete [] state->tree.list;
		delete [] state->tree.node;
		delete state;
		return 0;
	}
	else
		return EINVAL;
}

errno_t Pal::Tools::DecodeYJ2StreamReset(void* pvState)
{
	struct YJ2_Decode_State* state = (struct YJ2_Decode_State*)pvState;

	if (state && state->bInitialed)
	{
		uint32 uiGrowBy = state->uiIGrowBy;
		uint32 uiLength = state->uiILength;
		uint8* pIBuffer = state->pIBuffer;
		uint8* pOBuffer = state->pOBuffer;

		delete [] state->tree.list;
		delete [] state->tree.node;
		memset(state, 0, sizeof(struct YJ2_Decode_State));
		if (!build_tree(state->tree))
		{
			delete [] pOBuffer;
			delete [] pIBuffer;
			delete state;
			return ENOMEM;
		}
		state->dest = state->pOBuffer = pOBuffer;
		state->pIBuffer = pIBuffer;
		state->uiIGrowBy = uiGrowBy;
		state->uiILength = uiLength;
		state->bInitialed = true;
		return 0;
	}
	else
		return EINVAL;
}