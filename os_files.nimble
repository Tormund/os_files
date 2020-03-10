# Package
version = "0.1.2"
author = "Tormund"
description = """Native file dialogs (x11, windows, osx) with extension filters and predefined path.
    System file icons in any resolution (x11 with theme support, windows, osx).
    Open file in default application (x11, windows, osx)"""

license = "MIT"

when defined(windows):
    requires "winim >= 3.1.1"

requires "oldgtk3"
requires "jsbind"
requires "https://github.com/yglukhov/darwin"
