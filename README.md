# OS_FILES

Native __file dialogs__ (x11, windows, osx) with extension filters and predefined path.
System __file icons__ in any resolution (x11 with theme support, windows, osx).
Open file with __system default__ application (x11, windows, osx).

## File Dialogs Example

Supported platforms:
* X11
* OSX
* Windows
* WIP: web (JavaScript)

```nim
    import os_files.dialog

    var di:DialogInfo
    # required: dialog kind - one of dkOpenFile dkSaveFile dkSelectFolder dkCreateFolder
    di.kind = dkSaveFile

    # optional: dialog's title
    di.title = "Test dialog"

    # optional: override current folder path
    di.folder = "C:\\Users\\tormund\\devel"

    # optional: extension filters
    di.filters = @[(name:"JSON", ext:"*.json"),(name: "Picture", ext:"*.png")]

    # optional dkSaveFile only: to automaticaly append extension
    di.extension = "rod"

    # call modal dialog
    let path = di.show()

    # validate dialog result
    if path.len > 0:
        #[
            your code here
        ]#
```

## System Icons Example

Supported platforms:
* X11
* OSX
* Windows

```nim
    import os_files.file_info

    ## path to file or folder
    let path_to_file: string = "/home"

    ## get icon bitmap data
    let iconSize = 128
    let icon_bitmap_data = iconBitmapForFile(path_to_file, iconSize, iconSize)

    ## do something with bitmap data
    ## for example create image using Nimx
    if not icon_bitmap_data.isNil:
        let image = imageWithBitmap(cast[ptr uint8](icon_bitmap_data), iconSize, iconSize, 4)
```

## Open file with default application Example

Supported platforms:
* X11
* OSX
* Windows

```nim
    import os_files.file_info

    let path_to_file = "/home/example_image.png"
    openInDefaultApp(path_to_file)
```
