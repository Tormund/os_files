import os

type
    DialogKind* = enum
        dkSelectFile
        dkSaveFile
        dkSelectFolder
        dkCreateFolder

    DialogInfo* = tuple
        kind: DialogKind
        title: string
        filters: seq[string]            ## used in open file dialog {optional} zero elem is name
        folder: string                  ## open dialog at path {optional}
        extension: string               ## used in save file dialog {optional}
        buttons: seq[DialogButtonInfo]  ## nil to use default buttons {optional}

    DialogButtonInfo* = tuple[title: string, responseType: int]

proc checkExtensionOnSave*(di: DialogInfo, res: var string)=
    if di.kind == dkSaveFile and di.extension.len > 0:
        let spr = res.splitFile()
        if spr.ext.len <= 1:
            if spr.ext.len == 0:
                res.add('.')
            res &= di.extension
