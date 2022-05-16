@echo off
if exist %1.obj del slickhuh.obj
if exist %1.exe del slickhuh.exe
\masm32\bin\ml.exe /c /coff slickhuh.asm
\masm32\BIN\PoLink.exe /SUBSYSTEM:WINDOWS /merge:.text=.slik /merge:.data=.slik slickhuh.obj
dir slickhuh.*
pause
