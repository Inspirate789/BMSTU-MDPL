@echo off
: -------------------------------
: if resources exist, build them
: -------------------------------
H:\masm32\BIN\rc.exe /v rsrc.rc
H:\masm32\BIN\CVTRES.EXE /machine:ix86 rsrc.res

if exist %1.obj del "multi_lingual.obj"
if exist %1.exe del "multi_lingual.exe"

: -----------------------------------------
: assemble Project.asm into an OBJ file
: -----------------------------------------
H:\masm32\BIN\ml.exe /c /coff "multi_lingual.asm"
if errorlevel 1 goto errasm

: --------------------------------------------------
: link the main OBJ file with the resource OBJ file
: --------------------------------------------------
H:\masm32\BIN\LINK.EXE /SUBSYSTEM:WINDOWS "multi_lingual.obj" rsrc.obj
if errorlevel 1 goto errlink
dir "multi_lingual.*"
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
