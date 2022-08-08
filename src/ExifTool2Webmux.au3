; :autoIndent=full:collapseFolds=0:deepIndent=false:folding=indent:indentSize=4:maxLineLen=80:mode=autoitscript:noTabs=false:noWordSep=_@:tabSize=4:wordBreakChars=,+-\=<>/?^&*:wrap=none:
; # ExifTool2WebPMux # =========================================================
; Name ..........: ExifTool2WebPMux
; Description ...: Uses ExifTool and WebPMux to tag WebP-images
; AutoIt Version : v3.3.16.0
; Version .......: V2.3.0
; Syntax ........:
; Author(s) .....: Thorsten Willert
; Date ..........: Mon Aug 08 08:05:28 CEST 2022
; Link ..........: www.thorsten-willert.de
; Example .......: Yes
; Created with ..: jEdit4AutoIt
; ==============================================================================
#pragma compile(Console, true)

#include <WinAPIShPath.au3>
#include <File.au3>
#include <AutoItConstants.au3>

Opt("ExpandVarStrings", 1)

; check for tools
If Not Run("exiftool.exe -h", "", @SW_HIDE , $STDERR_MERGED) Then
	ConsoleWrite("Error: ExifTool.exe not available" & @crlf)
	Exit
EndIf
If Not Run("exiftool.exe -h", "", @SW_HIDE , $STDERR_MERGED) Then
	ConsoleWrite("Error: WebPMux.exe not available" & @crlf)
	Exit
EndIf

Const $aCmdLine = _WinAPI_CommandLineToArgv($CmdLineRaw)

; help and exit
If ($aCmdLine[0] = 0) Then
	ConsoleWrite(StringReplace("ExifTool2WebPMux V2.3.0: 2022 by Thorsten Willert\n\nOptions:\n1: filename\n2: parameters for ExifTool\n-result: shows all metadata of the output file\n", "\n", @CRLF))
	Exit
EndIf

; tmp-files
Const $tmpFileE = _TempFile(@TempDir, "~", ".exif")
Const $tmpFileX = _TempFile(@TempDir, "~", ".xmp")
OnAutoItExitRegister("_exit") ; must be here because of tmp-file-vars

; output file check
Const $outfile = $aCmdLine[1]
If Not FileExists($outfile) Then
	ConsoleWrite(@crlf & "File not found: $outfile$" & @crlf)
	Exit(1)
EndIf
Const $sMux = ' "$outfile$" -o "$outfile$"'

Global $sExifToolArgs = ""
Global $bResult = False
Global $bSilent = False

;===============================================================================
; command for ExifTool
For $i = 2 To $aCmdLine[0]
	$sExifToolArgs &= StringStripWS($aCmdLine[$i], 3) & " "
Next

; rebuild " for ExifTool-commands
$sExifToolArgs = StringReplace($sExifToolArgs, "=", '="')
$sExifToolArgs = StringReplace($sExifToolArgs, " -", '" -')
$sExifToolArgs &= '"'
$sExifToolArgs = StringReplace($sExifToolArgs, ':all=" "', ':all=')
$sExifToolArgs = StringReplace($sExifToolArgs, ':all=""', ':all=')

; print result
If StringInStr( $sExifToolArgs, "-result") Then $bResult = True
$sExifToolArgs = StringReplace($sExifToolArgs, '-result', '')
; print nothing
If StringInStr( $sExifToolArgs, "-silent") Then $bSilent = True
$sExifToolArgs = StringReplace($sExifToolArgs, '-silent', '')

; size of original file
If Not $bSilent Then ConsoleWrite( "## Filesize: " & Round(FileGetSize( $outfile) / 1000, 3) & " kB" & @crlf)

Select
	Case StringInStr($sExifToolArgs, "-exif:all=") ; strip EXIF
		RunCom("WebPMux", ' -strip exif' & $sMux)

	Case StringInStr($sExifToolArgs, "-xmp:all=") ; strip XMP
		RunCom("WebPMux", ' -strip xmp' & $sMux)

	Case StringInStr($sExifToolArgs, "-icc:all=") ; strip ICC-Profile
		RunCom("WebPMux", ' -strip icc' & $sMux)

	Case Else ; write or upate all other tags
		; creating exif sidecar file with ExifTool
		If RunCom("ExifTool", ' -o "$tmpFileE$" ' & ANSI_to_437($sExifToolArgs)) Then
			RunCom("WebPMux", ' -set exif "$tmpFileE$"' & $sMux) ; metadata => WebPMux
		EndIf

		; creating xmp sidecar file with ExifTool
		If RunCom("ExifTool", ' -o "$tmpFileX$" ' & ANSI_to_437($sExifToolArgs)) Then
			RunCom("WebPMux", ' -set xmp "$tmpFileX$"' & $sMux) ; metadata => WebPMux
		EndIf
EndSelect

If $bResult Then RunCom("ExifTool", ' -g "$outfile$" ' )

;===============================================================================
; run commands
Func RunCom($sExe, $sPara = "")

	Const $iPID = Run($sExe & ".exe " & $sPara, "", @SW_HIDE , $STDERR_MERGED)
	Local $sOutput = ""

	If Not $bSilent Then ConsoleWrite( @crlf & "## " &  $sExe & ":" & @crlf )

	While Sleep(10)
		$sOutput = StdoutRead($iPID)
		If @error Then ExitLoop
		If StringInStr($sOutput, "Error:") Then Return 0
		If Not $bSilent Then ConsoleWrite($sOutput)
	WEnd

	Return $iPID
EndFunc   ;==>RunCom

;===============================================================================
;Clean up tmp-files
Func _exit()
	FileDelete($tmpFileE)
	FileDelete($tmpFileX)
EndFunc   ;==>_exit

;===============================================================================
Func ANSI_to_437($text)
	$text = DllCall('user32.dll', 'Int', 'CharToOem', 'str', $text, 'str', '')
	Return $text[2]
EndFunc   ;==>ANSI_to_437
