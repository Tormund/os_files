import winim
import strutils, logging
import dialog_types
export dialog_types

const FOS_PICKFOLDERS = 0x20

converter pointerConverter(x: ptr): ptr PVOID = cast[ptr PVOID](x)

proc show*(di: DialogInfo): string =
    try:
        if CoInitializeEx(nil, COINIT_APARTMENTTHREADED or COINIT_DISABLE_OLE1DDE).FAILED:
            raise
        defer: CoUninitialize()

        var dialog: ptr IFileDialog
        var item: ptr IShellItem
        var buff: PWSTR

        if di.kind != dkSaveFile:
            if CoCreateInstance(&CLSID_FileOpenDialog, NULL, CLSCTX_ALL, &IID_IFileOpenDialog, &dialog).FAILED:
                raise
        else:
            if CoCreateInstance(&CLSID_FileSaveDialog, NULL, CLSCTX_ALL, &IID_IFileSaveDialog, &dialog).FAILED:
                raise

        defer: dialog.Release()

        if di.kind == dkSelectFolder or di.kind == dkCreateFolder:
            var fdOpt: DWORD
            if dialog.GetOptions(addr fdOpt).SUCCEEDED:
                dialog.SetOptions(fdOpt or FOS_PICKFOLDERS)

        if di.folder.len > 0:
            var folderItem: ptr IShellItem
            if SHCreateItemFromParsingName(di.folder, NULL, &IID_IShellItem, &folderItem).FAILED:
                raise
            dialog.SetFolder(folderItem)
            defer: folderItem.Release()

        if di.filters.len > 0:
            var filters = newSeq[COMDLG_FILTERSPEC]()
            var allTypes = newSeq[string]()

            for fi in di.filters:
                filters.add(COMDLG_FILTERSPEC(pszName:fi.name, pszSpec:fi.ext))
                allTypes.add(fi.ext)

            filters.insert(COMDLG_FILTERSPEC(pszName:"All", pszSpec:allTypes.join(";")), 0)
            if dialog.SetFileTypes(filters.len.UINT, addr filters[0]).FAILED: raise

        if di.title.len > 0:
            dialog.SetTitle(di.title)

        if dialog.Show(0).SUCCEEDED:
            if dialog.GetResult(addr item).FAILED: raise
            defer: item.Release()

            if item.GetDisplayName(SIGDN_FILESYSPATH, addr buff).FAILED: raise
            defer: CoTaskMemFree(buff)
            result = $buff

            di.checkExtensionOnSave(result)

    except:
        error "win32_dialog failed ", di, " Exception: ",  getCurrentExceptionMsg()
