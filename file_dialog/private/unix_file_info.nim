import osproc, os
import gtk2
import pure.mimetypes

# {.emit:"""
#     #include <gio/gio.h>
# """.}

const defaultIconsPath = "/usr/share/icons"

{.pragma: glib, stdcall, dynlib: "libgio-2.0.so(|.0)" .}
type GFile {.importc.} = ptr object of RootObj
type GIcon {.importc.} = ptr object of RootObj
type GFileIcon {.importc.} = ptr object of GIcon
type GThemedIcon {.importc.} = ptr object of GIcon
type GFileInfo {.importc.} = ptr object of RootObj
type GCancellable {.importc.} = ptr object of RootObj
type GError {.importc.} = ptr object of RootObj
# type GFileAttributeMatcher {.importc.} = ptr object of RootObj

proc gfileForPath(path: cstring): GFile {.glib, importc:"g_file_new_for_path".}
proc gfilePath(file: GFile): cstring {.glib, importc:"g_file_get_path".}
proc gfileIconFile(file: GIcon):GFile {.glib, importc:"g_file_icon_get_file".}
proc gfileIconNew(file: GFile): GFileIcon {.glib, importc:"g_file_icon_new".}
proc gfileInfo(file: GFile, attr: cstring, flags: cint, can: GCancellable, err: GError): GFileInfo {.glib, importc:"g_file_query_info".}
proc gfileInfoGetIcon(fi: GFileInfo): GIcon {.glib, importc:"g_file_info_get_icon".}
proc giconToString(icon: GIcon):cstring {.glib, importc:"g_icon_to_string".}
# proc gContentTypeGetIconName(t: cstring): cstring {.glib, importc: "g_content_type_get_generic_icon_name".}
# proc gContentTypeFromMime(mime: cstring): cstring {.glib, importc: "g_content_type_from_mime_type".}
# proc gfileAttrMatcherNew(attr: cstring): GFileAttributeMatcher {.glib, importc: "g_file_attribute_matcher_new".}
# proc gfileAttrToString(attrmatch: GFileAttributeMatcher):cstring {.glib, importc: "g_file_attribute_matcher_to_string".}
proc gfileInfoGetAttrString(fi: GFileInfo, key: cstring):cstring {.glib, importc: "g_file_info_get_attribute_byte_string".}
proc gfileInfoListAttrs(fi: GFileInfo, patt: cstring):cstring {.glib, importc: "g_file_info_list_attributes".}
proc gfileInfoGetAttrUint32(fi: GFileInfo, key: cstring):cstring {.glib, importc:"g_file_info_get_attribute_uint32".}

var mimeDB = newMimetypes()

proc getFileInfo(file: string):string=
    let filePath = file
    # var iconPath = ""

    echo "paht ", file, " theme dir ", rc_get_theme_dir()
    var gfile = gfileForPath(filePath.cstring)
    echo gfile.isNil
    var error: GError
    var fi = gfileInfo(gfile, "*", 0, nil, error)
    # echo gfileInfoListAttrs(fi, "thumbnail::*")
    var thumb = gfileInfoGetAttrString(fi, "thumbnail::path")
    result = $thumb
    # let matcher = gfileAttrMatcherNew("thumbnail::path")
    # result = $gfileAttrToString(matcher)
    # echo "fi ", fi
    var hasPreview = gfileInfoGetAttrUint32(fi, "filesystem::use-preview")
    echo "haspreview ", hasPreview
    var icon = gfileInfoGetIcon(fi)
    echo "Icon str ", $giconToString(icon)

    # var iconFile = gfileIconFile(icon)
    # echo "iconfile is nil ", iconFile.isNil
    # echo "path ", $gfilePath(iconFile)

    # var fileIcon = gfileIconNew(gfile)
    # echo "icon str 2 ", $giconToString((GIcon)fileIcon)

    # var icon = gfileIconNew(gfile)
    # var ifile = gfileIconFile(icon)
    # echo ifile.isNil
    # result = $gfilePath(ifile)

    # {.emit:"""
    #     //GError *error;
    #     GFile *gfile = g_file_new_for_path(`filePath`);
    #     //GFileInfo *file_info = g_file_query_info(gfile, "standard::*", 0, NULL, &error);
    #     //const char *content_type = g_file_info_get_content_type(file_info);
    #     //char *desc = g_content_type_get_description(content_type);
    #     GFile *icoFile = g_file_icon_get_file(gfile);
    #     `iconPath` = g_file_get_path(icoFile);
    # """.}
    # result = iconPath

proc iconForFile*(file: string):string=
    var ext = file.splitFile().ext
    if ext.len > 0:
        ext = ext.substr(1)
    var mimetype = mimeDb.getMimetype(ext)
    echo "mimetype ", mimetype
    # var cont = gContentTypeFromMime(mimetype)
    # result = $gContentTypeGetIconName(cont)
    # result = mimetype

    result = getFileInfo(file)


#[
    nim c --passC="`pkg-config --libs --cflags glib-2.0`" -r file_info.nim
]#