@echo off

if not exist rsrc.rc goto over1
\masm32\bin\porc.exe /v rsrc.rc
:over1

if exist runcpl.obj del runcpl.obj
if exist runcpl.exe del runcpl.exe

\masm32\bin\poasm.exe /V2 runcpl.asm
if errorlevel 1 goto errasm

\masm32\BIN\PoLink.exe /SUBSYSTEM:WINDOWS /merge:.data=.text /merge:.rsrc=.text runcpl.obj > nul
if errorlevel 1 goto errlink

del runcpl.obj > nul

dir runcpl.*
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

