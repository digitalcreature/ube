/*** Autogenerated by WIDL 5.16 from include/ctfutb.idl - Do not edit ***/

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

#ifndef __ctfutb_h__
#define __ctfutb_h__

/* Forward declarations */

#ifndef __ITfLangBarItem_FWD_DEFINED__
#define __ITfLangBarItem_FWD_DEFINED__
typedef interface ITfLangBarItem ITfLangBarItem;
#ifdef __cplusplus
interface ITfLangBarItem;
#endif /* __cplusplus */
#endif

#ifndef __IEnumTfLangBarItems_FWD_DEFINED__
#define __IEnumTfLangBarItems_FWD_DEFINED__
typedef interface IEnumTfLangBarItems IEnumTfLangBarItems;
#ifdef __cplusplus
interface IEnumTfLangBarItems;
#endif /* __cplusplus */
#endif

#ifndef __ITfLangBarItemSink_FWD_DEFINED__
#define __ITfLangBarItemSink_FWD_DEFINED__
typedef interface ITfLangBarItemSink ITfLangBarItemSink;
#ifdef __cplusplus
interface ITfLangBarItemSink;
#endif /* __cplusplus */
#endif

#ifndef __ITfLangBarItemMgr_FWD_DEFINED__
#define __ITfLangBarItemMgr_FWD_DEFINED__
typedef interface ITfLangBarItemMgr ITfLangBarItemMgr;
#ifdef __cplusplus
interface ITfLangBarItemMgr;
#endif /* __cplusplus */
#endif

#ifndef __ITfLangBarMgr_FWD_DEFINED__
#define __ITfLangBarMgr_FWD_DEFINED__
typedef interface ITfLangBarMgr ITfLangBarMgr;
#ifdef __cplusplus
interface ITfLangBarMgr;
#endif /* __cplusplus */
#endif

#ifndef __ITfLangBarEventSink_FWD_DEFINED__
#define __ITfLangBarEventSink_FWD_DEFINED__
typedef interface ITfLangBarEventSink ITfLangBarEventSink;
#ifdef __cplusplus
interface ITfLangBarEventSink;
#endif /* __cplusplus */
#endif

/* Headers for imported files */

#include <oaidl.h>

#ifdef __cplusplus
extern "C" {
#endif

#ifndef __ITfLangBarEventSink_FWD_DEFINED__
#define __ITfLangBarEventSink_FWD_DEFINED__
typedef interface ITfLangBarEventSink ITfLangBarEventSink;
#ifdef __cplusplus
interface ITfLangBarEventSink;
#endif /* __cplusplus */
#endif

#ifndef __ITfLangBarItemMgr_FWD_DEFINED__
#define __ITfLangBarItemMgr_FWD_DEFINED__
typedef interface ITfLangBarItemMgr ITfLangBarItemMgr;
#ifdef __cplusplus
interface ITfLangBarItemMgr;
#endif /* __cplusplus */
#endif

#ifndef __ITfInputProcessorProfiles_FWD_DEFINED__
#define __ITfInputProcessorProfiles_FWD_DEFINED__
typedef interface ITfInputProcessorProfiles ITfInputProcessorProfiles;
#ifdef __cplusplus
interface ITfInputProcessorProfiles;
#endif /* __cplusplus */
#endif

#define TF_LBI_DESC_MAXLEN (32)

typedef struct TF_LANGBARITEMINFO {
    CLSID clsidService;
    GUID guidItem;
    DWORD dwStyle;
    ULONG ulSort;
    WCHAR szDescription[32];
} TF_LANGBARITEMINFO;
/*****************************************************************************
 * ITfLangBarItem interface
 */
#ifndef __ITfLangBarItem_INTERFACE_DEFINED__
#define __ITfLangBarItem_INTERFACE_DEFINED__

DEFINE_GUID(IID_ITfLangBarItem, 0x73540d69, 0xedeb, 0x4ee9, 0x96,0xc9, 0x23,0xaa,0x30,0xb2,0x59,0x16);
#if defined(__cplusplus) && !defined(CINTERFACE)
MIDL_INTERFACE("73540d69-edeb-4ee9-96c9-23aa30b25916")
ITfLangBarItem : public IUnknown
{
    virtual HRESULT STDMETHODCALLTYPE GetInfo(
                     TF_LANGBARITEMINFO *pInfo) = 0;

    virtual HRESULT STDMETHODCALLTYPE GetStatus(
                     DWORD *pdwStatus) = 0;

    virtual HRESULT STDMETHODCALLTYPE Show(
                     WINBOOL fShow) = 0;

    virtual HRESULT STDMETHODCALLTYPE GetTooltipString(
                     BSTR *pbstrToolTip) = 0;

};
#ifdef __CRT_UUID_DECL
__CRT_UUID_DECL(ITfLangBarItem, 0x73540d69, 0xedeb, 0x4ee9, 0x96,0xc9, 0x23,0xaa,0x30,0xb2,0x59,0x16)
#endif
#else
typedef struct ITfLangBarItemVtbl {
    BEGIN_INTERFACE

    /*** IUnknown methods ***/
    HRESULT (STDMETHODCALLTYPE *QueryInterface)(
                     ITfLangBarItem *This,
                     REFIID riid,
                     void **ppvObject);

    ULONG (STDMETHODCALLTYPE *AddRef)(
                     ITfLangBarItem *This);

    ULONG (STDMETHODCALLTYPE *Release)(
                     ITfLangBarItem *This);

    /*** ITfLangBarItem methods ***/
    HRESULT (STDMETHODCALLTYPE *GetInfo)(
                     ITfLangBarItem *This,
                     TF_LANGBARITEMINFO *pInfo);

    HRESULT (STDMETHODCALLTYPE *GetStatus)(
                     ITfLangBarItem *This,
                     DWORD *pdwStatus);

    HRESULT (STDMETHODCALLTYPE *Show)(
                     ITfLangBarItem *This,
                     WINBOOL fShow);

    HRESULT (STDMETHODCALLTYPE *GetTooltipString)(
                     ITfLangBarItem *This,
                     BSTR *pbstrToolTip);

    END_INTERFACE
} ITfLangBarItemVtbl;

interface ITfLangBarItem {
    CONST_VTBL ITfLangBarItemVtbl* lpVtbl;
};

#ifdef COBJMACROS
#ifndef WIDL_C_INLINE_WRAPPERS
/*** IUnknown methods ***/
#define ITfLangBarItem_QueryInterface(This,riid,ppvObject) (This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define ITfLangBarItem_AddRef(This) (This)->lpVtbl->AddRef(This)
#define ITfLangBarItem_Release(This) (This)->lpVtbl->Release(This)
/*** ITfLangBarItem methods ***/
#define ITfLangBarItem_GetInfo(This,pInfo) (This)->lpVtbl->GetInfo(This,pInfo)
#define ITfLangBarItem_GetStatus(This,pdwStatus) (This)->lpVtbl->GetStatus(This,pdwStatus)
#define ITfLangBarItem_Show(This,fShow) (This)->lpVtbl->Show(This,fShow)
#define ITfLangBarItem_GetTooltipString(This,pbstrToolTip) (This)->lpVtbl->GetTooltipString(This,pbstrToolTip)
#else
/*** IUnknown methods ***/
static FORCEINLINE HRESULT ITfLangBarItem_QueryInterface(ITfLangBarItem* This,REFIID riid,void **ppvObject) {
    return This->lpVtbl->QueryInterface(This,riid,ppvObject);
}
static FORCEINLINE ULONG ITfLangBarItem_AddRef(ITfLangBarItem* This) {
    return This->lpVtbl->AddRef(This);
}
static FORCEINLINE ULONG ITfLangBarItem_Release(ITfLangBarItem* This) {
    return This->lpVtbl->Release(This);
}
/*** ITfLangBarItem methods ***/
static FORCEINLINE HRESULT ITfLangBarItem_GetInfo(ITfLangBarItem* This,TF_LANGBARITEMINFO *pInfo) {
    return This->lpVtbl->GetInfo(This,pInfo);
}
static FORCEINLINE HRESULT ITfLangBarItem_GetStatus(ITfLangBarItem* This,DWORD *pdwStatus) {
    return This->lpVtbl->GetStatus(This,pdwStatus);
}
static FORCEINLINE HRESULT ITfLangBarItem_Show(ITfLangBarItem* This,WINBOOL fShow) {
    return This->lpVtbl->Show(This,fShow);
}
static FORCEINLINE HRESULT ITfLangBarItem_GetTooltipString(ITfLangBarItem* This,BSTR *pbstrToolTip) {
    return This->lpVtbl->GetTooltipString(This,pbstrToolTip);
}
#endif
#endif

#endif


#endif  /* __ITfLangBarItem_INTERFACE_DEFINED__ */

/*****************************************************************************
 * IEnumTfLangBarItems interface
 */
#ifndef __IEnumTfLangBarItems_INTERFACE_DEFINED__
#define __IEnumTfLangBarItems_INTERFACE_DEFINED__

DEFINE_GUID(IID_IEnumTfLangBarItems, 0x583f34d0, 0xde25, 0x11d2, 0xaf,0xdd, 0x00,0x10,0x5a,0x27,0x99,0xb5);
#if defined(__cplusplus) && !defined(CINTERFACE)
MIDL_INTERFACE("583f34d0-de25-11d2-afdd-00105a2799b5")
IEnumTfLangBarItems : public IUnknown
{
    virtual HRESULT STDMETHODCALLTYPE Clone(
                     IEnumTfLangBarItems **ppEnum) = 0;

    virtual HRESULT STDMETHODCALLTYPE Next(
                     ULONG ulCount,
                     ITfLangBarItem **ppItem,
                     ULONG *pcFetched) = 0;

    virtual HRESULT STDMETHODCALLTYPE Reset(
                     ) = 0;

    virtual HRESULT STDMETHODCALLTYPE Skip(
                     ULONG ulCount) = 0;

};
#ifdef __CRT_UUID_DECL
__CRT_UUID_DECL(IEnumTfLangBarItems, 0x583f34d0, 0xde25, 0x11d2, 0xaf,0xdd, 0x00,0x10,0x5a,0x27,0x99,0xb5)
#endif
#else
typedef struct IEnumTfLangBarItemsVtbl {
    BEGIN_INTERFACE

    /*** IUnknown methods ***/
    HRESULT (STDMETHODCALLTYPE *QueryInterface)(
                     IEnumTfLangBarItems *This,
                     REFIID riid,
                     void **ppvObject);

    ULONG (STDMETHODCALLTYPE *AddRef)(
                     IEnumTfLangBarItems *This);

    ULONG (STDMETHODCALLTYPE *Release)(
                     IEnumTfLangBarItems *This);

    /*** IEnumTfLangBarItems methods ***/
    HRESULT (STDMETHODCALLTYPE *Clone)(
                     IEnumTfLangBarItems *This,
                     IEnumTfLangBarItems **ppEnum);

    HRESULT (STDMETHODCALLTYPE *Next)(
                     IEnumTfLangBarItems *This,
                     ULONG ulCount,
                     ITfLangBarItem **ppItem,
                     ULONG *pcFetched);

    HRESULT (STDMETHODCALLTYPE *Reset)(
                     IEnumTfLangBarItems *This);

    HRESULT (STDMETHODCALLTYPE *Skip)(
                     IEnumTfLangBarItems *This,
                     ULONG ulCount);

    END_INTERFACE
} IEnumTfLangBarItemsVtbl;

interface IEnumTfLangBarItems {
    CONST_VTBL IEnumTfLangBarItemsVtbl* lpVtbl;
};

#ifdef COBJMACROS
#ifndef WIDL_C_INLINE_WRAPPERS
/*** IUnknown methods ***/
#define IEnumTfLangBarItems_QueryInterface(This,riid,ppvObject) (This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define IEnumTfLangBarItems_AddRef(This) (This)->lpVtbl->AddRef(This)
#define IEnumTfLangBarItems_Release(This) (This)->lpVtbl->Release(This)
/*** IEnumTfLangBarItems methods ***/
#define IEnumTfLangBarItems_Clone(This,ppEnum) (This)->lpVtbl->Clone(This,ppEnum)
#define IEnumTfLangBarItems_Next(This,ulCount,ppItem,pcFetched) (This)->lpVtbl->Next(This,ulCount,ppItem,pcFetched)
#define IEnumTfLangBarItems_Reset(This) (This)->lpVtbl->Reset(This)
#define IEnumTfLangBarItems_Skip(This,ulCount) (This)->lpVtbl->Skip(This,ulCount)
#else
/*** IUnknown methods ***/
static FORCEINLINE HRESULT IEnumTfLangBarItems_QueryInterface(IEnumTfLangBarItems* This,REFIID riid,void **ppvObject) {
    return This->lpVtbl->QueryInterface(This,riid,ppvObject);
}
static FORCEINLINE ULONG IEnumTfLangBarItems_AddRef(IEnumTfLangBarItems* This) {
    return This->lpVtbl->AddRef(This);
}
static FORCEINLINE ULONG IEnumTfLangBarItems_Release(IEnumTfLangBarItems* This) {
    return This->lpVtbl->Release(This);
}
/*** IEnumTfLangBarItems methods ***/
static FORCEINLINE HRESULT IEnumTfLangBarItems_Clone(IEnumTfLangBarItems* This,IEnumTfLangBarItems **ppEnum) {
    return This->lpVtbl->Clone(This,ppEnum);
}
static FORCEINLINE HRESULT IEnumTfLangBarItems_Next(IEnumTfLangBarItems* This,ULONG ulCount,ITfLangBarItem **ppItem,ULONG *pcFetched) {
    return This->lpVtbl->Next(This,ulCount,ppItem,pcFetched);
}
static FORCEINLINE HRESULT IEnumTfLangBarItems_Reset(IEnumTfLangBarItems* This) {
    return This->lpVtbl->Reset(This);
}
static FORCEINLINE HRESULT IEnumTfLangBarItems_Skip(IEnumTfLangBarItems* This,ULONG ulCount) {
    return This->lpVtbl->Skip(This,ulCount);
}
#endif
#endif

#endif


#endif  /* __IEnumTfLangBarItems_INTERFACE_DEFINED__ */

/*****************************************************************************
 * ITfLangBarItemSink interface
 */
#ifndef __ITfLangBarItemSink_INTERFACE_DEFINED__
#define __ITfLangBarItemSink_INTERFACE_DEFINED__

DEFINE_GUID(IID_ITfLangBarItemSink, 0x57dbe1a0, 0xde25, 0x11d2, 0xaf,0xdd, 0x00,0x10,0x5a,0x27,0x99,0xb5);
#if defined(__cplusplus) && !defined(CINTERFACE)
MIDL_INTERFACE("57dbe1a0-de25-11d2-afdd-00105a2799b5")
ITfLangBarItemSink : public IUnknown
{
    virtual HRESULT STDMETHODCALLTYPE OnUpdate(
                     DWORD dwFlags) = 0;

};
#ifdef __CRT_UUID_DECL
__CRT_UUID_DECL(ITfLangBarItemSink, 0x57dbe1a0, 0xde25, 0x11d2, 0xaf,0xdd, 0x00,0x10,0x5a,0x27,0x99,0xb5)
#endif
#else
typedef struct ITfLangBarItemSinkVtbl {
    BEGIN_INTERFACE

    /*** IUnknown methods ***/
    HRESULT (STDMETHODCALLTYPE *QueryInterface)(
                     ITfLangBarItemSink *This,
                     REFIID riid,
                     void **ppvObject);

    ULONG (STDMETHODCALLTYPE *AddRef)(
                     ITfLangBarItemSink *This);

    ULONG (STDMETHODCALLTYPE *Release)(
                     ITfLangBarItemSink *This);

    /*** ITfLangBarItemSink methods ***/
    HRESULT (STDMETHODCALLTYPE *OnUpdate)(
                     ITfLangBarItemSink *This,
                     DWORD dwFlags);

    END_INTERFACE
} ITfLangBarItemSinkVtbl;

interface ITfLangBarItemSink {
    CONST_VTBL ITfLangBarItemSinkVtbl* lpVtbl;
};

#ifdef COBJMACROS
#ifndef WIDL_C_INLINE_WRAPPERS
/*** IUnknown methods ***/
#define ITfLangBarItemSink_QueryInterface(This,riid,ppvObject) (This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define ITfLangBarItemSink_AddRef(This) (This)->lpVtbl->AddRef(This)
#define ITfLangBarItemSink_Release(This) (This)->lpVtbl->Release(This)
/*** ITfLangBarItemSink methods ***/
#define ITfLangBarItemSink_OnUpdate(This,dwFlags) (This)->lpVtbl->OnUpdate(This,dwFlags)
#else
/*** IUnknown methods ***/
static FORCEINLINE HRESULT ITfLangBarItemSink_QueryInterface(ITfLangBarItemSink* This,REFIID riid,void **ppvObject) {
    return This->lpVtbl->QueryInterface(This,riid,ppvObject);
}
static FORCEINLINE ULONG ITfLangBarItemSink_AddRef(ITfLangBarItemSink* This) {
    return This->lpVtbl->AddRef(This);
}
static FORCEINLINE ULONG ITfLangBarItemSink_Release(ITfLangBarItemSink* This) {
    return This->lpVtbl->Release(This);
}
/*** ITfLangBarItemSink methods ***/
static FORCEINLINE HRESULT ITfLangBarItemSink_OnUpdate(ITfLangBarItemSink* This,DWORD dwFlags) {
    return This->lpVtbl->OnUpdate(This,dwFlags);
}
#endif
#endif

#endif


#endif  /* __ITfLangBarItemSink_INTERFACE_DEFINED__ */

/*****************************************************************************
 * ITfLangBarItemMgr interface
 */
#ifndef __ITfLangBarItemMgr_INTERFACE_DEFINED__
#define __ITfLangBarItemMgr_INTERFACE_DEFINED__

DEFINE_GUID(IID_ITfLangBarItemMgr, 0xba468c55, 0x9956, 0x4fb1, 0xa5,0x9d, 0x52,0xa7,0xdd,0x7c,0xc6,0xaa);
#if defined(__cplusplus) && !defined(CINTERFACE)
MIDL_INTERFACE("ba468c55-9956-4fb1-a59d-52a7dd7cc6aa")
ITfLangBarItemMgr : public IUnknown
{
    virtual HRESULT STDMETHODCALLTYPE EnumItems(
                     IEnumTfLangBarItems **ppEnum) = 0;

    virtual HRESULT STDMETHODCALLTYPE GetItem(
                     REFGUID rguid,
                     ITfLangBarItem **ppItem) = 0;

    virtual HRESULT STDMETHODCALLTYPE AddItem(
                     ITfLangBarItem *punk) = 0;

    virtual HRESULT STDMETHODCALLTYPE RemoveItem(
                     ITfLangBarItem *punk) = 0;

    virtual HRESULT STDMETHODCALLTYPE AdviseItemSink(
                     ITfLangBarItemSink *punk,
                     DWORD *pdwCookie,
                     REFGUID rguidItem) = 0;

    virtual HRESULT STDMETHODCALLTYPE UnadviseItemSink(
                     DWORD dwCookie) = 0;

    virtual HRESULT STDMETHODCALLTYPE GetItemFloatingRect(
                     DWORD dwThreadId,
                     REFGUID rguid,
                     RECT *prc) = 0;

    virtual HRESULT STDMETHODCALLTYPE GetItemsStatus(
                     ULONG ulCount,
                     const GUID *prgguid,
                     DWORD *pdwStatus) = 0;

    virtual HRESULT STDMETHODCALLTYPE GetItemNum(
                     ULONG *pulCount) = 0;

    virtual HRESULT STDMETHODCALLTYPE GetItems(
                     ULONG ulCount,
                     ITfLangBarItem **ppItem,
                     TF_LANGBARITEMINFO *pInfo,
                     DWORD *pdwStatus,
                     ULONG *pcFetched) = 0;

    virtual HRESULT STDMETHODCALLTYPE AdviseItemsSink(
                     ULONG ulCount,
                     ITfLangBarItemSink **ppunk,
                     const GUID *pguidItem,
                     DWORD *pdwCookie) = 0;

    virtual HRESULT STDMETHODCALLTYPE UnadviseItemsSink(
                     ULONG ulCount,
                     DWORD *pdwCookie) = 0;

};
#ifdef __CRT_UUID_DECL
__CRT_UUID_DECL(ITfLangBarItemMgr, 0xba468c55, 0x9956, 0x4fb1, 0xa5,0x9d, 0x52,0xa7,0xdd,0x7c,0xc6,0xaa)
#endif
#else
typedef struct ITfLangBarItemMgrVtbl {
    BEGIN_INTERFACE

    /*** IUnknown methods ***/
    HRESULT (STDMETHODCALLTYPE *QueryInterface)(
                     ITfLangBarItemMgr *This,
                     REFIID riid,
                     void **ppvObject);

    ULONG (STDMETHODCALLTYPE *AddRef)(
                     ITfLangBarItemMgr *This);

    ULONG (STDMETHODCALLTYPE *Release)(
                     ITfLangBarItemMgr *This);

    /*** ITfLangBarItemMgr methods ***/
    HRESULT (STDMETHODCALLTYPE *EnumItems)(
                     ITfLangBarItemMgr *This,
                     IEnumTfLangBarItems **ppEnum);

    HRESULT (STDMETHODCALLTYPE *GetItem)(
                     ITfLangBarItemMgr *This,
                     REFGUID rguid,
                     ITfLangBarItem **ppItem);

    HRESULT (STDMETHODCALLTYPE *AddItem)(
                     ITfLangBarItemMgr *This,
                     ITfLangBarItem *punk);

    HRESULT (STDMETHODCALLTYPE *RemoveItem)(
                     ITfLangBarItemMgr *This,
                     ITfLangBarItem *punk);

    HRESULT (STDMETHODCALLTYPE *AdviseItemSink)(
                     ITfLangBarItemMgr *This,
                     ITfLangBarItemSink *punk,
                     DWORD *pdwCookie,
                     REFGUID rguidItem);

    HRESULT (STDMETHODCALLTYPE *UnadviseItemSink)(
                     ITfLangBarItemMgr *This,
                     DWORD dwCookie);

    HRESULT (STDMETHODCALLTYPE *GetItemFloatingRect)(
                     ITfLangBarItemMgr *This,
                     DWORD dwThreadId,
                     REFGUID rguid,
                     RECT *prc);

    HRESULT (STDMETHODCALLTYPE *GetItemsStatus)(
                     ITfLangBarItemMgr *This,
                     ULONG ulCount,
                     const GUID *prgguid,
                     DWORD *pdwStatus);

    HRESULT (STDMETHODCALLTYPE *GetItemNum)(
                     ITfLangBarItemMgr *This,
                     ULONG *pulCount);

    HRESULT (STDMETHODCALLTYPE *GetItems)(
                     ITfLangBarItemMgr *This,
                     ULONG ulCount,
                     ITfLangBarItem **ppItem,
                     TF_LANGBARITEMINFO *pInfo,
                     DWORD *pdwStatus,
                     ULONG *pcFetched);

    HRESULT (STDMETHODCALLTYPE *AdviseItemsSink)(
                     ITfLangBarItemMgr *This,
                     ULONG ulCount,
                     ITfLangBarItemSink **ppunk,
                     const GUID *pguidItem,
                     DWORD *pdwCookie);

    HRESULT (STDMETHODCALLTYPE *UnadviseItemsSink)(
                     ITfLangBarItemMgr *This,
                     ULONG ulCount,
                     DWORD *pdwCookie);

    END_INTERFACE
} ITfLangBarItemMgrVtbl;

interface ITfLangBarItemMgr {
    CONST_VTBL ITfLangBarItemMgrVtbl* lpVtbl;
};

#ifdef COBJMACROS
#ifndef WIDL_C_INLINE_WRAPPERS
/*** IUnknown methods ***/
#define ITfLangBarItemMgr_QueryInterface(This,riid,ppvObject) (This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define ITfLangBarItemMgr_AddRef(This) (This)->lpVtbl->AddRef(This)
#define ITfLangBarItemMgr_Release(This) (This)->lpVtbl->Release(This)
/*** ITfLangBarItemMgr methods ***/
#define ITfLangBarItemMgr_EnumItems(This,ppEnum) (This)->lpVtbl->EnumItems(This,ppEnum)
#define ITfLangBarItemMgr_GetItem(This,rguid,ppItem) (This)->lpVtbl->GetItem(This,rguid,ppItem)
#define ITfLangBarItemMgr_AddItem(This,punk) (This)->lpVtbl->AddItem(This,punk)
#define ITfLangBarItemMgr_RemoveItem(This,punk) (This)->lpVtbl->RemoveItem(This,punk)
#define ITfLangBarItemMgr_AdviseItemSink(This,punk,pdwCookie,rguidItem) (This)->lpVtbl->AdviseItemSink(This,punk,pdwCookie,rguidItem)
#define ITfLangBarItemMgr_UnadviseItemSink(This,dwCookie) (This)->lpVtbl->UnadviseItemSink(This,dwCookie)
#define ITfLangBarItemMgr_GetItemFloatingRect(This,dwThreadId,rguid,prc) (This)->lpVtbl->GetItemFloatingRect(This,dwThreadId,rguid,prc)
#define ITfLangBarItemMgr_GetItemsStatus(This,ulCount,prgguid,pdwStatus) (This)->lpVtbl->GetItemsStatus(This,ulCount,prgguid,pdwStatus)
#define ITfLangBarItemMgr_GetItemNum(This,pulCount) (This)->lpVtbl->GetItemNum(This,pulCount)
#define ITfLangBarItemMgr_GetItems(This,ulCount,ppItem,pInfo,pdwStatus,pcFetched) (This)->lpVtbl->GetItems(This,ulCount,ppItem,pInfo,pdwStatus,pcFetched)
#define ITfLangBarItemMgr_AdviseItemsSink(This,ulCount,ppunk,pguidItem,pdwCookie) (This)->lpVtbl->AdviseItemsSink(This,ulCount,ppunk,pguidItem,pdwCookie)
#define ITfLangBarItemMgr_UnadviseItemsSink(This,ulCount,pdwCookie) (This)->lpVtbl->UnadviseItemsSink(This,ulCount,pdwCookie)
#else
/*** IUnknown methods ***/
static FORCEINLINE HRESULT ITfLangBarItemMgr_QueryInterface(ITfLangBarItemMgr* This,REFIID riid,void **ppvObject) {
    return This->lpVtbl->QueryInterface(This,riid,ppvObject);
}
static FORCEINLINE ULONG ITfLangBarItemMgr_AddRef(ITfLangBarItemMgr* This) {
    return This->lpVtbl->AddRef(This);
}
static FORCEINLINE ULONG ITfLangBarItemMgr_Release(ITfLangBarItemMgr* This) {
    return This->lpVtbl->Release(This);
}
/*** ITfLangBarItemMgr methods ***/
static FORCEINLINE HRESULT ITfLangBarItemMgr_EnumItems(ITfLangBarItemMgr* This,IEnumTfLangBarItems **ppEnum) {
    return This->lpVtbl->EnumItems(This,ppEnum);
}
static FORCEINLINE HRESULT ITfLangBarItemMgr_GetItem(ITfLangBarItemMgr* This,REFGUID rguid,ITfLangBarItem **ppItem) {
    return This->lpVtbl->GetItem(This,rguid,ppItem);
}
static FORCEINLINE HRESULT ITfLangBarItemMgr_AddItem(ITfLangBarItemMgr* This,ITfLangBarItem *punk) {
    return This->lpVtbl->AddItem(This,punk);
}
static FORCEINLINE HRESULT ITfLangBarItemMgr_RemoveItem(ITfLangBarItemMgr* This,ITfLangBarItem *punk) {
    return This->lpVtbl->RemoveItem(This,punk);
}
static FORCEINLINE HRESULT ITfLangBarItemMgr_AdviseItemSink(ITfLangBarItemMgr* This,ITfLangBarItemSink *punk,DWORD *pdwCookie,REFGUID rguidItem) {
    return This->lpVtbl->AdviseItemSink(This,punk,pdwCookie,rguidItem);
}
static FORCEINLINE HRESULT ITfLangBarItemMgr_UnadviseItemSink(ITfLangBarItemMgr* This,DWORD dwCookie) {
    return This->lpVtbl->UnadviseItemSink(This,dwCookie);
}
static FORCEINLINE HRESULT ITfLangBarItemMgr_GetItemFloatingRect(ITfLangBarItemMgr* This,DWORD dwThreadId,REFGUID rguid,RECT *prc) {
    return This->lpVtbl->GetItemFloatingRect(This,dwThreadId,rguid,prc);
}
static FORCEINLINE HRESULT ITfLangBarItemMgr_GetItemsStatus(ITfLangBarItemMgr* This,ULONG ulCount,const GUID *prgguid,DWORD *pdwStatus) {
    return This->lpVtbl->GetItemsStatus(This,ulCount,prgguid,pdwStatus);
}
static FORCEINLINE HRESULT ITfLangBarItemMgr_GetItemNum(ITfLangBarItemMgr* This,ULONG *pulCount) {
    return This->lpVtbl->GetItemNum(This,pulCount);
}
static FORCEINLINE HRESULT ITfLangBarItemMgr_GetItems(ITfLangBarItemMgr* This,ULONG ulCount,ITfLangBarItem **ppItem,TF_LANGBARITEMINFO *pInfo,DWORD *pdwStatus,ULONG *pcFetched) {
    return This->lpVtbl->GetItems(This,ulCount,ppItem,pInfo,pdwStatus,pcFetched);
}
static FORCEINLINE HRESULT ITfLangBarItemMgr_AdviseItemsSink(ITfLangBarItemMgr* This,ULONG ulCount,ITfLangBarItemSink **ppunk,const GUID *pguidItem,DWORD *pdwCookie) {
    return This->lpVtbl->AdviseItemsSink(This,ulCount,ppunk,pguidItem,pdwCookie);
}
static FORCEINLINE HRESULT ITfLangBarItemMgr_UnadviseItemsSink(ITfLangBarItemMgr* This,ULONG ulCount,DWORD *pdwCookie) {
    return This->lpVtbl->UnadviseItemsSink(This,ulCount,pdwCookie);
}
#endif
#endif

#endif


#endif  /* __ITfLangBarItemMgr_INTERFACE_DEFINED__ */

/*****************************************************************************
 * ITfLangBarMgr interface
 */
#ifndef __ITfLangBarMgr_INTERFACE_DEFINED__
#define __ITfLangBarMgr_INTERFACE_DEFINED__

DEFINE_GUID(IID_ITfLangBarMgr, 0x87955690, 0xe627, 0x11d2, 0x8d,0xdb, 0x00,0x10,0x5a,0x27,0x99,0xb5);
#if defined(__cplusplus) && !defined(CINTERFACE)
MIDL_INTERFACE("87955690-e627-11d2-8ddb-00105a2799b5")
ITfLangBarMgr : public IUnknown
{
    virtual HRESULT STDMETHODCALLTYPE AdviseEventSink(
                     ITfLangBarEventSink *pSink,
                     HWND hwnd,
                     DWORD dwflags,
                     DWORD *pdwCookie) = 0;

    virtual HRESULT STDMETHODCALLTYPE UnAdviseEventSink(
                     DWORD dwCookie) = 0;

    virtual HRESULT STDMETHODCALLTYPE GetThreadMarshalInterface(
                     DWORD dwThreadId,
                     DWORD dwType,
                     REFIID riid,
                     IUnknown **ppunk) = 0;

    virtual HRESULT STDMETHODCALLTYPE GetThreadLangBarItemMgr(
                     DWORD dwThreadId,
                     ITfLangBarItemMgr **pplbie,
                     DWORD *pdwThreadid) = 0;

    virtual HRESULT STDMETHODCALLTYPE GetInputProcessorProfiles(
                     DWORD dwThreadId,
                     ITfInputProcessorProfiles **ppaip,
                     DWORD *pdwThreadid) = 0;

    virtual HRESULT STDMETHODCALLTYPE RestoreLastFocus(
                     DWORD *dwThreadId,
                     WINBOOL fPrev) = 0;

    virtual HRESULT STDMETHODCALLTYPE SetModalInput(
                     ITfLangBarEventSink *pSink,
                     DWORD dwThreadId,
                     DWORD dwFlags) = 0;

    virtual HRESULT STDMETHODCALLTYPE ShowFloating(
                     DWORD dwFlags) = 0;

    virtual HRESULT STDMETHODCALLTYPE GetShowFloatingStatus(
                     DWORD *pdwFlags) = 0;

};
#ifdef __CRT_UUID_DECL
__CRT_UUID_DECL(ITfLangBarMgr, 0x87955690, 0xe627, 0x11d2, 0x8d,0xdb, 0x00,0x10,0x5a,0x27,0x99,0xb5)
#endif
#else
typedef struct ITfLangBarMgrVtbl {
    BEGIN_INTERFACE

    /*** IUnknown methods ***/
    HRESULT (STDMETHODCALLTYPE *QueryInterface)(
                     ITfLangBarMgr *This,
                     REFIID riid,
                     void **ppvObject);

    ULONG (STDMETHODCALLTYPE *AddRef)(
                     ITfLangBarMgr *This);

    ULONG (STDMETHODCALLTYPE *Release)(
                     ITfLangBarMgr *This);

    /*** ITfLangBarMgr methods ***/
    HRESULT (STDMETHODCALLTYPE *AdviseEventSink)(
                     ITfLangBarMgr *This,
                     ITfLangBarEventSink *pSink,
                     HWND hwnd,
                     DWORD dwflags,
                     DWORD *pdwCookie);

    HRESULT (STDMETHODCALLTYPE *UnAdviseEventSink)(
                     ITfLangBarMgr *This,
                     DWORD dwCookie);

    HRESULT (STDMETHODCALLTYPE *GetThreadMarshalInterface)(
                     ITfLangBarMgr *This,
                     DWORD dwThreadId,
                     DWORD dwType,
                     REFIID riid,
                     IUnknown **ppunk);

    HRESULT (STDMETHODCALLTYPE *GetThreadLangBarItemMgr)(
                     ITfLangBarMgr *This,
                     DWORD dwThreadId,
                     ITfLangBarItemMgr **pplbie,
                     DWORD *pdwThreadid);

    HRESULT (STDMETHODCALLTYPE *GetInputProcessorProfiles)(
                     ITfLangBarMgr *This,
                     DWORD dwThreadId,
                     ITfInputProcessorProfiles **ppaip,
                     DWORD *pdwThreadid);

    HRESULT (STDMETHODCALLTYPE *RestoreLastFocus)(
                     ITfLangBarMgr *This,
                     DWORD *dwThreadId,
                     WINBOOL fPrev);

    HRESULT (STDMETHODCALLTYPE *SetModalInput)(
                     ITfLangBarMgr *This,
                     ITfLangBarEventSink *pSink,
                     DWORD dwThreadId,
                     DWORD dwFlags);

    HRESULT (STDMETHODCALLTYPE *ShowFloating)(
                     ITfLangBarMgr *This,
                     DWORD dwFlags);

    HRESULT (STDMETHODCALLTYPE *GetShowFloatingStatus)(
                     ITfLangBarMgr *This,
                     DWORD *pdwFlags);

    END_INTERFACE
} ITfLangBarMgrVtbl;

interface ITfLangBarMgr {
    CONST_VTBL ITfLangBarMgrVtbl* lpVtbl;
};

#ifdef COBJMACROS
#ifndef WIDL_C_INLINE_WRAPPERS
/*** IUnknown methods ***/
#define ITfLangBarMgr_QueryInterface(This,riid,ppvObject) (This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define ITfLangBarMgr_AddRef(This) (This)->lpVtbl->AddRef(This)
#define ITfLangBarMgr_Release(This) (This)->lpVtbl->Release(This)
/*** ITfLangBarMgr methods ***/
#define ITfLangBarMgr_AdviseEventSink(This,pSink,hwnd,dwflags,pdwCookie) (This)->lpVtbl->AdviseEventSink(This,pSink,hwnd,dwflags,pdwCookie)
#define ITfLangBarMgr_UnAdviseEventSink(This,dwCookie) (This)->lpVtbl->UnAdviseEventSink(This,dwCookie)
#define ITfLangBarMgr_GetThreadMarshalInterface(This,dwThreadId,dwType,riid,ppunk) (This)->lpVtbl->GetThreadMarshalInterface(This,dwThreadId,dwType,riid,ppunk)
#define ITfLangBarMgr_GetThreadLangBarItemMgr(This,dwThreadId,pplbie,pdwThreadid) (This)->lpVtbl->GetThreadLangBarItemMgr(This,dwThreadId,pplbie,pdwThreadid)
#define ITfLangBarMgr_GetInputProcessorProfiles(This,dwThreadId,ppaip,pdwThreadid) (This)->lpVtbl->GetInputProcessorProfiles(This,dwThreadId,ppaip,pdwThreadid)
#define ITfLangBarMgr_RestoreLastFocus(This,dwThreadId,fPrev) (This)->lpVtbl->RestoreLastFocus(This,dwThreadId,fPrev)
#define ITfLangBarMgr_SetModalInput(This,pSink,dwThreadId,dwFlags) (This)->lpVtbl->SetModalInput(This,pSink,dwThreadId,dwFlags)
#define ITfLangBarMgr_ShowFloating(This,dwFlags) (This)->lpVtbl->ShowFloating(This,dwFlags)
#define ITfLangBarMgr_GetShowFloatingStatus(This,pdwFlags) (This)->lpVtbl->GetShowFloatingStatus(This,pdwFlags)
#else
/*** IUnknown methods ***/
static FORCEINLINE HRESULT ITfLangBarMgr_QueryInterface(ITfLangBarMgr* This,REFIID riid,void **ppvObject) {
    return This->lpVtbl->QueryInterface(This,riid,ppvObject);
}
static FORCEINLINE ULONG ITfLangBarMgr_AddRef(ITfLangBarMgr* This) {
    return This->lpVtbl->AddRef(This);
}
static FORCEINLINE ULONG ITfLangBarMgr_Release(ITfLangBarMgr* This) {
    return This->lpVtbl->Release(This);
}
/*** ITfLangBarMgr methods ***/
static FORCEINLINE HRESULT ITfLangBarMgr_AdviseEventSink(ITfLangBarMgr* This,ITfLangBarEventSink *pSink,HWND hwnd,DWORD dwflags,DWORD *pdwCookie) {
    return This->lpVtbl->AdviseEventSink(This,pSink,hwnd,dwflags,pdwCookie);
}
static FORCEINLINE HRESULT ITfLangBarMgr_UnAdviseEventSink(ITfLangBarMgr* This,DWORD dwCookie) {
    return This->lpVtbl->UnAdviseEventSink(This,dwCookie);
}
static FORCEINLINE HRESULT ITfLangBarMgr_GetThreadMarshalInterface(ITfLangBarMgr* This,DWORD dwThreadId,DWORD dwType,REFIID riid,IUnknown **ppunk) {
    return This->lpVtbl->GetThreadMarshalInterface(This,dwThreadId,dwType,riid,ppunk);
}
static FORCEINLINE HRESULT ITfLangBarMgr_GetThreadLangBarItemMgr(ITfLangBarMgr* This,DWORD dwThreadId,ITfLangBarItemMgr **pplbie,DWORD *pdwThreadid) {
    return This->lpVtbl->GetThreadLangBarItemMgr(This,dwThreadId,pplbie,pdwThreadid);
}
static FORCEINLINE HRESULT ITfLangBarMgr_GetInputProcessorProfiles(ITfLangBarMgr* This,DWORD dwThreadId,ITfInputProcessorProfiles **ppaip,DWORD *pdwThreadid) {
    return This->lpVtbl->GetInputProcessorProfiles(This,dwThreadId,ppaip,pdwThreadid);
}
static FORCEINLINE HRESULT ITfLangBarMgr_RestoreLastFocus(ITfLangBarMgr* This,DWORD *dwThreadId,WINBOOL fPrev) {
    return This->lpVtbl->RestoreLastFocus(This,dwThreadId,fPrev);
}
static FORCEINLINE HRESULT ITfLangBarMgr_SetModalInput(ITfLangBarMgr* This,ITfLangBarEventSink *pSink,DWORD dwThreadId,DWORD dwFlags) {
    return This->lpVtbl->SetModalInput(This,pSink,dwThreadId,dwFlags);
}
static FORCEINLINE HRESULT ITfLangBarMgr_ShowFloating(ITfLangBarMgr* This,DWORD dwFlags) {
    return This->lpVtbl->ShowFloating(This,dwFlags);
}
static FORCEINLINE HRESULT ITfLangBarMgr_GetShowFloatingStatus(ITfLangBarMgr* This,DWORD *pdwFlags) {
    return This->lpVtbl->GetShowFloatingStatus(This,pdwFlags);
}
#endif
#endif

#endif


#endif  /* __ITfLangBarMgr_INTERFACE_DEFINED__ */

/*****************************************************************************
 * ITfLangBarEventSink interface
 */
#ifndef __ITfLangBarEventSink_INTERFACE_DEFINED__
#define __ITfLangBarEventSink_INTERFACE_DEFINED__

DEFINE_GUID(IID_ITfLangBarEventSink, 0x18a4e900, 0xe0ae, 0x11d2, 0xaf,0xdd, 0x00,0x10,0x5a,0x27,0x99,0xb5);
#if defined(__cplusplus) && !defined(CINTERFACE)
MIDL_INTERFACE("18a4e900-e0ae-11d2-afdd-00105a2799b5")
ITfLangBarEventSink : public IUnknown
{
    virtual HRESULT STDMETHODCALLTYPE OnSetFocus(
                     DWORD dwThreadId) = 0;

    virtual HRESULT STDMETHODCALLTYPE OnThreadTerminate(
                     DWORD dwThreadId) = 0;

    virtual HRESULT STDMETHODCALLTYPE OnThreadItemChange(
                     DWORD dwThreadId) = 0;

    virtual HRESULT STDMETHODCALLTYPE OnModalInput(
                     DWORD dwThreadId,
                     UINT uMsg,
                     WPARAM wParam,
                     LPARAM lParam) = 0;

    virtual HRESULT STDMETHODCALLTYPE ShowFloating(
                     DWORD dwFlags) = 0;

    virtual HRESULT STDMETHODCALLTYPE GetItemFloatingRect(
                     DWORD dwThreadId,
                     REFGUID rguid,
                     RECT *prc) = 0;

};
#ifdef __CRT_UUID_DECL
__CRT_UUID_DECL(ITfLangBarEventSink, 0x18a4e900, 0xe0ae, 0x11d2, 0xaf,0xdd, 0x00,0x10,0x5a,0x27,0x99,0xb5)
#endif
#else
typedef struct ITfLangBarEventSinkVtbl {
    BEGIN_INTERFACE

    /*** IUnknown methods ***/
    HRESULT (STDMETHODCALLTYPE *QueryInterface)(
                     ITfLangBarEventSink *This,
                     REFIID riid,
                     void **ppvObject);

    ULONG (STDMETHODCALLTYPE *AddRef)(
                     ITfLangBarEventSink *This);

    ULONG (STDMETHODCALLTYPE *Release)(
                     ITfLangBarEventSink *This);

    /*** ITfLangBarEventSink methods ***/
    HRESULT (STDMETHODCALLTYPE *OnSetFocus)(
                     ITfLangBarEventSink *This,
                     DWORD dwThreadId);

    HRESULT (STDMETHODCALLTYPE *OnThreadTerminate)(
                     ITfLangBarEventSink *This,
                     DWORD dwThreadId);

    HRESULT (STDMETHODCALLTYPE *OnThreadItemChange)(
                     ITfLangBarEventSink *This,
                     DWORD dwThreadId);

    HRESULT (STDMETHODCALLTYPE *OnModalInput)(
                     ITfLangBarEventSink *This,
                     DWORD dwThreadId,
                     UINT uMsg,
                     WPARAM wParam,
                     LPARAM lParam);

    HRESULT (STDMETHODCALLTYPE *ShowFloating)(
                     ITfLangBarEventSink *This,
                     DWORD dwFlags);

    HRESULT (STDMETHODCALLTYPE *GetItemFloatingRect)(
                     ITfLangBarEventSink *This,
                     DWORD dwThreadId,
                     REFGUID rguid,
                     RECT *prc);

    END_INTERFACE
} ITfLangBarEventSinkVtbl;

interface ITfLangBarEventSink {
    CONST_VTBL ITfLangBarEventSinkVtbl* lpVtbl;
};

#ifdef COBJMACROS
#ifndef WIDL_C_INLINE_WRAPPERS
/*** IUnknown methods ***/
#define ITfLangBarEventSink_QueryInterface(This,riid,ppvObject) (This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define ITfLangBarEventSink_AddRef(This) (This)->lpVtbl->AddRef(This)
#define ITfLangBarEventSink_Release(This) (This)->lpVtbl->Release(This)
/*** ITfLangBarEventSink methods ***/
#define ITfLangBarEventSink_OnSetFocus(This,dwThreadId) (This)->lpVtbl->OnSetFocus(This,dwThreadId)
#define ITfLangBarEventSink_OnThreadTerminate(This,dwThreadId) (This)->lpVtbl->OnThreadTerminate(This,dwThreadId)
#define ITfLangBarEventSink_OnThreadItemChange(This,dwThreadId) (This)->lpVtbl->OnThreadItemChange(This,dwThreadId)
#define ITfLangBarEventSink_OnModalInput(This,dwThreadId,uMsg,wParam,lParam) (This)->lpVtbl->OnModalInput(This,dwThreadId,uMsg,wParam,lParam)
#define ITfLangBarEventSink_ShowFloating(This,dwFlags) (This)->lpVtbl->ShowFloating(This,dwFlags)
#define ITfLangBarEventSink_GetItemFloatingRect(This,dwThreadId,rguid,prc) (This)->lpVtbl->GetItemFloatingRect(This,dwThreadId,rguid,prc)
#else
/*** IUnknown methods ***/
static FORCEINLINE HRESULT ITfLangBarEventSink_QueryInterface(ITfLangBarEventSink* This,REFIID riid,void **ppvObject) {
    return This->lpVtbl->QueryInterface(This,riid,ppvObject);
}
static FORCEINLINE ULONG ITfLangBarEventSink_AddRef(ITfLangBarEventSink* This) {
    return This->lpVtbl->AddRef(This);
}
static FORCEINLINE ULONG ITfLangBarEventSink_Release(ITfLangBarEventSink* This) {
    return This->lpVtbl->Release(This);
}
/*** ITfLangBarEventSink methods ***/
static FORCEINLINE HRESULT ITfLangBarEventSink_OnSetFocus(ITfLangBarEventSink* This,DWORD dwThreadId) {
    return This->lpVtbl->OnSetFocus(This,dwThreadId);
}
static FORCEINLINE HRESULT ITfLangBarEventSink_OnThreadTerminate(ITfLangBarEventSink* This,DWORD dwThreadId) {
    return This->lpVtbl->OnThreadTerminate(This,dwThreadId);
}
static FORCEINLINE HRESULT ITfLangBarEventSink_OnThreadItemChange(ITfLangBarEventSink* This,DWORD dwThreadId) {
    return This->lpVtbl->OnThreadItemChange(This,dwThreadId);
}
static FORCEINLINE HRESULT ITfLangBarEventSink_OnModalInput(ITfLangBarEventSink* This,DWORD dwThreadId,UINT uMsg,WPARAM wParam,LPARAM lParam) {
    return This->lpVtbl->OnModalInput(This,dwThreadId,uMsg,wParam,lParam);
}
static FORCEINLINE HRESULT ITfLangBarEventSink_ShowFloating(ITfLangBarEventSink* This,DWORD dwFlags) {
    return This->lpVtbl->ShowFloating(This,dwFlags);
}
static FORCEINLINE HRESULT ITfLangBarEventSink_GetItemFloatingRect(ITfLangBarEventSink* This,DWORD dwThreadId,REFGUID rguid,RECT *prc) {
    return This->lpVtbl->GetItemFloatingRect(This,dwThreadId,rguid,prc);
}
#endif
#endif

#endif


#endif  /* __ITfLangBarEventSink_INTERFACE_DEFINED__ */

/* Begin additional prototypes for all interfaces */

ULONG                        __RPC_USER BSTR_UserSize     (ULONG *, ULONG, BSTR *);
unsigned char * __RPC_USER BSTR_UserMarshal  (ULONG *, unsigned char *, BSTR *);
unsigned char * __RPC_USER BSTR_UserUnmarshal(ULONG *, unsigned char *, BSTR *);
void                                      __RPC_USER BSTR_UserFree     (ULONG *, BSTR *);
ULONG                        __RPC_USER HWND_UserSize     (ULONG *, ULONG, HWND *);
unsigned char * __RPC_USER HWND_UserMarshal  (ULONG *, unsigned char *, HWND *);
unsigned char * __RPC_USER HWND_UserUnmarshal(ULONG *, unsigned char *, HWND *);
void                                      __RPC_USER HWND_UserFree     (ULONG *, HWND *);

/* End additional prototypes */

#ifdef __cplusplus
}
#endif

#endif /* __ctfutb_h__ */
