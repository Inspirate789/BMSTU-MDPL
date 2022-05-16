@echo off

if exist %1.obj del enumdisplay.obj
if exist %1.exe del enumdisplay.exe

: -----------------------------------------
: assemble Controls.asm into an OBJ file
: -----------------------------------------
\MASM32\BIN\Ml.exe /c /coff enumdisplay.asm
if errorlevel 1 goto errasm

: --------------------------------------------------
: link the main OBJ file
: --------------------------------------------------
\MASM32\BIN\Link.exe /SUBSYSTEM:WINDOWS enumdisplay.obj
if errorlevel 1 goto errlink

dir enumdisplay.*

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
