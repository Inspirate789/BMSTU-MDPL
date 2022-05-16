; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    .486                      ; create 32 bit code
    .model flat, stdcall      ; 32 bit memory model
    option casemap :none      ; case sensitive

    include \masm32\include\dialogs.inc
    include \masm32\include\windows.inc

    include \masm32\include\user32.inc
    include \masm32\include\kernel32.inc

    GetTextInput PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
    GetTextProc  PROTO :DWORD,:DWORD,:DWORD,:DWORD

      FUNC MACRO parameters:VARARG
        invoke parameters
        EXITM <eax>
      ENDM

    ; ---------------------
    ; literal string MACRO
    ; ---------------------
      literal MACRO quoted_text:VARARG
        LOCAL local_text
        .data
          local_text db quoted_text,0
        .code
        EXITM <local_text>
      ENDM
    ; --------------------------------
    ; string address in INVOKE format
    ; --------------------------------
      SADD MACRO quoted_text:VARARG
        EXITM <ADDR literal(quoted_text)>
      ENDM


    .code

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

GetTextInput proc hParent   :DWORD,Instance :DWORD,
                  Icon      :DWORD,caption  :DWORD,
                  subcaption:DWORD,lpbuffer :DWORD

    Dialog  "0","MS Sans Serif",8, \
            WS_OVERLAPPED or WS_SYSMENU or DS_CENTER, \
            4,0,0,270,50,1024

    DlgEdit   WS_TABSTOP or WS_BORDER,10,12,200,12,101
    DlgButton "OK",WS_TABSTOP,220,5,40,12,IDOK
    DlgButton "Cancel",WS_TABSTOP,220,19,40,12,IDCANCEL

    DlgStatic "0",SS_CENTER,10,3,200,9,100

    CallModalDialog Instance,hParent,GetTextProc,ADDR hParent

    ret

GetTextInput endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

GetTextProc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

    LOCAL hStatic   :DWORD
    LOCAL hEdit     :DWORD
    LOCAL tl        :DWORD
    LOCAL hDC       :DWORD
    LOCAL ps        :PAINTSTRUCT
    LOCAL rct       :RECT

    .if uMsg == WM_INITDIALOG
      invoke SetWindowLong,hWin,GWL_USERDATA,lParam

      push esi
      mov esi, lParam

    ; --------------------
    ; set the window icon
    ; --------------------
      cmp DWORD PTR [esi+8], 0
      je noicon
      invoke SendMessage,hWin,WM_SETICON,1,[esi+8]
      jmp @F
    noicon:
      invoke SendMessage,hWin,WM_SETICON,1,FUNC(LoadIcon,0,IDI_ASTERISK)
    @@:

    ; -----------------------
    ; set the window caption
    ; -----------------------
      cmp BYTE PTR [esi+12], 0
      je notitle
      invoke SetWindowText,hWin,[esi+12]    ; caption
      jmp @F
    notitle:
      invoke SetWindowText,hWin,SADD("Get Text")
    @@:

      invoke GetDlgItem,hWin,101
      mov hEdit, eax
      invoke SetFocus,hEdit

    ; --------------------
    ; set the sub-caption
    ; --------------------
      invoke GetDlgItem,hWin,100
      mov hStatic, eax
      cmp BYTE PTR [esi+16], 0
      je @F
      invoke SetWindowText,hStatic,[esi+16] ; sub-caption
      jmp nxt1
    @@:
      invoke SetWindowText,hStatic,NULL
    nxt1:

      pop esi

    .elseif uMsg == WM_PAINT
      invoke BeginPaint,hWin,ADDR ps
      mov hDC, eax
      invoke GetClientRect,hWin,ADDR rct
      invoke DrawEdge,hDC,ADDR rct,EDGE_ETCHED,BF_RECT
      invoke EndPaint,hWin,ADDR ps

    .elseif uMsg == WM_COMMAND
      .if wParam == IDOK
        invoke GetDlgItem,hWin,101
        mov hEdit, eax
        invoke GetWindowTextLength,hEdit                ; test if zero length
        cmp eax, 0
        je @F
        mov tl, eax
        inc tl
        invoke GetWindowLong,hWin,GWL_USERDATA          ; get buffer address
        invoke SendMessage,hEdit,WM_GETTEXT,tl,[eax+20] ; write edit text to buffer
        jmp gtpExit
      @@:
      invoke SetFocus,hEdit

      .elseif wParam == IDCANCEL
        invoke GetWindowLong,hWin,GWL_USERDATA          ; get buffer address
        mov eax, [eax+20]
        mov BYTE PTR [eax], 0    ; set 1st byte in buffer to zero
        jmp gtpExit
      .endif

    .elseif uMsg == WM_CLOSE
      gtpExit:
      invoke EndDialog,hWin,0

    .endif

    xor eax, eax
    ret

GetTextProc endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    end