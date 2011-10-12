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

struct YJ2_Encode_State
{
	Tree		tree;

	uint8*		pIBuffer;
	uint32		uiILength;
	uint32		uiIGrowBy;
	uint32		uiIStart;
	uint32		uiIEnd;

	uint32		length;
	uint32		top;
	uint32		pos;
	uint32		match;
	uint32		match_len;

	sint32		*head;
	sint32		*prev;
	sint32		*_pre;
	bool		*code;

	bool		bInitialed;
	bool		bOutput;
	bool		bFinished;
	bool		bCompleted;
	bool		bCompatible;

	uint16		step;
	uint16		val;
	uint8		shift;
};

errno_t Pal::Tools::EncodeYJ2StreamInitialize(void*& pvState, uint32 uiSourceLength, uint32 uiGrowBy, bool bCompatible)
{
	struct YJ2_Encode_State* state;

	if (uiGrowBy < 0x1000)
		uiGrowBy = 0x1000;
	if ((state = new YJ2_Encode_State) == NULL)
		return ENOMEM;
	memset(state, 0, sizeof(struct YJ2_Encode_State));
	if (!build_tree(state->tree))
	{
		delete state;
		return ENOMEM;
	}
	if ((state->head = new sint32 [0x100]) == NULL)
	{
		delete [] state->tree.list;
		delete [] state->tree.node;
		delete state;
		return ENOMEM;
	}
	if ((state->_pre = state->prev = new sint32 [0x2000]) == NULL)
	{
		delete [] state->head;
		delete [] state->tree.list;
		delete [] state->tree.node;
		delete state;
		return ENOMEM;
	}
	if ((state->code = new bool [0x140]) == NULL)
	{
		delete [] state->prev;
		delete [] state->head;
		delete [] state->tree.list;
		delete [] state->tree.node;
		delete state;
		return ENOMEM;
	}
	if ((state->pIBuffer = new uint8 [uiGrowBy]) == NULL)
	{
		delete [] state->code;
		delete [] state->prev;
		delete [] state->head;
		delete [] state->tree.list;
		delete [] state->tree.node;
		delete state;
		return ENOMEM;
	}
	memset(state->head, 0xff, 0x100 * sizeof(sint32));
	memset(state->prev, 0xff, 0x2000 * sizeof(sint32));
	memset(state->code, 0, 0x140 * sizeof(bool));
	state->bInitialed = true;
	state->uiILength = uiGrowBy;
	state->uiIGrowBy = uiGrowBy;
	state->length = uiSourceLength;
	state->bCompatible = bCompatible;
	pvState = state;
	return 0;
}

errno_t Pal::Tools::EncodeYJ2StreamInput(void* pvState, const void* Source, uint32 SourceLength, bool bFinished)
{
	struct YJ2_Encode_State* state = (struct YJ2_Encode_State*)pvState;

	if (state && state->bInitialed && !state->bFinished)
	{
		uint8* src = (uint8*)Source;

		if (Source == NULL || SourceLength == 0)
		{
			state->bFinished = bFinished;
			return 0;
		}
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
		state->bFinished = bFinished;
		state->uiIEnd += SourceLength;
		return 0;
	}
	else
		return EINVAL;
}

static void EncodeYJ2StreamProcess(struct YJ2_Encode_State* state, void* dest, unsigned long& dptr, unsigned long dptrs)
{
	uint32 srclen;
	TreeNode* node;

	if (state->bCompleted)
		return;
	else if (state->bFinished)
		srclen = state->uiIEnd;
	else if (state->uiIEnd < 67)
		srclen = 0;
	else
		srclen = state->uiIEnd - 67;
	while(state->uiIStart < srclen)
	{
		sint32 temp, prv;

		switch(state->step)
		{
		case 0:
			state->val = state->pIBuffer[state->uiIStart];
			state->match = 0;
			state->match_len = 1;
			temp = (sint32)state->uiIStart;
			if (state->uiIStart >= state->top)
			{
				uint32 ptr, top, offset;

				if (state->top >= 0x1000 || state->uiIStart >= 0x1000)
				{
					sint32* pre = state->_pre + state->top - 0x1000;
					top = state->top + 0x1000;
					if (state->uiIEnd < 2)
						top = 0;
					else if (top > state->uiIEnd - 2)
						top = state->uiIEnd - 2;
					offset = top - state->top;
					if (pre > state->prev)
						memmove(state->prev, pre, 0x1000 * sizeof(sint32));
					state->_pre = state->prev - state->top + 0x1000;
				}
				else
				{
					if (state->uiIEnd > 0x1002)
						top = 0x1000;
					else
						top = state->uiIEnd - 2;
				}

				for(ptr = state->top; ptr < top; ptr++)
				{
					uint8 hash = state->pIBuffer[ptr] ^ state->pIBuffer[ptr + 1] ^ state->pIBuffer[ptr + 2];
					if (state->head[hash] >= 0 && ptr - state->head[hash] < 0x1000)
						state->_pre[ptr] = state->head[hash];
					state->head[hash] = ptr;
				}
				state->top = ptr;
			}
			while((prv = state->_pre[temp]) >= 0 && state->uiIStart - state->_pre[temp] < 0x1000)
			{
				uint32 cur = state->uiIStart;
				uint32 match_len_t = 0;
				while(match_len_t < 67 && state->uiIStart + match_len_t < state->uiIEnd && state->pIBuffer[prv++] == state->pIBuffer[cur++])
					match_len_t++;
				if (match_len_t >= 3 && state->match_len < match_len_t)
				{
					state->match_len = match_len_t;
					state->match = state->uiIStart - state->_pre[temp] - 1;
					if (state->match_len == 67 || state->uiIStart + state->match_len >= state->uiIEnd)
						break;
				}
				temp = state->_pre[temp];
			}
			if (state->match_len >= 3)
				state->val = state->match_len + 0xfd;
			else
				state->match_len = 1;
			node = state->tree.list[state->val]; state->pos = 0;
			while(node->value != 0x280)
			{
				if (node->parent->left == node)
					state->code[state->pos++] = false;
				else
					state->code[state->pos++] = true;
				node = node->parent;
			}
			state->step = 1;
		case 1:
			while(state->pos > 0 && dptr < dptrs)
				bit(dest, dptr++, state->code[--state->pos]);
			if (state->pos > 0)
				return;
			if (state->tree.node[0x280].weight == 0x8000)
			{
				sint32 i;
				for(i = 0; i < 0x141; i++)
					if (state->tree.list[i]->weight & 0x1)
						adjust_tree(state->tree, i);
				for(i = 0; i <= 0x280; i++)
					state->tree.node[i].weight >>= 1;
			}
			adjust_tree(state->tree, state->val);
			state->shift = 0;
			state->step = 2;
		case 2:
			if (state->val > 0xff)
			{
				uint32 tmp = (state->match >> 6) & 0x3f;
				uint32 table = ((state->match << data4[tmp]) & 0xff) | data3[tmp];
				tmp = table | (((state->match & 0x3f) >> (8 - data2[table & 0xf])) << 8);
				tmp >>= state->shift;
				while(dptr < dptrs && state->shift < data2[table & 0xf] + 6)
				{
					bit(dest, dptr++, tmp & 0x1);
					state->shift++;
					tmp >>= 1;
				}
				if (state->shift < data2[table & 0xf] + 6)
					return;
			}
			state->uiIStart += state->match_len;
			state->step = 0;
		}
	}
	if (state->bFinished && state->uiIStart >= state->uiIEnd)
	{
		switch(state->step)
		{
		case 0:
			node = state->tree.list[0x140]; state->pos = 0;
			while(node->value != 0x280)
			{
				if (node->parent->left == node)
					state->code[state->pos++] = false;
				else
					state->code[state->pos++] = true;
				node = node->parent;
			}
			if (state->bCompatible)
				state->match = state->pos;
			state->step = 3;
		case 3:
			while(state->pos > 0 && dptr < dptrs)
				bit(dest, dptr++, state->code[--state->pos]);
			if (state->pos > 0)
				return;
			state->shift = 0;
			state->step = 4;
		case 4:
			for(; state->shift < 8 && dptr < dptrs; state->shift++)
				bit(dest, dptr++, 0);
			if (state->shift < 8)
				return;
			state->shift = 0;
			state->step = 5;
		case 5:
			for(; state->shift < 6 && dptr < dptrs; state->shift++)
				bit(dest, dptr++, 1);
			if (state->shift < 6)
				return;
			state->shift = 0;
			state->step = 0;
		}
	}
}

errno_t Pal::Tools::EncodeYJ2StreamOutput(void* pvState, void* Destination, uint32 Length, uint32& ActualLength, uint32& Bits)
{
	struct YJ2_Encode_State* state = (struct YJ2_Encode_State*)pvState;

	if (state && state->bInitialed)
	{
		unsigned long dptr = Bits;
		uint32 addlen = 0;
		uint8* dest;

		if (Destination == NULL || Length == 0 || state->bCompleted)
		{
			if (state->bCompleted && state->bCompatible && state->length < state->top)
			{
				dest = (uint8*)Destination;
				for(ActualLength = 0; ActualLength < Length && state->length < state->top; ActualLength++, state->length++)
					dest[ActualLength] = 0;
				if (state->length == state->top)
					state->top = 0;
			}
			else
				ActualLength = 0;
			Bits = 0;
			return 0;
		}
		if (!state->bOutput)
		{
			if (state->top + Length < 4)
			{
				memcpy((uint8*)Destination + state->top, (uint8*)(&state->length) + state->top, Length);
				state->top += Length;
				ActualLength = Length;
				Bits = 0;
				return 0;
			}
			else
				memcpy((uint8*)Destination + state->top, (uint8*)(&state->length) + state->top, 4 - state->top);
			dest = (uint8*)Destination + 4 - state->top;
			Length -= 4 - state->top;
			addlen = 4 - state->top;
			state->length = 0;
			state->top = 0;
			state->bOutput = true;
		}
		else
			dest = (uint8*)Destination;
		EncodeYJ2StreamProcess(state, dest, dptr, Length << 3);
		if (!state->bCompleted && state->uiIStart > 0x1000 && state->uiIEnd >= 0x1002 &&
			state->uiIStart < state->uiIEnd && state->top > 0x1000)
		{
			uint32 start = state->uiIStart - 0x1000;
			memmove(state->pIBuffer, state->pIBuffer + start, state->uiIEnd - start);
			for(uint32 i = 0; i < 0x100; i++)
				if (state->head[i] < (sint32)start)
					state->head[i] = -1;
				else
					state->head[i] -= start;
			for(uint32 i = 0; i < 0x2000; i++)
				if (state->prev[i] < (sint32)start)
					state->prev[i] = -1;
				else
					state->prev[i] -= start;
			state->uiIEnd -= start;
			state->uiIStart = 0x1000;
			state->top -= start;
			state->_pre += start;
		}
		ActualLength = addlen + (dptr >> 3);
		Bits = dptr & 0x7;
		state->length += ActualLength;
		if (state->bFinished && state->step == 0)
		{
			if (Bits > 0)
			{
				for(uint32 i = Bits; i < 8; i++)
					bit(dest + ActualLength, i, 0);
				ActualLength++;
				state->length++;
				Bits = 0;
			}
			if (state->bCompatible)
			{
				uint32 temp = ((dptr - state->match - 14) >> 3) + 4 + addlen;
				state->top = state->length + temp - ActualLength;
				for(; ActualLength < temp && ActualLength < Length; ActualLength++, state->length++)
					dest[ActualLength] = 0;
			}
			state->bCompleted = true;
		}
		return 0;
	}
	else
		return EINVAL;
}

bool Pal::Tools::EncodeYJ2StreamFinished(void* pvState)
{
	struct YJ2_Encode_State* state = (struct YJ2_Encode_State*)pvState;

	if (state && state->bInitialed)
		return (state->bCompleted && (!state->bCompatible || state->top == 0));
	else
		return false;
}

errno_t Pal::Tools::EncodeYJ2StreamFinalize(void* pvState)
{
	struct YJ2_Encode_State* state = (struct YJ2_Encode_State*)pvState;

	if (state && state->bInitialed)
	{
		delete [] state->pIBuffer;
		delete [] state->code;
		delete [] state->prev;
		delete [] state->head;
		delete [] state->tree.list;
		delete [] state->tree.node;
		delete state;
		return 0;
	}
	else
		return EINVAL;
}
