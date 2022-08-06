; # ExifTool2WebPMux # =========================================================
; Name ..........: ExifTool2WebPMux
; Description ...: Uses ExifTool and Webpmux to tag WebP-images
; AutoIt Version : V3.3.14.2
; Version .......: V2.0.0
; Syntax ........: ExifTool2WebPMux WebP-File ExifTool-Parameters
; Author(s) .....: Thorsten Willert
; Date ..........: Sat Aug 06 18:30:14 CEST 2022
; Link ..........: www.thorsten-willert.de
; Example .......: Yes
; ==============================================================================
#pragma compile(Console, true)
#include <WinAPIShPath.au3>
#include <File.au3>
#include <AutoItConstants.au3>

; don't no why $aCmdLine doesn't work
Const $aCmdLine = _WinAPI_CommandLineToArgv($CmdLineRaw)

; help and exit
If ($aCmdLine[0] = 0) Then
	ConsoleWrite("ExifTool2WebPMux V2.0: 2022 by Thorsten Willert" & @CRLF & @CRLF & "Options: " & @CRLF & "1: filename" & @CRLF & "2: parameters for ExifTool" & @CRLF)
	Exit
EndIf

; tmp-files
Const $tmpFileE = _TempFile(@TempDir, "~", ".exif")
Const $tmpFileX = _TempFile(@TempDir, "~", ".xmp")

OnAutoItExitRegister("_exit")

Const $outfile = $aCmdLine[1]
Const $sMux = $outfile & '" -o "' & $outfile & '"'

Global $sExifToolArgs = ""
Global $sCom

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

Select
	Case StringInStr($sExifToolArgs, "-exif:all=") ; strip EXIF
		$sCom = ' -strip exif "' & $sMux
		RunCom("webpmux", $sCom)

	Case StringInStr($sExifToolArgs, "-xmp:all=") ; strip XMP
		$sCom = ' -strip xmp "' & $sMux
		RunCom("webpmux", $sCom)

	Case StringInStr($sExifToolArgs, "-icc:all=") ; strip ICC-Profile
		$sCom = ' -strip icc "' & $sMux
		RunCom("webpmux", $sCom)

	Case Else ; write or upate all other tags
		; creating sidecar file with ExifTool
		$sCom = ' -o "' & $tmpFileE & '" ' & ANSI_to_437($sExifToolArgs)
		RunCom("exiftool", $sCom)
		$sCom = ' -o "' & $tmpFileX & '" ' & ANSI_to_437($sExifToolArgs)
		RunCom("exiftool", $sCom)

		; sets metadata with webpmux
		$sCom = ' -set exif "' & $tmpFileE & '" "' & $sMux
		RunCom("webpmux", $sCom)
		$sCom = ' -set xmp "' & $tmpFileX & '" "' & $sMux
		RunCom("webpmux", $sCom)
EndSelect

;===============================================================================
; run commands
Func RunCom($sExe, $sPara)
	Const $iPID = Run($sExe & ".exe " & $sPara, "", @SW_HIDE, $STDERR_MERGED)
	Local $sOutput = ""
	While 1
		$sOutput = StdoutRead($iPID)
		If @error Then
			ExitLoop
		EndIf
		ConsoleWrite($sOutput)
	WEnd
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

