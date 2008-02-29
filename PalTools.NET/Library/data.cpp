#include "library.h"
#include <stdio.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <io.h>
#include <stdlib.h>
#include <memory.h>

PAL_DATA::PAL_DATA(const char *data_path, const char *word_path) throw(...)
{
	PAL_MKF *_data_ = NULL;
	int fd, i, len;
	unsigned char *temp;
	_menu.count = _magic_effect.count = _confirm.count = 0;
	_menu.item = _magic_effect.item = _confirm.item = NULL;
	_word = NULL;
	try
	{
		_data_ = new PAL_MKF(data_path, MKF_DATA);
		_menu = _data_->extract(9);
		_magic_effect = _data_->extract(10);
		_confirm = _data_->extract(12);
		memcpy(_shop, _data_->rawdata(0).buffer, _data_->rawdata(0).size);
		memcpy(_monster, _data_->rawdata(1).buffer, _data_->rawdata(1).size);
		memcpy(_team, _data_->rawdata(2).buffer, _data_->rawdata(2).size);
		delete _data_;
	}
	catch(ERROR_NO &err)
	{
		if (_data_)
			delete _data_;
		throw err;
	}
	fd = _open(word_path, _O_BINARY | _O_RDONLY);
	if (fd == -1)
		throw FILE_NOT_EXIST;
	_lseek(fd, 0, SEEK_END);
	len = _tell(fd);
	_word_count = len / 10;
	_lseek(fd, 0, SEEK_SET);
	temp = _word = new unsigned char [_word_count * 11];
	for(i = 0; i < _word_count; i++)
	{
		_read(fd, temp, 10);
		temp += 10; *temp++ = 0;
	}
	_close(fd);
	for(i = 0; i < _word_count * 11; i++)
		if (_word[i] == 0x20)
			_word[i] = 0;	
}

PAL_DATA::~PAL_DATA()
{
	int i;
	if (_menu.item)
		for(i = 0; i < _menu.count; i++)
			delete [] _menu.item[i].buffer;
	if (_magic_effect.item)
		for(i = 0; i < _magic_effect.count; i++)
			delete [] _magic_effect.item[i].buffer;
	if (_confirm.item)
		for(i = 0; i < _confirm.count; i++)
			delete [] _confirm.item[i].buffer;
	if (_word)
		delete [] _word;
}

const BufferGroup PAL_DATA::menu() const
{
	return _menu;
}

const BufferGroup PAL_DATA::magic_effect() const
{
	return _magic_effect;
}

const BufferGroup PAL_DATA::confirm() const
{
	return _confirm;
}

const unsigned char *PAL_DATA::word(int index) const
{
	if (index < 0 || index >= _word_count)
		return NULL;
	else
		return _word + index * 11;
}