@echo off

if not exist rsrc.rc goto over1
\masm32\bin\rc /v rsrc.rc
\masm32\bin\cvtres /machine:ix86 rsrc.res
 :over1
 
if exist "cb.obj" del "cb.obj"
if exist "cb.exe" del "cb.exe"

\masm32\bin\ml /c /coff "cb.asm"
if errorlevel 1 goto errasm

if not exist rsrc.obj goto nores

\masm32\bin\PoLink /SUBSYSTEM:CONSOLE "cb.obj" rsrc.res
 if errorlevel 1 goto errlink

dir "cb.*"
goto TheEnd

:nores
 \masm32\bin\PoLink /SUBSYSTEM:CONSOLE "cb.obj"
 if errorlevel 1 goto errlink
dir "cb.*"
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
