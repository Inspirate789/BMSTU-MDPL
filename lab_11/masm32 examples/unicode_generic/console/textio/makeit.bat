@echo off

if not exist rsrc.rc goto over1
\masm32\bin\rc /v rsrc.rc
\masm32\bin\cvtres /machine:ix86 rsrc.res
 :over1
 
if exist "textio.obj" del "textio.obj"
if exist "textio.exe" del "textio.exe"

\masm32\bin\ml /c /coff "textio.asm"
if errorlevel 1 goto errasm

if not exist rsrc.obj goto nores

\masm32\bin\Link /SUBSYSTEM:CONSOLE /OPT:NOREF "textio.obj" rsrc.res
 if errorlevel 1 goto errlink

dir "textio.*"
goto TheEnd

:nores
 \masm32\bin\Link /SUBSYSTEM:CONSOLE /OPT:NOREF "textio.obj"
 if errorlevel 1 goto errlink
dir "textio.*"
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
