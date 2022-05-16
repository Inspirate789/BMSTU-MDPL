@echo off

if exist minimum.obj del minimum.obj
if exist minimum.exe del minimum.exe

\masm32\bin\ml /c /coff /nologo minimum.asm
\masm32\bin\Link /SUBSYSTEM:WINDOWS /MERGE:.rdata=.text minimum.obj > nul

dir minimum.*

pause
