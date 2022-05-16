@echo off

if not exist rsrc.rc goto over1
\masm32\bin\rc /v rsrc.rc
\masm32\bin\cvtres /machine:ix86 rsrc.res
 :over1
 
if exist "rs.obj" del "rs.obj"
if exist "rs.exe" del "rs.exe"

\masm32\bin\ml /c /coff "rs.asm"
if errorlevel 1 goto errasm

if not exist rsrc.obj goto nores

\masm32\bin\Link /SUBSYSTEM:CONSOLE "rs.obj" rsrc.res
 if errorlevel 1 goto errlink

dir "rs.*"
goto TheEnd

:nores
 \masm32\bin\Link /SUBSYSTEM:CONSOLE "rs.obj"
 if errorlevel 1 goto errlink
dir "rs.*"
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
