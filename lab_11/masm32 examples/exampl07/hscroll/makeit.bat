@echo off
 
if exist "hscroll.obj" del "hscroll.obj"
if exist "hscroll.exe" del "hscroll.exe"

\masm32\bin\ml /c /coff "hscroll.asm"
if errorlevel 1 goto errasm

\masm32\bin\PoLink /SUBSYSTEM:WINDOWS "hscroll.obj"
if errorlevel 1 goto errlink
dir "hscroll.*"
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
