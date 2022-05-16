@echo off
: -------------------------------
: if resources exist, build them
: -------------------------------
if not exist AniDiagLeftRight_rc.rc goto over1
\MASM32\BIN\Rc.exe /v AniDiagLeftRight_rc.rc
\MASM32\BIN\Cvtres.exe /machine:ix86 AniDiagLeftRight_rc.res
:over1

if exist %1.obj del AniDiagLeftRight.obj
if exist %1.exe del AniDiagLeftRight.exe

: -----------------------------------------
: assemble AniDiagLeftRight.asm into an OBJ file
: -----------------------------------------
\MASM32\BIN\Ml.exe /c /coff AniDiagLeftRight.asm
if errorlevel 1 goto errasm

if not exist AniDiagLeftRight_rc.obj goto nores

: --------------------------------------------------
: link the main OBJ file with the resource OBJ file
: --------------------------------------------------
\MASM32\BIN\Link.exe /SUBSYSTEM:WINDOWS AniDiagLeftRight.obj AniDiagLeftRight_rc.obj
if errorlevel 1 goto errlink

dir AniDiagLeftRight.*

goto TheEnd

:errlink
: ----------------------------------------------------
: display message if there is an error during linking
: ----------------------------------------------------
echo.
echo There has been an error while linking this project.
echo.
goto TheEnd

:errasm
: -----------------------------------------------------
: display message if there is an error during assembly
: -----------------------------------------------------
echo.
echo There has been an error while assembling this project.
echo.
goto TheEnd

:TheEnd
pause
