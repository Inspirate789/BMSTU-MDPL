@echo off
: -------------------------------
: if resources exist, build them
: -------------------------------
if not exist rsrc.rc goto over1
\MASM32\BIN\Rc.exe /v rsrc.rc
\MASM32\BIN\Cvtres.exe /machine:ix86 rsrc.res
:over1

if exist enumdd.obj del enumdd.obj
if exist enumdd.exe del enumdd.exe

: -----------------------------------------
: assemble enumdd.asm into an OBJ file
: -----------------------------------------
\MASM32\BIN\Ml.exe /c /coff enumdd.asm
if errorlevel 1 goto errasm

if not exist rsrc.obj goto nores

: --------------------------------------------------
: link the main OBJ file with the resource OBJ file
: --------------------------------------------------
\MASM32\BIN\PoLink.exe /SUBSYSTEM:WINDOWS enumdd.obj rsrc.res
if errorlevel 1 goto errlink
dir enumdd.*
goto TheEnd

:nores
: -----------------------
: link the main OBJ file
: -----------------------
\MASM32\BIN\PoLink.exe /SUBSYSTEM:WINDOWS enumdd.obj
if errorlevel 1 goto errlink
dir enumdd.*
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
