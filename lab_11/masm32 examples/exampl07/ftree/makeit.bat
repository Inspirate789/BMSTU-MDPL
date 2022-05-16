@echo off
 
if exist "ftree.obj" del "ftree.obj"
if exist "ftree.exe" del "ftree.exe"

\masm32\bin\ml /c /coff "ftree.asm"
if errorlevel 1 goto errasm

\masm32\bin\PoLink /SUBSYSTEM:CONSOLE "ftree.obj"
if errorlevel 1 goto errlink
dir "ftree.*"
goto TheEnd

:errlink
echo _
echo Link error
goto TheEnd

:errasm
echo _
echo Assembly Error
goto TheEnd

:TheEnd
 
pause
