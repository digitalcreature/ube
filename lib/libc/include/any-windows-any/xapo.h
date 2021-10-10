/*** Autogenerated by WIDL 5.16 from include/xapo.idl - Do not edit ***/

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

#ifndef __xapo_h__
#define __xapo_h__

/* Forward declarations */

#ifndef __IXAPO_FWD_DEFINED__
#define __IXAPO_FWD_DEFINED__
typedef interface IXAPO IXAPO;
#ifdef __cplusplus
interface IXAPO;
#endif /* __cplusplus */
#endif

#ifndef __IXAPOParameters_FWD_DEFINED__
#define __IXAPOParameters_FWD_DEFINED__
typedef interface IXAPOParameters IXAPOParameters;
#ifdef __cplusplus
interface IXAPOParameters;
#endif /* __cplusplus */
#endif

/* Headers for imported files */

#include <unknwn.h>

#ifdef __cplusplus
extern "C" {
#endif

#define XAPO_FLAG_CHANNELS_MUST_MATCH 0x1
#define XAPO_FLAG_FRAMERATE_MUST_MATCH 0x2
#define XAPO_FLAG_BITSPERSAMPLE_MUST_MATCH 0x4
#define XAPO_FLAG_BUFFERCOUNT_MUST_MATCH 0x8
#define XAPO_FLAG_INPLACE_SUPPORTED 0x10
#define XAPO_FLAG_INPLACE_REQUIRED 0x20
#if 0
typedef struct WAVEFORMATEX {
    WORD wFormatTag;
    WORD nChannels;
    DWORD nSamplesPerSec;
    DWORD nAvgBytesPerSec;
    WORD nBlockAlign;
    WORD wBitsPerSample;
    WORD cbSize;
} WAVEFORMATEX;
typedef struct __WIDL_xapo_generated_name_0000000C {
    WAVEFORMATEX Format;
    union {
                     WORD wValidBitsPerSample;
                     WORD wSamplesPerBlock;
                     WORD wReserved;
    } Samples;
    DWORD dwChannelMask;
    GUID SubFormat;
} WAVEFORMATEXTENSIBLE;
typedef struct __WIDL_xapo_generated_name_0000000C *PWAVEFORMATEXTENSIBLE;
#else
#include <mmreg.h>
#endif
typedef struct XAPO_REGISTRATION_PROPERTIES {
    CLSID clsid;
    WCHAR FriendlyName[256];
    WCHAR CopyrightInfo[256];
    UINT32 MajorVersion;
    UINT32 MinorVersion;
    UINT32 Flags;
    UINT32 MinInputBufferCount;
    UINT32 MaxInputBufferCount;
    UINT32 MinOutputBufferCount;
    UINT32 MaxOutputBufferCount;
} XAPO_REGISTRATION_PROPERTIES;
typedef struct XAPO20_REGISTRATION_PROPERTIES {
    CLSID clsid;
    WCHAR FriendlyName[256];
    WCHAR CopyrightInfo[256];
    UINT32 MajorVersion;
    UINT32 MinorVersion;
    UINT32 Flags;
    UINT32 MinInputBufferCount;
    UINT32 MaxInputBufferCount;
    UINT32 MinOutputBufferCount;
    UINT32 MaxOutputBufferCount;
    UINT32 InterfaceCount;
    IID InterfaceArray[1];
} XAPO20_REGISTRATION_PROPERTIES;
typedef struct XAPO_LOCKFORPROCESS_BUFFER_PARAMETERS {
    const WAVEFORMATEX *pFormat;
    UINT32 MaxFrameCount;
} XAPO_LOCKFORPROCESS_BUFFER_PARAMETERS;
typedef enum XAPO_BUFFER_FLAGS {
    XAPO_BUFFER_SILENT = 0,
    XAPO_BUFFER_VALID = 1
} XAPO_BUFFER_FLAGS;
typedef struct XAPO_PROCESS_BUFFER_PARAMETERS {
    void *pBuffer;
    XAPO_BUFFER_FLAGS BufferFlags;
    UINT32 ValidFrameCount;
} XAPO_PROCESS_BUFFER_PARAMETERS;
/*****************************************************************************
 * IXAPO interface
 */
#ifndef __IXAPO_INTERFACE_DEFINED__
#define __IXAPO_INTERFACE_DEFINED__

DEFINE_GUID(IID_IXAPO, 0xa410b984, 0x9839, 0x4819, 0xa0,0xbe, 0x28,0x56,0xae,0x6b,0x3a,0xdb);
#if defined(__cplusplus) && !defined(CINTERFACE)
MIDL_INTERFACE("a410b984-9839-4819-a0be-2856ae6b3adb")
IXAPO : public IUnknown
{
    virtual HRESULT STDMETHODCALLTYPE GetRegistrationProperties(
                     XAPO_REGISTRATION_PROPERTIES **props) = 0;

    virtual HRESULT STDMETHODCALLTYPE IsInputFormatSupported(
                     const WAVEFORMATEX *output_fmt,
                     const WAVEFORMATEX *input_fmt,
                     WAVEFORMATEX **supported_fmt) = 0;

    virtual HRESULT STDMETHODCALLTYPE IsOutputFormatSupported(
                     const WAVEFORMATEX *input_fmt,
                     const WAVEFORMATEX *output_fmt,
                     WAVEFORMATEX **supported_fmt) = 0;

    virtual HRESULT STDMETHODCALLTYPE Initialize(
                     const void *data,
                     UINT32 data_len) = 0;

    virtual void STDMETHODCALLTYPE Reset(
                     ) = 0;

    virtual HRESULT STDMETHODCALLTYPE LockForProcess(
                     UINT32 in_params_count,
                     const XAPO_LOCKFORPROCESS_BUFFER_PARAMETERS *in_params,
                     UINT32 out_params_count,
                     const XAPO_LOCKFORPROCESS_BUFFER_PARAMETERS *out_params) = 0;

    virtual void STDMETHODCALLTYPE UnlockForProcess(
                     ) = 0;

    virtual void STDMETHODCALLTYPE Process(
                     UINT32 in_params_count,
                     const XAPO_PROCESS_BUFFER_PARAMETERS *in_params,
                     UINT32 out_params_count,
                     XAPO_PROCESS_BUFFER_PARAMETERS *out_params,
                     WINBOOL enabled) = 0;

    virtual UINT32 STDMETHODCALLTYPE CalcInputFrames(
                     UINT32 output_frames) = 0;

    virtual UINT32 STDMETHODCALLTYPE CalcOutputFrames(
                     UINT32 input_frames) = 0;

};
#ifdef __CRT_UUID_DECL
__CRT_UUID_DECL(IXAPO, 0xa410b984, 0x9839, 0x4819, 0xa0,0xbe, 0x28,0x56,0xae,0x6b,0x3a,0xdb)
#endif
#else
typedef struct IXAPOVtbl {
    BEGIN_INTERFACE

    /*** IUnknown methods ***/
    HRESULT (STDMETHODCALLTYPE *QueryInterface)(
                     IXAPO *This,
                     REFIID riid,
                     void **ppvObject);

    ULONG (STDMETHODCALLTYPE *AddRef)(
                     IXAPO *This);

    ULONG (STDMETHODCALLTYPE *Release)(
                     IXAPO *This);

    /*** IXAPO methods ***/
    HRESULT (STDMETHODCALLTYPE *GetRegistrationProperties)(
                     IXAPO *This,
                     XAPO_REGISTRATION_PROPERTIES **props);

    HRESULT (STDMETHODCALLTYPE *IsInputFormatSupported)(
                     IXAPO *This,
                     const WAVEFORMATEX *output_fmt,
                     const WAVEFORMATEX *input_fmt,
                     WAVEFORMATEX **supported_fmt);

    HRESULT (STDMETHODCALLTYPE *IsOutputFormatSupported)(
                     IXAPO *This,
                     const WAVEFORMATEX *input_fmt,
                     const WAVEFORMATEX *output_fmt,
                     WAVEFORMATEX **supported_fmt);

    HRESULT (STDMETHODCALLTYPE *Initialize)(
                     IXAPO *This,
                     const void *data,
                     UINT32 data_len);

    void (STDMETHODCALLTYPE *Reset)(
                     IXAPO *This);

    HRESULT (STDMETHODCALLTYPE *LockForProcess)(
                     IXAPO *This,
                     UINT32 in_params_count,
                     const XAPO_LOCKFORPROCESS_BUFFER_PARAMETERS *in_params,
                     UINT32 out_params_count,
                     const XAPO_LOCKFORPROCESS_BUFFER_PARAMETERS *out_params);

    void (STDMETHODCALLTYPE *UnlockForProcess)(
                     IXAPO *This);

    void (STDMETHODCALLTYPE *Process)(
                     IXAPO *This,
                     UINT32 in_params_count,
                     const XAPO_PROCESS_BUFFER_PARAMETERS *in_params,
                     UINT32 out_params_count,
                     XAPO_PROCESS_BUFFER_PARAMETERS *out_params,
                     WINBOOL enabled);

    UINT32 (STDMETHODCALLTYPE *CalcInputFrames)(
                     IXAPO *This,
                     UINT32 output_frames);

    UINT32 (STDMETHODCALLTYPE *CalcOutputFrames)(
                     IXAPO *This,
                     UINT32 input_frames);

    END_INTERFACE
} IXAPOVtbl;

interface IXAPO {
    CONST_VTBL IXAPOVtbl* lpVtbl;
};

#ifdef COBJMACROS
#ifndef WIDL_C_INLINE_WRAPPERS
/*** IUnknown methods ***/
#define IXAPO_QueryInterface(This,riid,ppvObject) (This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define IXAPO_AddRef(This) (This)->lpVtbl->AddRef(This)
#define IXAPO_Release(This) (This)->lpVtbl->Release(This)
/*** IXAPO methods ***/
#define IXAPO_GetRegistrationProperties(This,props) (This)->lpVtbl->GetRegistrationProperties(This,props)
#define IXAPO_IsInputFormatSupported(This,output_fmt,input_fmt,supported_fmt) (This)->lpVtbl->IsInputFormatSupported(This,output_fmt,input_fmt,supported_fmt)
#define IXAPO_IsOutputFormatSupported(This,input_fmt,output_fmt,supported_fmt) (This)->lpVtbl->IsOutputFormatSupported(This,input_fmt,output_fmt,supported_fmt)
#define IXAPO_Initialize(This,data,data_len) (This)->lpVtbl->Initialize(This,data,data_len)
#define IXAPO_Reset(This) (This)->lpVtbl->Reset(This)
#define IXAPO_LockForProcess(This,in_params_count,in_params,out_params_count,out_params) (This)->lpVtbl->LockForProcess(This,in_params_count,in_params,out_params_count,out_params)
#define IXAPO_UnlockForProcess(This) (This)->lpVtbl->UnlockForProcess(This)
#define IXAPO_Process(This,in_params_count,in_params,out_params_count,out_params,enabled) (This)->lpVtbl->Process(This,in_params_count,in_params,out_params_count,out_params,enabled)
#define IXAPO_CalcInputFrames(This,output_frames) (This)->lpVtbl->CalcInputFrames(This,output_frames)
#define IXAPO_CalcOutputFrames(This,input_frames) (This)->lpVtbl->CalcOutputFrames(This,input_frames)
#else
/*** IUnknown methods ***/
static FORCEINLINE HRESULT IXAPO_QueryInterface(IXAPO* This,REFIID riid,void **ppvObject) {
    return This->lpVtbl->QueryInterface(This,riid,ppvObject);
}
static FORCEINLINE ULONG IXAPO_AddRef(IXAPO* This) {
    return This->lpVtbl->AddRef(This);
}
static FORCEINLINE ULONG IXAPO_Release(IXAPO* This) {
    return This->lpVtbl->Release(This);
}
/*** IXAPO methods ***/
static FORCEINLINE HRESULT IXAPO_GetRegistrationProperties(IXAPO* This,XAPO_REGISTRATION_PROPERTIES **props) {
    return This->lpVtbl->GetRegistrationProperties(This,props);
}
static FORCEINLINE HRESULT IXAPO_IsInputFormatSupported(IXAPO* This,const WAVEFORMATEX *output_fmt,const WAVEFORMATEX *input_fmt,WAVEFORMATEX **supported_fmt) {
    return This->lpVtbl->IsInputFormatSupported(This,output_fmt,input_fmt,supported_fmt);
}
static FORCEINLINE HRESULT IXAPO_IsOutputFormatSupported(IXAPO* This,const WAVEFORMATEX *input_fmt,const WAVEFORMATEX *output_fmt,WAVEFORMATEX **supported_fmt) {
    return This->lpVtbl->IsOutputFormatSupported(This,input_fmt,output_fmt,supported_fmt);
}
static FORCEINLINE HRESULT IXAPO_Initialize(IXAPO* This,const void *data,UINT32 data_len) {
    return This->lpVtbl->Initialize(This,data,data_len);
}
static FORCEINLINE void IXAPO_Reset(IXAPO* This) {
    This->lpVtbl->Reset(This);
}
static FORCEINLINE HRESULT IXAPO_LockForProcess(IXAPO* This,UINT32 in_params_count,const XAPO_LOCKFORPROCESS_BUFFER_PARAMETERS *in_params,UINT32 out_params_count,const XAPO_LOCKFORPROCESS_BUFFER_PARAMETERS *out_params) {
    return This->lpVtbl->LockForProcess(This,in_params_count,in_params,out_params_count,out_params);
}
static FORCEINLINE void IXAPO_UnlockForProcess(IXAPO* This) {
    This->lpVtbl->UnlockForProcess(This);
}
static FORCEINLINE void IXAPO_Process(IXAPO* This,UINT32 in_params_count,const XAPO_PROCESS_BUFFER_PARAMETERS *in_params,UINT32 out_params_count,XAPO_PROCESS_BUFFER_PARAMETERS *out_params,WINBOOL enabled) {
    This->lpVtbl->Process(This,in_params_count,in_params,out_params_count,out_params,enabled);
}
static FORCEINLINE UINT32 IXAPO_CalcInputFrames(IXAPO* This,UINT32 output_frames) {
    return This->lpVtbl->CalcInputFrames(This,output_frames);
}
static FORCEINLINE UINT32 IXAPO_CalcOutputFrames(IXAPO* This,UINT32 input_frames) {
    return This->lpVtbl->CalcOutputFrames(This,input_frames);
}
#endif
#endif

#endif


#endif  /* __IXAPO_INTERFACE_DEFINED__ */

DEFINE_GUID(IID_IXAPO27, 0xa90bc001, 0xe897, 0xe897, 0x55, 0xe4, 0x9e, 0x47, 0x00, 0x00, 0x00, 0x00);
/*****************************************************************************
 * IXAPOParameters interface
 */
#ifndef __IXAPOParameters_INTERFACE_DEFINED__
#define __IXAPOParameters_INTERFACE_DEFINED__

DEFINE_GUID(IID_IXAPOParameters, 0x26d95c66, 0x80f2, 0x499a, 0xad,0x54, 0x5a,0xe7,0xf0,0x1c,0x6d,0x98);
#if defined(__cplusplus) && !defined(CINTERFACE)
MIDL_INTERFACE("26d95c66-80f2-499a-ad54-5ae7f01c6d98")
IXAPOParameters : public IUnknown
{
    virtual void STDMETHODCALLTYPE SetParameters(
                     const void *params,
                     UINT32 params_len) = 0;

    virtual void STDMETHODCALLTYPE GetParameters(
                     void *params,
                     UINT32 params_len) = 0;

};
#ifdef __CRT_UUID_DECL
__CRT_UUID_DECL(IXAPOParameters, 0x26d95c66, 0x80f2, 0x499a, 0xad,0x54, 0x5a,0xe7,0xf0,0x1c,0x6d,0x98)
#endif
#else
typedef struct IXAPOParametersVtbl {
    BEGIN_INTERFACE

    /*** IUnknown methods ***/
    HRESULT (STDMETHODCALLTYPE *QueryInterface)(
                     IXAPOParameters *This,
                     REFIID riid,
                     void **ppvObject);

    ULONG (STDMETHODCALLTYPE *AddRef)(
                     IXAPOParameters *This);

    ULONG (STDMETHODCALLTYPE *Release)(
                     IXAPOParameters *This);

    /*** IXAPOParameters methods ***/
    void (STDMETHODCALLTYPE *SetParameters)(
                     IXAPOParameters *This,
                     const void *params,
                     UINT32 params_len);

    void (STDMETHODCALLTYPE *GetParameters)(
                     IXAPOParameters *This,
                     void *params,
                     UINT32 params_len);

    END_INTERFACE
} IXAPOParametersVtbl;

interface IXAPOParameters {
    CONST_VTBL IXAPOParametersVtbl* lpVtbl;
};

#ifdef COBJMACROS
#ifndef WIDL_C_INLINE_WRAPPERS
/*** IUnknown methods ***/
#define IXAPOParameters_QueryInterface(This,riid,ppvObject) (This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define IXAPOParameters_AddRef(This) (This)->lpVtbl->AddRef(This)
#define IXAPOParameters_Release(This) (This)->lpVtbl->Release(This)
/*** IXAPOParameters methods ***/
#define IXAPOParameters_SetParameters(This,params,params_len) (This)->lpVtbl->SetParameters(This,params,params_len)
#define IXAPOParameters_GetParameters(This,params,params_len) (This)->lpVtbl->GetParameters(This,params,params_len)
#else
/*** IUnknown methods ***/
static FORCEINLINE HRESULT IXAPOParameters_QueryInterface(IXAPOParameters* This,REFIID riid,void **ppvObject) {
    return This->lpVtbl->QueryInterface(This,riid,ppvObject);
}
static FORCEINLINE ULONG IXAPOParameters_AddRef(IXAPOParameters* This) {
    return This->lpVtbl->AddRef(This);
}
static FORCEINLINE ULONG IXAPOParameters_Release(IXAPOParameters* This) {
    return This->lpVtbl->Release(This);
}
/*** IXAPOParameters methods ***/
static FORCEINLINE void IXAPOParameters_SetParameters(IXAPOParameters* This,const void *params,UINT32 params_len) {
    This->lpVtbl->SetParameters(This,params,params_len);
}
static FORCEINLINE void IXAPOParameters_GetParameters(IXAPOParameters* This,void *params,UINT32 params_len) {
    This->lpVtbl->GetParameters(This,params,params_len);
}
#endif
#endif

#endif


#endif  /* __IXAPOParameters_INTERFACE_DEFINED__ */

DEFINE_GUID(IID_IXAPO27Parameters, 0xa90bc001, 0xe897, 0xe897, 0x55, 0xe4, 0x9e, 0x47, 0x00, 0x00, 0x00, 0x01);
/* Begin additional prototypes for all interfaces */


/* End additional prototypes */

#ifdef __cplusplus
}
#endif

#endif /* __xapo_h__ */
