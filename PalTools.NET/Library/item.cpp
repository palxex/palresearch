#include "library.h"
#include <stdio.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <io.h>
#include <stdlib.h>
#include <memory.h>

PAL_ITEM::PAL_ITEM(const char *data_path, const char *sss_path, const char *msg_path, const char *word_path) throw(...)
{
	PAL_MKF_R *data = NULL, *sss = NULL;
	int fd, len;
	_word.item = NULL;
	_shop.item = NULL;
	_team.item = NULL;
	_msg_index.item = NULL;
	_event_script.item = NULL;
	_msg = NULL;
	dos = false;
	try
	{
		data = new PAL_MKF_R(data_path, MKF_DATA);
		sss = new PAL_MKF_R(sss_path, MKF_SSS);
		dos = data->dos();

		_shop.count = data->rawlength(0) / sizeof(ShopData);
		_shop.item = new ShopData [_shop.count];
		memcpy(_shop.item, data->rawdata(0), data->rawlength(0));

		_monster.count = data->rawlength(1) / sizeof(MonsterData);
		_monster.item = new MonsterData [_monster.count];
		memcpy(_monster.item, data->rawdata(1), data->rawlength(1));

		_team.count = data->rawlength(2) / sizeof(TeamData);
		_team.item = new TeamData [_team.count];
		memcpy(_team.item, data->rawdata(2), data->rawlength(2));

		if (dos)
		{
			_object_dos.count = sss->rawlength(2) / sizeof(ObjectDataDos);
			_object_dos.item = new ObjectDataDos [_object_dos.count];
			memcpy(_object_dos.item, sss->rawdata(2), sss->rawlength(2));
		}
		else
		{
			_object_win.count = sss->rawlength(2) / sizeof(ObjectDataWin);
			_object_win.item = new ObjectDataWin [_object_win.count];
			memcpy(_object_win.item, sss->rawdata(2), sss->rawlength(2));
		}

		_msg_index.count = (sss->rawlength(3) >> 2) - 1;
		_msg_index.item = new unsigned int [_msg_index.count + 1];
		memcpy(_msg_index.item, sss->rawdata(3), sss->rawlength(3));

		_event_script.count = sss->rawlength(4) >> 3;
		_event_script.item = new EventScript [_event_script.count];
		memcpy(_event_script.item, sss->rawdata(4), sss->rawlength(4));

		delete sss;
		delete data;
	}
	catch(ERROR_NO &err)
	{
		if (data)
			delete data;
		if (sss)
			delete sss;
		throw err;
	}
	fd = _open(word_path, _O_BINARY | _O_RDONLY);
	if (fd == -1)
		throw FILE_NOT_EXIST;
	_lseek(fd, 0, SEEK_END);
	len = _tell(fd);
	_word.count = len / 10;
	_lseek(fd, 0, SEEK_SET);
	_word.item = new WordData [_word.count];
	_read(fd, _word.item, len);
	_close(fd);
	fd = _open(msg_path, _O_BINARY | _O_RDONLY);
	if (fd == -1)
		throw FILE_NOT_EXIST;
	_lseek(fd, 0, SEEK_END);
	len = _tell(fd);
	_msg = new unsigned char [len];
	_lseek(fd, 0, SEEK_SET);
	_read(fd, _msg, len);
	_close(fd);
}

PAL_ITEM::~PAL_ITEM()
{
	if (_word.item)
		delete [] _word.item;
	if (_shop.item)
		delete [] _shop.item;
	if (_monster.item)
		delete [] _monster.item;
	if (_msg_index.item)
		delete [] _msg_index.item;
	if (_msg)
		delete [] _msg;
}

bool PAL_ITEM::isdos() const
{
	return dos;
}

const unsigned char *PAL_ITEM::message() const
{
	return _msg;
}

const TypedBufferGroup<unsigned int> PAL_ITEM::msg_index() const
{
	return _msg_index;
}

const TypedBufferGroup<WordData> PAL_ITEM::word() const
{
	return _word;
}

const WordData PAL_ITEM::word(int index) const throw(...)
{
	if (index < 0 || index >= _word.count)
		throw INDEX_OUT_OF_RANGE;
	else
		return _word.item[index];
}

const TypedBufferGroup<ShopData> PAL_ITEM::shop() const
{
	return _shop;
}

const ShopData PAL_ITEM::shop(int index) const throw(...)
{
	if (index < 0 || index >= _shop.count)
		throw INDEX_OUT_OF_RANGE;
	else
		return _shop.item[index];
}
const TypedBufferGroup<TeamData> PAL_ITEM::team() const
{
	return _team;
}

const TeamData PAL_ITEM::team(int index) const throw(...)
{
	if (index < 0 || index >= _team.count)
		throw INDEX_OUT_OF_RANGE;
	else
		return _team.item[index];
}

const TypedBufferGroup<MonsterData> PAL_ITEM::monster() const
{
	return _monster;
}

const MonsterData PAL_ITEM::monster(int index) const throw(...)
{
	if (index < 0 || index >= _monster.count)
		throw INDEX_OUT_OF_RANGE;
	else
		return _monster.item[index];
}

const TypedBufferGroup<ObjectDataDos> PAL_ITEM::object_dos() const throw(...)
{
	if (dos)
		return _object_dos;
	else
		throw VERSION_NOT_MATCH;
}

const ObjectDataDos PAL_ITEM::object_dos(int index) const throw(...)
{
	if (index < 0 || index >= _object_dos.count)
		throw INDEX_OUT_OF_RANGE;
	else if (dos)
		return _object_dos.item[index];
	else
		throw VERSION_NOT_MATCH;
}

const TypedBufferGroup<ObjectDataWin> PAL_ITEM::object_win() const throw(...)
{
	if (dos)
		throw VERSION_NOT_MATCH;
	else
		return _object_win;
}

const ObjectDataWin PAL_ITEM::object_win(int index) const throw(...)
{
	if (index < 0 || index >= _object_win.count)
		throw INDEX_OUT_OF_RANGE;
	else if (dos)
		throw VERSION_NOT_MATCH;
	else
		return _object_win.item[index];
}

const TypedBufferGroup<EventScript> PAL_ITEM::event_script() const
{
	return _event_script;
}

const EventScript PAL_ITEM::event_script(int index) const throw(...)
{
	if (index < 0 || index >= _event_script.count)
		throw INDEX_OUT_OF_RANGE;
	else
		return _event_script.item[index];
}