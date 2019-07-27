//for compatible with call conversion of DecodeJY in pal95tool

#include "pallib.h"
#include <string.h>

extern "C" errno_t DecodeJY(const void* Source, void* Destination, int isDOS)
{
	uint32 Length;
	int ret=0;
	void *dst = NULL;
	if( isDOS == 1 )
		ret = Pal::Tools::DecodeYJ1(Source, dst, Length);
	else
		ret = Pal::Tools::DecodeYJ2(Source, dst, Length);
	memcpy(Destination, dst, Length);
	return ret;
}
