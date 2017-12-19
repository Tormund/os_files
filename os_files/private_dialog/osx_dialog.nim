import dialog_types
export dialog_types

import strutils

{.passL: "-framework Foundation".}
{.passL: "-framework AppKit".}

type NSSavePanel {.importobjc: "NSSavePanel*", header: "<AppKit/AppKit.h>", incompleteStruct.} = object
type NSOpenPanel {.importobjc: "NSOpenPanel*", header: "<AppKit/AppKit.h>", incompleteStruct.} = object

{.pragma: objc, header: "<Foundation/Foundation.h>", nodecl.}
type NSObject* {.objc, importobjc, final.} = ptr object {.inheritable.}
type NSString* {.objc, importobjc, final.} = ptr object of NSObject
type NSArrayAbstract* {.objc, importc: "NSArray", final.} = ptr object of NSObject
type NSArray*[T] = ptr object of NSArrayAbstract
type NSMutableArray*[T] = ptr object of NSArray[T]
type NSMutableArrayAbstract* {.objc, importc: "NSMutableArray", final.} = ptr object of NSArrayAbstract

proc newOpenPanel: NSOpenPanel {.importobjc: "NSOpenPanel openPanel", nodecl.}
proc newSavePanel: NSSavePanel {.importobjc: "NSSavePanel savePanel", nodecl.}

proc newNSMutableArrayAbstract*(capacity: int): NSMutableArrayAbstract {.importobjc: "NSMutableArray arrayWithCapacity", nodecl.}
proc newNSMutableArray*[T](capacity: int): NSMutableArray[T] {.inline.} = cast[NSMutableArray[T]](newNSMutableArrayAbstract(capacity))

proc addObject*(a: NSMutableArrayAbstract, o: NSObject) {.importobjc, nodecl.}
template add*[T](a: NSMutableArray[T], v: T) = cast[NSMutableArrayAbstract](a).addObject(v)

proc NSStringWithString*(n: cstring): NSString {.importobjc: "NSString stringWithUTF8String", nodecl.}
converter toNSString*(s: string): NSString = NSStringWithString(s)

proc showOpen(di: DialogInfo): string =
    var dialog = newOpenPanel()
    let ctitle: cstring = di.title
    let kind = di.kind
    let path: cstring = if di.folder.isNil: "" else: di.folder
    var cres: cstring

    var filters = newNSMutableArray[NSString](di.filters.len())
    for f in di.filters:
        filters.add(toNSString(f.ext.replace("*.", "")))

    {.emit: """
        if (`kind` == `dkSelectFolder`){
            [`dialog` setCanChooseDirectories:YES];
            [`dialog` setCanChooseFiles:NO];
        }
        else {
            [`dialog` setCanChooseDirectories:NO];
            [`dialog` setCanChooseFiles:YES];
        }

        if ([`filters` count] > 0)
            [`dialog` setAllowedFileTypes: `filters`];

        `dialog`.title = [NSString stringWithUTF8String: `ctitle`];
        [`dialog` setDirectoryURL:[NSURL fileURLWithPath: [NSString stringWithUTF8String: `path`]]];
        if ([`dialog` runModal] == NSOKButton && `dialog`.URLs.count > 0)
            `cres` = [`dialog`.URLs objectAtIndex: 0].path.UTF8String;
    """.}

    if not cres.isNil:
        result = $cres

proc showSave(di: DialogInfo): string =
    var dialog = newSavePanel()
    let ctitle: cstring = di.title
    let kind = di.kind
    let path: cstring = if di.folder.isNil: "" else: di.folder
    var cres: cstring

    var filters = newNSMutableArray[NSString](di.filters.len())
    for f in di.filters:
        filters.add(toNSString(f.ext.replace("*.", "")))

    {.emit: """
        [`dialog` setCanChooseFiles:YES];

        if ([`filters` count] > 0)
            [`dialog` setAllowedFileTypes: `filters`];


        `dialog`.canCreateDirectories = true;
        `dialog`.title = [NSString stringWithUTF8String: `ctitle`];
        [`dialog` setDirectoryURL:[NSURL fileURLWithPath: [NSString stringWithUTF8String: `path`]]];
        if ([`dialog` runModal] == NSOKButton)
                `cres` = `dialog`.URL.path.UTF8String;
    """.}

    if not cres.isNil:
        result = $cres

proc show*(di: DialogInfo): string =
    if di.kind == dkOpenFile or di.kind == dkSelectFolder:
        result = di.showOpen()
    else:
        result = di.showSave()
