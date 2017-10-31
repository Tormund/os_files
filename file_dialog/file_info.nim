when defined(linux) and not defined(android) and not defined(emscripten):
    import private/unix_file_info
    export unix_file_info

elif defined(windows):
    import private/win32_dialog
    export win32_dialog

elif defined(macosx) and not defined(ios):
    import private/osx_file_info
    export osx_file_info

else:
    {.error: "Unsupported platform".}
