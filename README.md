# ExifTool2WebPMux
Command line utility to write WebP metadata with ExifTool and webpmuxer.

## Installation
In the same path or direcory like exiftool.exe and webpmuxer.exe

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
