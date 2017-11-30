when defined(linux) and not defined(android) and not defined(emscripten):
    import private/unix_file_info
    export unix_file_info

elif defined(windows):
    import private/win32_file_info
    export win32_file_info

elif defined(macosx) and not defined(ios):
    import private/osx_file_info
    export osx_file_info

else:
    {.error: "Unsupported platform".}

when isMainModule:
    discard iconBitmapForFile("""C:\ыфвф""", 128, 128)
    openInDefaultApp("""C:\Users\tormund\devel\falcon\rodplugin.nim""")
