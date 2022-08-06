; :autoIndent=full:collapseFolds=0:deepIndent=false:folding=indent:indentSize=4:maxLineLen=80:mode=autoitscript:noTabs=false:noWordSep=_@:tabSize=4:wordBreakChars=,+-\=<>/?^&*:wrap=none:
; # ExifTool2WebPMux # =========================================================
; Name ..........: ExifTool2WebPMux
; Description ...: Uses ExifTool and Webpmux to tag WebP-images
; AutoIt Version : V3.3.14.2
; Version .......: V2.1.0
; Syntax ........:
; Author(s) .....: Thorsten Willert
; Date ..........: Sat Aug 06 21:01:17 CEST 2022
; Link ..........: www.thorsten-willert.de
; Example .......: Yes
; Created with ..: jEdit4AutoIt
; ==============================================================================
#pragma compile(Console, true)

#include <WinAPIShPath.au3>
#include <File.au3>
#include <AutoItConstants.au3>

Opt("ExpandVarStrings", 1)

Const $aCmdLine = _WinAPI_CommandLineToArgv($CmdLineRaw)

; help and exit
If ($aCmdLine[0] = 0) Then
	ConsoleWrite(StringReplace("ExifTool2WebPMux V2.1.0: 2022 by Thorsten Willert\n\nOptions:\n1: filename\n2: parameters for ExifTool\n", "\n", @CRLF))
	Exit
EndIf

; tmp-files
Const $tmpFileE = _TempFile(@TempDir, "~", ".exif")
Const $tmpFileX = _TempFile(@TempDir, "~", ".xmp")
OnAutoItExitRegister("_exit") ; must be here because of tmp-file-vars

Const $outfile = $aCmdLine[1]
If Not FileExists($outfile) Then
	ConsoleWrite("Output-file not found: $outfile$")
	Exit (1)
EndIf

Const $sMux = ' "$outfile$" -o "$outfile$"'

Global $sExifToolArgs = ""

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

;ConsoleWrite( $sExifToolArgs & @crlf)

Select
	Case StringInStr($sExifToolArgs, "-exif:all=") ; strip EXIF
		RunCom("webpmux", ' -strip exif' & $sMux)

	Case StringInStr($sExifToolArgs, "-xmp:all=") ; strip XMP
		RunCom("webpmux", ' -strip xmp' & $sMux)

	Case StringInStr($sExifToolArgs, "-icc:all=") ; strip ICC-Profile
		RunCom("webpmux", ' -strip icc' & $sMux)

	Case Else ; write or upate all other tags

		; creating exif sidecar file with ExifTool
		If RunCom("exiftool", ' -o "$tmpFileE$" ' & ANSI_to_437($sExifToolArgs)) Then
			RunCom("webpmux", ' -set exif "$tmpFileE$"' & $sMux) ; metadata => webpmux
		EndIf

		; creating xmp sidecar file with ExifTool
		If RunCom("exiftool", ' -o "$tmpFileX$" ' & ANSI_to_437($sExifToolArgs)) Then
			RunCom("webpmux", ' -set xmp "$tmpFileX$"' & $sMux) ; metadata => webpmux
		EndIf
EndSelect

;===============================================================================
; run commands
Func RunCom($sExe, $sPara)
	Const $iPID = Run($sExe & ".exe " & $sPara, "", @SW_HIDE, $STDERR_MERGED)
	Local $sOutput = ""

	While 1
		$sOutput = StdoutRead($iPID)
		If @error Then ExitLoop
		ConsoleWrite($sOutput)
		If StringInStr($sOutput, "Error:") Then Return 0
	WEnd

	Return 1
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
