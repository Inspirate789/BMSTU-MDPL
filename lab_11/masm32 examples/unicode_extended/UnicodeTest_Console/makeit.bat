@echo off

if not exist rsrc.rc goto over1
\masm32\bin\rc /v rsrc.rc
\masm32\bin\cvtres /machine:ix86 rsrc.res
 :over1
 
if exist "UnicodeTest_Console.obj" del "UnicodeTest_Console.obj"
if exist "UnicodeTest_Console.exe" del "UnicodeTest_Console.exe"

\masm32\bin\ml /c /coff "UnicodeTest_Console.asm"
if errorlevel 1 goto errasm

if not exist rsrc.obj goto nores

\masm32\bin\Link /SUBSYSTEM:CONSOLE /OPT:NOREF "UnicodeTest_Console.obj" rsrc.res
 if errorlevel 1 goto errlink

dir "UnicodeTest_Console.*"
goto TheEnd

:nores
 \masm32\bin\Link /SUBSYSTEM:CONSOLE /OPT:NOREF "UnicodeTest_Console.obj"
 if errorlevel 1 goto errlink
dir "UnicodeTest_Console.*"
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
