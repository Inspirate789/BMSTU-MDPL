@echo off

if not exist rsrc.rc goto over1
\masm32\BIN\porc.exe /v rsrc.rc
:over1

if exist %1.obj del Richedit.obj
if exist %1.exe del Richedit.exe

\masm32\BIN\poasm.exe /V2 Richedit.asm
if errorlevel 1 goto errasm

\masm32\BIN\PoLink.exe /SUBSYSTEM:WINDOWS /merge:.data=.text /merge:.rsrc=.text Richedit.obj rsrc.res > nul
if errorlevel 1 goto errlink

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

del Richedit.obj
del rsrc.res
dir Richedit.*

pause

