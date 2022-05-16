@echo off

if exist smc.obj del smc.obj
if exist smc.exe del smc.exe

\masm32\bin\ml /c /coff smc.asm
if errorlevel 1 goto errasm

if not exist rsrc.obj goto nores

\masm32\bin\Link /SUBSYSTEM:WINDOWS /section:.text,RWE smc.obj rsrc.obj
if errorlevel 1 goto errlink

dir smc
goto TheEnd

:nores
\masm32\bin\Link /SUBSYSTEM:WINDOWS /section:.text,RWE smc.obj
if errorlevel 1 goto errlink
dir smc
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
