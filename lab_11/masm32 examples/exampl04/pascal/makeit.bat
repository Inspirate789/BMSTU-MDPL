@echo off
\masm32\bin\ml /c /coff Pascal.asm
\masm32\bin\Link /MERGE:.text=.rdata /SUBSYSTEM:WINDOWS Pascal.obj
dir pascal.*
pause
