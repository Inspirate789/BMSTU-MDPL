; #########################################################################

      .386
      .model flat, stdcall
      option casemap :none   ; case sensitive

; #########################################################################

    ; ------------------------------
    ; Build this app in console mode.
    ; ------------------------------

      include \masm32\include\windows.inc

      include \masm32\include\user32.inc
      include \masm32\include\kernel32.inc
      include \masm32\include\masm32.inc

      includelib \masm32\lib\user32.lib
      includelib \masm32\lib\kernel32.lib
      includelib \masm32\lib\masm32.lib

    ; ------------
    ; Local macros
    ; ------------
      print MACRO Quoted_Text:VARARG
        LOCAL Txt
          .data
            Txt db Quoted_Text,0
          .code
        invoke StdOut,ADDR Txt
      ENDM

      input MACRO Quoted_Prompt_Text:VARARG
        LOCAL Txt
        LOCAL Buffer
          .data
            Txt db Quoted_Prompt_Text,0
            Buffer db 128 dup(?)
          .code
        invoke StdOut,ADDR Txt
        invoke StdIn,ADDR Buffer,LENGTHOF Buffer
        mov eax, offset Buffer
      ENDM

      cls MACRO
        invoke ClearScreen
      ENDM

      Main   PROTO

; #########################################################################

    .data
      Msg1        db "Type something > ",0
      Msg2        db "You typed > ",0

; #########################################################################

    .code

    start:
      invoke Main
      invoke ExitProcess,0

; #########################################################################

Main proc

    LOCAL InputBuffer[128]:BYTE

  ; -------------------------------
  ; console mode library procedures
  ; -------------------------------

  ; ------------
  ; using macros
  ; ------------

    cls
    print "Console function test",13,10,13,10

    input "Enter Some Text > "
    invoke StdOut,eax           ; return address in eax

  ; ----------------
  ; using procedures
  ; ----------------
  
    invoke locate,10,10
    invoke StdOut,ADDR Msg1 
    invoke StdIn,ADDR InputBuffer,LENGTHOF InputBuffer

    invoke locate,10,11 
    invoke StdOut,ADDR Msg2
    invoke StdOut,ADDR InputBuffer

    ret

Main endp

; #########################################################################

    end start