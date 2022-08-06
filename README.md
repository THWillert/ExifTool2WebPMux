# ExifTool2WebPMux
Command line utility to write WebP metadata with ExifTool and webpmuxer.

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
