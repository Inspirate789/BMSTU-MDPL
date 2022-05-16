@echo off
cls
echo.

echo    ** Linking smalled.lib
echo.
\masm32\bin\link -lib "*.obj" "/out:smalled.lib" 
dir *.lib
pause
