@echo off

    if exist "bubble.obj" del "bubble.obj"
    if exist "bubble.exe" del "bubble.exe"
    
    \masm32\bin\ml /c /coff "bubble.asm"
    if errorlevel 1 goto errasm
    
    \masm32\bin\Link /SUBSYSTEM:CONSOLE "bubble.obj"
    if errorlevel 1 goto errlink
    dir "bubble.*"
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
