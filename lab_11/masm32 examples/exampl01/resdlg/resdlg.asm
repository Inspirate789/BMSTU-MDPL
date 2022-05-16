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

        ;=============
        ; Local macros
        ;=============
  
        szText MACRO Name, Text:VARARG
          LOCAL lbl
            jmp lbl
              Name db Text,0
            lbl:
          ENDM
          
        ;=================
        ; Local prototypes
        ;=================
        WndProc PROTO :DWORD,:DWORD,:DWORD,:DWORD
        
    .data
        dlgname       db "TESTWIN",0
        hInstance     dd 0

    .code

start:

; #########################################################################

        invoke GetModuleHandle, NULL
        mov hInstance, eax
        
        ; -------------------------------------------
        ; Call the dialog box stored in resource file
        ; -------------------------------------------
        invoke DialogBoxParam,hInstance,ADDR dlgname,0,ADDR WndProc,0

        invoke ExitProcess,eax

; #########################################################################

WndProc proc hWin   :DWORD,
             uMsg   :DWORD,
             wParam :DWORD,
             lParam :DWORD

      .if uMsg == WM_INITDIALOG
        szText dlgTitle,"Demo dialog box"
        invoke SendMessage,hWin,WM_SETTEXT,0,ADDR dlgTitle

      .elseif uMsg == WM_CLOSE
        invoke EndDialog,hWin,0

      .endif

    xor eax, eax
    ret

WndProc endp

; ########################################################################

end start
