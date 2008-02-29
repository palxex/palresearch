//$ Id: PalLibrary.h 1.02 2006-05-23 14:34:50 +8:00 $

/*
 * PAL Library common include file
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
 *《仙剑奇侠传》库公共头文件
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
#pragma once

namespace PalLibrary
{
	typedef struct _DataBuffer
	{
		void			*data;
		unsigned int	length;
	} DataBuffer;

	DataBuffer DecodeYJ_1(const void *Source);
	DataBuffer EncodeYJ_1(const void *Source, unsigned int SourceLength);
	DataBuffer DecodeWin(const void *Source);
	DataBuffer EncodeWin(const void *Source, unsigned int SourceLength);
	DataBuffer DecodeRNG(const void *Source, void *PrevFrame);
	DataBuffer EncodeRNG(const void *PrevFrame, const void *CurFrame);
}
