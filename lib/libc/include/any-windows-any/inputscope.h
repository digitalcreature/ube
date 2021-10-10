/*** Autogenerated by WIDL 5.0-rc1 from inputscope.idl - Do not edit ***/

#ifdef _WIN32
#ifndef __REQUIRED_RPCNDR_H_VERSION__
#define __REQUIRED_RPCNDR_H_VERSION__ 475
#endif
#include <rpc.h>
#include <rpcndr.h>
#endif

#ifndef COM_NO_WINDOWS_H
#include <windows.h>
#include <ole2.h>
#endif

#ifndef __inputscope_h__
#define __inputscope_h__

/* Forward declarations */

#ifndef __ITfInputScope_FWD_DEFINED__
#define __ITfInputScope_FWD_DEFINED__
typedef interface ITfInputScope ITfInputScope;
#ifdef __cplusplus
interface ITfInputScope;
#endif /* __cplusplus */
#endif

#ifndef __ITfInputScope2_FWD_DEFINED__
#define __ITfInputScope2_FWD_DEFINED__
typedef interface ITfInputScope2 ITfInputScope2;
#ifdef __cplusplus
interface ITfInputScope2;
#endif /* __cplusplus */
#endif

/* Headers for imported files */

#include <oaidl.h>
#include <ocidl.h>

#ifdef __cplusplus
extern "C" {
#endif

#include <winapifamily.h>
#if WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_APP)
typedef enum __WIDL_inputscope_generated_name_00000020 {
    IS_DEFAULT = 0,
    IS_URL = 1,
    IS_FILE_FULLFILEPATH = 2,
    IS_FILE_FILENAME = 3,
    IS_EMAIL_USERNAME = 4,
    IS_EMAIL_SMTPEMAILADDRESS = 5,
    IS_LOGINNAME = 6,
    IS_PERSONALNAME_FULLNAME = 7,
    IS_PERSONALNAME_PREFIX = 8,
    IS_PERSONALNAME_GIVENNAME = 9,
    IS_PERSONALNAME_MIDDLENAME = 10,
    IS_PERSONALNAME_SURNAME = 11,
    IS_PERSONALNAME_SUFFIX = 12,
    IS_ADDRESS_FULLPOSTALADDRESS = 13,
    IS_ADDRESS_POSTALCODE = 14,
    IS_ADDRESS_STREET = 15,
    IS_ADDRESS_STATEORPROVINCE = 16,
    IS_ADDRESS_CITY = 17,
    IS_ADDRESS_COUNTRYNAME = 18,
    IS_ADDRESS_COUNTRYSHORTNAME = 19,
    IS_CURRENCY_AMOUNTANDSYMBOL = 20,
    IS_CURRENCY_AMOUNT = 21,
    IS_DATE_FULLDATE = 22,
    IS_DATE_MONTH = 23,
    IS_DATE_DAY = 24,
    IS_DATE_YEAR = 25,
    IS_DATE_MONTHNAME = 26,
    IS_DATE_DAYNAME = 27,
    IS_DIGITS = 28,
    IS_NUMBER = 29,
    IS_ONECHAR = 30,
    IS_PASSWORD = 31,
    IS_TELEPHONE_FULLTELEPHONENUMBER = 32,
    IS_TELEPHONE_COUNTRYCODE = 33,
    IS_TELEPHONE_AREACODE = 34,
    IS_TELEPHONE_LOCALNUMBER = 35,
    IS_TIME_FULLTIME = 36,
    IS_TIME_HOUR = 37,
    IS_TIME_MINORSEC = 38,
    IS_NUMBER_FULLWIDTH = 39,
    IS_ALPHANUMERIC_HALFWIDTH = 40,
    IS_ALPHANUMERIC_FULLWIDTH = 41,
    IS_CURRENCY_CHINESE = 42,
    IS_BOPOMOFO = 43,
    IS_HIRAGANA = 44,
    IS_KATAKANA_HALFWIDTH = 45,
    IS_KATAKANA_FULLWIDTH = 46,
    IS_HANJA = 47,
    IS_HANGUL_HALFWIDTH = 48,
    IS_HANGUL_FULLWIDTH = 49,
    IS_SEARCH = 50,
    IS_FORMULA = 51,
    IS_SEARCH_INCREMENTAL = 52,
    IS_CHINESE_HALFWIDTH = 53,
    IS_CHINESE_FULLWIDTH = 54,
    IS_NATIVE_SCRIPT = 55,
    IS_YOMI = 56,
    IS_TEXT = 57,
    IS_CHAT = 58,
    IS_NAME_OR_PHONENUMBER = 59,
    IS_EMAILNAME_OR_ADDRESS = 60,
    IS_PRIVATE = 61,
    IS_MAPS = 62,
    IS_NUMERIC_PASSWORD = 63,
    IS_NUMERIC_PIN = 64,
    IS_ALPHANUMERIC_PIN = 65,
    IS_ALPHANUMERIC_PIN_SET = 66,
    IS_FORMULA_NUMBER = 67,
    IS_CHAT_WITHOUT_EMOJI = 68,
    IS_PHRASELIST = -1,
    IS_REGULAREXPRESSION = -2,
    IS_SRGS = -3,
    IS_XML = -4,
    IS_ENUMSTRING = -5
} InputScope;
#endif /* WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_APP) */
#if WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_DESKTOP)
HRESULT WINAPI SetInputScope(HWND hwnd,InputScope inputscope);
HRESULT WINAPI SetInputScopes(HWND hwnd,const InputScope *pInputScopes,UINT cInputScopes,WCHAR **ppszPhraseList,UINT cPhrases,WCHAR *pszRegExp,WCHAR *pszSRGS);
HRESULT WINAPI SetInputScopes2(HWND hwnd,const InputScope *pInputScopes,UINT cInputScopes,IEnumString *pEnumString,PWSTR pszRegExp,PWSTR pszSRGS);
HRESULT WINAPI SetInputScopeXML(HWND hwnd,WCHAR *pszXML);
#endif /* WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_DESKTOP) */
#if WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_APP)
DEFINE_GUID(GUID_PROP_INPUTSCOPE,0x1713dd5a,0x68e7,0x4a5b,0x9a,0xf6,0x59,0x2a,0x59,0x5c,0x77,0x8d);
/*****************************************************************************
 * ITfInputScope interface
 */
#ifndef __ITfInputScope_INTERFACE_DEFINED__
#define __ITfInputScope_INTERFACE_DEFINED__

DEFINE_GUID(IID_ITfInputScope, 0xfde1eaee, 0x6924, 0x4cdf, 0x91,0xe7, 0xda,0x38,0xcf,0xf5,0x55,0x9d);
#if defined(__cplusplus) && !defined(CINTERFACE)
MIDL_INTERFACE("fde1eaee-6924-4cdf-91e7-da38cff5559d")
ITfInputScope : public IUnknown
{
    virtual HRESULT STDMETHODCALLTYPE GetInputScopes(
                     InputScope **pprgInputScopes,
                     UINT *pcCount) = 0;

    virtual HRESULT STDMETHODCALLTYPE GetPhrase(
                     BSTR **ppbstrPhrases,
                     UINT *pcCount) = 0;

    virtual HRESULT STDMETHODCALLTYPE GetRegularExpression(
                     BSTR *pbstrRegExp) = 0;

    virtual HRESULT STDMETHODCALLTYPE GetSRGS(
                     BSTR *pbstrSRGS) = 0;

    virtual HRESULT STDMETHODCALLTYPE GetXML(
                     BSTR *pbstrXML) = 0;

};
#ifdef __CRT_UUID_DECL
__CRT_UUID_DECL(ITfInputScope, 0xfde1eaee, 0x6924, 0x4cdf, 0x91,0xe7, 0xda,0x38,0xcf,0xf5,0x55,0x9d)
#endif
#else
typedef struct ITfInputScopeVtbl {
    BEGIN_INTERFACE

    /*** IUnknown methods ***/
    HRESULT (STDMETHODCALLTYPE *QueryInterface)(
                     ITfInputScope *This,
                     REFIID riid,
                     void **ppvObject);

    ULONG (STDMETHODCALLTYPE *AddRef)(
                     ITfInputScope *This);

    ULONG (STDMETHODCALLTYPE *Release)(
                     ITfInputScope *This);

    /*** ITfInputScope methods ***/
    HRESULT (STDMETHODCALLTYPE *GetInputScopes)(
                     ITfInputScope *This,
                     InputScope **pprgInputScopes,
                     UINT *pcCount);

    HRESULT (STDMETHODCALLTYPE *GetPhrase)(
                     ITfInputScope *This,
                     BSTR **ppbstrPhrases,
                     UINT *pcCount);

    HRESULT (STDMETHODCALLTYPE *GetRegularExpression)(
                     ITfInputScope *This,
                     BSTR *pbstrRegExp);

    HRESULT (STDMETHODCALLTYPE *GetSRGS)(
                     ITfInputScope *This,
                     BSTR *pbstrSRGS);

    HRESULT (STDMETHODCALLTYPE *GetXML)(
                     ITfInputScope *This,
                     BSTR *pbstrXML);

    END_INTERFACE
} ITfInputScopeVtbl;

interface ITfInputScope {
    CONST_VTBL ITfInputScopeVtbl* lpVtbl;
};

#ifdef COBJMACROS
#ifndef WIDL_C_INLINE_WRAPPERS
/*** IUnknown methods ***/
#define ITfInputScope_QueryInterface(This,riid,ppvObject) (This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define ITfInputScope_AddRef(This) (This)->lpVtbl->AddRef(This)
#define ITfInputScope_Release(This) (This)->lpVtbl->Release(This)
/*** ITfInputScope methods ***/
#define ITfInputScope_GetInputScopes(This,pprgInputScopes,pcCount) (This)->lpVtbl->GetInputScopes(This,pprgInputScopes,pcCount)
#define ITfInputScope_GetPhrase(This,ppbstrPhrases,pcCount) (This)->lpVtbl->GetPhrase(This,ppbstrPhrases,pcCount)
#define ITfInputScope_GetRegularExpression(This,pbstrRegExp) (This)->lpVtbl->GetRegularExpression(This,pbstrRegExp)
#define ITfInputScope_GetSRGS(This,pbstrSRGS) (This)->lpVtbl->GetSRGS(This,pbstrSRGS)
#define ITfInputScope_GetXML(This,pbstrXML) (This)->lpVtbl->GetXML(This,pbstrXML)
#else
/*** IUnknown methods ***/
static FORCEINLINE HRESULT ITfInputScope_QueryInterface(ITfInputScope* This,REFIID riid,void **ppvObject) {
    return This->lpVtbl->QueryInterface(This,riid,ppvObject);
}
static FORCEINLINE ULONG ITfInputScope_AddRef(ITfInputScope* This) {
    return This->lpVtbl->AddRef(This);
}
static FORCEINLINE ULONG ITfInputScope_Release(ITfInputScope* This) {
    return This->lpVtbl->Release(This);
}
/*** ITfInputScope methods ***/
static FORCEINLINE HRESULT ITfInputScope_GetInputScopes(ITfInputScope* This,InputScope **pprgInputScopes,UINT *pcCount) {
    return This->lpVtbl->GetInputScopes(This,pprgInputScopes,pcCount);
}
static FORCEINLINE HRESULT ITfInputScope_GetPhrase(ITfInputScope* This,BSTR **ppbstrPhrases,UINT *pcCount) {
    return This->lpVtbl->GetPhrase(This,ppbstrPhrases,pcCount);
}
static FORCEINLINE HRESULT ITfInputScope_GetRegularExpression(ITfInputScope* This,BSTR *pbstrRegExp) {
    return This->lpVtbl->GetRegularExpression(This,pbstrRegExp);
}
static FORCEINLINE HRESULT ITfInputScope_GetSRGS(ITfInputScope* This,BSTR *pbstrSRGS) {
    return This->lpVtbl->GetSRGS(This,pbstrSRGS);
}
static FORCEINLINE HRESULT ITfInputScope_GetXML(ITfInputScope* This,BSTR *pbstrXML) {
    return This->lpVtbl->GetXML(This,pbstrXML);
}
#endif
#endif

#endif


#endif  /* __ITfInputScope_INTERFACE_DEFINED__ */

/*****************************************************************************
 * ITfInputScope2 interface
 */
#ifndef __ITfInputScope2_INTERFACE_DEFINED__
#define __ITfInputScope2_INTERFACE_DEFINED__

DEFINE_GUID(IID_ITfInputScope2, 0x5731eaa0, 0x6bc2, 0x4681, 0xa5,0x32, 0x92,0xfb,0xb7,0x4d,0x7c,0x41);
#if defined(__cplusplus) && !defined(CINTERFACE)
MIDL_INTERFACE("5731eaa0-6bc2-4681-a532-92fbb74d7c41")
ITfInputScope2 : public ITfInputScope
{
    virtual HRESULT STDMETHODCALLTYPE EnumWordList(
                     IEnumString **ppEnumString) = 0;

};
#ifdef __CRT_UUID_DECL
__CRT_UUID_DECL(ITfInputScope2, 0x5731eaa0, 0x6bc2, 0x4681, 0xa5,0x32, 0x92,0xfb,0xb7,0x4d,0x7c,0x41)
#endif
#else
typedef struct ITfInputScope2Vtbl {
    BEGIN_INTERFACE

    /*** IUnknown methods ***/
    HRESULT (STDMETHODCALLTYPE *QueryInterface)(
                     ITfInputScope2 *This,
                     REFIID riid,
                     void **ppvObject);

    ULONG (STDMETHODCALLTYPE *AddRef)(
                     ITfInputScope2 *This);

    ULONG (STDMETHODCALLTYPE *Release)(
                     ITfInputScope2 *This);

    /*** ITfInputScope methods ***/
    HRESULT (STDMETHODCALLTYPE *GetInputScopes)(
                     ITfInputScope2 *This,
                     InputScope **pprgInputScopes,
                     UINT *pcCount);

    HRESULT (STDMETHODCALLTYPE *GetPhrase)(
                     ITfInputScope2 *This,
                     BSTR **ppbstrPhrases,
                     UINT *pcCount);

    HRESULT (STDMETHODCALLTYPE *GetRegularExpression)(
                     ITfInputScope2 *This,
                     BSTR *pbstrRegExp);

    HRESULT (STDMETHODCALLTYPE *GetSRGS)(
                     ITfInputScope2 *This,
                     BSTR *pbstrSRGS);

    HRESULT (STDMETHODCALLTYPE *GetXML)(
                     ITfInputScope2 *This,
                     BSTR *pbstrXML);

    /*** ITfInputScope2 methods ***/
    HRESULT (STDMETHODCALLTYPE *EnumWordList)(
                     ITfInputScope2 *This,
                     IEnumString **ppEnumString);

    END_INTERFACE
} ITfInputScope2Vtbl;

interface ITfInputScope2 {
    CONST_VTBL ITfInputScope2Vtbl* lpVtbl;
};

#ifdef COBJMACROS
#ifndef WIDL_C_INLINE_WRAPPERS
/*** IUnknown methods ***/
#define ITfInputScope2_QueryInterface(This,riid,ppvObject) (This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define ITfInputScope2_AddRef(This) (This)->lpVtbl->AddRef(This)
#define ITfInputScope2_Release(This) (This)->lpVtbl->Release(This)
/*** ITfInputScope methods ***/
#define ITfInputScope2_GetInputScopes(This,pprgInputScopes,pcCount) (This)->lpVtbl->GetInputScopes(This,pprgInputScopes,pcCount)
#define ITfInputScope2_GetPhrase(This,ppbstrPhrases,pcCount) (This)->lpVtbl->GetPhrase(This,ppbstrPhrases,pcCount)
#define ITfInputScope2_GetRegularExpression(This,pbstrRegExp) (This)->lpVtbl->GetRegularExpression(This,pbstrRegExp)
#define ITfInputScope2_GetSRGS(This,pbstrSRGS) (This)->lpVtbl->GetSRGS(This,pbstrSRGS)
#define ITfInputScope2_GetXML(This,pbstrXML) (This)->lpVtbl->GetXML(This,pbstrXML)
/*** ITfInputScope2 methods ***/
#define ITfInputScope2_EnumWordList(This,ppEnumString) (This)->lpVtbl->EnumWordList(This,ppEnumString)
#else
/*** IUnknown methods ***/
static FORCEINLINE HRESULT ITfInputScope2_QueryInterface(ITfInputScope2* This,REFIID riid,void **ppvObject) {
    return This->lpVtbl->QueryInterface(This,riid,ppvObject);
}
static FORCEINLINE ULONG ITfInputScope2_AddRef(ITfInputScope2* This) {
    return This->lpVtbl->AddRef(This);
}
static FORCEINLINE ULONG ITfInputScope2_Release(ITfInputScope2* This) {
    return This->lpVtbl->Release(This);
}
/*** ITfInputScope methods ***/
static FORCEINLINE HRESULT ITfInputScope2_GetInputScopes(ITfInputScope2* This,InputScope **pprgInputScopes,UINT *pcCount) {
    return This->lpVtbl->GetInputScopes(This,pprgInputScopes,pcCount);
}
static FORCEINLINE HRESULT ITfInputScope2_GetPhrase(ITfInputScope2* This,BSTR **ppbstrPhrases,UINT *pcCount) {
    return This->lpVtbl->GetPhrase(This,ppbstrPhrases,pcCount);
}
static FORCEINLINE HRESULT ITfInputScope2_GetRegularExpression(ITfInputScope2* This,BSTR *pbstrRegExp) {
    return This->lpVtbl->GetRegularExpression(This,pbstrRegExp);
}
static FORCEINLINE HRESULT ITfInputScope2_GetSRGS(ITfInputScope2* This,BSTR *pbstrSRGS) {
    return This->lpVtbl->GetSRGS(This,pbstrSRGS);
}
static FORCEINLINE HRESULT ITfInputScope2_GetXML(ITfInputScope2* This,BSTR *pbstrXML) {
    return This->lpVtbl->GetXML(This,pbstrXML);
}
/*** ITfInputScope2 methods ***/
static FORCEINLINE HRESULT ITfInputScope2_EnumWordList(ITfInputScope2* This,IEnumString **ppEnumString) {
    return This->lpVtbl->EnumWordList(This,ppEnumString);
}
#endif
#endif

#endif


#endif  /* __ITfInputScope2_INTERFACE_DEFINED__ */

#endif /* WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_APP) */
/* Begin additional prototypes for all interfaces */

ULONG                        __RPC_USER BSTR_UserSize     (ULONG *, ULONG, BSTR *);
unsigned char * __RPC_USER BSTR_UserMarshal  (ULONG *, unsigned char *, BSTR *);
unsigned char * __RPC_USER BSTR_UserUnmarshal(ULONG *, unsigned char *, BSTR *);
void                                      __RPC_USER BSTR_UserFree     (ULONG *, BSTR *);

/* End additional prototypes */

#ifdef __cplusplus
}
#endif

#endif /* __inputscope_h__ */
