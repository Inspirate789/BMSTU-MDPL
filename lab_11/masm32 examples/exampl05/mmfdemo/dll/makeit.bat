@echo off

if exist mmfdll.obj del mmfdll.obj
if exist mmfdll.dll del mmfdll.dll

\masm32\bin\ml /c /coff mmfdll.asm

\masm32\bin\Link /SUBSYSTEM:WINDOWS /DLL /DEF:mmfdll.def mmfdll.obj

dir mmfdll.*

pause