@echo off

if not exist rsrc.rc goto over1
\masm32\BIN\porc.exe /v rsrc.rc
:over1

if exist %1.obj del fda2.obj
if exist %1.exe del fda2.exe

\masm32\BIN\poasm.exe /V2 fda2.asm
if errorlevel 1 goto errasm

\masm32\BIN\PoLink.exe /SUBSYSTEM:WINDOWS /merge:.data=.text /merge:.rsrc=.text fda2.obj > nul
if errorlevel 1 goto errlink

dir fda2.*
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

