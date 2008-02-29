
unsigned char *deyj1(unsigned char *src);

int decompress(const unsigned char *src, unsigned char *dest);
int compress(const unsigned char *src, unsigned char *dest, int srclen);

unsigned char *rng_decode(const unsigned char *src, unsigned char *dest);
int rng_encode(const unsigned char *psrc, const unsigned char *src, unsigned char *dest);

unsigned char *rle_decode(const unsigned char *rle, unsigned char *image, int image_width, int image_height, int pos_x, int pos_y);
enum ERROR_NO
{
	OK,
	FILE_NOT_EXIST,
	FILE_NOT_WRITABLE,
	INDEX_OUT_OF_RANGE,
	NOT_GROUPED_FILE,
	BUFFER_OVERLAPPED,
	DIRECTMUSIC_ERROR,
	VERSION_NOT_MATCH
};

enum MKF_FILE
{
	MKF_ABC,	MKF_BALL,	MKF_DATA,	MKF_F,
	MKF_FBP,	MKF_FIRE,	MKF_GOP,	MKF_MAP,
	MKF_MGO,	MKF_MIDI,	MKF_MUS,	MKF_PAT,
	MKF_RGM,	MKF_RNG,	MKF_SOUNDS,	MKF_SSS,
	MKF_VOC
};

typedef struct _BufferItem
{
	unsigned char *buffer;
	int size;
} BufferItem;

typedef struct _BufferGroup
{
	BufferItem *item;
	int count;
} BufferGroup;

class PAL_MKF
{
public:
	PAL_MKF(const char *name, MKF_FILE file);
	~PAL_MKF();
	ERROR_NO errorno() const;
	int count() const;
	BufferItem rawdata(int index);
	unsigned char *unpack(int index, int &length) const;
	int pack(const unsigned char *data, int length, int index);
	BufferGroup extract(int index);
	int package(BufferGroup buf, int index);
	void save(const char *name);

private:
	MKF_FILE file;
	BufferGroup _buffer;
	ERROR_NO _errorno;
	bool is_dos, packed;
};

class PAL_MKF_R
{
public:
	PAL_MKF_R(const char *name, MKF_FILE file);
	~PAL_MKF_R();
	bool dos() const;
	int count() const;
	int offset(int index) const;
	int rawlength() const;
	unsigned char *rawdata() const;
	int rawlength(int index) const;
	unsigned char *rawdata(int index);
	int length(int index) const;
	unsigned char *data(int index) const;
	BufferGroup extract(int index) const;

private:
	MKF_FILE file;
	int _count, _filelen, *_start, *_length, *_len;
	bool is_dos, packed;
	char *_name;
};

#pragma pack(2)
typedef struct _MonsterData
{
	short attribute[11];
	short hp;
	short exp;
	short money;
	short level;
	short magic;
	short magic_feq;
	short thing;
	short thing_feq;
	short steal;
	short steal_num;
	short wushu;
	short lingli;
	short fangyu;
	short shengfa;
	short jiyun;
	short anti_poison;
	short anti_wind;
	short anti_thunder;
	short anti_water;
	short anti_fire;
	short anti_earth;
	short anti_physical;
	short again;
	short linghu;
} MonsterData;

typedef struct _ShopData
{
	short data[9];
} ShopData;

typedef struct _TeamData
{
	short data[5];
} TeamData;

typedef struct _WordData
{
	char data[10];
} WordData;

typedef union _ObjectDataDos
{
	struct
	{
		unsigned short param0;
		unsigned short param1;
		unsigned short script_fellow_die;
		unsigned short scrpit_self_hurt;
		unsigned short param2;
		unsigned short param3;
	} role;
	struct
	{
		unsigned short index;
		unsigned short price;
		unsigned short script_use;
		unsigned short script_wear;
		unsigned short script_throw;
		struct
		{
			unsigned short useable:	 1;
			unsigned short wearable: 1;
			unsigned short throwable:1;
			unsigned short noconsume:1;
			unsigned short noselect: 1;
			unsigned short sellable: 1;
			unsigned short li_use:	 1;
			unsigned short zhao_use: 1;
			unsigned short lin_use:	 1;
			unsigned short wu_use:	 1;
			unsigned short nu_use:	 1;
			unsigned short gai_use:	 1;
			unsigned short :		 4;
		} attribute;
	} item;
	struct
	{
		unsigned short index;
		unsigned short param0;
		unsigned short script_after;
		unsigned short script_before;
		unsigned short param1;
		struct
		{
			unsigned short nofight_use:	1;
			unsigned short fight_use:	1;
			unsigned short unknown:		1;
			unsigned short to_enemy:	1;
			unsigned short no_select:	1;
			unsigned short :			11;
		} attribute;
	} magic;
	struct
	{
		unsigned short index;
		unsigned short anti_abnormal;
		unsigned short script_before;
		unsigned short script_after;
		unsigned short script_fighting;
		unsigned short param0;
	} monster;
	struct
	{
		unsigned short level;
		unsigned short color;
		unsigned short script_us;
		unsigned short param0;
		unsigned short script_enemy;
		unsigned short param1;
	} poison;
	unsigned short param[6];
} ObjectDataDos;

typedef union _ObjectDataWin
{
	struct
	{
		unsigned short param0;
		unsigned short param1;
		unsigned short script_fellow_die;
		unsigned short scrpit_self_hurt;
		unsigned short param2;
		unsigned short param3;
		unsigned short param4;
	} role;
	struct
	{
		unsigned short index;
		unsigned short price;
		unsigned short script_use;
		unsigned short script_wear;
		unsigned short script_throw;
		unsigned short description;
		struct
		{
			unsigned short useable:	 1;
			unsigned short wearable: 1;
			unsigned short throwable:1;
			unsigned short noconsume:1;
			unsigned short noselect: 1;
			unsigned short sellable: 1;
			unsigned short li_use:	 1;
			unsigned short zhao_use: 1;
			unsigned short lin_use:	 1;
			unsigned short wu_use:	 1;
			unsigned short nu_use:	 1;
			unsigned short gai_use:	 1;
			unsigned short :		 4;
		} attribute;
	} item;
	struct
	{
		unsigned short index;
		unsigned short param0;
		unsigned short script_after;
		unsigned short script_before;
		unsigned short param1;
		unsigned short description;
		struct
		{
			unsigned short nofight_use:	1;
			unsigned short fight_use:	1;
			unsigned short unknown:		1;
			unsigned short to_enemy:	1;
			unsigned short no_select:	1;
			unsigned short :		   11;
		} attribute;
	} magic;
	struct
	{
		unsigned short index;
		unsigned short anti_abnormal;
		unsigned short script_before;
		unsigned short script_after;
		unsigned short script_fighting;
		unsigned short param0;
		unsigned short param1;
	} monster;
	struct
	{
		unsigned short level;
		unsigned short color;
		unsigned short script_us;
		unsigned short param0;
		unsigned short script_enemy;
		unsigned short param1;
		unsigned short param2;
	} poison;
	unsigned short param[7];
} ObjectDataWin;

typedef struct _EventScript
{
	unsigned short ins;
	unsigned short param0;
	unsigned short param1;
	unsigned short param2;
} EventScript;

#pragma pack()

template<typename _Type>
struct TypedBufferGroup
{
	_Type *item;
	int count;
};

class PAL_ITEM
{
public:
	PAL_ITEM(const char *data_path, const char *sss_path, const char *msg_path, const char *word_path);
	~PAL_ITEM();
	bool isdos() const;
	const unsigned char *message() const;
	const TypedBufferGroup<unsigned int> msg_index() const;
	const TypedBufferGroup<WordData> word() const;
	const WordData word(int index) const;
	const TypedBufferGroup<ShopData> shop() const;
	const ShopData shop(int index) const;
	const TypedBufferGroup<TeamData> team() const;
	const TeamData team(int index) const;
	const TypedBufferGroup<MonsterData> monster() const;
	const MonsterData monster(int index) const;
	const TypedBufferGroup<ObjectDataDos> object_dos() const;
	const ObjectDataDos object_dos(int index) const;
	const TypedBufferGroup<ObjectDataWin> object_win() const;
	const ObjectDataWin object_win(int index) const;
	const TypedBufferGroup<EventScript> event_script() const;
	const EventScript event_script(int index) const;

private:
	TypedBufferGroup<ShopData>		_shop;
	TypedBufferGroup<TeamData>		_team;
	TypedBufferGroup<MonsterData>	_monster;
	TypedBufferGroup<WordData>		_word;
	TypedBufferGroup<ObjectDataDos>	_object_dos;
	TypedBufferGroup<ObjectDataWin>	_object_win;
	TypedBufferGroup<EventScript>	_event_script;
	TypedBufferGroup<unsigned int>	_msg_index;
	unsigned char *_msg;
	bool dos;
};
