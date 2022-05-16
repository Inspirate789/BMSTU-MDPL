@echo off

\MASM32\BIN\Rc.exe /v rsrc.rc

if exist Richedit.obj del Richedit.obj
if exist Richedit.exe del Richedit.exe

: ----------------------------------------------------------------
: shuffle the text files and write the results as asm source files
: ----------------------------------------------------------------
sa includes.txt includes.asm           : shuffle source code
sa idat.txt idat.asm                   : shuffle initialised data
sa udat.txt udat.asm                   : shuffle uninitialised data

\MASM32\BIN\Ml.exe /c /coff Richedit.asm
if errorlevel 1 goto errasm

\MASM32\BIN\PoLink.exe /SUBSYSTEM:WINDOWS Richedit.obj rsrc.res
if errorlevel 1 goto errlink

dir Richedit.*
goto TheEnd

:errlink
echo _
echo Link error
goto TheEnd

:errasm
echo _
echo Assembly Error
goto TheEnd

:TheEnd

pause

