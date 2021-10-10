#include <windows.h>
#include <malloc.h>
#include <time.h>
#include <errno.h>
#include <msvcrt.h>

static errno_t __cdecl _int_wctime32_s (wchar_t *, size_t, const __time32_t *);
static errno_t __cdecl _stub (wchar_t *, size_t, const __time32_t *);

errno_t __cdecl (*__MINGW_IMP_SYMBOL(_wctime32_s))(wchar_t *, size_t, const __time32_t *) = 
 _stub;

static errno_t __cdecl
_stub (wchar_t *d, size_t dn, const __time32_t *pt)
{
  errno_t __cdecl (*f)(wchar_t*,size_t, const __time32_t *) = __MINGW_IMP_SYMBOL(_wctime32_s);

  if (f == _stub)
    {
	f = (errno_t __cdecl (*)(wchar_t *, size_t, const __time32_t *))
	    GetProcAddress (__mingw_get_msvcrt_handle (), "_wctime32_s");
	if (!f)
	  f = _int_wctime32_s;
	__MINGW_IMP_SYMBOL(_wctime32_s) = f;
    }
  return (*f)(d, dn, pt);
}

errno_t __cdecl
_wctime32_s (wchar_t *d, size_t dn, const __time32_t *pt)
{
  return _stub (d, dn, pt);
}

static errno_t __cdecl
_int_wctime32_s (wchar_t *d, size_t dn, const __time32_t *pt)
{
  struct tm ltm;
  errno_t e;

  if (!d || !dn)
     {
                     errno = EINVAL;
	return EINVAL;
     }
  d[0] = 0;
  if (!pt)
     {
	errno = EINVAL;
	return EINVAL;
     }

  if ((e = _localtime32_s (&ltm, pt)) != 0)
    return e;  
  return _wasctime_s (d, dn, &ltm);
}
