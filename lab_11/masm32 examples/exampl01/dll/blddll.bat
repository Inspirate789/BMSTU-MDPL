@echo off

if exist tstdll.obj del tstdll.obj
if exist tstdll.dll del tstdll.dll

\masm32\bin\ml /c /coff tstdll.asm

\masm32\bin\Link /SUBSYSTEM:WINDOWS /DLL /DEF:tstdll.def tstdll.obj

dir tstdll.*

pause