@echo off

if not exist rsrc.rc goto over1
\masm32\bin\rc /v rsrc.rc
\masm32\bin\cvtres /machine:ix86 rsrc.res
 :over1
 
if exist "touch.obj" del "touch.obj"
if exist "touch.exe" del "touch.exe"

\masm32\bin\ml /c /coff "touch.asm"
if errorlevel 1 goto errasm

if not exist rsrc.obj goto nores

\masm32\bin\PoLink /SUBSYSTEM:CONSOLE "touch.obj" rsrc.res
 if errorlevel 1 goto errlink

dir "touch.*"
goto TheEnd

:nores
 \masm32\bin\PoLink /SUBSYSTEM:CONSOLE "touch.obj"
 if errorlevel 1 goto errlink
dir "touch.*"
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
