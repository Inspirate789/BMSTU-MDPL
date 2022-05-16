; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

      ; __UNICODE__ equ 1

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
      include \masm32\include\msvcrt.inc
      include \masm32\macros\macros.asm

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
      includelib \masm32\lib\msvcrt.lib

      include \masm32\include\dialogs.inc

      DlgProc  PROTO :DWORD,:DWORD,:DWORD,:DWORD
      text_bar PROTO :DWORD

    .data?
      hWnd      dd ?
      hInstance dd ?
      hToolbar  dd ?
      hFont     dd ?

    .code

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

start:
  
      mov hInstance, FUNC(GetModuleHandle,NULL)

      call main

      invoke ExitProcess,eax

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

main proc

    LOCAL icce:INITCOMMONCONTROLSEX
    
    mov icce.dwSize, SIZEOF INITCOMMONCONTROLSEX
    mov icce.dwICC,  ICC_BAR_CLASSES
    invoke InitCommonControlsEx,ADDR icce

    Dialog "Text Toolbar Demo", \           ; caption
           "MS Sans Serif",10, \            ; font,pointsize
            WS_OVERLAPPED or \              ; styles for
            WS_SYSMENU or DS_CENTER, \      ; dialog window
            1, \                            ; number of controls
            50,50,215,100, \                ; x y co-ordinates
            1024                            ; memory buffer size

    DlgStatus 150

    CallModalDialog hInstance,0,DlgProc,NULL

    ret

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

DlgProc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD 

    switch uMsg
      Case WM_INITDIALOG
        invoke SendMessage,hWin,WM_SETICON,1,
                           FUNC(LoadIcon,NULL,IDI_ASTERISK)
        m2m hWnd, hWin

        mov hToolbar, rv(text_bar,hWnd)
        mov hFont, rv(GetStockObject,ANSI_VAR_FONT)
        invoke SendMessage,hToolbar,WM_SETFONT,hFont,TRUE

        return 0

      case WM_COMMAND
        switch wParam
          case 50
            fn MessageBox,hWnd,str$(eax),"Title",MB_OK
          case 51
            fn MessageBox,hWnd,str$(eax),"Title",MB_OK
          case 52
            fn MessageBox,hWnd,str$(eax),"Title",MB_OK
          case 53
            fn MessageBox,hWnd,str$(eax),"Title",MB_OK
          case 54
            fn MessageBox,hWnd,str$(eax),"Title",MB_OK
          case 55
            fn MessageBox,hWnd,str$(eax),"Title",MB_OK
          case 56
            jmp quit_dialog
        endsw
      case WM_CLOSE
        quit_dialog:
         invoke EndDialog,hWin,0
    endsw

    return 0

DlgProc endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

text_bar proc hParent:DWORD

    TB_BEGIND hParent
    TxtItem  0,  50, "  New  "
    TxtItem  1,  51, " Open "
    TxtItem  2,  52, " Save "
    ;; TxtSeperator
    TxtItem  3,  53, "  Cut  "
    TxtItem  4,  54, " Copy "
    TxtItem  5,  55, " Paste "
    ;; TxtSeperator
    TxtItem  6,  56, "  Exit  "
    TB_END

text_bar endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start
