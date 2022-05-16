@echo off

if not exist rsrc.rc goto over1
\masm32\bin\rc /v rsrc.rc
\masm32\bin\cvtres /machine:ix86 rsrc.res
 :over1
 
if exist "qikpad.obj" del "qikpad.obj"
if exist "qikpad.exe" del "qikpad.exe"

\masm32\bin\ml /c /coff "qikpad.asm"
if errorlevel 1 goto errasm

if not exist rsrc.obj goto nores

\masm32\bin\Link /SUBSYSTEM:WINDOWS "qikpad.obj" rsrc.res
 if errorlevel 1 goto errlink

dir "qikpad.*"
goto TheEnd

:nores
 \masm32\bin\Link /SUBSYSTEM:WINDOWS "qikpad.obj"
 if errorlevel 1 goto errlink
dir "qikpad.*"
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
