comment * ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

        This example will build with both MASM and POASM. To build it with
        POASM use MAKEIT.BAT from the "Project" menu. Smaller results are
        acheived with the POASM / POLINK combination.

        ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл *

      .486
      .model flat, stdcall
      option casemap :none   ; case sensitive

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

      include \masm32\include\windows.inc
      include \masm32\include\user32.inc
      include \masm32\include\kernel32.inc
      include \masm32\include\gdi32.inc
      include \masm32\macros\pomacros.asm

      includelib \masm32\lib\user32.lib
      includelib \masm32\lib\kernel32.lib
      includelib \masm32\lib\gdi32.lib

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

        ;=================
        ; Local prototypes
        ;=================
        WinMain   PROTO :DWORD,:DWORD,:DWORD,:DWORD
        WndProc   PROTO :DWORD,:DWORD,:DWORD,:DWORD
        TopXY     PROTO :DWORD,:DWORD
        ListBox   PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
        EnmProc   PROTO :DWORD,:DWORD
        EnmProc   PROTO :DWORD,:DWORD
        Static    PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
        ListProc  PROTO :DWORD,:DWORD,:DWORD,:DWORD
        PushButton PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD

    .data
        szDisplayName db "Enumerate Windows",0

    .data?
        CommandLine   dd ?
        hWnd          dd ?
        hInstance     dd ?
        hList         dd ?
        hStat1        dd ?
        hStat2        dd ?
        lpfnListProc  dd ?

    .code

start:
        invoke GetModuleHandle, NULL
        mov hInstance, eax

        invoke GetCommandLine
        mov CommandLine, eax

        invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT
        invoke ExitProcess,eax

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

WinMain proc hInst     :DWORD,
             hPrevInst :DWORD,
             CmdLine   :DWORD,
             CmdShow   :DWORD

        ;====================
        ; Put LOCALs on stack
        ;====================

        LOCAL wc   :WNDCLASSEX
        LOCAL msg  :MSG

        LOCAL Wwd  :DWORD
        LOCAL Wht  :DWORD
        LOCAL Wtx  :DWORD
        LOCAL Wty  :DWORD

        ;==================================================
        ; Fill WNDCLASSEX structure with required variables
        ;==================================================

        mov wc.cbSize,         sizeof WNDCLASSEX
        mov wc.style,          CS_BYTEALIGNWINDOW
        mov wc.lpfnWndProc,    offset WndProc
        mov wc.cbClsExtra,     NULL
        mov wc.cbWndExtra,     NULL
        m2m wc.hInstance,      hInst                ;<< NOTE: "m2m" macro, not mnemonic
        mov wc.hbrBackground,  COLOR_BTNFACE+1
        mov wc.lpszMenuName,   NULL
        mov wc.lpszClassName,  offset szClassName
          invoke LoadIcon,hInst,500                 ; icon ID
        mov wc.hIcon,          eax
          invoke LoadCursor,NULL,IDC_ARROW
        mov wc.hCursor,        eax
        mov wc.hIconSm,        0

        invoke RegisterClassEx, ADDR wc

        ;================================
        ; Centre window at following size
        ;================================

        mov Wwd, 600
        mov Wht, 350

        invoke GetSystemMetrics,SM_CXSCREEN
        invoke TopXY,Wwd,eax
        mov Wtx, eax

        invoke GetSystemMetrics,SM_CYSCREEN
        invoke TopXY,Wht,eax
        mov Wty, eax

        szText szClassName,"Enumerator_Class"

        invoke CreateWindowEx,WS_EX_OVERLAPPEDWINDOW,
                              ADDR szClassName,
                              ADDR szDisplayName,
                              WS_OVERLAPPEDWINDOW or WS_CLIPCHILDREN,
                              Wtx,Wty,Wwd,Wht,
                              NULL,NULL,
                              hInst,NULL
        mov   hWnd,eax

        invoke EnumWindows,ADDR EnmProc,0

        invoke LoadMenu,hInst,600  ; menu ID
        invoke SetMenu,hWnd,eax

        invoke ShowWindow,hWnd,SW_SHOWNORMAL
        invoke UpdateWindow,hWnd

      ;===================================
      ; Loop until PostQuitMessage is sent
      ;===================================

    StartLoop:
      invoke GetMessage,ADDR msg,NULL,0,0
      cmp eax, 0
      je ExitLoop
      invoke TranslateMessage, ADDR msg
      invoke DispatchMessage,  ADDR msg
      jmp StartLoop
    ExitLoop:

      return msg.wParam

WinMain endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

WndProc proc hWin   :DWORD,
             uMsg   :DWORD,
             wParam :DWORD,
             lParam :DWORD

    LOCAL Rc      :RECT
    LOCAL rLeft   :DWORD
    LOCAL rTop    :DWORD
    LOCAL rRight  :DWORD
    LOCAL rBottom :DWORD

    .if uMsg == WM_COMMAND
    ;======== menu commands ========
        .if wParam == 1000
            invoke SendMessage,hWin,WM_SYSCOMMAND,SC_CLOSE,NULL
        .elseif wParam == 1001
            Refresh_It:
            invoke SendMessage,hList,LB_RESETCONTENT,0,0
            invoke EnumWindows,ADDR EnmProc,0
        .elseif wParam == 1900
            szText TheMsg,"Pelles Macro Assembler"
            invoke MessageBox,hWin,ADDR TheMsg,ADDR szDisplayName,MB_OK
        .elseif wParam == 502
            jmp Refresh_It
        .endif
    ;====== end menu commands ======

    .elseif uMsg == WM_CREATE
      invoke ListBox,20,20,550,200,hWin,600
      mov hList, eax

      invoke SetWindowLong,hList,GWL_WNDPROC,ListProc
      mov lpfnListProc, eax

      jmp @F
          lbl1 db " hWnd",0
          lbl2 db " Window Class Name",0
          btn1 db "Refresh",0
      @@:

      invoke Static,ADDR lbl1,hWin,20,5,52,18,500
      invoke Static,ADDR lbl2,hWin,95,5,160,18,501

      invoke PushButton,ADDR btn1,hWin,300,2,100,22,502


    .elseif uMsg == WM_SIZE

      invoke GetClientRect,hWin,ADDR Rc

        m2m rLeft, Rc.left
        add rLeft, 20

        m2m rTop, Rc.top
        add rTop, 25

        m2m rRight, Rc.right
        sub rRight, 40

        m2m rBottom, Rc.bottom
        sub rBottom, 45
        
      invoke MoveWindow,hList,rLeft,rTop,rRight,rBottom,TRUE

    .elseif uMsg == WM_CLOSE

    .elseif uMsg == WM_DESTROY
        invoke PostQuitMessage,NULL
        return 0 
    .endif

    invoke DefWindowProc,hWin,uMsg,wParam,lParam

    ret

WndProc endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

TopXY proc wDim:DWORD, sDim:DWORD

    shr sDim, 1      ; divide screen dimension by 2
    shr wDim, 1      ; divide window dimension by 2
    mov eax, wDim    ; copy window dimension into eax
    sub sDim, eax    ; sub half win dimension from half screen dimension

    return sDim

TopXY endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

ListBox proc a:DWORD,b:DWORD,wd:DWORD,ht:DWORD,hParent:DWORD,ID:DWORD

    LOCAL hFont :DWORD
    LOCAL hLst  :DWORD

    szText lstBox,"LISTBOX"

    invoke CreateWindowEx,WS_EX_CLIENTEDGE,ADDR lstBox,0,
              WS_VSCROLL or WS_VISIBLE or \
              WS_BORDER or WS_CHILD or \
              LBS_HASSTRINGS or LBS_NOINTEGRALHEIGHT or \
              LBS_DISABLENOSCROLL,
              a,b,wd,ht,hParent,ID,hInstance,NULL

    mov hLst, eax

    invoke GetStockObject,SYSTEM_FIXED_FONT      ; ANSI_FIXED_FONT
    mov hFont, eax
    invoke SendMessage,hLst,WM_SETFONT,hFont, 0

    mov eax, hLst

    ret

ListBox endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

EnmProc proc eHandle :DWORD, y :DWORD

    LOCAL Buffer[256]:BYTE
    LOCAL clName[64] :BYTE

    invoke GetClassName,eHandle,ADDR clName,64

    szText ctlstr,"%-2.6lu   %s"
    invoke wsprintf,ADDR Buffer,ADDR ctlstr,eHandle,ADDR clName

    invoke SendMessage,hList,LB_ADDSTRING,0,ADDR Buffer

    mov eax, eHandle
    ret

EnmProc endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

Static proc lpText:DWORD,hParent:DWORD,
                 a:DWORD,b:DWORD,wd:DWORD,ht:DWORD,ID:DWORD

    LOCAL hStat :DWORD
    LOCAL hFont :DWORD

    szText statClass,"STATIC"

    invoke CreateWindowEx,WS_EX_STATICEDGE,
            ADDR statClass,lpText,
            WS_CHILD or WS_VISIBLE or SS_LEFT,
            a,b,wd,ht,hParent,ID,
            hInstance,NULL

    mov hStat, eax

    invoke GetStockObject,ANSI_FIXED_FONT
    mov hFont, eax
    invoke SendMessage,hStat,WM_SETFONT,hFont, 0

    mov eax, hStat

    ret

Static endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

ListProc proc hCtl   :DWORD,
              uMsg   :DWORD,
              wParam :DWORD,
              lParam :DWORD

    LOCAL IndexItem   :DWORD
    LOCAL Buffer[128] :BYTE

    .if uMsg == WM_CHAR
      .if wParam == 13
        call ShowItem
      .endif

    .elseif uMsg == WM_LBUTTONDBLCLK
        call ShowItem

    .endif

    invoke CallWindowProc,lpfnListProc,hCtl,uMsg,wParam,lParam

    ret

    ShowItem:
      invoke SendMessage,hCtl,LB_GETCURSEL,0,0
      mov IndexItem, eax
      invoke SendMessage,hCtl,LB_GETTEXT,IndexItem,ADDR Buffer
      invoke MessageBox,hWnd,ADDR Buffer,ADDR szDisplayName,MB_OK
      invoke SetFocus,hCtl
    ret

ListProc endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

PushButton proc lpText:DWORD,hParent:DWORD,
                a:DWORD,b:DWORD,wd:DWORD,ht:DWORD,ID:DWORD

; PushButton PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
; invoke PushButton,ADDR szText,hWnd,20,20,100,25,500

    szText btnClass,"BUTTON"

    invoke CreateWindowEx,0,
            ADDR btnClass,lpText,
            WS_CHILD or WS_VISIBLE,
            a,b,wd,ht,hParent,ID,
            hInstance,NULL

    ret

PushButton endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start
