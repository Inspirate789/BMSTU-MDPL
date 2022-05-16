@echo off
cls
\MASM32\Bin\ML.EXE /coff /c "MemInfoMicro.asm"
if not %errorlevel%==0 goto compileerror

\masm32\bin\polink.exe /SUBSYSTEM:WINDOWS /MERGE:.data=.text /SECTION:.text,rwe "MemInfoMicro.obj" > nul
if not %errorlevel%==0 goto linkerror

:done
set  axerrstr=
dir MemInfoMicro.*
pause
exit

:compileerror
set axerrstr=Compiling
goto error

:linkerror
set axerrstr=Linking
goto error

:error
cls
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo 		Error on %axerrstr% the Program!
echo.
echo 		Press "any" key to exit...
pause>nul
set  axerrstr=
