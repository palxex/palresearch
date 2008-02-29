/***********************************************
* RNG编码/解码算法——By louyihua(SuperMouse)  *
************************************************/
//下面两行为函数声明
//unsigned char *rng_decode(const unsigned char *src, unsigned char *dest);
//int rng_encode(const unsigned char *psrc, const unsigned char *src, unsigned char *dest);

/****************************************************
 * 功能描述：RNG解码                                *
 * 参    数：src ---- 使用RNG编码后数据的首指针     *
 *           dest --- 存放解码后数据的首指针        *
 * 返 回 值：dest(该缓冲区长度固定为64000字节)      *
 ****************************************************/
unsigned char *rng_decode(const unsigned char *src, unsigned char *dest)
{
	int ptr = 0, dst_ptr = 0;
	unsigned char data;
	unsigned short wdata;
	unsigned int rep, i;
	while(1)
	{
		data = *(src + ptr++);
		switch(data)
		{
		case 0x00:
		case 0x13:
			//0x1000411b
			return dest;
		case 0x01:
		case 0x05:
			break;
		case 0x02:
			dst_ptr += 2;
			break;
		case 0x03:
			data = *(src + ptr++);
			dst_ptr += ((unsigned int)data + 1) << 1;
			break;
		case 0x04:
			wdata = *(unsigned short *)(src + ptr);
			ptr += 2;
			dst_ptr += ((unsigned int)wdata + 1) << 1;
			break;
		case 0x0a:
			*(unsigned short *)(dest + dst_ptr) = *(unsigned short *)(src + ptr);
			ptr += 2; dst_ptr += 2;
		case 0x09:
			*(unsigned short *)(dest + dst_ptr) = *(unsigned short *)(src + ptr);
			ptr += 2; dst_ptr += 2;
		case 0x08:
			*(unsigned short *)(dest + dst_ptr) = *(unsigned short *)(src + ptr);
			ptr += 2; dst_ptr += 2;
		case 0x07:
			*(unsigned short *)(dest + dst_ptr) = *(unsigned short *)(src + ptr);
			ptr += 2; dst_ptr += 2;
		case 0x06:
			*(unsigned short *)(dest + dst_ptr) = *(unsigned short *)(src + ptr);
			ptr += 2; dst_ptr += 2;
			break;
		case 0x0b:
			data = *(src + ptr++);
			rep = data; rep++;
			for(i = 0; i < rep; i++)
			{
				*(unsigned short *)(dest + dst_ptr) = *(unsigned short *)(src + ptr);
				ptr += 2; dst_ptr += 2;
			}
			break;
		case 0x0c:
			wdata = *(unsigned short *)(src + ptr);
			ptr += 2; rep = wdata; rep++;
			for(i = 0; i < rep; i++)
			{
				*(unsigned short *)(dest + dst_ptr) = *(unsigned short *)(src + ptr);
				ptr += 2; dst_ptr += 2;
			}
			break;
		case 0x0d:
			wdata = *(unsigned short *)(src + ptr);	ptr += 2;
			*(unsigned short *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			*(unsigned short *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			break;
		case 0x0e:
			wdata = *(unsigned short *)(src + ptr);	ptr += 2;
			*(unsigned short *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			*(unsigned short *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			*(unsigned short *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			break;
		case 0x0f:
			wdata = *(unsigned short *)(src + ptr);	ptr += 2;
			*(unsigned short *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			*(unsigned short *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			*(unsigned short *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			*(unsigned short *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			break;
		case 0x10:
			wdata = *(unsigned short *)(src + ptr);	ptr += 2;
			*(unsigned short *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			*(unsigned short *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			*(unsigned short *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			*(unsigned short *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			*(unsigned short *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			break;
		case 0x11:
			data = *(src + ptr++);
			rep = data; rep++;
			wdata = *(unsigned short *)(src + ptr);	ptr += 2;
			for(i = 0; i < rep; i++)
			{
				*(unsigned short *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			}
			break;
		case 0x12:
			wdata = *(unsigned short *)(src + ptr);
			rep = wdata; rep++; ptr += 2;
			wdata = *(unsigned short *)(src + ptr);	ptr += 2;
			for(i = 0; i < rep; i++)
			{
				*(unsigned short *)(dest + dst_ptr) = wdata; dst_ptr += 2;
			}
			break;
		}
	}
	return dest;
}

static unsigned short encode_1(unsigned short *&start, unsigned short *&data, unsigned char *&dest)
{
	unsigned short length = (unsigned short)(data - start - 1);
	unsigned short len;
	if (length > 0xff)
	{
		if (dest)
		{
			*dest++ = 0x04;
			*((unsigned short *)dest) = length;
			dest += 2;
		}
		len = 3;
	}
	else if (length > 0)
	{
		if (dest)
		{
			*dest++ = 0x03;
			*dest++ = (unsigned char)length;
		}
		len = 2;
	}
	else
	{
		if (dest)
			*dest++ = 0x02;
		len = 1;
	}
	return len;
}

static unsigned short encode_2(unsigned short *&start, unsigned short *&data, unsigned char *&dest)
{
	unsigned short *temp;
	unsigned short length = (unsigned short)(data - start - 1);
	unsigned short len = (length + 1) << 1;
	if (length > 0xff)
	{
		if (dest)
		{
			*dest++ = 0xc;
			*((unsigned short *)dest) = length;
			dest += 2;
		}
		len += 3;
	}
	else if (length > 0x4)
	{
		if (dest)
		{
			*dest++ = 0xb;
			*dest++ = (unsigned char)length;
		}
		len += 2;
	}
	else
	{
		if (dest)
			*dest++ = 0x6 + (unsigned char)length;
		len++;
	}
	if (dest)
	{
		temp = (unsigned short *)dest;
		for(int i = 0; i <= length; i++)
			*temp++ = *start++;
		dest = (unsigned char *)temp;
	}
	start = data;
	return len;
}

static unsigned short encode_3(unsigned short *&start, unsigned short *&data, unsigned char *&dest)
{
	unsigned short *temp;
	unsigned short length = (unsigned short)(data - start - 1);
	unsigned short len = 2;
	if (length > 0xff)
	{
		if (dest)
		{
			*dest++ = 0x12;
			*((unsigned short *)dest) = length;
			dest += 2;
		}
		len += 3;
	}
	else if (length > 0x4)
	{
		if (dest)
		{
			*dest++ = 0x11;
			*dest++ = (unsigned char)length;
		}
		len += 2;
	}
	else
	{
		if (dest)
			*dest++ = 0xc + (unsigned char)length;
		len++;
	}
	if (dest)
	{
		temp = (unsigned short *)dest;
		*temp++ = *start;
		dest = (unsigned char *)temp;
	}
	start = data;
	return len;
}

/****************************************************
 * 功能描述：RNG编码                                *
 * 参    数：src ---- 需要编码数据的首指针          *
 *           dest --- 存放编码后数据的首指针        *
 * 返 回 值：编码后数据的长度                       *
 ****************************************************/
int rng_encode(const unsigned char *psrc, const unsigned char *src, unsigned char *dest)
{
	int len = 0, status = 0;
	unsigned short *data = (unsigned short *)src;
	unsigned short *prev = (unsigned short *)psrc;
	unsigned short *start = data, *end = data + 0x7d00;
	while(data < end)
	{
		switch(status)
		{
		case 0:
			if (prev)
				if (*prev == *data)
				{
					status = 1; start = data;
					data++; break;
				}
			if (data < end - 1)
				if (*data == *(data + 1))
					if (prev)
						if (*(data + 1) == *(prev + 1))
							status = 2;
						else
							status = 3;
					else
						status = 3;
				else
					status = 2;
			else
				status = 2;
			start = data; data++;
			break;
		case 1:
			if (*prev == *data)
				data++;
			else
			{
				len += encode_1(start, data, dest);
				status = 0;
			}
			break;
		case 2:
			if (prev)
				if (*prev == *data)
				{
					len += encode_2(start, data, dest);
					status = 0; break;
				}
			if (data < end - 1)
				if (*data != *(data + 1))
					data++;
				else
				{
					if (prev)
						if (*(data + 1) == *(prev + 1))
						{
							data++; break;
						}
					len += encode_2(start, data, dest);
					status = 0;
				}
			else
				data++;
			break;
		case 3:
			if (prev)
				if (*prev == *data)
				{
					len += encode_3(start, data, dest);
					status = 0; break;
				}
			if (data < end - 1)
				if (*data == *(data + 1))
					data++;
				else
				{
					data++; if (prev) prev++;
					len += encode_3(start, data, dest);
					status = 0;
				}
			else
				data++;
			break;
		}
		if (status && prev)
			prev++;
	}
	switch(status)
	{
	case 1: len += encode_1(start, data, dest); break;
	case 2: len += encode_2(start, data, dest); break;
	case 3: len += encode_3(start, data, dest); break;
	}
	len++;
	if (dest)
	{
		*dest++ = 0;
		if (len & 0x1)
			*dest++ = 0;
	}
	if (len & 0x1)
		len++;
	return len;
}
