@echo off

if not exist rsrc.rc goto over1
\masm32\bin\rc /v rsrc.rc
\masm32\bin\cvtres /machine:ix86 rsrc.res
 :over1
 
if exist "fs.obj" del "fs.obj"
if exist "fs.exe" del "fs.exe"

\masm32\bin\ml /c /coff "fs.asm"
if errorlevel 1 goto errasm

if not exist rsrc.obj goto nores

\masm32\bin\Link /SUBSYSTEM:CONSOLE "fs.obj" rsrc.res
 if errorlevel 1 goto errlink

dir "fs.*"
goto TheEnd

:nores
 \masm32\bin\Link /SUBSYSTEM:CONSOLE "fs.obj"
 if errorlevel 1 goto errlink
dir "fs.*"
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
