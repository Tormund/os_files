import strutils
import nimx.write_image_impl

{.passL: "-framework Foundation".}
{.passL: "-framework AppKit".}

type NSWorkspace {.importobjc: "NSWorkspace*", header: "<AppKit/AppKit.h>", incompleteStruct.} = object

{.pragma: objc, header: "<Foundation/Foundation.h>", nodecl.}
type NSObject* {.objc, importobjc, final.} = ptr object {.inheritable.}
type NSString* {.objc, importobjc, final.} = ptr object of NSObject
type NSArrayAbstract* {.objc, importc: "NSArray", final.} = ptr object of NSObject
type NSArray*[T] = ptr object of NSArrayAbstract
type NSMutableArray*[T] = ptr object of NSArray[T]
type NSMutableArrayAbstract* {.objc, importc: "NSMutableArray", final.} = ptr object of NSArrayAbstract

proc newWorkspace: NSWorkspace {.importobjc: "NSWorkspace sharedWorkspace", nodecl.}

proc NSStringWithString*(n: cstring): NSString {.importobjc: "NSString stringWithUTF8String", nodecl.}
converter toNSString*(s: string): NSString = NSStringWithString(s)


proc iconBitmapForFile*(path: string, w, h: int): seq[byte] =
    let tt: cstring = path
    let workspace = newWorkspace()
    result = newSeq[byte](4 * w * h)
    var data = addr result[0]

    {.emit: """
        NSString* sPath = [[NSString alloc] initWithUTF8String: `tt`];
        NSImage* img = [`workspace` iconForFile: sPath];
        [sPath release];
        NSBitmapImageRep *bmp = [[NSBitmapImageRep alloc]
                                initWithBitmapDataPlanes: &`data`
                                pixelsWide: `w`
                                pixelsHigh: `h`
                                bitsPerSample: 8
                                samplesPerPixel: 4
                                hasAlpha: YES
                                isPlanar: NO
                                colorSpaceName: NSDeviceRGBColorSpace
                                bytesPerRow: `w` * 4
                                bitsPerPixel: 32];

        NSGraphicsContext *ctx = [NSGraphicsContext graphicsContextWithBitmapImageRep: bmp];
        [NSGraphicsContext saveGraphicsState];
        [NSGraphicsContext setCurrentContext: ctx];
        [img drawInRect: NSMakeRect(0, 0, `w`, `h`) fromRect: NSZeroRect operation: NSCompositeCopy fraction: 1.0];
        [ctx flushGraphics];
        [NSGraphicsContext restoreGraphicsState];
        [bmp release];
    """.}

proc openInDefaultApp*(path:string) =
    let workspace = newWorkspace()
    let appPath: cstring = path
    {.emit: """ [`workspace` openFile: [NSString stringWithUTF8String: `appPath`]]; """.}
