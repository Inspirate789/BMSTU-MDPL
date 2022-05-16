@echo off
: -------------------------------
: if resources exist, build them
: -------------------------------
if not exist AniRightLeft_rc.rc goto over1
\MASM32\BIN\Rc.exe /v AniRightLeft_rc.rc
\MASM32\BIN\Cvtres.exe /machine:ix86 AniRightLeft_rc.res
:over1

if exist %1.obj del AniRightLeft.obj
if exist %1.exe del AniRightLeft.exe

: -----------------------------------------
: assemble AniRightLeft.asm into an OBJ file
: -----------------------------------------
\MASM32\BIN\Ml.exe /c /coff AniRightLeft.asm
if errorlevel 1 goto errasm

if not exist AniRightLeft_rc.obj goto nores

: --------------------------------------------------
: link the main OBJ file with the resource OBJ file
: --------------------------------------------------
\MASM32\BIN\Link.exe /SUBSYSTEM:WINDOWS AniRightLeft.obj AniRightLeft_rc.obj
if errorlevel 1 goto errlink

dir AniRightLeft.*

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
