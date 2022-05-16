@echo off

if not exist rsrc.rc goto over1
\masm32\bin\rc /v rsrc.rc
\masm32\bin\cvtres /machine:ix86 rsrc.res 
:over1 
 
if exist "simple.obj" del "simple.obj"
if exist "simple.exe" del "simple.exe"

\masm32\bin\ml /c /coff "simple.asm"
if errorlevel 1 goto errasm

if not exist rsrc.obj goto nores

\masm32\bin\PoLink /SUBSYSTEM:WINDOWS "simple.obj" rsrc.obj 
 if errorlevel 1 goto errlink

dir "simple.*"
goto TheEnd

:nores 
\masm32\bin\PoLink /SUBSYSTEM:WINDOWS "simple.obj" 
if errorlevel 1 goto errlink
dir "simple.*"
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
