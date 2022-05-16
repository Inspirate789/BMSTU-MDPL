@echo off

if exist %1.obj del MemFree.obj
if exist %1.exe del MemFree.exe
\MASM32\BIN\Ml.exe /c /coff MemFree.asm
if errorlevel 1 goto errasm
\MASM32\BIN\Link.exe /SUBSYSTEM:WINDOWS MemFree.obj
if errorlevel 1 goto errlink

dir MemFree.*

goto TheEnd

:errlink
echo.
echo There has been an error while linking this project.
echo.
goto TheEnd

:errasm
echo.
echo There has been an error while assembling this project.
echo.
goto TheEnd

:TheEnd

pause
