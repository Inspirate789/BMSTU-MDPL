; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    .486                      ; create 32 bit code
    .model flat, stdcall      ; 32 bit memory model
    option casemap :none      ; case sensitive

    FUNC MACRO parameters:VARARG
      invoke parameters
      EXITM <eax>
    ENDM

    include \masm32\include\windows.inc
    include \masm32\include\dialogs.inc
    include \masm32\include\gdi32.inc
    include \masm32\include\user32.inc
    include \masm32\include\kernel32.inc

    GetFile     PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
    ListProc    PROTO :DWORD,:DWORD,:DWORD,:DWORD
    LoadList    PROTO :DWORD,:DWORD
    GetFileProc PROTO :DWORD,:DWORD,:DWORD,:DWORD

    .code

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

GetFile proc Parent :DWORD,Instance :DWORD,Icon:DWORD,
             caption:DWORD,directory:DWORD,
             pattern:DWORD,buffer   :DWORD

    LOCAL cDir[260]:BYTE

    invoke GetCurrentDirectory,260,ADDR cDir
    invoke SetCurrentDirectory,directory

    Dialog "Select File","MS Sans Serif",8, \
           DS_CENTER or WS_OVERLAPPED or WS_SYSMENU, \
           3, \
           0,0,210,154,1024

    DlgList     LBS_NOINTEGRALHEIGHT or WS_BORDER or \
                WS_TABSTOP or LBS_SORT or WS_VSCROLL,5,5,148,130,100
    DlgButton   "OK",WS_TABSTOP,160,5,40,15,IDOK
    DlgButton   "Cancel",WS_TABSTOP,160,22,40,15,IDCANCEL

    CallModalDialog Instance,Parent,GetFileProc,ADDR Parent

    invoke SetCurrentDirectory,ADDR cDir

    ret

GetFile endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

GetFileProc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

    LOCAL hDC:DWORD
    LOCAL ps :PAINTSTRUCT
    LOCAL rct:RECT

    .if uMsg == WM_INITDIALOG
      push esi
      mov esi, lParam
      cmp DWORD PTR [esi+8], 0
      je noicon
      invoke SendMessage,hWin,WM_SETICON,1,[esi+8]
      jmp @F
    noicon:
      invoke SendMessage,hWin,WM_SETICON,1,FUNC(LoadIcon,0,IDI_ASTERISK)
    @@:

      invoke SetWindowText,hWin,[esi+12]    ; set window caption

      .data?
        lpListProc    dd ?
        hList         dd ?
      .code

      invoke GetDlgItem,hWin,100
      mov hList, eax
      invoke SetWindowLong,hList,GWL_WNDPROC,ListProc
      mov lpListProc, eax

      invoke SetWindowLong,hList,GWL_USERDATA,[esi+24]

      invoke LoadList,hList,[esi+20]
      invoke SendDlgItemMessage,hWin,100,WM_KEYDOWN,VK_UP,0

      pop esi
      mov eax, 1
      ret

    .elseif uMsg == WM_PAINT
      invoke BeginPaint,hWin,ADDR ps
      mov hDC, eax
      invoke GetClientRect,hWin,ADDR rct
      invoke DrawEdge,hDC,ADDR rct,EDGE_ETCHED,BF_RECT
      invoke EndPaint,hWin,ADDR ps

    .elseif uMsg == WM_SYSCOMMAND
      .if wParam == SC_CLOSE
        jmp gfpCancel
      .endif

    .elseif uMsg == WM_COMMAND

      .if wParam == IDOK
        invoke SendDlgItemMessage,hWin,100,WM_LBUTTONDBLCLK,0,0

      .elseif wParam == IDCANCEL
        gfpCancel:
        invoke GetWindowLong,hList,GWL_USERDATA
        mov BYTE PTR [eax], 0
        jmp gfpOut
      .endif

    .elseif uMsg == WM_CLOSE
      gfpOut:
      invoke EndDialog,hWin,0

    .endif

    xor eax, eax
    ret

GetFileProc endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

ListProc proc hCtl   :DWORD,
              uMsg   :DWORD,
              wParam :DWORD,
              lParam :DWORD

    LOCAL buffer:DWORD
    LOCAL index :DWORD
    LOCAL Parent:DWORD

  ; -----------------------------
  ; Process control messages here
  ; -----------------------------

    .if uMsg == WM_KEYUP
      cmp wParam, VK_RETURN
      je wrt
      xor eax, eax
      ret

    .elseif uMsg == WM_LBUTTONDBLCLK
      wrt:
      invoke GetWindowLong,hCtl,GWL_USERDATA
      mov buffer, eax
      invoke SendMessage,hCtl,LB_GETCURSEL,0,0
      mov index, eax

      invoke SendMessage,hCtl,LB_GETTEXTLEN,index,0
      cmp eax, 0
      je @F

      invoke SendMessage,hCtl,LB_GETTEXT,index,buffer
      invoke GetParent,hCtl
      mov Parent, eax
      invoke PostMessage,Parent,WM_CLOSE,0,0

    @@:

    .endif

    invoke CallWindowProc,lpListProc,hCtl,uMsg,wParam,lParam

    ret

ListProc endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    end