@echo off

if exist "sa.obj" del "sa.obj"
if exist "sa.exe" del "sa.exe"

\masm32\bin\ml /c /coff "sa.asm"
\masm32\bin\PoLink /SUBSYSTEM:CONSOLE "sa.obj"
dir "sa.*"
 
pause
