#ifndef INPOUT32_DYN_H
#define INPOUT32_DYN_H

#include <windows.h>

#ifdef __cplusplus
extern "C" {
#endif

void __stdcall Out32(short PortAddress, short data);
short __stdcall Inp32(short PortAddress);

BOOL    __stdcall IsInpOutDriverOpen(void);

enum {
	INPOUT32_DYN_OK = 0,
	INPOUT32_DYN_ERR_DLL_NOT_FOUND = 1,
	INPOUT32_DYN_ERR_PROC_MISSING = 2,
	INPOUT32_DYN_ERR_DRIVER_NOT_LOADED = 3,
	INPOUT32_DYN_ERR_WRITE_FAILED = 4,
	INPOUT32_DYN_ERR_READ_FAILED = 5
};

int inpout32_dyn_get_last_error(void);
int inpout32_dyn_write_port(short PortAddress, short data);
int inpout32_dyn_read_port(short PortAddress, short *outValue);

#ifdef __cplusplus
}
#endif

#ifdef INPOUT32_DYN_IMPLEMENTATION

#include <string.h>

typedef void (__stdcall *inpout32_out32_fn)(short PortAddress, short data);
typedef short (__stdcall *inpout32_inp32_fn)(short PortAddress);
typedef BOOL (__stdcall *inpout32_is_open_fn)(void);

static HMODULE g_inpout_dll = NULL;
static inpout32_out32_fn g_out32 = NULL;
static inpout32_inp32_fn g_inp32 = NULL;
static inpout32_is_open_fn g_is_open = NULL;
static int g_inpout_tried = 0;
static int g_inpout_last_error = INPOUT32_DYN_OK;

static void inpout32_dyn_assign_proc(void *dst, FARPROC src)
{
	memcpy(dst, &src, sizeof(src));
}

static void inpout32_dyn_deinit_internal(void)
{
	if(g_inpout_dll != NULL)
	{
		FreeLibrary(g_inpout_dll);
		g_inpout_dll = NULL;
	}
	g_out32 = NULL;
	g_inp32 = NULL;
	g_is_open = NULL;
}

static int inpout32_dyn_ensure_ready(void)
{
	const char *dll_names[] = {"inpoutx64.dll", "inpout32.dll"};
	int i;

	if(g_out32 != NULL && g_inp32 != NULL)
	{
		if(g_is_open != NULL && !g_is_open())
		{
			g_inpout_last_error = INPOUT32_DYN_ERR_DRIVER_NOT_LOADED;
			return 0;
		}
		g_inpout_last_error = INPOUT32_DYN_OK;
		return 1;
	}
	if(g_inpout_tried) return 0;
	g_inpout_tried = 1;
	g_inpout_last_error = INPOUT32_DYN_OK;

	for(i = 0; i < 2 && g_inpout_dll == NULL; ++i)
		g_inpout_dll = LoadLibraryA(dll_names[i]);

	if(g_inpout_dll == NULL)
	{
		g_inpout_last_error = INPOUT32_DYN_ERR_DLL_NOT_FOUND;
		return 0;
	}

	inpout32_dyn_assign_proc(&g_out32, GetProcAddress(g_inpout_dll, "Out32"));
	inpout32_dyn_assign_proc(&g_inp32, GetProcAddress(g_inpout_dll, "Inp32"));
	inpout32_dyn_assign_proc(&g_is_open, GetProcAddress(g_inpout_dll, "IsInpOutDriverOpen"));

	if(g_out32 == NULL || g_inp32 == NULL || g_is_open == NULL)
	{
		g_inpout_last_error = INPOUT32_DYN_ERR_PROC_MISSING;
		inpout32_dyn_deinit_internal();
		return 0;
	}

	if(g_is_open != NULL && !g_is_open())
	{
		g_inpout_last_error = INPOUT32_DYN_ERR_DRIVER_NOT_LOADED;
		inpout32_dyn_deinit_internal();
		return 0;
	}

	g_inpout_last_error = INPOUT32_DYN_OK;
	return 1;
}

int inpout32_dyn_get_last_error(void)
{
	return g_inpout_last_error;
}

int inpout32_dyn_write_port(short PortAddress, short data)
{
	if(!inpout32_dyn_ensure_ready())
	{
		if(g_inpout_last_error == INPOUT32_DYN_OK)
			g_inpout_last_error = INPOUT32_DYN_ERR_WRITE_FAILED;
		return 0;
	}
	g_out32(PortAddress, data);
	return 1;
}

int inpout32_dyn_read_port(short PortAddress, short *outValue)
{
	if(!inpout32_dyn_ensure_ready())
	{
		if(g_inpout_last_error == INPOUT32_DYN_OK)
			g_inpout_last_error = INPOUT32_DYN_ERR_READ_FAILED;
		return 0;
	}
	if(outValue != NULL)
		*outValue = g_inp32(PortAddress);
	return 1;
}

BOOL __stdcall IsInpOutDriverOpen(void)
{
	if(!inpout32_dyn_ensure_ready())
		return FALSE;
	return g_is_open();
}

void __stdcall Out32(short PortAddress, short data)
{
	(void)inpout32_dyn_write_port(PortAddress, data);
}

short __stdcall Inp32(short PortAddress)
{
	short value = 0;
	if(inpout32_dyn_read_port(PortAddress, &value))
		return value;
	return 0;
}

#endif

#endif /* INPOUT32_DYN_H */