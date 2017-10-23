import oldwinapi.windows
import dialog_types
export dialog_types

proc show*(di: DialogInfo): string =
    var
      fileInfo: LPOPENFILENAME = cast[LPOPENFILENAME](alloc0(sizeof(TOPENFILENAME)))
      buf: cstring = cast[cstring](alloc0(1024))

    fileInfo.lStructSize = sizeof(TOPENFILENAME).DWORD
    fileInfo.hWndOwner = 0
    fileInfo.flags = OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST
    fileInfo.lpstrFile = buf
    fileInfo.nMaxFile = 1024
    fileInfo.lpstrFileTitle = title

    if di.folder.len > 0:
        fileInfo.lpstrInitialDir = di.folder
    if di.filters.isNil:
        fileInfo.lpstrFilter = "All\0*.*\0";
    else:
        var filsterStr = ""
        for fi in di.filters:
            filsterStr &= fi & "\0"
        fileInfo.lpstrFilter = filsterStr

    var res: int
    case di.kind:
    of dkSelectFile:
        if GetOpenFileName(fileInfo).bool:
            result = $buf

    of dkSaveFile:
        if GetSaveFileName(fileInfo).bool:
            result = $buf
            di.checkExtensionOnSave(result)
