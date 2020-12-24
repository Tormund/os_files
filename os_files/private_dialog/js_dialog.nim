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
        ctx.cb("", data)

proc openFile(di: DialogInfo, cb:proc(files:string, data:string)) =
    var filter:jsstring

    if di.filters.len > 0:
        var filters = newSeq[string](di.filters.len)
        for i, fi in di.filters:
            filters[i] = fi.ext.substr(1)
        filter = filters.join(",")
    else:
        filter = ""

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

const createA = """
    var a = document.getElementById("__os_files_save_link");
    if (a == null) {
        var a = document.createElement("a");
        a.style.position = "absolute";
        a.style.top = "-1000px";
        a.id = "__os_files_save_link";
        document.body.appendChild(a);
    }
"""

proc save*(di: DialogInfo, filename, data: string) =
    let fn = filename.cstring
    let d = data.cstring

    when defined(js):
        {.emit: createA.}
        {.emit: """
            var blob = new Blob([`d`], {type: "application/octet-stream"});
            var url = URL.createObjectURL(blob);
            a.href = url;
            a.download = `fn`;
            a.click();
        """.}
    elif defined(emscripten):
        discard EM_ASM_INT(createA & """
            var blob = new Blob([new Int8Array(HEAP8.buffer, $1, $2)], {type: "application/octet-stream"});
            var url = URL.createObjectURL(blob);
            a.href = url;
            a.download = UTF8ToString($0);
            a.click();
        """, fn, d, cint(data.len))

proc show*(di: DialogInfo, cb:proc(files:string, data:string)) =
    if di.kind == dkOpenFile:
        di.openFile(cb)
    else:
        discard
