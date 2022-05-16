@echo off

if not exist rsrc.rc goto over1
\masm32\bin\rc /v rsrc.rc
\masm32\bin\cvtres /machine:ix86 rsrc.res
 :over1
 
if exist "tstlib.obj" del "tstlib.obj"
if exist "tstlib.exe" del "tstlib.exe"

\masm32\bin\ml /c /coff "tstlib.asm"
if errorlevel 1 goto errasm

if not exist rsrc.obj goto nores

\masm32\bin\PoLink /SUBSYSTEM:WINDOWS "tstlib.obj" rsrc.res
 if errorlevel 1 goto errlink

dir "tstlib.*"
goto TheEnd

:nores
\masm32\bin\PoLink /SUBSYSTEM:WINDOWS "tstlib.obj"
if errorlevel 1 goto errlink
dir "tstlib.*"
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
