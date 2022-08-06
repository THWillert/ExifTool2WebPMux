# ExifTool2WebPMux
Command line utility (wrapper) to write WebP metadata with ExifTool and WebPMux.

## Installation
In the same path or directory like ExifTool.exe and WebPMux.exe

## How it works
The specified meta data is written to a sidecar file by the ExifTool. This is the input for WebPMux.

## Required files
[ExifTool](https://exiftool.org/)

[WebPMux](https://storage.googleapis.com/downloads.webmproject.org/releases/webp/index.html)

---
## Examples:

Writing metadata - same parameters like the ExifTool
``` Batch
ExifTool2Webpmux.exe "R:\test.webp" -owner="Thorsten Willert" -title="Test Datei"
```

Delete EXIF, XMP or ICC
``` Batch
ExifTool2Webpmux.exe "R:\test.webp" -xmp:all=
ExifTool2Webpmux.exe "R:\test.webp" -exif:all=
ExifTool2Webpmux.exe "R:\test.webp" -icc:all=
```

## ToDo
- [ ] Simple parameter check
- [ ] Check for existing exiftool and webpmux
