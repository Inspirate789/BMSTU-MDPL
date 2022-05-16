@echo off

if exist %1.obj del masm1k.obj
if exist %1.exe del masm1k.exe

: -----------------------------------------
: assemble masm1k.asm into an OBJ file
: -----------------------------------------
\MASM32\BIN\Ml.exe /c /coff masm1k.asm
if errorlevel 1 goto errasm

: -----------------------
: link the main OBJ file
: -----------------------
\MASM32\BIN\PoLink.exe /SUBSYSTEM:WINDOWS /merge:.data=.text masm1k.obj > nul
if errorlevel 1 goto errlink
dir masm1k.*
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
