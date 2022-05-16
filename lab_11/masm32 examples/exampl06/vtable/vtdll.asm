; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

; This DLL shows how to construct a virtual table of procedures that are
; not EXPORTED but have their starting addresses contained in the table.
; The ONLY EXPORT is the "vtquery" procedure which returns the address of
; tthe virtual table to the calling app.

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

      .486                      ; create 32 bit code
      .model flat, stdcall      ; 32 bit memory model
      option casemap :none      ; case sensitive 

;     include files
;     ~~~~~~~~~~~~~
      include \masm32\include\windows.inc
      include \masm32\include\masm32.inc
      include \masm32\include\gdi32.inc
      include \masm32\include\user32.inc
      include \masm32\include\kernel32.inc
      include \masm32\include\Comctl32.inc
      include \masm32\include\comdlg32.inc
      include \masm32\include\shell32.inc
      include \masm32\include\oleaut32.inc
      include \masm32\include\dialogs.inc
      include \masm32\macros\macros.asm     ; the macro file

;     libraries
;     ~~~~~~~~~
      includelib \masm32\lib\masm32.lib
      includelib \masm32\lib\gdi32.lib
      includelib \masm32\lib\user32.lib
      includelib \masm32\lib\kernel32.lib
      includelib \masm32\lib\Comctl32.lib
      includelib \masm32\lib\comdlg32.lib
      includelib \masm32\lib\shell32.lib
      includelib \masm32\lib\oleaut32.lib

    ; ----------------------------------------
    ; prototypes for local procedures go here
    ; ----------------------------------------

      GetAbout    PROTO :DWORD,:DWORD
      GetFileProc PROTO :DWORD,:DWORD
      GetUserIP   PROTO :DWORD,:DWORD
      GetUserText PROTO :DWORD,:DWORD

      .data?
        hInstance dd ?

      .code

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

LibMain proc instance:DWORD,reason:DWORD,unused:DWORD 

    .if reason == DLL_PROCESS_ATTACH
      push instance
      pop hInstance
      mov eax, TRUE

    .elseif reason == DLL_PROCESS_DETACH

    .elseif reason == DLL_THREAD_ATTACH

    .elseif reason == DLL_THREAD_DETACH

    .endif

    ret

LibMain endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

vtquery proc

  ; -------------------------------------------
  ; construct the virtual table here. Each name
  ; is resolved to its address in the DLL.
  ; -------------------------------------------
    .data
      vtable dd GetAbout,GetFileProc,GetUserIP,GetUserText
    .code

  ; ----------------------------------------------
  ; return the address of the virtual table in EAX
  ; ----------------------------------------------
    mov eax, OFFSET vtable

    ret

vtquery endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

GetAbout proc hParent:DWORD,instance:DWORD

    invoke AboutBox,hParent,instance,0,chr$("Virtual Table Test"), \
                    chr$("How to write a virtual table DLL"), \
                    chr$("Copyright (c) MASM32 1998-2005")

    ret

GetAbout endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

GetFileProc proc hParent:DWORD,instance:DWORD

    LOCAL buffer[260]:BYTE

    invoke GetFile,hParent,instance,0,chr$("Select A File"),chr$("c:\"),chr$("*.*"),ADDR buffer

    fn MessageBox,hParent,ADDR buffer,"You selected ...",MB_OK

    ret

GetFileProc endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

GetUserIP proc hParent:DWORD,instance:DWORD

    invoke GetIP,hParent,instance,0,chr$("Type in an IP"),chr$("Hi"),chr$("98765432")

    ret

GetUserIP endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

GetUserText proc hParent:DWORD,instance:DWORD

    LOCAL buffer[260]:BYTE

    invoke GetTextInput,hParent,instance,0,chr$("Type in some test"),
                        chr$("Now !"),ADDR buffer

    fn MessageBox,hParent,ADDR buffer,"This is what you typed",MB_OK

    ret

GetUserText endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end LibMain
