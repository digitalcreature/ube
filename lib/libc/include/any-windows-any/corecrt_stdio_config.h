/**
 * This file has no copyright assigned and is placed in the Public Domain.
 * This file is part of the Wine project.
 * No warranty is given; refer to the file DISCLAIMER.PD within this package.
 */

#ifndef _STDIO_CONFIG_DEFINED
#define _STDIO_CONFIG_DEFINED

#include <corecrt.h>

#define _CRT_INTERNAL_PRINTF_LEGACY_VSPRINTF_NULL_TERMINATION  0x0001ULL
#define _CRT_INTERNAL_PRINTF_STANDARD_SNPRINTF_BEHAVIOR                     0x0002ULL
#define _CRT_INTERNAL_PRINTF_LEGACY_WIDE_SPECIFIERS                                      0x0004ULL
#define _CRT_INTERNAL_PRINTF_LEGACY_MSVCRT_COMPATIBILITY                    0x0008ULL
#define _CRT_INTERNAL_PRINTF_LEGACY_THREE_DIGIT_EXPONENTS                   0x0010ULL

#define _CRT_INTERNAL_SCANF_SECURECRT                                                           0x0001ULL
#define _CRT_INTERNAL_SCANF_LEGACY_WIDE_SPECIFIERS                    0x0002ULL
#define _CRT_INTERNAL_SCANF_LEGACY_MSVCRT_COMPATIBILITY  0x0004ULL

#ifndef _CRT_INTERNAL_LOCAL_PRINTF_OPTIONS
#define _CRT_INTERNAL_LOCAL_PRINTF_OPTIONS  _CRT_INTERNAL_PRINTF_LEGACY_WIDE_SPECIFIERS
#endif

#ifndef _CRT_INTERNAL_LOCAL_SCANF_OPTIONS
#define _CRT_INTERNAL_LOCAL_SCANF_OPTIONS   _CRT_INTERNAL_SCANF_LEGACY_WIDE_SPECIFIERS
#endif

#endif /* _STDIO_CONFIG_DEFINED */