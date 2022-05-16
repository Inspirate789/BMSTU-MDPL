; #########################################################################

      .386
      .model flat, stdcall
      option casemap :none   ; case sensitive

; #########################################################################

      include \masm32\include\windows.inc
      include \masm32\include\user32.inc
      include \masm32\include\kernel32.inc
      include \masm32\include\gdi32.inc
      include \masm32\include\masm32.inc

      includelib \masm32\lib\user32.lib
      includelib \masm32\lib\kernel32.lib
      includelib \masm32\lib\gdi32.lib
      includelib \masm32\lib\masm32.lib

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
        hEdit1      dd 0
        hEdit2      dd 0
        hEdit3      dd 0
        hEdit4      dd 0
        hButn1      dd 0
        hButn2      dd 0
        hInstance   dd 0
        hIconImage  dd 0
        hIcon       dd 0
        dlgname     db "TESTWIN",0

; #########################################################################

    .code

start:

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

      LOCAL Ps :PAINTSTRUCT

      .if uMsg == WM_INITDIALOG
      
        szText dlgTitle," Demo dialog box"
        invoke SendMessage,hWin,WM_SETTEXT,0,ADDR dlgTitle

        invoke LoadIcon,hInstance,200
        mov hIcon, eax

        invoke SendMessage,hWin,WM_SETICON,1,hIcon

        invoke GetDlgItem,hWin,100
        mov hEdit1, eax

        invoke GetDlgItem,hWin,101
        mov hEdit2, eax

        invoke GetDlgItem,hWin,102
        mov hEdit3, eax

        invoke GetDlgItem,hWin,103
        mov hEdit4, eax

        invoke GetDlgItem,hWin,1000
        mov hButn1, eax

        invoke GetDlgItem,hWin,1001
        mov hButn2, eax

        xor eax, eax
        ret

      .elseif uMsg == WM_COMMAND
        .if wParam == 1000
            szText calcMsg,"Calculate Button"
            invoke MessageBox,hWin,ADDR calcMsg,
                              ADDR dlgTitle,MB_OK
        .elseif wParam == 1001
            szText clearMsg,"Clear Button"
            invoke MessageBox,hWin,ADDR clearMsg,
                              ADDR dlgTitle,MB_OK
        .endif

      .elseif uMsg == WM_CLOSE
        invoke EndDialog,hWin,0

      .elseif uMsg == WM_PAINT
        invoke BeginPaint,hWin,ADDR Ps
      ; ----------------------------------------
      ; The following function are in MASM32.LIB
      ; ----------------------------------------
        invoke FrameGrp,hButn1,hButn2,6,1,0
        invoke FrameGrp,hEdit1,hEdit3,4,1,0
        invoke FrameCtrl,hEdit4,4,1,0
        invoke FrameWindow,hWin,0,1,1
        invoke FrameWindow,hWin,1,1,0

        invoke EndPaint,hWin,ADDR Ps
        xor eax, eax
        ret

      .endif

    xor eax, eax    ; this must be here in NT4
    ret

WndProc endp

; ########################################################################

end start
