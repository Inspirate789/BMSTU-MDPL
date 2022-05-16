@echo off
: -----------------------------------------
: assemble tabs.asm into an OBJ file
: -----------------------------------------
\MASM32\BIN\Ml.exe /c /coff tabs.asm
if errorlevel 1 goto errasm

: -----------------------
: link the main OBJ file
: -----------------------
\MASM32\BIN\Link.exe /SUBSYSTEM:WINDOWS tabs.obj
if errorlevel 1 goto errlink

goto TheEnd

:errlink
: ----------------------------------------------------
: display message if there is an error during linking
: ----------------------------------------------------
echo.
echo There has been an error while linking tabs.
echo.
goto TheEnd

:errasm
: -----------------------------------------------------
: display message if there is an error during assembly
: -----------------------------------------------------
echo.
echo There has been an error while assembling tabs.
echo.
goto TheEnd

:TheEnd

pause
