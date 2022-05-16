@echo off

if exist %1.obj del poasm1k.obj
if exist %1.exe del poasm1k.exe

: -----------------------------------------
: assemble poasm1k.asm into an OBJ file
: -----------------------------------------
\masm32\BIN\poasm /V2 poasm1k.asm
if errorlevel 1 goto errasm

: -----------------------
: link the main OBJ file
: -----------------------
\masm32\BIN\PoLink.exe /SUBSYSTEM:WINDOWS /merge:.data=.text poasm1k.obj > nul
if errorlevel 1 goto errlink
dir poasm1k.*
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
