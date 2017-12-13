import dialog_types
export dialog_types
import strutils
import logging
import jsbind

when defined(emscripten):
    import jsbind.emscripten

    type Ctx = ref object
        cb: proc(files: string, data: string)

    proc nim_dialog_onLoaded(ctx: Ctx, data: string) {.EMSCRIPTEN_KEEPALIVE.} =
        GC_unref(ctx)
        ctx.cb(nil, data)

proc openFile(di: DialogInfo, cb:proc(files:string, data:string)) =
    var filter:jsstring

    if not di.filters.isNil:
        var filters = newSeq[string](di.filters.len)
        for i, fi in di.filters:
            filters[i] = fi.ext.substr(1)
        filter = filters.join(",")
    else:
        filter = nil

    when defined(js):
        let onLoaded = proc(data: cstring)=
            cb("files ", $data)

        {.emit:"""
            var input = document.createElement("input");
            input.setAttribute("type", "file");
            if(`filter`){
                input.setAttribute("accept", `filter`);
            }

            input.onchange = function(){
                var reader = new FileReader();
                reader.onloadend = function(){
                    `onLoaded`(reader.result);
                }

                reader.readAsBinaryString(input.files[0]);
            }

            input.click();

        """.}

    elif defined(emscripten):
        var ctx: Ctx
        ctx.new()
        ctx.cb = cb
        GC_ref(ctx)

        discard EM_ASM_INT("""
        var input = document.createElement("input");
        input.setAttribute("type", "file");

        if($0){
            var filter = UTF8ToString($0);
            if(filter){
                input.setAttribute("accept", filter);
            }
        }

        input.onchange = function(){
            var reader = new FileReader();
            reader.onloadend = function(){
                _nim_dialog_onLoaded($1, _nimem_s(reader.result));
            };

            reader.readAsBinaryString(input.files[0]);
        };

        input.click();
        """, cstring(filter), cast[pointer](ctx))

proc show*(di: DialogInfo, cb:proc(files:string, data:string)) =
    if di.kind == dkOpenFile:
        di.openFile(cb)
    else:
        raise
