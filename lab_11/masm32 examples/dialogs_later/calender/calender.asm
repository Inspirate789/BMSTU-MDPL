; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

      .486                      ; create 32 bit code
      .model flat, stdcall      ; 32 bit memory model
      option casemap :none      ; case sensitive

      include \masm32\include\dialogs.inc
      include calender.inc

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
    mov icce.dwICC, ICC_DATE_CLASSES
    invoke InitCommonControlsEx,ADDR icce

    Dialog "Today","MS Sans Serif",10, \        ; caption,font,pointsize
            WS_OVERLAPPED or DS_CENTER, \       ; style
            2, \                                ; control count
            50,50,189,125, \                    ; x y co-ordinates
            1024                                ; memory buffer size

    DlgMonthCal MCS_WEEKNUMBERS,5,5,129,100,101
    DlgButton   "Close",WS_TABSTOP,141,5,40,12,IDCANCEL

    CallModalDialog hInstance,0,dlgproc,NULL

    ret

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

dlgproc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

    .if uMsg == WM_COMMAND
      .if wParam == IDCANCEL
        jmp dlg_end
      .endif

    .elseif uMsg == WM_CLOSE
      dlg_end:
      invoke EndDialog,hWin,0

    .endif

    xor eax, eax
    ret

dlgproc endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start