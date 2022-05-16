@echo off
\masm32\bin\poasm /V2 tstdll.asm
\masm32\bin\polink /SUBSYSTEM:WINDOWS /def:tstdll.def /dll tstdll.obj
copy tstdll.dll ..
copy tstdll.lib ..
del tstdll.exp
del tstdll.obj
dir tstdll.*
pause