@echo off
: -------------------------------
: if resources exist, build them
: -------------------------------
if not exist rsrc.rc goto over1
\masm32\BIN\Rc.exe /v rsrc.rc
\masm32\BIN\Cvtres.exe /machine:ix86 rsrc.res
:over1

if exist %1.obj del uwin2.obj
if exist %1.exe del uwin2.exe

: -----------------------------------------
: assemble template.asm into an OBJ file
: -----------------------------------------
\masm32\BIN\Ml.exe /c /coff uwin2.asm
if errorlevel 1 goto errasm

if not exist rsrc.obj goto nores

: --------------------------------------------------
: link the main OBJ file with the resource OBJ file
: --------------------------------------------------
\masm32\BIN\Link.exe /SUBSYSTEM:WINDOWS uwin2.obj rsrc.obj
if errorlevel 1 goto errlink
dir uwin2.*
goto TheEnd

:nores
: -----------------------
: link the main OBJ file
: -----------------------
\masm32\BIN\Link.exe /SUBSYSTEM:WINDOWS uwin2.obj
if errorlevel 1 goto errlink
dir uwin2.*
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
