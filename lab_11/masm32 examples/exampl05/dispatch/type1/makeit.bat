@echo off
: -------------------------------
: if resources exist, build them
: -------------------------------
if not exist rsrc.rc goto over1
\MASM32\BIN\Rc.exe /v rsrc.rc
\MASM32\BIN\Cvtres.exe /machine:ix86 rsrc.res
:over1

if exist %1.obj del arrdisp.obj
if exist %1.exe del arrdisp.exe

: -----------------------------------------
: assemble arrdisp.asm into an OBJ file
: -----------------------------------------
\MASM32\BIN\Ml.exe /c /coff arrdisp.asm
if errorlevel 1 goto errasm

if not exist rsrc.obj goto nores

: --------------------------------------------------
: link the main OBJ file with the resource OBJ file
: --------------------------------------------------
\MASM32\BIN\Link.exe /SUBSYSTEM:WINDOWS arrdisp.obj rsrc.obj
if errorlevel 1 goto errlink
dir arrdisp.*
goto TheEnd

:nores
: -----------------------
: link the main OBJ file
: -----------------------
\MASM32\BIN\Link.exe /SUBSYSTEM:WINDOWS arrdisp.obj
if errorlevel 1 goto errlink
dir arrdisp.*
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
