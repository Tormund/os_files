import dialog_types
export dialog_types

import darwin / objc / runtime
import darwin / foundation

import strutils

{.passL: "-framework Foundation".}
{.passL: "-framework AppKit".}
when defined(cpp):
    {.passC: "-ObjC++".}

type NSSavePanel {.importobjc: "NSSavePanel*", header: "<AppKit/AppKit.h>", incompleteStruct.} = object
type NSOpenPanel {.importobjc: "NSOpenPanel*", header: "<AppKit/AppKit.h>", incompleteStruct.} = object

proc newOpenPanel: NSOpenPanel {.importobjc: "NSOpenPanel openPanel", nodecl.}
proc newSavePanel: NSSavePanel {.importobjc: "NSSavePanel savePanel", nodecl.}

proc showOpen(di: DialogInfo): string =
    var dialog = newOpenPanel()
    let ctitle: cstring = di.title
    let kind = di.kind
    let path: cstring = if di.folder.len == 0: "" else: di.folder
    var cres: cstring

    var filters = newMutableArray[NSString]()
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
            [`dialog` setAllowedFileTypes: (NSArray<NSString *> *)`filters`];

        `dialog`.title = [NSString stringWithUTF8String: `ctitle`];
        [`dialog` setDirectoryURL:[NSURL fileURLWithPath: [NSString stringWithUTF8String: `path`]]];
        if ([`dialog` runModal] == NSOKButton && `dialog`.URLs.count > 0)
            `cres` = (char *)[`dialog`.URLs objectAtIndex: 0].path.UTF8String;
    """.}

    if not cres.isNil:
        result = $cres

proc showSave(di: DialogInfo): string =
    var dialog = newSavePanel()
    let ctitle: cstring = di.title
    let kind = di.kind
    let path: cstring = if di.folder.len == 0: "" else: di.folder
    var cres: cstring

    var filters = newMutableArray[NSString]()
    for f in di.filters:
        filters.add(toNSString(f.ext.replace("*.", "")))

    {.emit: """
        if ([`filters` count] > 0)
            [`dialog` setAllowedFileTypes: (NSArray<NSString *> *)`filters`];


        `dialog`.canCreateDirectories = true;
        `dialog`.title = [NSString stringWithUTF8String: `ctitle`];
        [`dialog` setDirectoryURL:[NSURL fileURLWithPath: [NSString stringWithUTF8String: `path`]]];
        if ([`dialog` runModal] == NSOKButton)
                `cres` = (char *)`dialog`.URL.path.UTF8String;
    """.}

    if not cres.isNil:
        result = $cres

proc show*(di: DialogInfo): string =
    if di.kind == dkOpenFile or di.kind == dkSelectFolder:
        result = di.showOpen()
    else:
        result = di.showSave()
