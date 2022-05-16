@echo off

if exist %1.obj del redit.obj
if exist %1.exe del redit.exe

: -----------------------------------------
: assemble redit.asm into an OBJ file
: -----------------------------------------
\MASM32\BIN\Ml.exe /c /coff redit.asm
if errorlevel 1 goto errasm

: -----------------------
: link the main OBJ file
: -----------------------
\MASM32\BIN\PoLink.exe /SUBSYSTEM:WINDOWS redit.obj
if errorlevel 1 goto errlink
dir redit.*
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
