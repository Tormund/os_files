when defined(linux) and not defined(android) and not defined(emscripten):
   import private_dialog/unix_dialog
   export unix_dialog

elif defined(windows):
    import private_dialog/win32_dialog
    export win32_dialog

elif defined(macosx) and not defined(ios):
    import private_dialog/osx_dialog
    export osx_dialog

elif defined(js) or defined(emscripten):
    import private_dialog/js_dialog
    export js_dialog

else:
    {.error: "Unsupported platform".}

when isMainModule:
    import logging

    var di:DialogInfo
    di.title = "Test dialog"
    di.folder = "C:\\Users\\tormund\\devel"
    di.kind = dkOpenFile
    di.filters = @[(name:"JSON", ext:"*.json"),(name: "Picture", ext:"*.png")]
    di.extension = "rod"
    when defined(js) or defined(emscripten):
        di.show do(files: string, data: string):
            info data
    else:
        info di.show()

