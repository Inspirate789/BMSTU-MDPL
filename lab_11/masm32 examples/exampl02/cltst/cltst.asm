; #########################################################################

;   ----------------------------------------------------------------
;   This program will read as many arguments as can be fitted on the
;   command line and will display them as a list in the console. It
;   uses the command line parser function GetCL() and tests from the
;   return value of the function if there is a valid argument to
;   display. Each argument is displayed by the function StdOut().
;
;   It should be built with the "Console Assemble & Link" option on
;   the project menu.
;   ----------------------------------------------------------------

      .386
      .model flat, stdcall
      option casemap :none   ; case sensitive

; #########################################################################

      include \masm32\include\windows.inc

      include \masm32\include\user32.inc
      include \masm32\include\kernel32.inc
      include \masm32\include\masm32.inc

      includelib \masm32\lib\user32.lib
      includelib \masm32\lib\kernel32.lib
      includelib \masm32\lib\masm32.lib

      Main   PROTO

; #########################################################################

    .data
      lf          db 13,10,0
      Msg1        db "Command line arguments",13,10,13,10,0
      arg         db "arg ",0
      spc         db " = ",0

; #########################################################################

    .code

    start:
      invoke Main
      invoke ExitProcess,0

; #########################################################################

Main proc

    LOCAL cmdBuffer[128]:BYTE
    LOCAL cntBuffer[8]
    LOCAL cnt :DWORD

    mov cnt, 0

    invoke ClearScreen
    invoke StdOut,ADDR Msg1

  @@:
    invoke GetCL,cnt,ADDR cmdBuffer
    cmp eax, 1
    jne @F
    invoke dwtoa,cnt,ADDR cntBuffer
    invoke StdOut,ADDR arg
    invoke StdOut,ADDR cntBuffer
    invoke StdOut,ADDR spc
    invoke StdOut,ADDR cmdBuffer
    invoke StdOut,ADDR lf  
    inc cnt
    jmp @B
  @@:

    ret

Main endp

; #########################################################################

    end start