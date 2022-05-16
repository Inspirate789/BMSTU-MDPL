; #########################################################################
;
;          Build this DLL from the batch file called BldDLL.bat
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

; #########################################################################

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

.code

; ##########################################################################

LibMain proc hInstDLL:DWORD, reason:DWORD, unused:DWORD

            szText LmTitle,"tstdll's LibMain Function"

        .if reason == DLL_PROCESS_ATTACH
            szText ATTACHPROCESS,"PROCESS_ATTACH"
            invoke MessageBox,NULL,ADDR ATTACHPROCESS,addr LmTitle,MB_OK

            return TRUE
            ; -----------------------------
            ; If error at startup, return 0
            ; System will abort loading DLL
            ; -----------------------------

        .elseif reason == DLL_PROCESS_DETACH
            szText DETACHPROCESS,"PROCESS_DETACH"
            invoke MessageBox,NULL,addr DETACHPROCESS,addr LmTitle,MB_OK

        .elseif reason == DLL_THREAD_ATTACH
            szText ATTACHTHREAD,"THREAD_ATTACH"
            invoke MessageBox,NULL,addr ATTACHTHREAD,addr LmTitle,MB_OK

        .elseif reason == DLL_THREAD_DETACH
            szText DETACHTHREAD,"THREAD_DETACH"
            invoke MessageBox,NULL,addr DETACHTHREAD,addr LmTitle,MB_OK
            
        .endif

        ret

LibMain Endp

; ##########################################################################

TestProc proc

    jmp @F
      MbTitle db "Test function",0
      MbMsg db "This is tstdll.dll here",0
    @@:

    invoke MessageBox,NULL,addr MbMsg,addr MbTitle,MB_OK

    ret

TestProc endp

; ##########################################################################

End LibMain
