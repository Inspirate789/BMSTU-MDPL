; #########################################################################

    .486                      ; force 32 bit code
    .model flat, stdcall      ; memory model & calling convention
    option casemap :none      ; case sensitive

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
    include \masm32\macros\macros.asm

    IPM_SETADDRESS equ WM_USER + 101
    IPM_GETADDRESS equ WM_USER + 102

    GetIP PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
    GetIPProc PROTO :DWORD,:DWORD,:DWORD,:DWORD

    .code

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

GetIP proc Parent :DWORD,Instance:DWORD, Icon:DWORD,
           lpCaption:DWORD,lpText:DWORD,defIP:DWORD

    LOCAL icce:INITCOMMONCONTROLSEX

    mov icce.dwSize, SIZEOF INITCOMMONCONTROLSEX
    mov icce.dwICC,  ICC_INTERNET_CLASSES
    invoke InitCommonControlsEx,ADDR icce

    Dialog "Get IP Address", \         ; default dialog title
           "MS Sans Serif",8, \        ; font name & point size
           WS_OVERLAPPED or \
           WS_SYSMENU or DS_CENTER, \  ; window style
           4, \                        ; control count
           50,50, \                    ; top X Y coordinates
           170,70, \                   ; width and height
           1024                        ; buffer size to cllocate


    DlgStatic     0,SS_LEFT,10,4,150,10,101
    DlgIPAddress  WS_TABSTOP,10,15,90,13,100
    DlgButton     "&OK",    WS_TABSTOP,110,15,45,14,IDOK
    DlgButton     "&Cancel",WS_TABSTOP,110,31,45,14,IDCANCEL

    CallModalDialog Instance,  \    ; the Instance handle
                    Parent,    \    ; the parent handle
                    GetIPProc, \    ; name of dialog proc
                    ADDR Parent     ; optional argument(s)

    ret

GetIP endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

GetIPProc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

    LOCAL IP :DWORD
    LOCAL hDC:DWORD
    LOCAL ps :PAINTSTRUCT
    LOCAL rct:RECT

    .if uMsg == WM_INITDIALOG
      push esi
      mov esi, lParam

    ; ----------------------------------------------------
    ; set the icon to the handle passed else default icon
    ; ----------------------------------------------------
      cmp DWORD PTR [esi+8], 0
      je @F
      invoke SendMessage,hWin,WM_SETICON,1,[esi+8]
      jmp nxt1
    @@:
      invoke SendMessage,hWin,WM_SETICON,1,FUNC(LoadIcon,NULL,IDI_APPLICATION)
    nxt1:

    ; ----------------------------------------------
    ; set the window title else leave default title
    ; ----------------------------------------------
      cmp DWORD PTR [esi+12], 0
      je @F
      invoke SetWindowText,hWin,[esi+12]
    @@:

    ; ---------------------------------------------------
    ; set the extra text static control else leave blank
    ; ---------------------------------------------------
      cmp DWORD PTR [esi+16], 0
      je @F
      invoke SendDlgItemMessage,hWin,101,WM_SETTEXT,0,[esi+16]
    @@:

    ; -----------------------------------------
    ; set the default IP if parameter not zero
    ; -----------------------------------------
      cmp DWORD PTR [esi+20], 0
      je @F
      invoke SendDlgItemMessage,hWin,100,IPM_SETADDRESS,0,[esi+20]
    @@:

      pop esi
      mov eax, 1    ; return 1 to set focus to 1st control
      ret

    .elseif uMsg == WM_PAINT
      invoke BeginPaint,hWin,ADDR ps
      mov hDC, eax
      invoke GetClientRect,hWin,ADDR rct
      invoke DrawEdge,hDC,ADDR rct,EDGE_ETCHED,BF_RECT
      invoke EndPaint,hWin,ADDR ps

    .elseif uMsg == WM_COMMAND
      .if wParam == IDOK
        invoke SendDlgItemMessage,hWin,100,IPM_GETADDRESS,0,ADDR IP
        .if eax == 4
          mov ecx, IP
          jmp quit_dialog
        .endif

      .elseif wParam == IDCANCEL
        mov ecx, -1
        jmp quit_dialog
      .endif

    .elseif uMsg == WM_CLOSE
      mov ecx, -1
      quit_dialog:
      invoke EndDialog,hWin,ecx

    .endif

    xor eax, eax
    ret

GetIPProc endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end