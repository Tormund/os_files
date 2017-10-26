import glib2
import gtk2
import dialog_types
export dialog_types

nim_init()

proc show*(di: DialogInfo): string =
    var action: TFileChooserAction

    var buttons = newSeq[tuple[title:string, rType:int]](2)
    buttons[0] = (title: "Cancel", rType: RESPONSE_CANCEL.int)
    buttons[1] = (title: "Open", rType: RESPONSE_ACCEPT.int)

    case di.kind:
    of dkSelectFile:
        action = TFileChooserAction.FILE_CHOOSER_ACTION_OPEN
    of dkSaveFile:
        action = TFileChooserAction.FILE_CHOOSER_ACTION_SAVE
        buttons[1].title = "Save"
    of dkSelectFolder:
        action = TFileChooserAction.FILE_CHOOSER_ACTION_SELECT_FOLDER
        buttons[1].title = "Select"
    else:
        action = TFileChooserAction.FILE_CHOOSER_ACTION_CREATE_FOLDER
        buttons[1].title = "Select"

    var dialog = file_chooser_dialog_new(di.title.cstring, nil, action, nil)
    defer: dialog.destroy()

    for button in buttons:
        discard dialog.add_button(button.title.cstring, button.rType.cint)

    if di.folder.len > 0:
        discard dialog.set_current_folder(di.folder.cstring)

    if not di.filters.isNil and di.filters.len > 0:
        var filters = newSeq[PFileFilter]()
        var all = file_filter_new()
        all.set_name("All")
        filters.add(all)
        for fi in di.filters:
            var pfi = file_filter_new()
            pfi.add_pattern(fi.ext.cstring)
            all.add_pattern(fi.ext.cstring)
            pfi.set_name(fi.name.cstring)
            filters.add(pfi)

        for fi in filters:
            dialog.add_filter(fi)

    if dialog.run() in [RESPONSE_ACCEPT, RESPONSE_YES, RESPONSE_APPLY]:
        let fileChooser = cast[PFileChooser](pointer(dialog))
        result = $fileChooser.get_filename()
        di.checkExtensionOnSave(result)
    else:
        result = nil

    while events_pending() > 0:
        discard main_iteration()
