; #########################################################################

      .386
      .model flat, stdcall
      option casemap :none   ; case sensitive

; #########################################################################

      include \masm32\include\windows.inc

      include \masm32\include\user32.inc
      include \masm32\include\kernel32.inc
      include \masm32\include\comctl32.inc

      includelib \masm32\lib\user32.lib
      includelib \masm32\lib\kernel32.lib
      includelib \masm32\lib\comctl32.lib      

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

      m2m MACRO M1, M2
        push M2
        pop  M1
      ENDM

      return MACRO arg
        mov eax, arg
        ret
      ENDM

        ;=================
        ; Local prototypes
        ;=================
        WinMain PROTO :DWORD,:DWORD,:DWORD,:DWORD
        WndProc PROTO :DWORD,:DWORD,:DWORD,:DWORD
        TopXY PROTO   :DWORD,:DWORD
        Paint_Proc PROTO :DWORD,:DWORD

    .data
        szDisplayName db "Comctl32 Demo",0
        CommandLine   dd 0
        hWnd          dd 0
        hInstance     dd 0
        hStatus       dd 0
        hToolBar      dd 0

    .code

start:
        invoke GetModuleHandle, NULL
        mov hInstance, eax

        invoke GetCommandLine
        mov CommandLine, eax

        invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT
        invoke ExitProcess,eax

; #########################################################################

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

        invoke InitCommonControls

        ;==================================================
        ; Fill WNDCLASSEX structure with required variables
        ;==================================================

        mov wc.cbSize,         sizeof WNDCLASSEX
        mov wc.style,          CS_HREDRAW or CS_VREDRAW \
                               or CS_BYTEALIGNWINDOW
        mov wc.lpfnWndProc,    offset WndProc
        mov wc.cbClsExtra,     NULL
        mov wc.cbWndExtra,     NULL
        m2m wc.hInstance,      hInst   ;<< NOTE: macro not mnemonic
        mov wc.hbrBackground,  COLOR_BTNFACE+1
        mov wc.lpszMenuName,   NULL
        mov wc.lpszClassName,  offset szClassName
          invoke LoadIcon,hInst,500    ; icon ID
        mov wc.hIcon,          eax
          invoke LoadCursor,NULL,IDC_ARROW
        mov wc.hCursor,        eax
        mov wc.hIconSm,        0

        invoke RegisterClassEx, ADDR wc

        ;================================
        ; Centre window at following size
        ;================================

        mov Wwd, 500
        mov Wht, 350

        invoke GetSystemMetrics,SM_CXSCREEN
        invoke TopXY,Wwd,eax
        mov Wtx, eax

        invoke GetSystemMetrics,SM_CYSCREEN
        invoke TopXY,Wht,eax
        mov Wty, eax

        szText szClassName,"Comctl_Class"

        invoke CreateWindowEx,WS_EX_LEFT,
                              ADDR szClassName,
                              ADDR szDisplayName,
                              WS_OVERLAPPEDWINDOW,
                              Wtx,Wty,Wwd,Wht,
                              NULL,NULL,
                              hInst,NULL
        mov   hWnd,eax

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

; #########################################################################

WndProc proc hWin   :DWORD,
             uMsg   :DWORD,
             wParam :DWORD,
             lParam :DWORD

    LOCAL caW   :DWORD
    LOCAL caH   :DWORD
    LOCAL hDC   :DWORD
    LOCAL Rct   :RECT
    LOCAL tbb   :TBBUTTON
    LOCAL Tba   :TBADDBITMAP
    LOCAL Ps    :PAINTSTRUCT

    szText tbSelect,"You have selected"

    .if uMsg == WM_COMMAND
    ;======== toolbar commands ========

        .if wParam == 50
            szText tb50,"New File"
            invoke SendMessage,hStatus,SB_SETTEXT,0,ADDR tb50
            invoke MessageBox,hWin,ADDR tb50,ADDR tbSelect,MB_OK

        .elseif wParam == 51
            szText tb51,"Open File"
            invoke SendMessage,hStatus,SB_SETTEXT,0,ADDR tb51
            invoke MessageBox,hWin,ADDR tb51,ADDR tbSelect,MB_OK

        .elseif wParam == 52
            szText tb52,"Save File"
            invoke SendMessage,hStatus,SB_SETTEXT,0,ADDR tb52
            invoke MessageBox,hWin,ADDR tb52,ADDR tbSelect,MB_OK

        .elseif wParam == 53
            szText tb53,"Cut"
            invoke SendMessage,hStatus,SB_SETTEXT,0,ADDR tb53
            invoke MessageBox,hWin,ADDR tb53,ADDR tbSelect,MB_OK

        .elseif wParam == 54
            szText tb54,"Copy"
            invoke SendMessage,hStatus,SB_SETTEXT,0,ADDR tb54
            invoke MessageBox,hWin,ADDR tb54,ADDR tbSelect,MB_OK

        .elseif wParam == 55
            szText tb55,"Paste"
            invoke SendMessage,hStatus,SB_SETTEXT,0,ADDR tb55
            invoke MessageBox,hWin,ADDR tb55,ADDR tbSelect,MB_OK

        .elseif wParam == 56
            szText tb56,"Undo"
            invoke SendMessage,hStatus,SB_SETTEXT,0,ADDR tb56
            invoke MessageBox,hWin,ADDR tb56,ADDR tbSelect,MB_OK

        .elseif wParam == 57
            szText tb57,"Search"
            invoke SendMessage,hStatus,SB_SETTEXT,0,ADDR tb57
            invoke MessageBox,hWin,ADDR tb57,ADDR tbSelect,MB_OK

        .elseif wParam == 58
            szText tb58,"Replace"
            invoke SendMessage,hStatus,SB_SETTEXT,0,ADDR tb58
            invoke MessageBox,hWin,ADDR tb58,ADDR tbSelect,MB_OK

        .elseif wParam == 59
            szText tb59,"Print"
            invoke SendMessage,hStatus,SB_SETTEXT,0,ADDR tb59
            invoke MessageBox,hWin,ADDR tb59,ADDR tbSelect,MB_OK

    ;======== menu commands ========
        .elseif wParam == 1000
            invoke SendMessage,hWin,WM_SYSCOMMAND,SC_CLOSE,NULL
        .elseif wParam == 1900
            szText TheMsg,"Assembler, Pure & Simple"
            invoke MessageBox,hWin,ADDR TheMsg,ADDR szDisplayName,MB_OK
        .endif
    ;====== end menu commands ======

    .elseif uMsg == WM_CREATE

        ;--------------------
        ; Create the tool bar
        ;--------------------

        mov tbb.iBitmap,   0
        mov tbb.idCommand, 0
        mov tbb.fsState,   TBSTATE_ENABLED
        mov tbb.fsStyle,   TBSTYLE_SEP
        mov tbb.dwData,    0
        mov tbb.iString,   0

        invoke CreateToolbarEx,hWin,WS_CHILD or WS_CLIPSIBLINGS,
                               300,1,0,0,ADDR tbb,
                               1,16,16,0,0,sizeof TBBUTTON
        mov hToolBar, eax
        invoke ShowWindow,hToolBar,SW_SHOW

        ;-----------------------------------------
        ; Select tool bar bitmap from commctrl DLL
        ;-----------------------------------------

        mov Tba.hInst, HINST_COMMCTRL
        mov Tba.nID, 1   ; btnsize 1=big 2=small

        invoke SendMessage,hToolBar,TB_ADDBITMAP,1,ADDR Tba

        ;------------------------
        ; Add buttons to tool bar
        ;------------------------

        mov tbb.iBitmap,   STD_FILENEW
        mov tbb.fsStyle,   TBSTYLE_BUTTON
        mov tbb.idCommand, 50
        invoke SendMessage,hToolBar,TB_ADDBUTTONS,1,ADDR tbb

        mov tbb.iBitmap,   STD_FILEOPEN
        mov tbb.idCommand, 51
        mov tbb.fsStyle,   TBSTYLE_BUTTON
        invoke SendMessage,hToolBar,TB_ADDBUTTONS,1,ADDR tbb

        mov tbb.iBitmap,   STD_FILESAVE
        mov tbb.idCommand, 52
        mov tbb.fsStyle,   TBSTYLE_BUTTON
        invoke SendMessage,hToolBar,TB_ADDBUTTONS,1,ADDR tbb

        mov tbb.idCommand, 0
        mov tbb.fsStyle,   TBSTYLE_SEP
        invoke SendMessage,hToolBar,TB_ADDBUTTONS,1,ADDR tbb

        mov tbb.iBitmap,   STD_CUT
        mov tbb.idCommand, 53
        mov tbb.fsStyle,   TBSTYLE_BUTTON
        invoke SendMessage,hToolBar,TB_ADDBUTTONS,1,ADDR tbb

        mov tbb.iBitmap,   STD_COPY
        mov tbb.idCommand, 54
        mov tbb.fsStyle,   TBSTYLE_BUTTON
        invoke SendMessage,hToolBar,TB_ADDBUTTONS,1,ADDR tbb

        mov tbb.iBitmap,   STD_PASTE
        mov tbb.idCommand, 55
        mov tbb.fsStyle,   TBSTYLE_BUTTON
        invoke SendMessage,hToolBar,TB_ADDBUTTONS,1,ADDR tbb

        mov tbb.iBitmap,   STD_UNDO
        mov tbb.idCommand, 56
        mov tbb.fsStyle,   TBSTYLE_BUTTON
        invoke SendMessage,hToolBar,TB_ADDBUTTONS,1,ADDR tbb

        mov tbb.iBitmap,   0
        mov tbb.idCommand, 0
        mov tbb.fsStyle,   TBSTYLE_SEP
        invoke SendMessage,hToolBar,TB_ADDBUTTONS,1,ADDR tbb

        mov tbb.iBitmap,   STD_FIND
        mov tbb.idCommand, 57
        mov tbb.fsStyle,   TBSTYLE_BUTTON
        invoke SendMessage,hToolBar,TB_ADDBUTTONS,1,ADDR tbb

        mov tbb.iBitmap,   STD_REPLACE
        mov tbb.idCommand, 58
        mov tbb.fsStyle,   TBSTYLE_BUTTON
        invoke SendMessage,hToolBar,TB_ADDBUTTONS,1,ADDR tbb

        mov tbb.iBitmap,   0
        mov tbb.idCommand, 0
        mov tbb.fsStyle,   TBSTYLE_SEP
        invoke SendMessage,hToolBar,TB_ADDBUTTONS,1,ADDR tbb

        mov tbb.iBitmap,   STD_PRINT
        mov tbb.idCommand, 59
        mov tbb.fsStyle,   TBSTYLE_BUTTON
        invoke SendMessage,hToolBar,TB_ADDBUTTONS,1,ADDR tbb

        ;----------------------
        ; Create the status bar
        ;----------------------

        invoke CreateStatusWindow,WS_CHILD or WS_VISIBLE or \
                                   SBS_SIZEGRIP,0, hWin, 200
        mov hStatus, eax

    .elseif uMsg == WM_SIZE

        invoke SendMessage,hToolBar,TB_AUTOSIZE,0,0

        m2m caW, lParam[0]  ; client area width
        m2m caH, lParam[2]  ; client area height

        invoke GetWindowRect,hStatus,ADDR Rct
        mov eax, Rct.bottom
        sub eax, Rct.top
        sub caH, eax

        invoke MoveWindow,hStatus,0,caH,caW,caH,TRUE

    .elseif uMsg == WM_PAINT
        invoke BeginPaint,hWin,ADDR Ps
          mov hDC, eax
          invoke Paint_Proc,hWin,hDC
        invoke EndPaint,hWin,ADDR Ps
        return 0

    .elseif uMsg == WM_CLOSE

    .elseif uMsg == WM_DESTROY
        invoke PostQuitMessage,NULL
        return 0 
    .endif

    invoke DefWindowProc,hWin,uMsg,wParam,lParam

    ret

WndProc endp

; ########################################################################

TopXY proc wDim:DWORD, sDim:DWORD

    shr sDim, 1      ; divide screen dimension by 2
    shr wDim, 1      ; divide window dimension by 2
    mov eax, wDim    ; copy window dimension into eax
    sub sDim, eax    ; sub half win dimension from half screen dimension

    return sDim

TopXY endp

; ########################################################################

Paint_Proc proc hWin:DWORD, hDC:DWORD

    LOCAL caW :DWORD
    LOCAL caH :DWORD
    LOCAL tbH :DWORD
    LOCAL sbH :DWORD
    LOCAL Rct :RECT

    invoke GetClientRect,hWin,ADDR Rct
    m2m caW, Rct.right
    m2m caH, Rct.bottom

    invoke GetWindowRect,hToolBar,ADDR Rct
    mov eax, Rct.bottom
    sub eax, Rct.top
    mov tbH, eax

    invoke GetWindowRect,hStatus,ADDR Rct
    mov eax, Rct.bottom
    sub eax, Rct.top
    mov sbH, eax

    mov eax, caH
    sub eax, sbH
    mov caH, eax

    mov Rct.left, 0
    m2m Rct.top, tbH
    m2m Rct.right, caW
    m2m Rct.bottom, caH

    invoke DrawEdge,hDC,ADDR Rct,EDGE_SUNKEN,BF_RECT

    return 0

Paint_Proc endp

; ########################################################################

end start
