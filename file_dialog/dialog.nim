when defined(linux) and not defined(android) and not defined(emscripten):
   import private/unix_dialog
   export unix_dialog

elif defined(windows):
    import private/win32_dialog
    export win32_dialog

elif defined(macosx) and not defined(ios):
    import private/osx_dialog
    export osx_dialog
else:
    {.error: "Unsupported platform".}

when isMainModule:
    var di:DialogInfo
    di.title = "Test dialog"
    di.folder = "C:\\Users\\tormund\\devel"
    di.kind = dkSaveFile
    di.filters = @[(name:"JSON", ext:"*.json"),(name: "Picture", ext:"*.png")]
    di.extension = "rod"
    echo di.show()
