@echo off

if not exist rsrc.rc goto over1
\masm32\bin\rc /v rsrc.rc
\masm32\bin\cvtres /machine:ix86 rsrc.res
 :over1
 
if exist "pid.obj" del "pid.obj"
if exist "pid.exe" del "pid.exe"

\masm32\bin\ml /c /coff "pid.asm"
if errorlevel 1 goto errasm

if not exist rsrc.obj goto nores

\masm32\bin\PoLink /SUBSYSTEM:CONSOLE /MERGE:.data=.text "pid.obj" rsrc.res
 if errorlevel 1 goto errlink

dir "pid.*"
goto TheEnd

:nores
 \masm32\bin\PoLink /SUBSYSTEM:CONSOLE /MERGE:.data=.text "pid.obj"
 if errorlevel 1 goto errlink
dir "pid.*"
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
