@echo off

if not exist rsrc.rc goto over1
\masm32\bin\porc.exe /v rsrc.rc
:over1 

if exist template.obj del dlltst.obj
if exist template.exe del dlltst.exe

\masm32\bin\poasm.exe /V2 dlltst.asm
if errorlevel 1 goto errasm

\masm32\bin\polink.exe /SUBSYSTEM:WINDOWS dlltst.obj /merge:.data=.text /merge:.rsrc=.text rsrc.res > nul
if errorlevel 1 goto errlink

dir dlltst.*
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
