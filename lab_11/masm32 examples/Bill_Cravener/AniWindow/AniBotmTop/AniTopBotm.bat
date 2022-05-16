@echo off
: -------------------------------
: if resources exist, build them
: -------------------------------
if not exist AniTopBotm_rc.rc goto over1
\MASM32\BIN\Rc.exe /v AniTopBotm_rc.rc
\MASM32\BIN\Cvtres.exe /machine:ix86 AniTopBotm_rc.res
:over1

if exist %1.obj del AniTopBotm.obj
if exist %1.exe del AniTopBotm.exe

: -----------------------------------------
: assemble AniTopBotm.asm into an OBJ file
: -----------------------------------------
\MASM32\BIN\Ml.exe /c /coff AniTopBotm.asm
if errorlevel 1 goto errasm

if not exist AniTopBotm_rc.obj goto nores

: --------------------------------------------------
: link the main OBJ file with the resource OBJ file
: --------------------------------------------------
\MASM32\BIN\Link.exe /SUBSYSTEM:WINDOWS AniTopBotm.obj AniTopBotm_rc.obj
if errorlevel 1 goto errlink

dir AniTopBotm.*

goto TheEnd

:errlink
: ----------------------------------------------------
: display message if there is an error during linking
: ----------------------------------------------------
echo.
echo There has been an error while linking this project.
echo.
goto TheEnd

:errasm
: -----------------------------------------------------
: display message if there is an error during assembly
: -----------------------------------------------------
echo.
echo There has been an error while assembling this project.
echo.
goto TheEnd

:TheEnd
pause
