@echo off

if exist %1.obj del timer.obj
if exist %1.exe del timer.exe

: -----------------------------------------
: assemble timer.asm into an OBJ file
: -----------------------------------------
\MASM32\BIN\Ml.exe /c /coff timer.asm
if errorlevel 1 goto errasm

: -----------------------
: link the main OBJ file
: -----------------------
\MASM32\BIN\PoLink.exe /SUBSYSTEM:WINDOWS timer.obj
if errorlevel 1 goto errlink
dir timer.*
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
