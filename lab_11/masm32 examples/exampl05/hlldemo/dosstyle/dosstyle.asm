; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

;   Build this demo with the "Console Assemble & Link" option. It will
;   crash if you forget and build it as a GUI app and run it.

    .486
    .model flat, stdcall
    option casemap :none   ; case sensitive

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    include \masm32\include\windows.inc
    include \masm32\include\masm32.inc
    include \masm32\include\user32.inc
    include \masm32\include\kernel32.inc
    include \masm32\include\gdi32.inc
    include \masm32\include\msvcrt.inc
    include \masm32\macros\macros.asm

    includelib \masm32\lib\masm32.lib
    includelib \masm32\lib\user32.lib
    includelib \masm32\lib\kernel32.lib
    includelib \masm32\lib\gdi32.lib
    includelib \masm32\lib\msvcrt.lib

    main PROTO

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    .code

start:

    call main

    exit

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

main proc

    LOCAL str1:DWORD
    LOCAL str2:DWORD
    LOCAL rslt:DWORD
    LOCAL buffer1[32]:BYTE
    LOCAL buffer2[32]:BYTE

    mov str1, ptr$(buffer1)
    mov str2, ptr$(buffer2)

    cls

    print cmd$(1)

    loc 10, 6
    print "Hi folks, this is a demo of MASM32 console mode macros"

    loc 10, 8
    mov str1, input("Enter a number : ")

    loc 10, 10
    mov str2, input("Enter another number : ")

    push esi
    mov esi, uval(str1)
    add esi, uval(str2)
    mov rslt, ustr$(esi)
    pop esi

    loc 10, 12
    print "Result = "
    print rslt

    loc 10, 14
    print "Current directory is : "
    print CurDir$()

    mkdir "dirtest1"
    chdir "dirtest1"
    mkdir "dirtest2"
    chdir "dirtest2"

    loc 10, 16
    print "Current directory is : "
    print CurDir$()

    chdir ".."
    rmdir "dirtest2"
    chdir ".."
    rmdir "dirtest1"

    loc 10, 18
    print "Current directory is : "
    print CurDir$()

    loc 10, 20
    mov str1, input("Press enter to exit ....")

    cls

    ret

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start