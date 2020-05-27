import strutils
import oldgtk3/[gtk, gio, gdk_pixbuf, gobject]
import oldgtk3/gdk except string
import oldgtk3/glib except byte

var theme: IconTheme

proc initCheckWithArgv*(): bool {.inline.} =
    # TODO: This should be moved to oldgtk package
    var
      cmdLine{.importc.}: cstringArray
      cmdCount{.importc.}: cint
    gtk.initCheck(cmdCount, cmdLine).bool

proc iconBitmapForFile*(path: string, width, heigth: int):seq[byte]=
    discard initCheckWithArgv()

    let file = newFileForPath(path)
    var err: GError
    let fi = queryInfo(file, "*", GFileQueryInfoFlags.NONE, nil, err)
    if not err.isNil:
        return

    let gIcon = fi.getIcon()
    let strIcon = ($gIcon.toString()).split(" ")
    fi.objectUnref()

    if theme.isNil:
        let displ = display_open(nil)
        let screen = get_default_screen(displ)
        theme = iconThemeGetForScreen(screen)
        if theme.isNil:
            close(displ)
            return

    var kind = ""
    for i in strIcon:
        if theme.hasIcon(i):
            kind = i
            break

    let pixBuff = theme.loadIcon(kind, width.cint, cast[IconLookupFlags](0), err)
    if err.isNil:
        let w = pixBuff.getWidth().int
        let h = pixBuff.getHeight().int

        if w + h > 0:
            let pixels = pixBuff.getPixels()
            let bufSize = w * h * 4
            result = newSeq[byte](bufSize)
            copyMem(addr result[0], pixels, bufSize)

        pixBuff.unref()

import osproc
proc openInDefaultApp*(path:string)=
    discard execCmd("xdg-open " & path)

