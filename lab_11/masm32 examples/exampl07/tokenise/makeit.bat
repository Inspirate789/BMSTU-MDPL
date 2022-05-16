@echo off

if not exist rsrc.rc goto over1
\masm32\bin\rc /v rsrc.rc
\masm32\bin\cvtres /machine:ix86 rsrc.res
 :over1
 
if exist "tokenise.obj" del "tokenise.obj"
if exist "tokenise.exe" del "tokenise.exe"

\masm32\bin\ml /c /coff "tokenise.asm"
if errorlevel 1 goto errasm

if not exist rsrc.obj goto nores

\masm32\bin\PoLink /SUBSYSTEM:CONSOLE "tokenise.obj" rsrc.res
 if errorlevel 1 goto errlink

dir "tokenise.*"
goto TheEnd

:nores
 \masm32\bin\PoLink /SUBSYSTEM:CONSOLE "tokenise.obj"
 if errorlevel 1 goto errlink
dir "tokenise.*"
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
