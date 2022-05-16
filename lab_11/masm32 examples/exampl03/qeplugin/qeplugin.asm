; #########################################################################

; -------------------------------------------------------------------------
;             Documented interface for Quick Editor plugins.
; -------------------------------------------------------------------------

; This DLL is a skeleton for creating Quick Editor plugins. The "QePlugIn"
; procedure is the only one that is called by Quick Editor and it is a
; single call that does not wait for a return value. Quick Editor uses
; LoadLibrary() and GetProcAddress() to find this procedure and will
; display an error message if it cannot find the DLL or the correct
; procedure in it.

; You will need to properly understand the messaging and similar capacity
; of a richedit1 control to take advantage of this DLL interface. Be careful
; when writing this type of plugin, Quick Editor has been hammered to death
; to make it robust but direct access into its operations can crash Quick
; Editor if the plugin is not written correctly.

; Note that QE 4.0 uses a rich edit 2 or later which uses the ASCII 13
; internally without an ASCII 10 and this effects the assumption of code
; being read from the editor with richedit selection. If you need to
; select text from the editor, it will be line terminated with the ASCII 13
; only

; #########################################################################

    .386
    .model flat, stdcall
    option casemap :none   ; case sensitive

; #########################################################################

    include \masm32\include\windows.inc
    include \masm32\include\user32.inc
    include \masm32\include\kernel32.inc
    include \MASM32\include\oleaut32.inc

    includelib \masm32\lib\user32.lib
    includelib \masm32\lib\kernel32.lib
    includelib \MASM32\LIB\oleaut32.lib

; #########################################################################

    stralloc MACRO ln
      invoke SysAllocStringByteLen,0,ln
    ENDM

    strfree MACRO strhandle
      invoke SysFreeString,strhandle
    ENDM

    szText MACRO Name, Text:VARARG
      LOCAL lbl
        jmp lbl
          Name db Text,0
        lbl:
      ENDM

    m2m MACRO M1, M2
      push M2
      pop  M1
    ENDM

    return MACRO arg
      mov eax, arg
      ret
    ENDM

  ; -----------
  ; not needed
  ; -----------
    LibMain  PROTO :DWORD,:DWORD,:DWORD
    QePlugIn PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD

.code

; ##########################################################################

LibMain proc hInstDLL:DWORD, reason:DWORD, unused:DWORD

        .if reason == DLL_PROCESS_ATTACH

            return TRUE
          ; -----------------------------
          ; If error at startup, return 0
          ; System will abort loading DLL
          ; -----------------------------

 ;         ---------------------
 ;          uncomment if needed
 ;         ---------------------
 ;         .elseif reason == DLL_PROCESS_DETACH
 ; 
 ;         .elseif reason == DLL_THREAD_ATTACH
 ; 
 ;         .elseif reason == DLL_THREAD_DETACH
            
        .endif

        ret

LibMain Endp

; ##########################################################################

QePlugIn proc hInst:DWORD,hMain:DWORD,hEd:DWORD,hTool:DWORD,hStat:DWORD

 ;     hInst    =   instance handle
 ;     hMain    =   main window handle
 ;     hEd      =   rich edit control handle
 ;     hTool    =   toolbar handle
 ;     hStat    =   status bar handle

    LOCAL hMem:DWORD
    LOCAL Cr:CHARRANGE

    szText plugin,"Quick Editor Plugin"

    invoke SendMessage,hEd,EM_EXGETSEL,0,ADDR Cr    ; get selection

  ; -------------------------------------------------
  ; compare CHARRANGE to see if any text is selected
  ; -------------------------------------------------
    mov eax, Cr.cpMin
    cmp Cr.cpMax, eax
    jne @F

    szText noSelection,"Sorry, no text is selected"
    invoke MessageBox,hEd,ADDR noSelection,ADDR plugin,MB_OK
    jmp Bye

  @@:
  ; -------------------------
  ; get selected text length
  ; -------------------------
    mov eax, Cr.cpMin
    mov edx, Cr.cpMax
    sub edx, eax

  ; -----------------------
  ; allocate string memory
  ; -----------------------
    stralloc edx
    mov hMem, eax

    invoke SendMessage,hEd,EM_GETSELTEXT,0,hMem
    invoke MessageBox,hEd,hMem,ADDR plugin,MB_OK

  ; -------------------
  ; free string memory
  ; -------------------
    strfree hMem

  Bye:

    ret

QePlugIn endp

; ##########################################################################

End LibMain