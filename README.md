# ExifTool2WebPMux
Command line utility (wrapper) to write WebP metadata with ExifTool and WebPMux.

## Installation
In the same path or directory like ExifTool.exe and WebPMux.exe

## How it works
The specified meta data is written to a sidecar file by the ExifTool. This is the input for WebPMux.

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
