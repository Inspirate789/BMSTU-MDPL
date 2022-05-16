@echo off

if not exist rsrc.rc goto over1
\masm32\bin\rc /v rsrc.rc
\masm32\bin\cvtres /machine:ix86 rsrc.res
 :over1
 
if exist "UnicodeTest_GUI.obj" del "UnicodeTest_GUI.obj"
if exist "UnicodeTest_GUI.exe" del "UnicodeTest_GUI.exe"

\masm32\bin\ml /c /coff "UnicodeTest_GUI.asm"
if errorlevel 1 goto errasm

if not exist rsrc.obj goto nores

\masm32\bin\Link /SUBSYSTEM:WINDOWS "UnicodeTest_GUI.obj" rsrc.res
 if errorlevel 1 goto errlink

dir "UnicodeTest_GUI.*"
goto TheEnd

:nores
 \masm32\bin\Link /SUBSYSTEM:WINDOWS "UnicodeTest_GUI.obj"
 if errorlevel 1 goto errlink
dir "UnicodeTest_GUI.*"
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
