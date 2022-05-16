@echo off

if not exist rsrc.rc goto over1
\masm32\bin\rc /v rsrc.rc
\masm32\bin\cvtres /machine:ix86 rsrc.res
 :over1
 
if exist "multidl.obj" del "multidl.obj"
if exist "multidl.exe" del "multidl.exe"

\masm32\bin\ml /c /coff "multidl.asm"
if errorlevel 1 goto errasm

if not exist rsrc.obj goto nores

\masm32\bin\PoLink /SUBSYSTEM:CONSOLE "multidl.obj" rsrc.res
 if errorlevel 1 goto errlink

dir "multidl.*"
goto TheEnd

:nores
 \masm32\bin\PoLink /SUBSYSTEM:CONSOLE "multidl.obj"
 if errorlevel 1 goto errlink
dir "multidl.*"
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
