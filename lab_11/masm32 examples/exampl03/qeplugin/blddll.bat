@echo off

if exist qeplugin.obj del qeplugin.obj
if exist qeplugin.dll del qeplugin.dll

\masm32\bin\ml /c /coff qeplugin.asm

\masm32\bin\Link /SUBSYSTEM:WINDOWS /DLL /DEF:qeplugin.def qeplugin.obj

dir qeplugin.*

pause