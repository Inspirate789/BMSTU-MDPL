@echo off

if not exist rsrc.rc goto over1
\masm32\bin\rc /v rsrc.rc
\masm32\bin\cvtres /machine:ix86 rsrc.res
 :over1
 
if exist "gettext.obj" del "gettext.obj"
if exist "gettext.exe" del "gettext.exe"

\masm32\bin\ml /c /coff "gettext.asm"
if errorlevel 1 goto errasm

if not exist rsrc.obj goto nores

\masm32\bin\Link /SUBSYSTEM:WINDOWS "gettext.obj" rsrc.res
 if errorlevel 1 goto errlink

dir "gettext.*"
goto TheEnd

:nores
 \masm32\bin\Link /SUBSYSTEM:WINDOWS "gettext.obj"
 if errorlevel 1 goto errlink
dir "gettext.*"
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
