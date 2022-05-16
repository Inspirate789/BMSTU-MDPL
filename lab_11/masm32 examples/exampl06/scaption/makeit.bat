@echo off

if not exist rsrc.rc goto over1
\masm32\bin\rc /v rsrc.rc
\masm32\bin\cvtres /machine:ix86 rsrc.res
 :over1
 
if exist "scaption.obj" del "scaption.obj"
if exist "scaption.exe" del "scaption.exe"

\masm32\bin\ml /c /coff "scaption.asm"
if errorlevel 1 goto errasm

if not exist rsrc.obj goto nores

\masm32\bin\Link /SUBSYSTEM:WINDOWS "scaption.obj" rsrc.res
 if errorlevel 1 goto errlink

dir "scaption.*"
goto TheEnd

:nores
 \masm32\bin\Link /SUBSYSTEM:WINDOWS "scaption.obj"
 if errorlevel 1 goto errlink
dir "scaption.*"
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
