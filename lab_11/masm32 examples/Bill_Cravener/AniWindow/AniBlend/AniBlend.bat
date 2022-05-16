@echo off
: -------------------------------
: if resources exist, build them
: -------------------------------
if not exist AniBlend_rc.rc goto over1
\MASM32\BIN\Rc.exe /v AniBlend_rc.rc
\MASM32\BIN\Cvtres.exe /machine:ix86 AniBlend_rc.res
:over1

if exist %1.obj del AniBlend.obj
if exist %1.exe del AniBlend.exe

: -----------------------------------------
: assemble AniBlend.asm into an OBJ file
: -----------------------------------------
\MASM32\BIN\Ml.exe /c /coff AniBlend.asm
if errorlevel 1 goto errasm

if not exist AniBlend_rc.obj goto nores

: --------------------------------------------------
: link the main OBJ file with the resource OBJ file
: --------------------------------------------------
\MASM32\BIN\Link.exe /SUBSYSTEM:WINDOWS AniBlend.obj AniBlend_rc.obj
if errorlevel 1 goto errlink

dir AniBlend.*

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
