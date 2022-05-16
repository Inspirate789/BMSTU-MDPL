@echo off

if not exist rsrc.rc goto over1
\masm32\bin\rc /v rsrc.rc
\masm32\bin\cvtres /machine:ix86 rsrc.res
 :over1
 
if exist "pathinfo.obj" del "pathinfo.obj"
if exist "pathinfo.exe" del "pathinfo.exe"

\masm32\bin\ml /c /coff "pathinfo.asm"
if errorlevel 1 goto errasm

if not exist rsrc.obj goto nores

\masm32\bin\Link /SUBSYSTEM:CONSOLE "pathinfo.obj" rsrc.res
 if errorlevel 1 goto errlink

dir "pathinfo.*"
goto TheEnd

:nores
 \masm32\bin\Link /SUBSYSTEM:CONSOLE "pathinfo.obj"
 if errorlevel 1 goto errlink
dir "pathinfo.*"
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
