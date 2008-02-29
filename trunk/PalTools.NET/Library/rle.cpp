
unsigned char *rle_decode(const unsigned char *rle, unsigned char *image, int image_width, int image_height, int pos_x, int pos_y)
{
	int i, x, y, rle_width, rle_height;
	unsigned char count, *img_ptr;

	rle_width = *(unsigned short *)rle;
	rle_height = *(unsigned short *)(rle + 2);
	if (pos_x < 0 || pos_x + rle_width > image_width ||
		pos_y < 0 || pos_y + rle_height > image_height)
		return 0;
	rle += 4;
	for(y = pos_y; y < pos_y + rle_height; y++)
	{
		img_ptr = image + y * image_width;
		for(x = pos_x; x < pos_x + rle_width;)
		{
			count = *rle++;
			if (count < 0x80)
				for(i = 0; i < count; i++)
					img_ptr[x++] = *rle++;
			else
				x += count & 0x7f;
		}
	}
	return image;
}

/*
void encode_1(unsigned char *&rle, int len)
{
	int n = len / 0x7f;
	for(int i = 0; i < n; i++)
		*rle++ = 0xff;
	*rle++ = (unsigned char)(len % 0x7f);
}

void encode_2(unsigned char *&image, unsigned char *&rle, int len)
{
	int n = len / 0x7f;
	image -= len;
	for(int i = 0; i < n; i++)
	{
		*rle++ = 0xff;
		for(int j = 0; j < 0x7f; j++)
			*rle++ = *image++;
	}
	*rle++ = (unsigned char)(len % 0x7f);
	for(int i = 0; i < len % 0x7f; i++)
		*rle++ = *image++;
}

int rle_encode(const unsigned char *image, unsigned char *rle, unsigned char color, int width, int height)
{
	int x, y, length, len = 0;
	int status = 0;
	for(y = status = 0; y < height; y++)
		for(x = 0; x < width; x++)
		{
			switch(status)
			{
			case 0:
				status = (*image++ == color) ? 1 : 2;
				length = 1;
				break;
			case 1:
				if (*image == color)
				{
					length++;
					image++;
				}
				else
				{
					encode_1(rle, length);
					status = 0;
				}
				break;
			case 2:
				if (*image == color)
				{
					encode_2(image, rle, length);
					status = 0;
				}
				else
				{
					length++;
					image++;
				}
				break;
			}
		}
	return 0;
}
*/