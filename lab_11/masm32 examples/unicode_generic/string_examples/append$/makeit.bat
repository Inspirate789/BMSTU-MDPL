@echo off

if not exist rsrc.rc goto over1
\masm32\bin\rc /v rsrc.rc
\masm32\bin\cvtres /machine:ix86 rsrc.res
 :over1
 
if exist "append$.obj" del "append$.obj"
if exist "append$.exe" del "append$.exe"

\masm32\bin\ml /c /coff "append$.asm"
if errorlevel 1 goto errasm

if not exist rsrc.obj goto nores

\masm32\bin\Link /SUBSYSTEM:CONSOLE /OPT:NOREF "append$.obj" rsrc.res
 if errorlevel 1 goto errlink

dir "append$.*"
goto TheEnd

:nores
 \masm32\bin\Link /SUBSYSTEM:CONSOLE /OPT:NOREF "append$.obj"
 if errorlevel 1 goto errlink
dir "append$.*"
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
