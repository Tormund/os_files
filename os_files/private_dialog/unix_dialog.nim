# import glib2
import oldgtk3/[gtk, glib]
import dialog_types
export dialog_types

proc initCheckWithArgv*(): bool {.inline.} =
    var
      cmdLine{.importc.}: cstringArray
      cmdCount{.importc.}: cint
    gtk.initCheck(cmdCount, cmdLine).bool

proc show*(di: DialogInfo): string =
    discard initCheckWithArgv()

    var action: FileChooserAction

    var buttons = newSeq[tuple[title: string, rType: ResponseType]](2)
    buttons[0] = (title: "Cancel", rType: ResponseType.CANCEL)
    buttons[1] = (title: "Open", rType: ResponseType.ACCEPT)

    case di.kind:
    of dkOpenFile:
        action = FileChooserAction.OPEN
    of dkSaveFile:
        action = FileChooserAction.SAVE
        buttons[1].title = "Save"
    of dkSelectFolder:
        action = FileChooserAction.SELECT_FOLDER
        buttons[1].title = "Select"
    else:
        action = FileChooserAction.CREATE_FOLDER
        buttons[1].title = "Select"

    var dialog = newFileChooserDialog(di.title.cstring, nil, action, nil)
    for button in buttons:
        discard dialog.add_button(button.title, button.rType.cint)

    if di.folder.len > 0:
        discard cast[FileChooser](dialog).setCurrentFolder(di.folder.cstring)

    if not di.filters.len > 0 and di.filters.len > 0:
        var filters = newSeq[FileFilter]()
        let all = newFileFilter()
        all.setName("All")
        filters.add(all)
        for fi in di.filters:
            let pfi = newFileFilter()
            pfi.addPattern(fi.ext.cstring)
            all.addPattern(fi.ext.cstring)
            pfi.setName(fi.name.cstring)
            filters.add(pfi)

        for fi in filters:
            cast[FileChooser](dialog).addFilter(fi)

    let res = dialog.run()
    if cast[ResponseType](res) in [ResponseType.ACCEPT, ResponseType.YES, ResponseType.APPLY]:
        let fileChooser = cast[FileChooser](pointer(dialog))
        result = $fileChooser.getFilename()
        di.checkExtensionOnSave(result)
    else:
        result = ""

    dialog.destroy()

    while events_pending():
        discard main_iteration()
