import logging, strutils
import gtk2, gdk2

{.pragma: gtk, stdcall, dynlib: "libgtk-x11-2.0.so(|.0)".}
{.pragma: gdk, stdcall, dynlib: "libgdk-x11-2.0.so(|.0)".}
{.pragma: glib, stdcall, dynlib: "libgio-2.0.so(|.0)" .}

# GTK/GDK bindings
type GtkIconTheme {.importc.} = ptr object of RootObj
# type GtkIconInfo {.importc.} = ptr object of RootObj
type GError {.importc.} = ptr object of RootObj
type GdkPixbuf {.importc.} = ptr object of RootObj

# GIO bindings
type GFile {.importc.} = ptr object of RootObj
type GFileInfo {.importc.} = ptr object of RootObj
type GCancellable {.importc.} = ptr object of RootObj
type GIcon {.importc.} = ptr object of RootObj

# GTK?GDK bindings
proc icon_theme_get_for_screen(screen: PScreen): GtkIconTheme {.gtk, importc:"gtk_icon_theme_get_for_screen".}
proc gtk_icon_theme_load_icon(theme: GtkIconTheme, iconame: cstring, icosize: cint, flags: cint, err: GError):GdkPixbuf {.gtk, importc.}
proc gtk_icon_theme_has_icon(theme: GtkIconTheme, iconame: cstring): bool {.gtk, importc.}
proc gdk_pixbuf_get_pixels(pb: GdkPixbuf):cstring {.gdk, importc.}
proc gdk_pixbuf_get_width(buff: GdkPixbuf):cint {.gdk, importc.}
proc gdk_pixbuf_get_height(buff: GdkPixbuf):cint {.gdk, importc.}


# GIO bindings
proc gfileForPath(path: cstring): GFile {.glib, importc:"g_file_new_for_path".}
proc gfileInfo(file: GFile, attr: cstring, flags: cint, can: GCancellable, err: GError): GFileInfo {.glib, importc:"g_file_query_info".}
proc giconToString(icon: GIcon):cstring {.glib, importc:"g_icon_to_string".}
proc gfileInfoGetIcon(fi: GFileInfo): GIcon {.glib, importc:"g_file_info_get_icon".}

proc iconBitmapForFile*(path: string, width, heigth: int):seq[byte]=
    let file = gfileForPath(path)
    var err: GError
    let fi = gfileInfo(file, "*", 0, nil, err)
    if not err.isNil:
        return

    var gIcon = fi.gfileInfoGetIcon()
    var strIcon = ($gIcon.giconToString()).split(" ")

    let displ = display_open(nil)
    let screen = get_default_screen(displ)
    let theme = icon_theme_get_for_screen(screen)
    var kind = ""
    for i in strIcon:
        if gtk_icon_theme_has_icon(theme, i):
            kind = i
            break
    err = nil

    let pixBuff = gtk_icon_theme_load_icon(theme, kind, width.cint, 0.cint, err)
    let w = gdk_pixbuf_get_width(pixBuff).int
    let h = gdk_pixbuf_get_height(pixBuff).int
    let pixels = gdk_pixbuf_get_pixels(pixBuff)

    if err.isNil and w + h > 0:
        result = @[]
        for i in 0..<(w * h)*4:
            result.add(pixels[i].byte)

import osproc
proc openInDefaultApp*(path:string)=
    discard execCmd("xdg-open " & path)

