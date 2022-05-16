@echo off
if exist vtdll.obj del vtdll.obj
if exist vtdll.dll del vtdll.dll
\masm32\bin\ml /c /coff vtdll.asm
\masm32\bin\Link /SUBSYSTEM:WINDOWS /DLL /DEF:vtdll.def vtdll.obj 
del vtdll.obj
del vtdll.exp
dir vtdll.*
pause
