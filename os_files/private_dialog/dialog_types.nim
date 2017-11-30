type
    DialogKind* = enum
        dkOpenFile
        dkSaveFile
        dkSelectFolder
        dkCreateFolder

    DialogInfo* = tuple
        kind: DialogKind
        title: string
        filters: seq[DialogFilter]      ## used in open file dialog {optional} zero elem is name
        folder: string                  ## open dialog at path {optional}
        extension: string               ## used in save file dialog {optional}

    DialogFilter* = tuple[name: string, ext: string]

when not defined(js):
    import os
    proc checkExtensionOnSave*(di: DialogInfo, res: var string)=
        if di.kind == dkSaveFile and di.extension.len > 0:
            let spr = res.splitFile()
            if spr.ext.len <= 1:
                if spr.ext.len == 0:
                    res.add('.')
                res &= di.extension
