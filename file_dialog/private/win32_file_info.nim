import os
import winim

converter pointerConverter(x: ptr): ptr PVOID = cast[ptr PVOID](x)

const SHIL_JUMBO = 0x4
type 
    IImageList {.pure.} = object
        lpVtbl*: ptr IImageListVtbl
    IImageListVtbl {.pure, inheritable.} = object of IUnknownVtbl
        Add*: pointer 
        ReplaceIcon*: pointer
        SetOverlayImage*: pointer
        Replace*: pointer
        AddMasked*: pointer
        Draw*: proc(self: ptr IImageList, pimldp: ptr IMAGELISTDRAWPARAMS):HRESULT {.stdcall.}
        Remove*: pointer
        GetIcon*: proc(self: ptr IImageList, p1: INT, p2: UINT, p3: ptr HICON):HRESULT {.stdcall.}

converter winim_converter_IImageList*(x: ptr IImageList): ptr IUnknown = cast[ptr IUnknown](x)
proc QueryInterface*(self: ptr IImageList, P1: REFIID, P2: ptr PVOID): HRESULT {.inline, discardable.} = self.lpVtbl.QueryInterface(self, P1, P2)
proc GetIcon*(self: ptr IImageList, p1: INT, p2: UINT, p3: ptr HICON): HRESULT {.inline, discardable.} = self.lpVtbl.GetIcon(self, p1, p2, p3)
proc Draw*(self: ptr IImageList, p1: ptr IMAGELISTDRAWPARAMS):HRESULT {.inline, discardable.} = self.lpVtbl.Draw(self, p1)
proc SHGetImageList*(iImageList: INT, riid: REFIID, ppv: ptr PVOID): HRESULT {.winapi, dynlib: "shell32", importc.}

proc scaledPixels(icon: ICONINFO, hicon: HICON, sw, sh, dw, dh: LONG): seq[byte] =
    result = nil
    var hdcScreen = CreateDC("DISPLAY", nil, nil, nil)
    var hdcSource = CreateCompatibleDC(hdcScreen)
    var hBmpSource = icon.hbmColor
    var hBmpOldSource = (HBITMAP)SelectObject(hdcSource, hBmpSource)

    var hdcDest = CreateCompatibleDC(hdcScreen)
    var hBmpDest = CreateCompatibleBitmap(hdcSource, dw, dh)
    var hBmpOldDest = (HBITMAP)SelectObject(hdcDest, hBmpDest)
    
    SetStretchBltMode(hdcDest, STRETCH_DELETESCANS)
    StretchBlt(hdcDest, 0, 0, dw, dh, hdcSource, 0, 0, sw, sh, SRCCOPY)

    var bmInfo: BITMAPINFO
    bmInfo.bmiHeader.biSize = sizeof(BITMAPINFOHEADER).DWORD

    if GetDIBits(hdcDest, hBmpDest, 0, 0, nil, addr bmInfo, DIB_RGB_COLORS) == 0:
        return nil
    else:
        let bi = bmInfo.bmiHeader
        assert(bi.biSizeImage.int > 0)

        var bits = newSeq[byte](bi.biSizeImage.int)
        bmInfo.bmiHeader.biCompression = BI_RGB
        bmInfo.bmiHeader.biBitCount = 32

        if GetDIBits(hdcDest, hBmpDest, 0.UINT, bi.biHeight.UINT, (PVOID)(addr bits[0]), &bmInfo, DIB_RGB_COLORS) == 0:
            return nil

        result = newSeq[byte](bits.len)
        # flip bitmap verticaly and swap bgr into rgb
        let comp = 4
        for i in 0 ..< dh.int:
            var st = i * dw.int * comp
            let en = st + dw.int * comp

            copyMem(addr result[i * dw.int * comp], addr bits[(dh.int - 1 - i) * dw.int * comp], dw.int * comp)
            while st < en:
                swap(result[st], result[st+2])
                st += 4

    SelectObject(hdcSource, hBmpOldSource)
    SelectObject(hdcDest, hBmpOldDest)
    DeleteDC(hdcSource)
    DeleteDC(hdcDest)
    DeleteDC(hdcScreen)

proc iconBitmapForFile*(path: string, width, heigth: int):seq[byte]=
    var sp = splitFile(path)
    var item: SHFILEINFO
    let flags = SHGFI_SYSICONINDEX # or SHGFI_USEFILEATTRIBUTES or SHGFI_ICON

    if SHGetFileInfo(path, 0.DWORD, &item, sizeof(IShellItem).UINT, flags.UINT).int != 0:
        var ilist: ptr IImageList
        let err = SHGetImageList(SHIL_JUMBO, &IID_IImageList, &ilist)
        defer: ilist.Release()
        if err == S_OK:
            var hico: HICON 
            ilist.GetIcon(item.iIcon, ILD_IMAGE, addr hico)
            var iconInfo:ICONINFO
            if GetIconInfo(hico, addr iconInfo) == TRUE:
                let w = iconInfo.xHotspot * 2
                let h = iconInfo.yHotspot * 2
                let r = scaledPixels(iconInfo, hico, w.LONG, h.LONG, width.LONG, heigth.LONG)
                result = r

