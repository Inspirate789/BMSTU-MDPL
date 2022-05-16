; #########################################################################

;                              MULTIWIN.ASM

; #########################################################################

; Multiwin shows a couple of techniques for making child windows, the 1st
; uses the same registered window class as the main window and the menu
; is attached to the 1st child window. This windows processes its messages
; in the WndProc for the main window as it uses the same window class. This
; technique is particularly useful for making floating tool windows.

; A little care need to be taken with the window handles, instead of using
; the handle passed to the WndProc, differentiation is made on the specific
; handle from each window.

; The second child window registers its own class and has its own message
; handling proc, by manipulating the window styles, this window is fully
; captive within the client area of the main window.

; #########################################################################

      .386
      .model flat, stdcall  ; 32 bit memory model
      option casemap :none  ; case sensitive

      include multiwin.inc  ; local includes for this file

; #########################################################################

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

      LOCAL Wwd  :DWORD
      LOCAL Wht  :DWORD
      LOCAL Wtx  :DWORD
      LOCAL Wty  :DWORD
      LOCAL sWid :DWORD
      LOCAL sHgt :DWORD
      LOCAL msg  :MSG
      LOCAL wc   :WNDCLASSEX
      LOCAL wc2  :WNDCLASSEX

      ;==================================================
      ; Fill WNDCLASSEX structure with required variables
      ;==================================================

      invoke LoadIcon,hInst,500    ; icon ID
      mov hIcon, eax

      szText szClassName,"Project_Class"

      mov wc.cbSize,         sizeof WNDCLASSEX
      mov wc.style,          CS_HREDRAW or CS_VREDRAW \
                             or CS_BYTEALIGNWINDOW
      mov wc.lpfnWndProc,    offset WndProc
      mov wc.cbClsExtra,     NULL
      mov wc.cbWndExtra,     NULL
      m2m wc.hInstance,      hInst
      mov wc.hbrBackground,  COLOR_BTNFACE+1
      mov wc.lpszMenuName,   NULL
      mov wc.lpszClassName,  offset szClassName
      m2m wc.hIcon,          hIcon
        invoke LoadCursor,NULL,IDC_ARROW
      mov wc.hCursor,        eax
      m2m wc.hIconSm,        hIcon

      invoke RegisterClassEx, ADDR wc

      ;================================
      ; Centre window at following size
      ;================================

      mov Wwd, 500
      mov Wht, 350

      invoke GetSystemMetrics,SM_CXSCREEN
      mov sWid, eax
      invoke TopXY,Wwd,eax
      mov Wtx, eax

      invoke GetSystemMetrics,SM_CYSCREEN
      mov sHgt, eax
      invoke TopXY,Wht,eax
      mov Wty, eax

    ; ----------------
    ; The main window
    ; ----------------

      szText MainWindowTitle,"Main Window"

      invoke CreateWindowEx,WS_EX_LEFT,
                            ADDR szClassName,
                            ADDR MainWindowTitle,
                            WS_OVERLAPPEDWINDOW,
                            Wtx,Wty,Wwd,Wht,
                            NULL,NULL,
                            hInst,NULL
      mov   hWnd,eax

      szText tChild1,"Child Window 1"

    ; ------------------------------------------------------
    ; Because the second window uses the same classname it
    ; also uses the same WndProc for message processing.
    ; ------------------------------------------------------
      invoke CreateWindowEx,WS_EX_LEFT,
                            ADDR szClassName,
                            ADDR tChild1,
                            WS_OVERLAPPEDWINDOW,
                            0,0,sWid,50,
                            hWnd,NULL,
                            hInst,NULL
      mov hChild1, eax

    ; ------------------------------
    ; menu attached to child window
    ; ------------------------------
      invoke LoadMenu,hInst,600  ; menu ID
      invoke SetMenu,hChild1,eax

    ; ------------------------------------------
    ; The following child window defines its
    ; own WNDCLASSEX structure and registers
    ; its own window class. It has a seperate
    ; message handling procedure and its style
    ; is set so it is a captive window of the
    ; parent window.
    ; ------------------------------------------

      szText ClassName2,"Child_2_Class"

      mov wc2.cbSize,         sizeof WNDCLASSEX
      mov wc2.style,          CS_BYTEALIGNWINDOW
      mov wc2.lpfnWndProc,    offset WndProc2
      mov wc2.cbClsExtra,     NULL
      mov wc2.cbWndExtra,     NULL
      m2m wc2.hInstance,      hInst
      mov wc2.hbrBackground,  COLOR_BTNFACE+1
      mov wc2.lpszMenuName,   NULL
      mov wc2.lpszClassName,  offset ClassName2
      m2m wc2.hIcon,          NULL
        invoke LoadCursor,NULL,IDC_ARROW
      mov wc2.hCursor,        eax
      m2m wc2.hIconSm,        NULL

      invoke RegisterClassEx, ADDR wc2

      szText tChild2,"Child Window 2"

      invoke CreateWindowEx,WS_EX_LEFT,
                            ADDR ClassName2,
                            ADDR tChild2,
                            WS_CHILD or WS_CAPTION,
                            50,50,150,100,
                            hWnd,NULL,
                            hInst,NULL
      mov hChild2, eax

    ; ------------------------------------------

      invoke ShowWindow,hWnd,SW_SHOWNORMAL
      invoke ShowWindow,hChild1,SW_SHOWNORMAL
      invoke ShowWindow,hChild2,SW_SHOWNORMAL

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

    LOCAL var    :DWORD
    LOCAL caW    :DWORD
    LOCAL caH    :DWORD
    LOCAL Rct    :RECT
    LOCAL hDC    :DWORD
    LOCAL Ps     :PAINTSTRUCT
    LOCAL buffer1[128]:BYTE  ; these are two spare buffers
    LOCAL buffer2[128]:BYTE  ; for text manipulation etc..

    .if uMsg == WM_COMMAND
    ;======== menu commands ========
        .if wParam == 1010
          ; ------------------------------
          ; Close parent window IE. hWnd
          ; ------------------------------
            invoke SendMessage,hWnd,WM_SYSCOMMAND,SC_CLOSE,NULL
        .elseif wParam == 1900
            szText AboutMsg,"Prostart Pure Assembler Template",13,10,\
            "Copyright © Prostart 1999"
            invoke ShellAbout,hWin,ADDR szDisplayName,ADDR AboutMsg,hIcon
        .endif
    ;====== end menu commands ======

    .elseif uMsg == WM_CREATE
      ; ---------------------------------------
      ; Don't use this message to create other
      ; controls and initialise code. It is
      ; called twice by two different windows.
      ; Put window specific code after the
      ; CreateWindowEx calls in the WinMain.
      ; ---------------------------------------

    .elseif uMsg == WM_SIZE

    .elseif uMsg == WM_PAINT
        invoke BeginPaint,hWin,ADDR Ps
          mov hDC, eax
          invoke Paint_Proc,hWin,hDC
        invoke EndPaint,hWin,ADDR Ps
        return 0

    .elseif uMsg == WM_CLOSE
      ; ------------------------------------
      ; Disallow close if title bar button
      ; pressed in child window.
      ; ------------------------------------
        mov eax, hChild1
        .if hWin == eax
          mov eax, 0
          ret
        .endif

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

; #########################################################################

Paint_Proc proc hWin:DWORD, hDC:DWORD

    LOCAL btn_hi   :DWORD
    LOCAL btn_lo   :DWORD
    LOCAL Rct      :RECT

    invoke GetSysColor,COLOR_BTNHIGHLIGHT
    mov btn_hi, eax

    invoke GetSysColor,COLOR_BTNSHADOW
    mov btn_lo, eax

    return 0

Paint_Proc endp

; ########################################################################

WndProc2 proc hWin   :DWORD,
              uMsg   :DWORD,
              wParam :DWORD,
              lParam :DWORD

    .if uMsg == WM_LBUTTONUP
      szText dlgMsg,"You clicked in the child window"
      szText dlgTtl,"Child Win 2 here"
      invoke MessageBox,hWin,ADDR dlgMsg,ADDR dlgTtl,MB_OK
    .endif

    invoke DefWindowProc,hWin,uMsg,wParam,lParam

    ret

WndProc2 endp

; ########################################################################

end start
