@echo off

echo        Assembling library modules.
echo.
\masm32\bin\ml /c /coff *.asm
\masm32\bin\lib *.obj /out:btest.lib

dir makefont.*

@echo off
