#include <stdio.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <io.h>
#include <stdlib.h>
#include <memory.h>
#include <string.h>

#include "library.h"

PAL_MKF::PAL_MKF(const char *name, MKF_FILE file) throw(...)
{
	int start, end, fd;
	fd = _open(name, _O_BINARY | _O_RDONLY);
	if (fd == -1)
	{
		_errorno = FILE_NOT_EXIST;
		throw FILE_NOT_EXIST;
	}
	_read(fd, &start, 4);
	_buffer.count = (start >> 2) - 1;
	_buffer.item = new BufferItem [_buffer.count];
	for(int i = 0; i < _buffer.count; i++)
	{
		_lseek(fd, i * 4, SEEK_SET);
		_read(fd, &start, 4);
		_read(fd, &end, 4);
		_lseek(fd, start, SEEK_SET);
		_buffer.item[i].size = end - start;
		if (_buffer.item[i].size > 0)
		{
			_buffer.item[i].buffer = new unsigned char [_buffer.item[i].size];
			_read(fd, _buffer.item[i].buffer, _buffer.item[i].size);
		}
		else
			_buffer.item[i].buffer = NULL;
	}
	_close(fd);
	this->file = file; packed = false;
	if (file == MKF_MIDI || file == MKF_MUS || file == MKF_VOC)
		is_dos = true;
	else if (file == MKF_ABC || file == MKF_MAP || file == MKF_F ||	file == MKF_FBP || file == MKF_FIRE || file == MKF_MGO)
	{
		int i;
		for(i = 0; _buffer.item[i].buffer == NULL; i++);
		if (_buffer.item[i].buffer[0] == 'Y' && _buffer.item[i].buffer[1] == 'J' && _buffer.item[i].buffer[2] == '_' && _buffer.item[i].buffer[3] == '1')
			is_dos = true;
		else
			is_dos = false;
		packed = true;
	}
	else if (file == MKF_DATA)
		if (_buffer.item[8].buffer == NULL)
			is_dos = false;
		else
			is_dos = true;
	else
		is_dos = false;
}

PAL_MKF::~PAL_MKF()
{
	for(int i = 0; i < _buffer.count; i++)
		if (_buffer.item[i].buffer)
			delete [] _buffer.item[i].buffer;
	delete [] _buffer.item;
}

int PAL_MKF::count() const
{
	return _buffer.count;
}

ERROR_NO PAL_MKF::errorno() const
{
	return _errorno;
}

unsigned char *PAL_MKF::unpack(int index, int &length) const
{
	unsigned char *dest;
	if ((packed || (file == MKF_DATA && index == 8)) && _buffer.item[index].size > 0)
	{
		if (is_dos)
		{
			length = *(int *)(_buffer.item[index].buffer + 4);
			dest = deyj1(_buffer.item[index].buffer);
		}
		else
		{
			length = *(int *)_buffer.item[index].buffer;
			dest = new unsigned char [length];
			decompress(_buffer.item[index].buffer, dest);
		}
		return dest;
	}
	else if (_buffer.item[index].size > 0)
	{
		length = _buffer.item[index].size;
		dest = new unsigned char [length];
		memcpy(dest, _buffer.item[index].buffer, length);
		return dest;
	}
	else
	{
		length = 0;
		return NULL;
	}
}

int PAL_MKF::pack(const unsigned char *data, int length, int index) throw(...)
{
	int size = 0;
	if (data == NULL)
		return 0;
	if ((data < _buffer.item[index].buffer && data + length >= _buffer.item[index].buffer) || (data >= _buffer.item[index].buffer && data < _buffer.item[index].buffer + _buffer.item[index].size))
	{
		_errorno = BUFFER_OVERLAPPED;
		throw BUFFER_OVERLAPPED;
	}
	if ((packed || (file == MKF_DATA && index == 8)) && length > 0)
	{
		size = compress(data, NULL, length);
		_buffer.item[index].size = size;
		if (_buffer.item[index].buffer)
			delete [] _buffer.item[index].buffer;
		_buffer.item[index].buffer = new unsigned char [size];
		compress(data, _buffer.item[index].buffer, length);
	}
	else if (length > 0)
	{
		size = length;
		_buffer.item[index].size = size;
		if (_buffer.item[index].buffer)
			delete [] _buffer.item[index].buffer;
		_buffer.item[index].buffer = new unsigned char [size];
		memcpy(_buffer.item[index].buffer, data, size);
	}
	return size;
}

void PAL_MKF::save(const char *name) throw(...)
{
	int i, start, fd;
	fd = _open(name, _O_BINARY | _O_WRONLY | _O_CREAT | _O_TRUNC, _S_IWRITE);
	if (fd == -1)
	{
		_errorno = FILE_NOT_WRITABLE;
		throw FILE_NOT_WRITABLE;
	}
	start = (_buffer.count + 1) << 2;
	for(i = 0; i < _buffer.count; i++)
	{
		_write(fd, &start, 4);
		start += _buffer.item[i].size;
	}
	_write(fd, &start, 4);
	for(i = 0; i < _buffer.count; i++)
		if (_buffer.item[i].size > 0)
			_write(fd, _buffer.item[i].buffer, _buffer.item[i].size);
	_close(fd);
}

BufferGroup PAL_MKF::extract(int index) throw(...)
{
	BufferGroup buf = {NULL, 0};
	int i, *start, _start, _end, len;
	unsigned short *pos;
	unsigned char *temp;
	if (_buffer.item[index].size == 0)
		return buf;
	switch(file)
	{
	case MKF_RNG:
		start = (int *)_buffer.item[index].buffer;
		buf.count = (*start >> 2) - 2;
		buf.item = new BufferItem [buf.count];
		for(i = 0; i < buf.count; i++)
		{
			start = (int *)_buffer.item[index].buffer + i;
			buf.item[i].size = *(int *)(_buffer.item[index].buffer + *start);
			buf.item[i].buffer = new unsigned char [buf.item[i].size];
			decompress(_buffer.item[index].buffer + *start, buf.item[i].buffer);
		}
		break;
	case MKF_DATA:
		if (index != 9 && index != 10 && index != 12)
		{
			_errorno = NOT_GROUPED_FILE;
			throw NOT_GROUPED_FILE;
		}
	case MKF_ABC:
	case MKF_BALL:
	case MKF_F:
	case MKF_FIRE:
	case MKF_GOP:
	case MKF_MGO:
	case MKF_RGM:
		temp = unpack(index, len);
		pos = (unsigned short *)temp;
		buf.count = 1; pos++;
		for(i = 1; i < *(unsigned short *)temp; i++, pos++)
			if (*pos < *(pos - 1) || (*pos << 1) >= len)
				continue;
			else
				buf.count++;
		buf.item = new BufferItem [buf.count];
		for(i = 0; i < buf.count; i++)
		{
			pos = (unsigned short *)temp + i;
			_start = (int)*pos << 1;
			if (i == buf.count - 1)
				_end = len;
			else
				_end = (int)*(pos + 1) << 1;
			buf.item[i].size = _end - _start;
			buf.item[i].buffer = new unsigned char [buf.item[i].size];
			memcpy(buf.item[i].buffer, temp + _start, buf.item[i].size);
		}
		delete [] temp;
		break;
	default:
		_errorno = NOT_GROUPED_FILE;
		throw NOT_GROUPED_FILE;
	}
	return buf;
}

int PAL_MKF::package(BufferGroup buf, int index) throw(...)
{
	int i, *_pos, _ptr, len = 0, *len_t;
	unsigned short *pos, ptr;
	unsigned char *temp, *tmp;
	switch(file)
	{
	case MKF_RNG:
		len_t = new int [buf.count];
		for(i = 0; i < buf.count; i++)
		{
			len_t[i] = compress(buf.item[i].buffer, NULL, buf.item[i].size);
			len += len_t[i];
		}
		len += (buf.count + 2) << 2;
		if (_buffer.item[index].buffer)
			delete [] _buffer.item[index].buffer;
		_buffer.item[index].size = len;
		_buffer.item[index].buffer = new unsigned char [len];
		_pos = (int *)_buffer.item[index].buffer;
		_ptr = (buf.count + 2) << 2;
		for(i = 0; i < buf.count; i++)
		{
			*_pos++ = _ptr;
			_ptr += len_t[i];
		}
		*_pos++ = _ptr; *_pos++ = _ptr;
		delete [] len_t;
		temp = (unsigned char *)_pos;
		for(i = 0; i < buf.count; i++)
		{
			len = compress(buf.item[i].buffer, temp, buf.item[i].size);
			temp += len;
		}
		break;
	case MKF_DATA:
		if (index != 9 && index != 10 && index != 12)
		{
			_errorno = NOT_GROUPED_FILE;
			throw NOT_GROUPED_FILE;
		}
	case MKF_ABC:
	case MKF_BALL:
	case MKF_F:
	case MKF_FIRE:
	case MKF_GOP:
	case MKF_MGO:
	case MKF_RGM:
		for(i = 0; i < buf.count; i++)
			len += buf.item[i].size;
		len += (buf.count + 1) << 1;
		tmp = new unsigned char [len];
		pos = (unsigned short *)tmp;
		ptr = buf.count + 1;
		for(i = 0; i < buf.count; i++)
		{
			*pos++ = ptr;
			ptr += (buf.item[i].size >> 1);
		}
		*pos++ = 0; temp = (unsigned char *)pos;
		for(i = 0; i < buf.count; i++)
		{
			memcpy(temp, buf.item[i].buffer, buf.item[i].size);
			temp += buf.item[i].size;
		}
		len = pack(tmp, len, index);
		delete [] tmp;
		break;
	default:
		_errorno = NOT_GROUPED_FILE;
		throw NOT_GROUPED_FILE;
	}
	return len;
}

BufferItem PAL_MKF::rawdata(const int index) throw(...)
{
	if (index < 0 || index >= _buffer.count)
		throw INDEX_OUT_OF_RANGE;	
	else
		return _buffer.item[index];
}

PAL_MKF_R::PAL_MKF_R(const char *name, MKF_FILE file) throw(...)
{
	int start, fd;
	_start = _length = NULL;
	fd = _open(name, _O_BINARY | _O_RDONLY);
	if (fd == -1)
		throw FILE_NOT_EXIST;
	_name = new char [strlen(name) + 1];
	strcpy(_name, name);
	_read(fd, &start, 4);
	_count = (start >> 2) - 1;
	_start = new int [_count];
	_length = new int [_count];
	_len = new int [_count];
	for(int i = 0; i < _count; i++)
	{
		_start[i] = start;
		_read(fd, &start, 4);
		_len[i] = _length[i] = start - _start[i];
	}
	this->file = file; packed = false;
	if (file == MKF_MIDI || file == MKF_MUS || file == MKF_VOC)
		is_dos = true;
	else if (file == MKF_ABC || file == MKF_MAP || file == MKF_F ||	file == MKF_FBP || file == MKF_FIRE || file == MKF_MGO)
	{
		int i;
		for(i = 0; _length[i] == 0; i++);
		_lseek(fd, _start[i], SEEK_SET);
		_read(fd, &start, 4);
		if (start == 0x315F4A59)
			is_dos = true;
		else
			is_dos = false;
		packed = true;
		for(i = 0; i < _count; i++)
			if (_length[i] > 0)
			{
				if (is_dos)
					_lseek(fd, _start[i] + 4, SEEK_SET);
				else
					_lseek(fd, _start[i], SEEK_SET);
				_read(fd, &_len[i], 4);
			}
	}
	else if (file == MKF_DATA)
		if (_length[8] == 0)
			is_dos = false;
		else
		{
			_lseek(fd, _start[8] + 4, SEEK_SET);
			_read(fd, &_len[8], 4);
			is_dos = true;
		}
	else if (file == MKF_RNG)
	{
		int i;
		unsigned int s;
		for(i = 0; _length[i] == 0; i++);
		_lseek(fd, _start[i], SEEK_SET);
		_read(fd, &s, 4);
		start = _start[i] + s;
		_lseek(fd, start, SEEK_SET);
		_read(fd, &start, 4);
		if (start == 0x315F4A59)
			is_dos = true;
		else
			is_dos = false;
		//packed = true;
	}
	else
		is_dos = false;
	_lseek(fd, 0, SEEK_END);
	_filelen = _tell(fd);
	_close(fd);
}

PAL_MKF_R::~PAL_MKF_R()
{
	if (_name)
		delete [] _name;
	if (_start)
		delete [] _start;
	if (_length)
		delete [] _length;
	if (_len)
		delete [] _len;
}

bool PAL_MKF_R::dos() const
{
	return is_dos;
}

int PAL_MKF_R::count() const
{
	return _count;
}

int PAL_MKF_R::offset(int index) const
{
	if (index < 0 || index >= _count)
		throw INDEX_OUT_OF_RANGE;
	return _start[index];
}

int PAL_MKF_R::rawlength() const
{
	return _filelen;
}

unsigned char *PAL_MKF_R::rawdata() const
{
	unsigned char *buf;
	int len, fd;
	fd = _open(_name, _O_BINARY | _O_RDONLY);
	if (fd == -1)
		throw FILE_NOT_EXIST;
	_lseek(fd, 0, SEEK_END);
	len = _tell(fd);
	_lseek(fd, 0, SEEK_SET);
	buf = new unsigned char [len];
	_read(fd, buf, len);
	_close(fd);
	return buf;
}

int PAL_MKF_R::rawlength(int index) const throw(...)
{
	if (index < 0 || index >= _count)
		throw INDEX_OUT_OF_RANGE;
	return _length[index];
}

unsigned char *PAL_MKF_R::rawdata(int index) throw(...)
{
	unsigned char *buf;
	int fd;
	if (index < 0 || index >= _count)
		throw INDEX_OUT_OF_RANGE;
	if (_length[index] == 0)
		return NULL;
	fd = _open(_name, _O_BINARY | _O_RDONLY);
	if (fd == -1)
		throw FILE_NOT_EXIST;
	buf = new unsigned char [_length[index]];
	_lseek(fd, _start[index], SEEK_SET);
	_read(fd, buf, _length[index]);
	_close(fd);
	return buf;
}

int PAL_MKF_R::length(int index) const throw(...)
{
	if (index < 0 || index >= _count)
		throw INDEX_OUT_OF_RANGE;
	if ((packed || (file == MKF_DATA && index == 8)) && _length[index] > 0)
		return _len[index];
	else
		return _length[index];
}

unsigned char *PAL_MKF_R::data(int index) const throw(...)
{
	unsigned char *dest;
	int fd;
	if (index < 0 || index >= _count)
		throw INDEX_OUT_OF_RANGE;
	if ((packed || (file == MKF_DATA && index == 8)) && _length[index] > 0)
	{
		fd = _open(_name, _O_BINARY | _O_RDONLY);
		if (fd == -1)
			throw FILE_NOT_EXIST;
		unsigned char *buffer = new unsigned char [_length[index]];
		_lseek(fd, _start[index], SEEK_SET);
		_read(fd, buffer, _length[index]);
		if (is_dos)
			dest = deyj1(buffer);
		else
		{
			dest = new unsigned char [*(int *)buffer];
			decompress(buffer, dest);
		}
		delete [] buffer;
		_close(fd);
		return dest;
	}
	else if (_length[index] > 0)
	{
		fd = _open(_name, _O_BINARY | _O_RDONLY);
		if (fd == -1)
			throw FILE_NOT_EXIST;
		dest = new unsigned char [_length[index]];
		_lseek(fd, _start[index], SEEK_SET);
		_read(fd, dest, _length[index]);
		_close(fd);
		return dest;
	}
	else
		return NULL;
}

BufferGroup PAL_MKF_R::extract(int index) const throw(...)
{
	BufferGroup buf = {NULL, 0};
	int i, *start, _start, _end, len;
	unsigned short *pos;
	unsigned char *temp;
	if (index < 0 || index >= _count)
		throw INDEX_OUT_OF_RANGE;
	if (_length[index] == 0)
		return buf;
	switch(file)
	{
	case MKF_RNG:
		temp = data(index);
		start = (int *)temp;
		buf.count = (*start >> 2) - 2;
		buf.item = new BufferItem [buf.count];
		for(i = 0; i < buf.count; i++)
		{
			start = (int *)temp + i;
			if (is_dos)
			{
				buf.item[i].size = *(int *)(temp + *start + 4);
				buf.item[i].buffer = deyj1(temp + *start);
			}
			else
			{
				buf.item[i].size = *(int *)(temp + *start);
				buf.item[i].buffer = new unsigned char [buf.item[i].size];
				decompress(temp + *start, buf.item[i].buffer);
			}
		}
		delete [] temp;
		break;
	case MKF_DATA:
		if (index != 9 && index != 10 && index != 12)
			throw NOT_GROUPED_FILE;
	case MKF_ABC:
	case MKF_BALL:
	case MKF_F:
	case MKF_FIRE:
	case MKF_GOP:
	case MKF_MGO:
	case MKF_RGM:
		len = length(index);
		temp = data(index);
		pos = (unsigned short *)temp;
		buf.count = 1; pos++;
		for(i = 1; i < *(unsigned short *)temp; i++, pos++)
			if (*pos < *(pos - 1) || (*pos << 1) >= len)
				continue;
			else
				buf.count++;
		buf.item = new BufferItem [buf.count];
		for(i = 0; i < buf.count; i++)
		{
			pos = (unsigned short *)temp + i;
			_start = (int)*pos << 1;
			if (i == buf.count - 1)
				_end = len;
			else
				_end = (int)*(pos + 1) << 1;
			buf.item[i].size = _end - _start;
			buf.item[i].buffer = new unsigned char [buf.item[i].size];
			memcpy(buf.item[i].buffer, temp + _start, buf.item[i].size);
		}
		delete [] temp;
		break;
	default:
		throw NOT_GROUPED_FILE;
	}
	return buf;
}