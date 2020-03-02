import strutils
import oldgtk3/[gtk, gio, gdk_pixbuf]
import oldgtk3/gdk except string
import oldgtk3/glib except byte

proc iconBitmapForFile*(path: string, width, heigth: int):seq[byte]=
    let file = newFileForPath(path)
    var err: GError
    let fi = queryInfo(file, "*", GFileQueryInfoFlags.NONE, nil, err)
    if not err.isNil:
        return

    var gIcon = fi.getIcon()
    var strIcon = ($gIcon.toString()).split(" ")

    let displ = display_open(nil)
    let screen = get_default_screen(displ)
    let theme = iconThemeGetForScreen(screen)
    var kind = ""
    for i in strIcon:
        if theme.hasIcon(i):
            kind = i
            break
    err = nil

    let pixBuff = theme.loadIcon(kind, width.cint, cast[IconLookupFlags](0), err)
    if err.isNil:
        let w = pixBuff.getWidth().int
        let h = pixBuff.getHeight().int
        let pixels = pixBuff.getPixels()

        if w + h > 0:
            let bufSize = w * h * 4
            result = newSeq[byte](bufSize)
            copyMem(addr result[0], pixels, bufSize)

    close(displ)

import osproc
proc openInDefaultApp*(path:string)=
    discard execCmd("xdg-open " & path)

