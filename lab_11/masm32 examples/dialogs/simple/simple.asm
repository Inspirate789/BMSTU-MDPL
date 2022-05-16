; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

      .486                      ; create 32 bit code
      .model flat, stdcall      ; 32 bit memory model
      option casemap :none      ; case sensitive

      include \masm32\include\dialogs.inc
      include simple.inc

      dlgproc PROTO :DWORD,:DWORD,:DWORD,:DWORD

    .code

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

start:

      mov hInstance, FUNC(GetModuleHandle,NULL)

      call main

      invoke ExitProcess,eax

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

main proc

    Dialog "Simple Dialog","MS Sans Serif",10, \            ; caption,font,pointsize
            WS_OVERLAPPED or WS_SYSMENU or DS_CENTER, \     ; style
            2, \                                            ; control count
            50,50,150,80, \                                 ; x y co-ordinates
            1024                                            ; memory buffer size

    DlgButton "&OK",WS_TABSTOP,48,40,50,15,IDCANCEL
    DlgStatic "Simple Dialog Written In MASM32",SS_CENTER,2,20,140,9,100

    CallModalDialog hInstance,0,dlgproc,NULL

    ret

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

dlgproc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

    .if uMsg == WM_INITDIALOG
      invoke SendMessage,hWin,WM_SETICON,1,FUNC(LoadIcon,NULL,IDI_ASTERISK)

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