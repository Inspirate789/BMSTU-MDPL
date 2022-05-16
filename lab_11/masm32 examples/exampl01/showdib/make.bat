@echo off

: clean up previous builds
: ~~~~~~~~~~~~~~~~~~~~~~~~
if exist ShowDib2.obj del ShowDib2.obj
if exist Dibfile.obj del Dibfile.obj
if exist ShowDib2.exe del ShowDib2.exe

: test if both modules build OK
: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
\masm32\bin\ml /c /coff ShowDib2.asm
if errorlevel 1 goto errasm1

\masm32\bin\ml /c /coff Dibfile.asm
if errorlevel 1 goto errasm1

: build the .RC file into obj module
: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
\masm32\bin\rc /v rsrc.rc
\masm32\bin\cvtres /machine:ix86 rsrc.res

: link all modules, note that main module is first.
: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
\masm32\bin\Link /SUBSYSTEM:WINDOWS ShowDib2.obj DibFile.obj rsrc.obj
if errorlevel 1 goto LinkErr
goto ShowFiles

:errasm1
echo Incomplete build, assembly error
goto TheEnd

:LinkErr
echo Linking error
goto TheEnd

:ShowFiles
dir ShowDib2.*

:TheEnd













