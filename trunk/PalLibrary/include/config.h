#pragma once

#ifndef	PAL_LIBRARY_H
#	error	Please include pallib.h instead of this file!
#endif

#if	defined(_MSC_VER)
#	if	(_MSC_VER >= 1400)
#		pragma	warning(disable: 4996)
#	endif
#	pragma	warning(disable: 4200)
#endif

#if	defined(__GNUC__) && !defined(_STDEXT)
#	define	_STDEXT	__gnu_cxx
#endif

#ifndef	uint8
typedef	unsigned char		uint8;
#endif
#ifndef	uint16
typedef	unsigned short		uint16;
#endif
#ifndef	uint32
typedef	unsigned int		uint32;
#endif
#ifndef	uint64
typedef	unsigned long long	uint64;
#endif
#ifndef	sint8
typedef	signed char			sint8;
#endif
#ifndef	sint16
typedef	signed short		sint16;
#endif
#ifndef	sint32
typedef	signed int		sint32;
#endif
#ifndef	sint64
typedef	signed long long	sint64;
#endif

#ifndef	palerrno_t
typedef	int	palerrno_t;
#endif

#ifndef	NULL
#	define	NULL	0
#endif

#if !defined(_ASSERT)
#	if	defined(_DEBUG) || defined(DEBUG)
#		include <assert.h>
#		define	_ASSERT(x)	assert(x)
#	else
#		define	_ASSERT(x)
#	endif
#endif
