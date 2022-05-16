@echo off
\masm32\bin\ml /c /coff /Cp VolCtrl.asm
\masm32\bin\link /DLL /DEF:VolCtrl.def /SUBSYSTEM:WINDOWS /LIBPATH:\masm32\lib VolCtrl.obj
pause