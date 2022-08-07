; :autoIndent=full:collapseFolds=0:deepIndent=false:folding=indent:indentSize=4:maxLineLen=80:mode=autoitscript:noTabs=false:noWordSep=_@:tabSize=4:wordBreakChars=,+-\=<>/?^&*:wrap=none:
; # ExifTool2WebPMux # =========================================================
; Name ..........: ExifTool2WebPMux
; Description ...: Uses ExifTool and WebPMux to tag WebP-images
; AutoIt Version : V3.3.14.2
; Version .......: V2.2.0
; Syntax ........:
; Author(s) .....: Thorsten Willert
; Date ..........: Sun Aug 07 15:13:58 CEST 2022
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
	ConsoleWrite(StringReplace("ExifTool2WebPMux V2.2.0: 2022 by Thorsten Willert\n\nOptions:\n1: filename\n2: parameters for ExifTool\n", "\n", @CRLF))
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
	Exit (1)
EndIf
Const $sMux = ' "$outfile$" -o "$outfile$"'

Global $sExifToolArgs = ""
Global $bResult = False

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

ConsoleWrite( "## Filesize: " & Round(FileGetSize( $outfile) / 1000, 3) & " kB" & @crlf)

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
Func RunCom($sExe, $sPara )

	Const $iPID = Run($sExe & ".exe " & $sPara, "", @SW_HIDE, $STDERR_MERGED)
	Local $sOutput = ""

	ConsoleWrite( @crlf & "## " &  $sExe & ":" & @crlf )

	While Sleep(10)
		$sOutput = StdoutRead($iPID)
		If @error Then ExitLoop
		If StringInStr($sOutput, "Error:") Then Return 0
		ConsoleWrite($sOutput)
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
