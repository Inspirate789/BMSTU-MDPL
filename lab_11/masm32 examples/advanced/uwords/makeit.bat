@echo off

if not exist rsrc.rc goto over1
\masm32\bin\rc /v rsrc.rc
\masm32\bin\cvtres /machine:ix86 rsrc.res
 :over1
 
if exist "uwords.obj" del "uwords.obj"
if exist "uwords.exe" del "uwords.exe"

\masm32\bin\ml /c /coff "uwords.asm"
if errorlevel 1 goto errasm

if not exist rsrc.obj goto nores

\masm32\bin\Link /SUBSYSTEM:CONSOLE "uwords.obj" rsrc.res
 if errorlevel 1 goto errlink

dir "uwords.*"
goto TheEnd

:nores
 \masm32\bin\Link /SUBSYSTEM:CONSOLE "uwords.obj"
 if errorlevel 1 goto errlink
dir "uwords.*"
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
