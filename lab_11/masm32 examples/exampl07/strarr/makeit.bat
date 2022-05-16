@echo off

if not exist rsrc.rc goto over1
\masm32\bin\rc /v rsrc.rc
\masm32\bin\cvtres /machine:ix86 rsrc.res
 :over1
 
if exist "strarr.obj" del "strarr.obj"
if exist "strarr.exe" del "strarr.exe"

\masm32\bin\ml /c /coff "strarr.asm"
if errorlevel 1 goto errasm

if not exist rsrc.obj goto nores

\masm32\bin\PoLink /SUBSYSTEM:WINDOWS "strarr.obj" rsrc.res
 if errorlevel 1 goto errlink

dir "strarr.*"
goto TheEnd

:nores
 \masm32\bin\PoLink /SUBSYSTEM:WINDOWS "strarr.obj"
 if errorlevel 1 goto errlink
dir "strarr.*"
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
