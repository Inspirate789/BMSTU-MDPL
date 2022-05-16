; #########################################################################
;
;   SMC.ASM is a test piece for reading and writing to the code section
;   of a PE file. In this example, there are two procedures, one which
;   is called, the second that is read and written at the address
;   of the first. The proc is called twice, before & after the code has
;   been modified.
;
;   This is made possible by using the link option "/section:.text,RWE"
;   which sets the code section as read/write/execute. This file should
;   be built with the supplied "build.bat"
;
;   Iczelion assisted in the development of this example.
;
; #########################################################################

      .386
      .model flat, stdcall
      option casemap :none   ; case sensitive

; #########################################################################

      include \masm32\include\windows.inc
      include \masm32\include\user32.inc
      include \masm32\include\kernel32.inc

      includelib \masm32\lib\user32.lib
      includelib \masm32\lib\kernel32.lib

      CalledProc PROTO
      ReplaceMentProc  PROTO

; #########################################################################

    .data
        lnth1       dd 0
        szDlgTitle  db "SMC example",0
        Phony       db "This is 1st call of proc",0
        Replc       db "This is 2nd call of proc",0
        ttl1        db "Original Code",0
        ttl2        db "Replacement Code",0

; #########################################################################
    
    .code

start:

    invoke CalledProc   ; call proc as written
    
    lea eax, rpEnd      ; end label of 2nd proc
    lea edx, rpStart    ; start label of 2nd proc
    sub eax, edx        ; get offset differences
    mov lnth1, eax      ; save the length

    lea esi, rpStart    ; load address of 2nd proc
    lea edi, ppStart    ; load address of 1st proc
    mov ecx, lnth1      ; put length of 2nd proc in ecx
    rep movsb           ; write code from 2nd proc to address of 1st

    invoke CalledProc   ; call it again after it has been modified

    invoke ExitProcess,0

; #########################################################################

CalledProc proc

    ppStart::   ; labels with [ :: ] are visable GLOBALLY.

    invoke MessageBox,0,ADDR Phony,ADDR ttl1,MB_OK

    ppEnd::

  ; ------------------------------------------------------
  ; The "nop's" are padding to ensure that there is enough
  ; room for the code that is written between the 2 labels
  ; ------------------------------------------------------

    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

    ret

CalledProc endp

; #########################################################################

ReplaceMentProc proc

    ; -----------------------------------
    ; this proc is never called but the
    ; code between the two labels is read
    ; and then written to the address of
    ; the first proc
    ; -----------------------------------

    rpStart::
    
    push MB_OK or MB_ICONEXCLAMATION
    lea eax, ttl2
    push eax
    lea eax, Replc
    push eax
    push 0
    lea eax, MessageBox
    call eax

    rpEnd::

    ret

ReplaceMentProc endp

; #########################################################################

end start