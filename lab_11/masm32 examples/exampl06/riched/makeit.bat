@echo off

if not exist rsrc.rc goto over1
\MASM32\BIN\Rc.exe /v rsrc.rc
\MASM32\BIN\Cvtres.exe /machine:ix86 rsrc.res
:over1

if exist Richedit.obj del Richedit.obj
if exist Richedit.exe del Richedit.exe

\MASM32\BIN\Ml.exe /c /coff Richedit.asm
if errorlevel 1 goto errasm

if not exist rsrc.obj goto nores

\MASM32\BIN\Link.exe /SUBSYSTEM:WINDOWS Richedit.obj rsrc.obj
if errorlevel 1 goto errlink

dir Richedit.*
goto TheEnd

:nores
\MASM32\BIN\Link.exe /SUBSYSTEM:WINDOWS Richedit.obj
if errorlevel 1 goto errlink
dir Richedit.*
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

