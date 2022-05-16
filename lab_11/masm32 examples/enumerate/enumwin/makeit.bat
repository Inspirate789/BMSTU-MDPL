@echo off

if not exist rsrc.rc goto over1
\masm32\bin\rc /v rsrc.rc
\masm32\bin\cvtres /machine:ix86 rsrc.res
:over1
 
if exist "enumwin.obj" del "enumwin.obj"
if exist "enumwin.exe" del "enumwin.exe"

\masm32\bin\ml /c /coff "enumwin.asm"
if errorlevel 1 goto errasm

if not exist rsrc.obj goto nores

\masm32\bin\PoLink /SUBSYSTEM:WINDOWS /merge:.data=.text /merge:.rsrc=.text "enumwin.obj" rsrc.res > nul
 if errorlevel 1 goto errlink

dir "enumwin.*"
goto TheEnd

:nores
 \masm32\bin\PoLink /SUBSYSTEM:WINDOWS /merge:.data=.text /merge:.rsrc=.text "enumwin.obj" > nul
 if errorlevel 1 goto errlink
dir "enumwin.*"
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
