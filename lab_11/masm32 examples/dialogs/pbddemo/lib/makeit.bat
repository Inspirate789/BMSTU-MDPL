@echo off

echo        Assembling library module.
echo.
\masm32\bin\ml /c /coff *.asm
\masm32\bin\lib *.obj /out:dlglib.lib

del *.obj
dir *.lib

pause
@echo off
