; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

      .486                      ; create 32 bit code
      .model flat, stdcall      ; 32 bit memory model
      option casemap :none      ; case sensitive

      include \masm32\include\dialogs.inc
      include tests.inc

      dlgproc PROTO :DWORD,:DWORD,:DWORD,:DWORD

    .code

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

start:

      mov hInstance, FUNC(GetModuleHandle,NULL)

      call main

      invoke ExitProcess,eax

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

main proc

    LOCAL icce:INITCOMMONCONTROLSEX
    
    mov icce.dwSize, SIZEOF INITCOMMONCONTROLSEX
    mov icce.dwICC, ICC_DATE_CLASSES or \
                    ICC_INTERNET_CLASSES or \
                    ICC_PAGESCROLLER_CLASS or \
                    ICC_COOL_CLASSES

    invoke InitCommonControlsEx,ADDR icce

    Dialog "Common Control Tests","MS Sans Serif",10, \     ; caption,font,pointsize
            WS_OVERLAPPED or DS_CENTER, \                   ; style
            7, \                                            ; control count
            50,50,150,100, \                                ; x y co-ordinates
            1024                                            ; memory buffer size

    DlgButton "Cancel",WS_TABSTOP,110,2,35,12,IDCANCEL

    DlgStatic "Date Time Picker",0,2,2,100,9,100
    DlgDateTime  WS_TABSTOP or DTS_TIMEFORMAT,2,12,80,12,101

    DlgStatic "IP Address control",0,2,30,100,9,103
    DlgIPAddress WS_TABSTOP,2,40,80,11,104

    DlgStatic "Hotkey control",0,2,55,100,9,105
    DlgHotkey WS_TABSTOP,2,65,80,12,106

    CallModalDialog hInstance,0,dlgproc,NULL

    ret

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

dlgproc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

    .if uMsg == WM_INITDIALOG

    .elseif uMsg == WM_COMMAND
      .if wParam == IDCANCEL
        jmp quit_dialog
      .endif

    .elseif uMsg == WM_CLOSE
      quit_dialog:
      invoke EndDialog,hWin,0

    .endif

    xor eax, eax
    ret

dlgproc endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start