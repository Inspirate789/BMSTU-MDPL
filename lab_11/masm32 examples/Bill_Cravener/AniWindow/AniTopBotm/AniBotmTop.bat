@echo off
: -------------------------------
: if resources exist, build them
: -------------------------------
if not exist AniBotmTop_rc.rc goto over1
\MASM32\BIN\Rc.exe /v AniBotmTop_rc.rc
\MASM32\BIN\Cvtres.exe /machine:ix86 AniBotmTop_rc.res
:over1

if exist %1.obj del AniBotmTop.obj
if exist %1.exe del AniBotmTop.exe

: -----------------------------------------
: assemble AniBotmTop.asm into an OBJ file
: -----------------------------------------
\MASM32\BIN\Ml.exe /c /coff AniBotmTop.asm
if errorlevel 1 goto errasm

if not exist AniBotmTop_rc.obj goto nores

: --------------------------------------------------
: link the main OBJ file with the resource OBJ file
: --------------------------------------------------
\MASM32\BIN\Link.exe /SUBSYSTEM:WINDOWS AniBotmTop.obj AniBotmTop_rc.obj
if errorlevel 1 goto errlink

dir AniBotmTop.*

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
