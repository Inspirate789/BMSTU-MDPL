; #########################################################################

;   -------------------------------------------------------------------
;   This program uses the FindFirstFile() FindNextFile() API functions
;   to perform a directory list search which is displayed at the console.
;
;   This file should be built with the "Console assemble & link" option
;   on the project menu.
;   -------------------------------------------------------------------

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
      wCard       db "*.*",0
      notfound    db "File not found",13,10,0
      spc         db " ",0
      bytes       db " bytes",0
      fMtStrinG   db "%lu",0


; #########################################################################

    .code

    start:
      invoke Main
      invoke ExitProcess,0

; #########################################################################

Main proc

    LOCAL hSearch :DWORD            ; search handle
    LOCAL sizeBuffer[16]:BYTE
    LOCAL fBuffer[256]:BYTE         ; file name buffer
    LOCAL clBuffer[128]:BYTE        ; command line buffer
    LOCAL wfd :WIN32_FIND_DATA

    invoke GetCL,1,ADDR clBuffer    ; get arg 1
    .if eax != 1                    ; if no arg
      mov ecx, LENGTHOF wCard       ; copy *.* into
      mov esi, offset wCard         ; clBuffer
      lea edi, clBuffer
      rep movsb
    .endif

    invoke FindFirstFile,ADDR clBuffer,ADDR wfd
    .if eax == INVALID_HANDLE_VALUE
      invoke StdOut,ADDR notfound   ; display "not found" message
      jmp TheEnd
    .else
      mov hSearch, eax
    .endif
    invoke StdOut,ADDR wfd.cFileName
      mov al, [wfd.cFileName]
      cmp al, "."
      je nxt
    invoke StdOut,ADDR spc
    invoke wsprintf,ADDR sizeBuffer,ADDR fMtStrinG,wfd.nFileSizeLow
    invoke StdOut,ADDR sizeBuffer
    invoke StdOut,ADDR bytes
  nxt:
    invoke StdOut,ADDR lf
  @@:
    invoke FindNextFile,hSearch,ADDR wfd
    cmp eax, 0
    je lpOut
    invoke StdOut,ADDR wfd.cFileName
      mov al, [wfd.cFileName]
      cmp al, "."
      je nxt1
    invoke StdOut,ADDR spc
    invoke wsprintf,ADDR sizeBuffer,ADDR fMtStrinG,wfd.nFileSizeLow
    invoke StdOut,ADDR sizeBuffer
    invoke StdOut,ADDR bytes
  nxt1:
    invoke StdOut,ADDR lf
    jmp @B

  lpOut:
    invoke FindClose,hSearch

  TheEnd:

    ret

Main endp

; #########################################################################

    end start