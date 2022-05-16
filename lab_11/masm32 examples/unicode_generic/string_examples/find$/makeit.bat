@echo off

if not exist rsrc.rc goto over1
\masm32\bin\rc /v rsrc.rc
\masm32\bin\cvtres /machine:ix86 rsrc.res
 :over1
 
if exist "find$.obj" del "find$.obj"
if exist "find$.exe" del "find$.exe"

\masm32\bin\ml /c /coff "find$.asm"
if errorlevel 1 goto errasm

if not exist rsrc.obj goto nores

\masm32\bin\Link /SUBSYSTEM:CONSOLE /OPT:NOREF "find$.obj" rsrc.res
 if errorlevel 1 goto errlink

dir "find$.*"
goto TheEnd

:nores
 \masm32\bin\Link /SUBSYSTEM:CONSOLE /OPT:NOREF "find$.obj"
 if errorlevel 1 goto errlink
dir "find$.*"
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
