import dialog_types
export dialog_types
import strutils
import logging

proc show*(di: DialogInfo): string =
    var filter:cstring = ""
    if not di.filters.isNil:
        var filters = newSeq[string](di.filters.len)
        for i, fi in di.filters:
            filters[i] = fi.ext.substr(1)
        filter = filters.join(",").cstring

    {.emit:"""
        var input = document.createElement("input");
        input.setAttribute("type", "file");
        input.setAttribute("accept", `filter`);
        input.click();
        input.onchange = function(){
            input.parentNode.removeChild();
        }
    """.}
