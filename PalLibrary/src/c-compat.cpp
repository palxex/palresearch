//”√”⁄ºÊ»› C ”Ô—‘
/*
#include "pallib.h"

extern "C" errno_t decodeyj1(const void* Source, void** Destination, uint32* Length)
{
	return Pal::Tools::DecodeYJ1(Source, *Destination, *Length);
}

extern "C" errno_t encodeyj1(const void* Source, uint32 SourceLength, void** Destination, uint32* Length)
{
	return Pal::Tools::EncodeYJ1(Source, SourceLength, *Destination, *Length);
}

extern "C" errno_t decodeyj2(const void* Source, void** Destination, uint32* Length)
{
	return Pal::Tools::DecodeYJ2(Source, *Destination, *Length);
}

extern "C" errno_t encodeyj2(const void* Source, uint32 SourceLength, void** Destination, uint32* Length, int bCompatible)
{
	return Pal::Tools::EncodeYJ2(Source, SourceLength, *Destination, *Length);
}

extern "C" errno_t decoderng(const void* Source, void* PrevFrame)
{
	return Pal::Tools::DecodeRNG(Source, PrevFrame);
}

extern "C" errno_t encoderng(const void* PrevFrame, const void* CurFrame, void** Destination, uint32* Length)
{
	return Pal::Tools::EncodeRNG(PrevFrame, CurFrame, *Destination, *Length);
}

extern "C" errno_t decoderle(const void* Rle, void* Destination, sint32 Stride, sint32 Width, sint32 Height, sint32 x, sint32 y)
{
	return Pal::Tools::DecodeRLE(Rle, Destination, Stride, Width, Height, x, y);
}

extern "C" errno_t encoderle(const void* Source, const void *Base, sint32 Stride, sint32 Width, sint32 Height, void** Destination, uint32* Length)
{
	return Pal::Tools::EncodeRLE(Source, Base, Stride, Width, Height, *Destination, *Length);
}

extern "C" errno_t encoderlet(const void* Source, uint8 TransparentColor, sint32 Stride, sint32 Width, sint32 Height, void** Destination, uint32* Length)
{
	return Pal::Tools::EncodeRLE(Source, TransparentColor, Stride, Width, Height, *Destination, *Length);
}


extern "C" errno_t decodeyj1streaminitialize(void** pvState, uint32 uiGrowBy)
{
	return Pal::Tools::DecodeYJ1StreamInitialize(*pvState, uiGrowBy);
}

extern "C" errno_t decodeyj1streaminput(void* pvState, const void* Source, uint32 SourceLength)
{
	return Pal::Tools::DecodeYJ1StreamInput(pvState, Source, SourceLength);
}

extern "C" errno_t decodeyj1streamoutput(void* pvState, void* Destination, uint32 Length, uint32* ActualLength)
{
	return Pal::Tools::DecodeYJ1StreamOutput(pvState, Destination, Length, *ActualLength);
}

extern "C" int decodeyj1streamfinished(void* pvState, uint32* AvailableLength)
{
	return Pal::Tools::DecodeYJ1StreamFinished(pvState, *AvailableLength);
}

extern "C" errno_t decodeyj1streamfinalize(void* pvState)
{
	return Pal::Tools::DecodeYJ1StreamFinalize(pvState);
}

extern "C" errno_t decodeyj1streamreset(void* pvState)
{
	return Pal::Tools::DecodeYJ1StreamReset(pvState);
}


extern "C" errno_t decodeyj2streaminitialize(void** pvState, uint32 uiGrowBy)
{
	return Pal::Tools::DecodeYJ2StreamInitialize(*pvState, uiGrowBy);
}

extern "C" errno_t decodeyj2streaminput(void* pvState, const void* Source, uint32 SourceLength)
{
	return Pal::Tools::DecodeYJ2StreamInput(pvState, Source, SourceLength);
}

extern "C" errno_t decodeyj2streamoutput(void* pvState, void* Destination, uint32 Length, uint32* ActualLength)
{
	return Pal::Tools::DecodeYJ2StreamOutput(pvState, Destination, Length, *ActualLength);
}

extern "C" int decodeyj2streamfinished(void* pvState, uint32* AvailableLength)
{
	return Pal::Tools::DecodeYJ2StreamFinished(pvState, *AvailableLength);
}

extern "C" errno_t decodeyj2streamfinalize(void* pvState)
{
	return Pal::Tools::DecodeYJ2StreamFinalize(pvState);
}

extern "C" errno_t decodeyj2streamreset(void* pvState)
{
	return Pal::Tools::DecodeYJ2StreamReset(pvState);
}


extern "C" errno_t encodeyj2streaminitialize(void** pvState, uint32 uiSourceLength, uint32 uiGrowBy, int bCompatible)
{
	return Pal::Tools::EncodeYJ2StreamInitialize(*pvState, uiSourceLength, uiGrowBy, bCompatible != 0);
}

extern "C" errno_t encodeyj2streaminput(void* pvState, const void* Source, uint32 SourceLength, int bFinished)
{
	return Pal::Tools::EncodeYJ2StreamInput(pvState, Source, SourceLength, bFinished != 0);
}

extern "C" errno_t encodeyj2streamoutput(void* pvState, void* Destination, uint32 Length, uint32* ActualLength, uint32* Bits)
{
	return Pal::Tools::EncodeYJ2StreamOutput(pvState, Destination, Length, *ActualLength, *Bits);
}

extern "C" int encodeyj2streamfinished(void* pvState)
{
	return Pal::Tools::EncodeYJ2StreamFinished(pvState);
}

extern "C" errno_t encodeyj2streamfinalize(void* pvState)
{
	return Pal::Tools::EncodeYJ2StreamFinalize(pvState);
}


extern "C" errno_t grfopen(const char* grffile, const char* base, int create, int truncate, GRFFILE** grf)
{
	if (grf == NULL)
		return EINVAL;
	else
		return Pal::Tools::GRF::GRFopen(grffile, base, (create != 0), (truncate != 0), *grf);
}

extern "C" errno_t grfclose(GRFFILE* stream)
{
	return Pal::Tools::GRF::GRFclose(stream);
}

extern "C" errno_t grfflush(GRFFILE* stream)
{
	return Pal::Tools::GRF::GRFflush(stream);
}

extern "C" errno_t grfgettype(GRFFILE* stream, int* type)
{
	if (type == NULL)
		return EINVAL;
	else
		return Pal::Tools::GRF::GRFgettype(stream, *type);
}

extern "C" errno_t grfenumname(GRFFILE* stream, const char* prevname, char** nextname)
{
	if (nextname == NULL)
		return EINVAL;
	else
		return Pal::Tools::GRF::GRFenumname(stream, prevname, *nextname);
}


extern "C" errno_t grferror(GRFFILE* stream)
{
	return Pal::Tools::GRF::GRFerror(stream);
}

extern "C" void grfclearerr(GRFFILE* stream)
{
	Pal::Tools::GRF::GRFclearerr(stream);
}


extern "C" errno_t grfopenfile(GRFFILE* stream, const char* name, const char* mode, FILE** fp)
{
	if (fp == NULL)
		return EINVAL;
	else
		return Pal::Tools::GRF::GRFopenfile(stream, name, mode, *fp);
}

extern "C" errno_t grfappendfile(GRFFILE* stream, const char* name)
{
	return Pal::Tools::GRF::GRFappendfile(stream, name);
}

extern "C" errno_t grfremovefile(GRFFILE* stream, const char* name)
{
	return Pal::Tools::GRF::GRFremovefile(stream, name);
}

extern "C" errno_t grfrenamefile(GRFFILE* stream, const char* oldname, const char* newname)
{
	return Pal::Tools::GRF::GRFrenamefile(stream, oldname, newname);
}

extern "C" errno_t grfgetfileattr(GRFFILE* stream, const char* name, int attr, void* value)
{
	return Pal::Tools::GRF::GRFgetfileattr(stream, name, attr, value);
}

extern "C" errno_t grfsetfileattr(GRFFILE* stream, const char* name, int attr, const void* value)
{
	return Pal::Tools::GRF::GRFsetfileattr(stream, name, attr, value);
}


extern "C" errno_t grfseekfile(GRFFILE* stream, const char* name)
{
	return Pal::Tools::GRF::GRFseekfile(stream, name);
}

extern "C" errno_t grfeof(GRFFILE* stream)
{
	return Pal::Tools::GRF::GRFeof(stream);
}

extern "C" errno_t grfseek(GRFFILE* stream, long offset, int origin, long* pos)
{
	if (pos == NULL)
		return EINVAL;
	else
		return Pal::Tools::GRF::GRFseek(stream, offset, origin, *pos);
}

extern "C" errno_t grftell(GRFFILE* stream, long* pos)
{
	if (pos == NULL)
		return EINVAL;
	else
		return Pal::Tools::GRF::GRFtell(stream, *pos);
}

extern "C" errno_t grfread(GRFFILE* stream, void* buffer, long size, long* len)
{
	if (len == NULL)
		return EINVAL;
	else
		return Pal::Tools::GRF::GRFread(stream, buffer, size, (uint32&)*len);
}

extern "C" errno_t grfgetattr(GRFFILE* stream, int attr, void* value)
{
	return Pal::Tools::GRF::GRFgetattr(stream, attr, value);
}

extern "C" errno_t grfpackage(const char* pszGRF, const char* pszBasePath, const char* pszNewFile)
{
	return Pal::Tools::GRF::GRFPackage(pszGRF, pszBasePath, pszNewFile);
}

extern "C" errno_t grfextract(const char* pszGRF, const char* pszBasePath, const char* pszNewFile)
{
	return Pal::Tools::GRF::GRFExtract(pszGRF, pszBasePath, pszNewFile);
}
*/