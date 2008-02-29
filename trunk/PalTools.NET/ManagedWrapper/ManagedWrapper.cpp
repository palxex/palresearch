
#include "stdafx.h"

#define INITGUID
#include <dmusici.h>
#include <windows.h>
#include <memory.h>
#include "ManagedWrapper.h"

#pragma pack(1)
typedef struct _BitmapHeader
{
	BITMAPFILEHEADER	bmfHeader;
	BITMAPINFOHEADER	bmiHeader;
	RGBQUAD				bmiColor[0x100];
} BitmapHeader;
#pragma pack()

PalTools::PalMkf::PalMkf(System::String ^path, MkfFile file)
{
	System::IntPtr _name = Marshal::StringToHGlobalAnsi(path);
	char *name = (char *)_name.ToPointer();
	_file = file;
	
	_mkf = 0;
	try
	{
		_mkf = new PAL_MKF_R(name, (MKF_FILE)file);
		Marshal::FreeHGlobal(_name);
	}
	catch(ERROR_NO &)
	{
		Marshal::FreeHGlobal(_name);
		throw gcnew System::IO::FileNotFoundException(System::String::Concat("无法找到文件", path));
	}
}

PalTools::PalMkf::~PalMkf()
{
	if (_mkf)
		delete _mkf;
}

int PalTools::PalMkf::Count()
{
	return _mkf->count();
}

PalTools::MkfBufferItem PalTools::PalMkf::RawData()
{
	MkfBufferItem temp = {nullptr, 0};
	unsigned char *buf;
	temp.Size = _mkf->rawlength();
	buf = _mkf->rawdata();
	temp.Buffer = gcnew array<unsigned char>(temp.Size);
	Marshal::Copy(System::IntPtr(buf), temp.Buffer, 0, temp.Size);
	delete [] buf;
	return temp;
}

PalTools::MkfBufferItem PalTools::PalMkf::RawData(int index)
{
	if (index < 0 || index >= _mkf->count())
		throw gcnew System::Exception("指定的索引超出范围");
	else if (_mkf->rawlength(index) == 0)
	{
		MkfBufferItem temp = {nullptr, 0};
		return temp;
	}
	else
	{
		MkfBufferItem temp;
		unsigned char *tmp;
		tmp = _mkf->rawdata(index);
		temp.Size = _mkf->rawlength(index);
		temp.Buffer = gcnew array<unsigned char>(temp.Size);
		Marshal::Copy(System::IntPtr(tmp), temp.Buffer, 0, temp.Size);
		delete [] tmp;
		return temp;
	}
}

PalTools::MkfBufferItem PalTools::PalMkf::Data(int index)
{
	if (index < 0 || index >= _mkf->count())
		throw gcnew System::Exception("指定的索引超出范围");
	else if (_mkf->length(index) == 0)
	{
		MkfBufferItem temp = {nullptr, 0};
		return temp;
	}
	else
	{
		MkfBufferItem temp;
		unsigned char *buf;
		temp.Size = _mkf->length(index);
		buf = _mkf->data(index);
		temp.Buffer = gcnew array<unsigned char>(temp.Size);
		Marshal::Copy(System::IntPtr(buf), temp.Buffer, 0, temp.Size);
		delete [] buf;
		return temp;
	}
}

int PalTools::PalMkf::RawLength()
{
	return _mkf->rawlength();
}

int PalTools::PalMkf::Offset(int index)
{
	if (index < 0 || index >= _mkf->count())
		throw gcnew System::Exception("指定的索引超出范围");
	else
		return _mkf->offset(index);
}

int PalTools::PalMkf::RawLength(int index)
{
	if (index < 0 || index >= _mkf->count())
		throw gcnew System::Exception("指定的索引超出范围");
	else
		return _mkf->rawlength(index);
}

int PalTools::PalMkf::Length(int index)
{
	if (index < 0 || index >= _mkf->count())
		throw gcnew System::Exception("指定的索引超出范围");
	else
		return _mkf->length(index);
}

PalTools::MkfBufferGroup PalTools::PalMkf::Extract(int index)
{
	if (index < 0 || index >= _mkf->count())
		throw gcnew System::Exception("指定的索引超出范围");
	else
	{
		int i;
		MkfBufferGroup temp;
		BufferGroup tmp;
		try
		{
			tmp = _mkf->extract(index);
		}
		catch(ERROR_NO &)
		{
			throw gcnew System::Exception("指定的索引对象不是文件组");
		}
		temp.Count = tmp.count;
		temp.Item = gcnew array<MkfBufferItem>(tmp.count);
		for(i = 0; i < tmp.count; i++)
		{
			temp.Item[i].Size = tmp.item[i].size;
			temp.Item[i].Buffer = gcnew array<unsigned char>(tmp.item[i].size);
			Marshal::Copy(System::IntPtr(tmp.item[i].buffer), temp.Item[i].Buffer, 0, tmp.item[i].size);
			delete [] tmp.item[i].buffer;
		}
		delete [] tmp.item;
		return temp;
	}
}

array<int> ^PalTools::PalMkf::ExtractLength(int index)
{
	if (index < 0 || index >= _mkf->count())
		throw gcnew System::Exception("指定的索引超出范围");
	else
	{
		int i;
		array<int> ^temp;
		BufferGroup tmp;
		try
		{
			tmp = _mkf->extract(index);
		}
		catch(ERROR_NO &)
		{
			throw gcnew System::Exception("指定的索引对象不是文件组");
		}
		if (tmp.count == 0)
			return nullptr;
		temp = gcnew array<int>(tmp.count);
		for(i = 0; i < tmp.count; i++)
		{
			temp[i] = tmp.item[i].size;
			delete [] tmp.item[i].buffer;
		}
		delete [] tmp.item;
		return temp;
	}
}

System::Drawing::Bitmap ^PalTools::PalMkf::GetBitmap(int index, System::IntPtr palette)
{
	System::Drawing::Bitmap ^bmp;
	System::IO::MemoryStream ^mem;
	array<unsigned char> ^buf;
	BitmapHeader bh;
	unsigned char *ptr, *pat;
	int i, len;
	if (_file != MkfFile::MKF_FBP && _file != MkfFile::MKF_BALL && _file != MkfFile::MKF_RGM)
		return nullptr;
	if (index < 0 || index >= _mkf->count())
		return nullptr;
	bh.bmfHeader.bfType = 0x4d42;
	bh.bmfHeader.bfReserved1 = bh.bmfHeader.bfReserved2 = 0;
	bh.bmfHeader.bfOffBits = sizeof(BitmapHeader);
	bh.bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
	bh.bmiHeader.biPlanes = 1;
	bh.bmiHeader.biBitCount = 8;
	bh.bmiHeader.biCompression = BI_RGB;
	bh.bmiHeader.biXPelsPerMeter = bh.bmiHeader.biYPelsPerMeter = 0;
	bh.bmiHeader.biClrUsed = bh.bmiHeader.biClrImportant = 0;
	pat = (unsigned char *)palette.ToPointer();
	for(i = 0; i < 256; i++)
	{
		bh.bmiColor[i].rgbRed = *pat++ << 2;
		bh.bmiColor[i].rgbGreen = *pat++ << 2;
		bh.bmiColor[i].rgbBlue = *pat++ << 2;
		bh.bmiColor[i].rgbReserved = 0;
	}
	if (_file == MkfFile::MKF_FBP)
	{
		len = _mkf->length(index);
		ptr = _mkf->data(index);
		if (!ptr)
			return nullptr;
		bh.bmfHeader.bfSize = len + sizeof(BitmapHeader);
		bh.bmiHeader.biWidth = 320;
		bh.bmiHeader.biHeight = 200;
		bh.bmiHeader.biSizeImage = len;
	}
	else
	{
		int width, height, w;
		BufferGroup bg = _mkf->extract(index);
		if (bg.count == 0)
			return nullptr;
		width = *(unsigned short *)bg.item[0].buffer;
		height = *(unsigned short *)(bg.item[0].buffer + 2);
		if (width & 0x3)
			w = ((width >> 2) + 1) << 2;
		else
			w = width;
		len = w * height;
		ptr = new unsigned char [len];
		memset(ptr, 0, len);
		rle_decode(bg.item[0].buffer, ptr, w, height, 0, 0);
		delete [] bg.item[0].buffer;
		bh.bmfHeader.bfSize = len + sizeof(BitmapHeader);
		bh.bmiHeader.biWidth = width;
		bh.bmiHeader.biHeight = height;
		bh.bmiHeader.biSizeImage = len;
	}
	buf = gcnew array<unsigned char>(sizeof(BitmapHeader) + len);
	Marshal::Copy(System::IntPtr(&bh), buf, 0, sizeof(BitmapHeader));
	Marshal::Copy(System::IntPtr(ptr), buf, sizeof(BitmapHeader), len);
	delete [] ptr;
	mem = gcnew System::IO::MemoryStream(buf);
	bmp = gcnew System::Drawing::Bitmap(mem);
	bmp->RotateFlip(System::Drawing::RotateFlipType::RotateNoneFlipY);
	return bmp;
}

System::Drawing::Bitmap ^PalTools::PalMkf::GetBitmap(int index, System::IntPtr palette, PalTools::PalMkf ^gop, int layer, bool grid)
{
	System::Drawing::Bitmap ^bmp;
	System::IO::MemoryStream ^mem;
	array<unsigned char> ^buf;
	BufferGroup bg;
	BitmapHeader bh;
	unsigned char *ptr, *pat, *map;
	unsigned char grid_line[] = {
		0x20, 0x00, 0x0f, 0x00,
		0x91, 0x01, 0x00, 0x8e,
		0x93, 0x01, 0x00, 0x8c,
		0x95, 0x01, 0x00, 0x8a,
		0x97, 0x01, 0x00, 0x88,
		0x99, 0x01, 0x00, 0x86,
		0x9b, 0x01, 0x00, 0x84,
		0x9d, 0x01, 0x00, 0x82,
		0x9f, 0x01, 0x00,
		0x9d, 0x01, 0x00, 0x82,
		0x9b, 0x01, 0x00, 0x84,
		0x99, 0x01, 0x00, 0x86,
		0x97, 0x01, 0x00, 0x88,
		0x95, 0x01, 0x00, 0x8a,
		0x93, 0x01, 0x00, 0x8c,
		0x91, 0x01, 0x00, 0x8e,
	};
	int i, j, h, k, p, len;
	int off[2] = {0, 8};
	if (_file != MkfFile::MKF_MAP)
		return nullptr;
	if (index < 0 || index >= _mkf->count())
		return nullptr;
	bh.bmfHeader.bfType = 0x4d42;
	bh.bmfHeader.bfReserved1 = bh.bmfHeader.bfReserved2 = 0;
	bh.bmfHeader.bfOffBits = sizeof(BitmapHeader);
	bh.bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
	bh.bmiHeader.biPlanes = 1;
	bh.bmiHeader.biBitCount = 8;
	bh.bmiHeader.biCompression = BI_RGB;
	bh.bmiHeader.biXPelsPerMeter = bh.bmiHeader.biYPelsPerMeter = 0;
	bh.bmiHeader.biClrUsed = bh.bmiHeader.biClrImportant = 0;
	pat = (unsigned char *)palette.ToPointer();
	for(i = 0; i < 256; i++)
	{
		bh.bmiColor[i].rgbRed = *pat++ << 2;
		bh.bmiColor[i].rgbGreen = *pat++ << 2;
		bh.bmiColor[i].rgbBlue = *pat++ << 2;
		bh.bmiColor[i].rgbReserved = 0;
	}
	len = _mkf->length(index);
	ptr = _mkf->data(index);
	if (len == 0)
		return nullptr;
	h = len >> 9;
	bh.bmiHeader.biWidth = 128 * 16 + 16;
	bh.bmiHeader.biHeight = h * 16 + 7;
	bh.bmiHeader.biSizeImage = bh.bmiHeader.biWidth * bh.bmiHeader.biHeight;
	bh.bmfHeader.bfSize = bh.bmiHeader.biSizeImage + sizeof(BitmapHeader);
	bg = gop->_mkf->extract(index);
	if (bg.count == 0)
	{
		if (len > 0)
			delete [] ptr;
		return nullptr;
	}
	map = new unsigned char [bh.bmiHeader.biSizeImage];
	memset(map, 0, bh.bmiHeader.biSizeImage);
	for(p = i = 0; i < h; i++)
		for(j = 0; j < 128; j++)
		{
			if (layer & 0x1)
			{
				k = ptr[p++];
				k |= (ptr[p++] & 0x10) << 4;
				rle_decode(bg.item[k].buffer, map, bh.bmiHeader.biWidth, bh.bmiHeader.biHeight, j << 4, (i << 4) + off[j & 0x1]);
			}
			else
				p += 2;
			if (layer & 0x2)
			{
				k = ptr[p++];
				k |= (ptr[p++] & 0x10) << 4;
				if (k > 0)
					rle_decode(bg.item[k - 1].buffer, map, bh.bmiHeader.biWidth, bh.bmiHeader.biHeight, j << 4, (i << 4) + off[j & 0x1]);
			}
			else
				p += 2;
			if (grid)
				rle_decode(grid_line, map, bh.bmiHeader.biWidth, bh.bmiHeader.biHeight, j << 4, (i << 4) + off[j & 0x1]);
		}
	for(i = 0; i < bg.count; i++)
		delete [] bg.item[i].buffer;
	delete [] bg.item;
	delete [] ptr;
	buf = gcnew array<unsigned char>(bh.bmfHeader.bfSize);
	Marshal::Copy(System::IntPtr(&bh), buf, 0, sizeof(BitmapHeader));
	Marshal::Copy(System::IntPtr(map), buf, sizeof(BitmapHeader), bh.bmiHeader.biSizeImage);
	delete [] map;
	mem = gcnew System::IO::MemoryStream(buf);
	bmp = gcnew System::Drawing::Bitmap(mem);
	bmp->RotateFlip(System::Drawing::RotateFlipType::RotateNoneFlipY);
	return bmp;
}

array<System::Drawing::Bitmap^> ^PalTools::PalMkf::GetBitmaps(int index, System::IntPtr palette)
{
	array<System::Drawing::Bitmap^> ^bmp;
	System::IO::MemoryStream ^mem;
	array<unsigned char> ^buf;
	BitmapHeader bh;
	unsigned char *ptr, *pat;
	int width, height, w, i, len;
	if (_file != MkfFile::MKF_ABC && _file != MkfFile::MKF_DATA && _file != MkfFile::MKF_F &&
		_file != MkfFile::MKF_FIRE && _file != MkfFile::MKF_GOP && _file != MkfFile::MKF_MGO)
		return nullptr;
	if (index < 0 || index >= _mkf->count())
		return nullptr;
	if (_file == MkfFile::MKF_DATA && index != 9 && index != 10 && index != 12)
		return nullptr;
	bh.bmfHeader.bfType = 0x4d42;
	bh.bmfHeader.bfReserved1 = bh.bmfHeader.bfReserved2 = 0;
	bh.bmfHeader.bfOffBits = sizeof(BitmapHeader);
	bh.bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
	bh.bmiHeader.biPlanes = 1;
	bh.bmiHeader.biBitCount = 8;
	bh.bmiHeader.biCompression = BI_RGB;
	bh.bmiHeader.biXPelsPerMeter = bh.bmiHeader.biYPelsPerMeter = 0;
	bh.bmiHeader.biClrUsed = bh.bmiHeader.biClrImportant = 0;
	pat = (unsigned char *)palette.ToPointer();
	for(i = 0; i < 256; i++)
	{
		bh.bmiColor[i].rgbRed = *pat++ << 2;
		bh.bmiColor[i].rgbGreen = *pat++ << 2;
		bh.bmiColor[i].rgbBlue = *pat++ << 2;
		bh.bmiColor[i].rgbReserved = 0;
	}
	BufferGroup bg = _mkf->extract(index);
	if (bg.count == 0)
		return nullptr;
	bmp = gcnew array <System::Drawing::Bitmap^>(bg.count);
	for(i = 0; i < bg.count; i++)
	{
		width = *(unsigned short *)bg.item[i].buffer;
		height = *(unsigned short *)(bg.item[i].buffer + 2);
		if (width & 0x3)
			w = ((width >> 2) + 1) << 2;
		else
			w = width;
		len = w * height;
		ptr = new unsigned char [len];
		memset(ptr, 0, len);
		rle_decode(bg.item[i].buffer, ptr, w, height, 0, 0);
		delete [] bg.item[i].buffer;
		bh.bmfHeader.bfSize = len + sizeof(BitmapHeader);
		bh.bmiHeader.biWidth = width;
		bh.bmiHeader.biHeight = height;
		bh.bmiHeader.biSizeImage = len;
		len = bh.bmiHeader.biSizeImage;
		buf = gcnew array<unsigned char>(sizeof(BitmapHeader) + len);
		Marshal::Copy(System::IntPtr(&bh), buf, 0, sizeof(BitmapHeader));
		Marshal::Copy(System::IntPtr(ptr), buf, sizeof(BitmapHeader), len);
		delete [] ptr;
		mem = gcnew System::IO::MemoryStream(buf);
		bmp[i] = gcnew System::Drawing::Bitmap(mem);
		bmp[i]->RotateFlip(System::Drawing::RotateFlipType::RotateNoneFlipY);
	}
	delete [] bg.item;
	return bmp;
}

array<System::Drawing::Bitmap^> ^PalTools::PalMkf::GetMovie(int index, System::IntPtr palette)
{
	array<System::Drawing::Bitmap^> ^bmp;
	System::IO::MemoryStream ^mem;
	array<unsigned char> ^buf;
	BitmapHeader bh;
	unsigned char *ptr, *pat;
	int i;
	if (_file != MkfFile::MKF_RNG)
		return nullptr;
	if (index < 0 || index >= _mkf->count())
		return nullptr;
	bh.bmfHeader.bfType = 0x4d42;
	bh.bmfHeader.bfReserved1 = bh.bmfHeader.bfReserved2 = 0;
	bh.bmfHeader.bfOffBits = sizeof(BitmapHeader);
	bh.bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
	bh.bmiHeader.biPlanes = 1;
	bh.bmiHeader.biBitCount = 8;
	bh.bmiHeader.biCompression = BI_RGB;
	bh.bmiHeader.biXPelsPerMeter = bh.bmiHeader.biYPelsPerMeter = 0;
	bh.bmiHeader.biClrUsed = bh.bmiHeader.biClrImportant = 0;
	bh.bmfHeader.bfSize = 64000 + sizeof(BitmapHeader);
	bh.bmiHeader.biWidth = 320;
	bh.bmiHeader.biHeight = 200;
	bh.bmiHeader.biSizeImage = 64000;
	pat = (unsigned char *)palette.ToPointer();
	for(i = 0; i < 256; i++)
	{
		bh.bmiColor[i].rgbRed = *pat++ << 2;
		bh.bmiColor[i].rgbGreen = *pat++ << 2;
		bh.bmiColor[i].rgbBlue = *pat++ << 2;
		bh.bmiColor[i].rgbReserved = 0;
	}
	BufferGroup bg = _mkf->extract(index);
	if (bg.count == 0)
		return nullptr;
	bmp = gcnew array <System::Drawing::Bitmap^>(bg.count);
	ptr = new unsigned char [64000];
	for(i = 0; i < bg.count; i++)
	{
		rng_decode(bg.item[i].buffer, ptr);
		delete [] bg.item[i].buffer;
		buf = gcnew array<unsigned char>(sizeof(BitmapHeader) + 64000);
		Marshal::Copy(System::IntPtr(&bh), buf, 0, sizeof(BitmapHeader));
		Marshal::Copy(System::IntPtr(ptr), buf, sizeof(BitmapHeader), 64000);
		mem = gcnew System::IO::MemoryStream(buf);
		bmp[i] = gcnew System::Drawing::Bitmap(mem);
		bmp[i]->RotateFlip(System::Drawing::RotateFlipType::RotateNoneFlipY);
	}
	delete [] ptr;
	delete [] bg.item;
	return bmp;
}

array<unsigned char> ^PalTools::PalMkf::GetWave(int index)
{
	unsigned char *buf, *ptr, block;
	int len, length, total = 0;
	array<unsigned char> ^tmp, ^tmp1;
	WAVEFILEHEADER hdr;
	System::IO::MemoryStream ^temp;
	if (_file != MkfFile::MKF_VOC)
		return nullptr;
	if (index < 0 || index >= _mkf->count())
		return nullptr;
	buf = _mkf->rawdata(index);
	len = _mkf->rawlength(index);
	ptr = buf + *(unsigned short *)(buf + 0x14);
	hdr.wFormatTag = 1;
	hdr.nChannels = 1;
	temp = gcnew System::IO::MemoryStream();
	while(block = *ptr++)
	{
		length = *(unsigned int *)ptr & 0xffffff; ptr += 3;
		switch(block)
		{
		case 1:
			hdr.nSamplesPerSec = 1000000 / (256 - *ptr++);
			hdr.wBitsPerSample = 8;
			if (*ptr++ != 0)
			{
				delete [] buf;
				return nullptr;
			}
			length -= 2;
		case 2:
			tmp = gcnew array<unsigned char>(length);
			Marshal::Copy(System::IntPtr(ptr), tmp, 0, length);
			temp->Write(tmp, 0, length);
			total += length;
		case 3:
		case 4:
		case 5:
		case 6:
		case 7:
		case 8:
		case 9:
		default:
			ptr += length;
			break;
		}
	}
	delete [] buf;
	hdr.nBlockAlign = hdr.nChannels * hdr.wBitsPerSample / 8;
	hdr.nAvgBytesPerSec = hdr.nBlockAlign * hdr.nSamplesPerSec;
	hdr.id = 0x46464952;
	hdr.wave_id = 0x45564157;
	hdr.fmt_thunk = 0x20746d66;
	hdr.data_thunk = 0x61746164;
	hdr.len = sizeof(WAVEFILEHEADER) - 8 + total;
	hdr.fmt_len = 0x10;
	hdr.data_len = total;
	tmp1 = gcnew array<unsigned char>(hdr.len + 8);
	Marshal::Copy(System::IntPtr(&hdr), tmp1, 0, sizeof(WAVEFILEHEADER));
	temp->Seek(0, System::IO::SeekOrigin::Begin);
	temp->Read(tmp1, sizeof(WAVEFILEHEADER), total);
	return tmp1;
}

PalTools::PalPalette::PalPalette(System::String ^path)
{
	System::IntPtr _name = Marshal::StringToHGlobalAnsi(path);
	PAL_MKF_R *mkf;
	char *name = (char *)_name.ToPointer();
	
	count = 0;
	try
	{
		mkf = new PAL_MKF_R(name, MKF_PAT);
		Marshal::FreeHGlobal(_name);
	}
	catch(ERROR_NO &)
	{
		Marshal::FreeHGlobal(_name);
		throw gcnew System::IO::FileNotFoundException(System::String::Concat("无法找到文件", path));
	}
	count = mkf->count();
	palette = new BufferItem [count];
	for(int i = 0; i < mkf->count(); i++)
	{
		palette[i].size = mkf->rawlength(i);
		palette[i].buffer = mkf->rawdata(i);
	}
	delete mkf;
}

PalTools::PalPalette::~PalPalette()
{
	if (count)
	{
		for(int i = 0; i < count; i++)
			delete [] palette[i].buffer;
		delete [] palette;
	}
}

System::IntPtr PalTools::PalPalette::GetPalette(int index)
{
	switch(index)
	{
	case 0:
		return GetPalette(0, false);
	case 1:
		return GetPalette(0, true);
	case 2:
	case 3:
	case 4:
	case 5:
	case 6:
		return GetPalette(index - 1, false);
	case 7:
		return GetPalette(5, true);
	case 8:
	case 9:
	case 10:
		return GetPalette(index - 2, false);
	default:
		return System::IntPtr::Zero;
	}
}

System::IntPtr PalTools::PalPalette::GetPalette(int index, bool night)
{
	unsigned char *pat;
	if (index < 0 || index >= count)
		return System::IntPtr::Zero;
	pat = palette[index].buffer;
	if ((index == 0 || index == 5) && night)
		pat += 768;
	return System::IntPtr(pat);
}

void PalTools::MultiMediaPlayer::PlayMidi(array<unsigned char> ^buffer)
{
	unsigned char *buf;
	Multi_Media_Player *mmp;
	int len = buffer->GetLength(0);
	buf = new unsigned char [len];
	Marshal::Copy(buffer, 0, System::IntPtr(buf), len);
	try
	{
		mmp = new Multi_Media_Player(buf, len);
	}
	catch(ERROR_NO &)
	{
		throw gcnew System::Exception("DirectMusic异常");
	}
}

PalTools::PalItem::PalItem(System::String ^data_path, System::String ^sss_path, System::String ^msg_path, System::String ^word_path)
{
	_item = NULL;
	System::IntPtr data_name = Marshal::StringToHGlobalAnsi(data_path);
	System::IntPtr sss_name = Marshal::StringToHGlobalAnsi(sss_path);
	System::IntPtr msg_name = Marshal::StringToHGlobalAnsi(msg_path);
	System::IntPtr word_name = Marshal::StringToHGlobalAnsi(word_path);

	try
	{
		_item = new PAL_ITEM((char *)data_name.ToPointer(), (char *)sss_name.ToPointer(), (char *)msg_name.ToPointer(), (char *)word_name.ToPointer());
		Marshal::FreeHGlobal(data_name);
		Marshal::FreeHGlobal(sss_name);
		Marshal::FreeHGlobal(msg_name);
		Marshal::FreeHGlobal(word_name);
	}
	catch(ERROR_NO &)
	{
		Marshal::FreeHGlobal(data_name);
		Marshal::FreeHGlobal(sss_name);
		Marshal::FreeHGlobal(msg_name);
		Marshal::FreeHGlobal(word_name);
		throw gcnew System::IO::FileNotFoundException("无法找到文件");
	}

	if (_item->isdos())
	{
		int i, len;
		TypedBufferGroup<WordData> wd = _item->word();
		TypedBufferGroup<unsigned int> idx = _item->msg_index();
		unsigned char *msg = (unsigned char *)_item->message();
		len = wd.count * 10;
		array<unsigned char> ^tmp = gcnew array<unsigned char>(len);
		System::Text::Encoding ^gbk = System::Text::Encoding::GetEncoding(936);
		System::Text::Encoding ^big5 = System::Text::Encoding::GetEncoding(950);
		Marshal::Copy(System::IntPtr(wd.item[i].data), tmp, 0, len);
		tmp = System::Text::Encoding::Convert(big5, gbk, tmp);
		Marshal::Copy(tmp, 0, System::IntPtr(wd.item[i].data), tmp->GetLength(0));
		len = idx.item[idx.count];
		tmp = gcnew array<unsigned char>(len);
		Marshal::Copy(System::IntPtr(msg), tmp, 0, len);
		tmp = System::Text::Encoding::Convert(big5, gbk, tmp);
		Marshal::Copy(tmp, 0, System::IntPtr(msg), tmp->GetLength(0));
	}
}

PalTools::PalItem::~PalItem()
{
	if (_item)
		delete _item;
}

array<System::String^> ^PalTools::PalItem::Message()
{
	unsigned char *msg = (unsigned char *)_item->message();
	TypedBufferGroup<unsigned int> idx = _item->msg_index();
	array<System::String^> ^temp = gcnew array<System::String^>(idx.count);
	for(int i = 0; i < idx.count; i++)
		temp[i] = Marshal::PtrToStringAnsi(System::IntPtr(msg + idx.item[i]), idx.item[i + 1] - idx.item[i]);
	return temp;
}

System::String ^PalTools::PalItem::Message(int index)
{
	if (index < 0 || index >= _item->msg_index().count)
		throw gcnew System::Exception("指定的索引超出范围");
	else
	{
		unsigned char *msg = (unsigned char *)_item->message();
		TypedBufferGroup<unsigned int> idx = _item->msg_index();
		return Marshal::PtrToStringAnsi(System::IntPtr(msg + idx.item[index]), idx.item[index + 1] - idx.item[index]);
	}
}

array<System::String^> ^PalTools::PalItem::Word()
{
	TypedBufferGroup<WordData> wd = _item->word();
	array<System::String^> ^temp;
	temp = gcnew array<System::String^>(wd.count);
	for(int i = 0; i < wd.count; i++)
		temp[i] = Marshal::PtrToStringAnsi(System::IntPtr(wd.item[i].data), 10);
	return temp;
}

System::String ^PalTools::PalItem::Word(int index)
{
	if (index < 0 || index >= _item->word().count)
		throw gcnew System::Exception("指定的索引超出范围");
	else
	{
		WordData tmp = _item->word(index);
		return Marshal::PtrToStringAnsi(System::IntPtr(tmp.data), 10);
	}
}

PalTools::PalTypedBufferGroup<PalTools::PalShopData> PalTools::PalItem::Shop()
{
	TypedBufferGroup<ShopData> tbg = _item->shop();
	PalTypedBufferGroup<PalShopData> ptbg;
	pin_ptr<array<PalShopData>^> p;
	ptbg.Count = tbg.count;
	ptbg.Item = gcnew array<PalShopData>(tbg.count);
	p = &ptbg.Item;
	memcpy(p, tbg.item, tbg.count * sizeof(ShopData));
	return ptbg;
}

PalTools::PalShopData PalTools::PalItem::Shop(int index)
{
	if (index < 0 || index >= _item->shop().count)
		throw gcnew System::Exception("指定的索引超出范围");
	else
	{
		ShopData tmp = _item->shop(index);
		PalShopData temp;
		pin_ptr<PalShopData> p = &temp;
		memcpy(p, &tmp, sizeof(ShopData));
		return temp;
	}
}

PalTools::PalTypedBufferGroup<PalTools::PalTeamData> PalTools::PalItem::Team()
{
	TypedBufferGroup<TeamData> tbg = _item->team();
	PalTypedBufferGroup<PalTeamData> ptbg;
	pin_ptr<array<PalTeamData>^> p;
	ptbg.Count = tbg.count;
	ptbg.Item = gcnew array<PalTeamData>(tbg.count);
	p = &ptbg.Item;
	memcpy(p, tbg.item, tbg.count * sizeof(TeamData));
	return ptbg;
}

PalTools::PalTeamData PalTools::PalItem::Team(int index)
{
	if (index < 0 || index >= _item->team().count)
		throw gcnew System::Exception("指定的索引超出范围");
	else
	{
		TeamData tmp = _item->team(index);
		PalTeamData temp;
		pin_ptr<PalTeamData> p = &temp;
		memcpy(p, &tmp, sizeof(TeamData));
		return temp;
	}
}

PalTools::PalTypedBufferGroup<PalTools::PalMonsterData> PalTools::PalItem::Monster()
{
	TypedBufferGroup<MonsterData> tbg = _item->monster();
	PalTypedBufferGroup<PalMonsterData> ptbg;
	pin_ptr<array<PalMonsterData>^> p;
	ptbg.Count = tbg.count;
	ptbg.Item = gcnew array<PalMonsterData>(tbg.count);
	p = &ptbg.Item;
	memcpy(p, tbg.item, tbg.count * sizeof(MonsterData));
	return ptbg;
}

PalTools::PalMonsterData PalTools::PalItem::Monster(int index)
{
	if (index < 0 || index >= _item->monster().count)
		throw gcnew System::Exception("指定的索引超出范围");
	else
	{
		MonsterData tmp = _item->monster(index);
		PalMonsterData temp;
		pin_ptr<PalMonsterData> p = &temp;
		memcpy(p, &tmp, sizeof(MonsterData));
		return temp;
	}
}

PalTools::PalTypedBufferGroup<PalTools::PalObjectData> PalTools::PalItem::Object()
{
	PalTypedBufferGroup<PalObjectData> ptbg;
	int i;
	if (_item->isdos())
	{
		TypedBufferGroup<ObjectDataDos> tbg = _item->object_dos();
		ptbg.Count = tbg.count;
		ptbg.Item = gcnew array<PalObjectData>(tbg.count);
		for(i = 0; i < tbg.count; i++)
		{
			ptbg.Item[i].Param.Param0 = tbg.item[i].param[0];
			ptbg.Item[i].Param.Param1 = tbg.item[i].param[1];
			ptbg.Item[i].Param.Param2 = tbg.item[i].param[2];
			ptbg.Item[i].Param.Param3 = tbg.item[i].param[3];
			ptbg.Item[i].Param.Param4 = tbg.item[i].param[4];
			ptbg.Item[i].Param.Param5 = 0;
			ptbg.Item[i].Param.Param6 = tbg.item[i].param[5];
		}
	}
	else
	{
		TypedBufferGroup<ObjectDataWin> tbg = _item->object_win();
		ptbg.Count = tbg.count;
		ptbg.Item = gcnew array<PalObjectData>(tbg.count);
		pin_ptr<array<PalObjectData>^> p = &ptbg.Item;
		memcpy(p, tbg.item, tbg.count * sizeof(ObjectDataWin));
	}
	return ptbg;
}

PalTools::PalObjectData PalTools::PalItem::Object(int index)
{
	PalObjectData temp;
	if (_item->isdos())
		if (index < 0 || index >= _item->object_dos().count)
			throw gcnew System::Exception("指定的索引超出范围");
		else
		{
			ObjectDataDos tmp = _item->object_dos(index);
			temp.Param.Param0 = tmp.param[0];
			temp.Param.Param1 = tmp.param[1];
			temp.Param.Param2 = tmp.param[2];
			temp.Param.Param3 = tmp.param[3];
			temp.Param.Param4 = tmp.param[4];
			temp.Param.Param5 = 0;
			temp.Param.Param6 = tmp.param[5];
		}
	else
		if (index < 0 || index >= _item->object_win().count)
			throw gcnew System::Exception("指定的索引超出范围");
		else
		{
			ObjectDataWin tmp = _item->object_win(index);
			temp.Param.Param0 = tmp.param[0];
			temp.Param.Param1 = tmp.param[1];
			temp.Param.Param2 = tmp.param[2];
			temp.Param.Param3 = tmp.param[3];
			temp.Param.Param4 = tmp.param[4];
			temp.Param.Param5 = tmp.param[5];
			temp.Param.Param6 = tmp.param[6];
		}
	return temp;
}

PalTools::PalTypedBufferGroup<PalTools::PalEventScript> PalTools::PalItem::Script()
{
	PalTypedBufferGroup<PalEventScript> ptbg;
	TypedBufferGroup<EventScript> tbg = _item->event_script();
	ptbg.Count = tbg.count;
	ptbg.Item = gcnew array<PalEventScript>(tbg.count);
	pin_ptr<array<PalEventScript>^> p = &ptbg.Item;
	memcpy(p, tbg.item, tbg.count * sizeof(EventScript));
	return ptbg;
}

PalTools::PalEventScript PalTools::PalItem::Script(int index)
{
	if (index < 0 || index >= _item->event_script().count)
		throw gcnew System::Exception("指定的索引超出范围");
	else
	{
		PalEventScript pes;
		EventScript es = _item->event_script(index);
		pes.Instruction = es.ins;
		pes.Parameter0 = es.param0;
		pes.Parameter1 = es.param1;
		pes.Parameter2 = es.param2;
		return pes;
	}
}

Multi_Media_Player::Multi_Media_Player(unsigned char *buf, int len) throw(...)
{
    DMUS_OBJECTDESC desc;
	GUID guid = GUID_NOTIFICATION_PERFORMANCE;
	DWORD threadid;

	thr = _notify.hNotify = NULL;
	_notify.pPerformance = pPerformance = NULL;
	pSegment = NULL;
	pLoader = NULL;
	_len = 0;
	_notify.obj = this;
	_buf = buf;
	_len = len;

	memset(&desc, 0, sizeof(DMUS_OBJECTDESC));
	if (CoInitialize(NULL) < 0)
	{
		delete [] buf;
		throw DIRECTMUSIC_ERROR;
	}
	if (CoCreateInstance(CLSID_DirectMusicLoader, NULL, CLSCTX_INPROC, IID_IDirectMusicLoader8, (void**)&pLoader) < 0)
	{
		delete [] buf;
		throw DIRECTMUSIC_ERROR;
	}
	if (CoCreateInstance(CLSID_DirectMusicPerformance, NULL, CLSCTX_INPROC, IID_IDirectMusicPerformance8, (void**)&pPerformance) < 0)
	{
		pLoader->Release();
		delete [] buf;
		throw DIRECTMUSIC_ERROR;
	}
	if (pPerformance->InitAudio(NULL, NULL, NULL, DMUS_APATH_SHARED_STEREOPLUSREVERB, 64, DMUS_AUDIOF_ALL, NULL) != S_OK)
	{
		pPerformance->Release();
		pLoader->Release();
		delete [] buf;
		throw DIRECTMUSIC_ERROR;
	}

	desc.dwSize = sizeof(DMUS_OBJECTDESC);
    desc.guidClass = CLSID_DirectMusicSegment;
    desc.pbMemData = buf;
    desc.llMemLength = len;
    desc.dwValidData = DMUS_OBJ_CLASS | DMUS_OBJ_MEMORY;
	_notify.pPerformance = pPerformance;

	if (pLoader->GetObject(&desc, IID_IDirectMusicSegment, (void**)&pSegment) != S_OK)
	{
		delete [] _buf;
		pPerformance->Release();
		pLoader->Release();
		throw DIRECTMUSIC_ERROR;
	}
	if (pSegment->Download(pPerformance) != S_OK)
	{
		delete [] _buf;
		pPerformance->Release();
		pLoader->Release();
		throw DIRECTMUSIC_ERROR;
	}

	if (pSegment->SetParam(GUID_StandardMIDIFile, -1, DMUS_SEG_ALLTRACKS, 0, pPerformance) != S_OK)
	{
		delete [] _buf;
		pPerformance->Release();
		pLoader->Release();
		throw DIRECTMUSIC_ERROR;
	}

	if (pPerformance->AddNotificationType(guid) != S_OK)
	{
		delete [] _buf;
		pPerformance->Release();
		pLoader->Release();
		throw DIRECTMUSIC_ERROR;
	}

	_notify.hNotify = CreateEvent(NULL, FALSE, FALSE, NULL);
	if (_notify.hNotify == NULL)
	{
		delete [] _buf;
		pPerformance->Release();
		pLoader->Release();
		throw DIRECTMUSIC_ERROR;
	}

	if (pPerformance->SetNotificationHandle(_notify.hNotify, 0) != S_OK)
	{
		delete [] _buf;
		CloseHandle(_notify.hNotify);
		pPerformance->Release();
		pLoader->Release();
		throw DIRECTMUSIC_ERROR;
	}

	if ((thr = CreateThread(NULL, 0, EventThreadProc, &_notify, 0, &threadid)) == NULL)
	{
		delete [] _buf;
		CloseHandle(_notify.hNotify);
		pPerformance->Release();
		pLoader->Release();
		throw DIRECTMUSIC_ERROR;
	}

	if (pPerformance->PlaySegmentEx(pSegment, NULL, NULL, 0, 0, NULL, NULL, NULL) != S_OK)
	{
		delete [] _buf;
		CloseHandle(_notify.hNotify);
		pPerformance->Release();
		pLoader->Release();
		throw DIRECTMUSIC_ERROR;
	}
}

Multi_Media_Player::~Multi_Media_Player()
{
	if (pLoader)
		pLoader->Release();
	if (pPerformance)
		pPerformance->Release();
	if (pSegment)
		pSegment->Release();
	if (thr)
		CloseHandle(thr);
	if (_notify.hNotify)
		CloseHandle(_notify.hNotify);
	if (_buf)
		delete [] _buf;
}

DWORD WINAPI EventThreadProc(LPVOID lpParameter)
{
	bool flag = true;
	DWORD dwResult;
	DMUS_NOTIFICATION_PMSG* pPmsg;
	NotifyData *data = (NotifyData *)lpParameter;

	while(flag)
	{
		dwResult = WaitForSingleObject(data->hNotify, 100);
		while (S_OK == data->pPerformance->GetNotificationPMsg(&pPmsg))
		{
			if (pPmsg->guidNotificationType == GUID_NOTIFICATION_PERFORMANCE &&
				(pPmsg->dwNotificationOption == DMUS_NOTIFICATION_MUSICALMOSTEND ||
				pPmsg->dwNotificationOption == DMUS_NOTIFICATION_MUSICSTOPPED))
				flag = false;
			data->pPerformance->FreePMsg((DMUS_PMSG*)pPmsg); 
		}
	}
	delete data->obj;
	return 0;
}