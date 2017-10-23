import glib2
import gtk2
import dialog_types
export dialog_types

nim_init()

let
    dialogFileOpenDefaultButtons*: seq[DialogButtonInfo] = @[
      (title: "Cancel", responseType: RESPONSE_CANCEL.int),
      (title: "Open", responseType: RESPONSE_ACCEPT.int)
    ]

    dialogFileSaveDefaultButtons*: seq[DialogButtonInfo] = @[
      (title: "Cancel", responseType: RESPONSE_CANCEL.int),
      (title: "Save", responseType: RESPONSE_ACCEPT.int)
    ]

    dialogFolderCreateDefaultButtons*: seq[DialogButtonInfo] = @[
      (title: "Cancel", responseType: RESPONSE_CANCEL.int),
      (title: "Create", responseType: RESPONSE_ACCEPT.int)
    ]

    dialogFolderSelectDefaultButtons*: seq[DialogButtonInfo] = @[
      (title: "Cancel", responseType: RESPONSE_CANCEL.int),
      (title: "Select", responseType: RESPONSE_ACCEPT.int)
    ]

proc show*(di: DialogInfo): string =

    var action: TFileChooserAction
    var defaultButtons: seq[DialogButtonInfo]

    case di.kind:
    of dkSelectFile:
        action = TFileChooserAction.FILE_CHOOSER_ACTION_OPEN
        defaultButtons = dialogFileOpenDefaultButtons
    of dkSaveFile:
        action = TFileChooserAction.FILE_CHOOSER_ACTION_SAVE
        defaultButtons = dialogFileSaveDefaultButtons
    of dkSelectFolder:
        action = TFileChooserAction.FILE_CHOOSER_ACTION_SELECT_FOLDER
        defaultButtons = dialogFolderSelectDefaultButtons
    else:
        action = TFileChooserAction.FILE_CHOOSER_ACTION_CREATE_FOLDER
        defaultButtons = dialogFolderCreateDefaultButtons

    var dialog = file_chooser_dialog_new(di.title.cstring, nil, action, nil)

    var buttons = di.buttons
    if buttons.isNil:
        buttons = defaultButtons

    for button in buttons:
        discard dialog.add_button(button.title.cstring, button.responseType.cint)

    if di.folder.len > 0:
        discard dialog.set_current_folder(di.folder.cstring)

    if not di.filters.isNil:
        var pfi = file_filter_new()
        for fi in di.filters:
            pfi.add_pattern(fi.string)
        dialog.set_filter(pfi)

    var res = dialog.run()

    case res:
    of RESPONSE_ACCEPT, RESPONSE_YES, RESPONSE_APPLY:
        let fileChooser = cast[PFileChooser](pointer(dialog))
        result = $fileChooser.get_filename()
        di.checkExtensionOnSave(result)
    of RESPONSE_REJECT, RESPONSE_NO, RESPONSE_CANCEL, RESPONSE_CLOSE:
        result = nil
    else:
        result = nil

    dialog.destroy()
    while events_pending() > 0:
        discard main_iteration()
