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
        Frame3D PROTO :DWORD, :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
        FrameCtrl PROTO :DWORD,:DWORD,:DWORD,:DWORD
        FrameWindow PROTO :DWORD,:DWORD,:DWORD,:DWORD

        ; ----------------------------------
        ; These are the two controls used on
        ; the client area of the window
        ; ----------------------------------
        EditSl PROTO  :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
        Static PROTO  :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
        PushButton PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD

    .data
        szDisplayName db "Registration Skeleton",0
        CommandLine   dd 0
        hWnd          dd 0
        hInstance     dd 0
        hEdit1        dd 0
        hEdit2        dd 0
        hEdit3        dd 0
        hButn1        dd 0
        hFont         dd 0
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

        mov Wwd, 355
        mov Wht, 280

        invoke GetSystemMetrics,SM_CXSCREEN
        invoke TopXY,Wwd,eax
        mov Wtx, eax

        invoke GetSystemMetrics,SM_CYSCREEN
        invoke TopXY,Wht,eax
        mov Wty, eax

        szText szClassName,"Template_Class"

        invoke CreateWindowEx,WS_EX_LEFT,
                              ADDR szClassName,
                              ADDR szDisplayName,
                              WS_OVERLAPPED or WS_SYSMENU,
                              Wtx,Wty,Wwd,Wht,
                              NULL,NULL,
                              hInst,NULL
        mov   hWnd,eax

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

    LOCAL hDC  :DWORD
    LOCAL Ps   :PAINTSTRUCT

    .if uMsg == WM_COMMAND
        .if wParam == 500  ;<<<< The button
            invoke SendMessage,hWin,WM_SYSCOMMAND,SC_CLOSE,NULL
        .endif

    .elseif uMsg == WM_CREATE
        szText font1,"Times New Roman"
        invoke CreateFont,16,8,0,0,500,0,0,0, \
                          DEFAULT_CHARSET,0,0,0,\
                          DEFAULT_PITCH,ADDR font1
        mov hFont, eax

        szText adrTxt,0

        szText lbl1," Text Box 1"
        invoke Static,ADDR lbl1,hWin,50,30,200,17,0
        szText lbl2," Text Box 2"
        invoke Static,ADDR lbl2,hWin,50,80,200,17,0
        szText lbl3," Text Box 3"
        invoke Static,ADDR lbl3,hWin,50,130,200,17,0

        invoke EditSl,ADDR adrTxt,50,50,250,23,hWin,700
        mov hEdit1, eax
        invoke EditSl,ADDR adrTxt,50,100,250,23,hWin,701
        mov hEdit2, eax
        invoke EditSl,ADDR adrTxt,50,150,250,23,hWin,702
        mov hEdit3, eax

        szText ButnTxt,"Register"
        invoke PushButton,ADDR ButnTxt,hWin,125,215,100,25,500
        mov hButn1, eax

    .elseif uMsg == WM_PAINT
        invoke BeginPaint,hWin,ADDR Ps
          mov hDC, eax
          invoke Paint_Proc,hWin,hDC
        invoke EndPaint,hWin,ADDR Ps
        return 0

    .elseif uMsg == WM_CLOSE
        invoke DeleteObject,hFont

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

EditSl proc szMsg:DWORD,a:DWORD,b:DWORD,
               wd:DWORD,ht:DWORD,hParent:DWORD,ID:DWORD

; EditSl PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
; invoke EditSl,ADDR adrTxt,200,10,150,25,hWnd,700

    LOCAL hndle:DWORD

    szText slEdit,"EDIT"

    invoke CreateWindowEx,WS_EX_CLIENTEDGE,ADDR slEdit,szMsg,
                WS_VISIBLE or WS_CHILDWINDOW or \
                ES_AUTOHSCROLL or ES_NOHIDESEL,
              a,b,wd,ht,hParent,ID,hInstance,NULL

    mov hndle, eax

    invoke SendMessage,hndle,WM_SETFONT,hFont,1

    mov eax, hndle

    ret

EditSl endp

; ########################################################################

Static proc lpText:DWORD,hParent:DWORD,
                 a:DWORD,b:DWORD,wd:DWORD,ht:DWORD,ID:DWORD

; Static PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
; invoke Static,ADDR szText,hWnd,20,20,100,15,500

    LOCAL hndle:DWORD

    szText statClass,"STATIC"

    invoke CreateWindowEx,WS_EX_LEFT,
            ADDR statClass,lpText,
            WS_CHILD or WS_VISIBLE or SS_LEFT,
            a,b,wd,ht,hParent,ID,
            hInstance,NULL

    mov hndle, eax

    invoke SendMessage,hndle,WM_SETFONT,hFont, 0

    mov eax, hndle

    ret

Static endp

; ########################################################################

PushButton proc lpText:DWORD,hParent:DWORD,
                a:DWORD,b:DWORD,wd:DWORD,ht:DWORD,ID:DWORD

; PushButton PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
; invoke PushButton,ADDR szText,hWnd,20,20,100,25,500

    LOCAL hndle:DWORD

    szText btnClass,"BUTTON"

    invoke CreateWindowEx,0,
            ADDR btnClass,lpText,
            WS_CHILD or WS_VISIBLE,
            a,b,wd,ht,hParent,ID,
            hInstance,NULL

    mov hndle, eax

    invoke SendMessage,hndle,WM_SETFONT,hFont, 0

    mov eax, hndle

    ret

PushButton endp

; ########################################################################

Paint_Proc proc hWin:DWORD, hDC:DWORD

    invoke FrameCtrl,hEdit1,2,1,1
    invoke FrameCtrl,hEdit2,2,1,1
    invoke FrameCtrl,hEdit3,2,1,1
    invoke FrameCtrl,hButn1,3,1,0

    invoke FrameGrp,hEdit1,hEdit3,26,1,1
    invoke FrameGrp,hEdit1,hEdit3,27,1,0

    invoke FrameWindow,hWin,0,1,0
    invoke FrameWindow,hWin,4,1,1

    return 0

Paint_Proc endp

; #########################################################################

end start
