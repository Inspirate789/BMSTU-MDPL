@echo off
\masm32\bin\ml /c /coff lcd.asm
\masm32\bin\rc lcd.rc
\masm32\bin\link /subsystem:windows lcd.obj lcd.res
pause