@echo off

if not exist rsrc.rc goto over1
\masm32\bin\porc.exe /v rsrc.rc
:over1

if exist winenum.obj del winenum.obj
if exist winenum.exe del winenum.exe

\masm32\bin\poasm.exe /V2 winenum.asm
if errorlevel 1 goto errasm

\masm32\BIN\PoLink.exe /SUBSYSTEM:WINDOWS /merge:.data=.text /merge:.rsrc=.text winenum.obj rsrc.res > nul
if errorlevel 1 goto errlink

del winenum.obj > nul

dir winenum.*
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

