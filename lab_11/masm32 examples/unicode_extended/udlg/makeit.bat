@echo off
: -------------------------------
: if resources exist, build them
: -------------------------------
\masm32\BIN\rc.exe /v rsrc.rc
\masm32\BIN\CVTRES.EXE /machine:ix86 rsrc.res

if exist %1.obj del "udlg.obj"
if exist %1.exe del "udlg.exe"

: -----------------------------------------
: assemble Project.asm into an OBJ file
: -----------------------------------------
\masm32\BIN\ml.exe /c /coff "udlg.asm"
if errorlevel 1 goto errasm

: --------------------------------------------------
: link the main OBJ file with the resource OBJ file
: --------------------------------------------------
\masm32\BIN\LINK.EXE /SUBSYSTEM:WINDOWS "udlg.obj" rsrc.obj
if errorlevel 1 goto errlink
dir "udlg.*"
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
