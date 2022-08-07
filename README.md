# ExifTool2WebPMux
Command line utility (wrapper) to write WebP metadata with ExifTool and WebPMux.

## Installation
In the same path or directory like ExifTool.exe and WebPMux.exe

## How it works
The specified meta data is written to a sidecar file by the ExifTool. This is the input for WebPMux.

## Parameters
1: WebP-file

2: Parameters for ExifTool

-result: shows all metadata of the output-file (same like "exiftool.exe -g image.webp")

## Required files
[ExifTool](https://exiftool.org/)

[WebPMux](https://storage.googleapis.com/downloads.webmproject.org/releases/webp/index.html)

---
## Examples:

Writing metadata - same parameters like the ExifTool and shows all metadata of the picture.
``` Batch
ExifTool2Webpmux.exe "R:\test.webp" -owner="Thorsten Willert" -title="Test Datei" -result
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
