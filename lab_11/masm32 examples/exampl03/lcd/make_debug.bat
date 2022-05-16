@echo off
ml /Zi /c /coff lcd.asm
rc lcd.rc
link /debug /debugtype:CV /subsystem:windows lcd.obj lcd.res
pause>nul