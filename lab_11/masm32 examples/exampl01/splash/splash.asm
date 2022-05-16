; #########################################################################
;
;   This demo creates a window for the splash screen and displays it
;   with the WS_EX_TOPMOST attribute. It then creates the main window
;   under it and waits until the programmed time delay is up before
;   closing the Splash screen. The splash screen window creation code
;   is in the WinMain proc, the message handling is in the SplashProc
;   proc at the end of the file.
;
; #########################################################################

      .386
      .model flat, stdcall  ; 32 bit memory model
      option casemap :none  ; case sensitive

      include Splash.inc    ; local includes for this file

; #########################################################################

.code

start:
      invoke GetModuleHandle, NULL
      mov hInstance, eax

      invoke GetCommandLine
      mov CommandLine, eax

      invoke InitCommonControls

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
      LOCAL spl  :WNDCLASSEX
      LOCAL msg  :MSG
      LOCAL Wwd  :DWORD
      LOCAL Wht  :DWORD
      LOCAL Wtx  :DWORD
      LOCAL Wty  :DWORD
      LOCAL tc   :DWORD
      LOCAL lb   :LOGBRUSH
      LOCAL brsh :DWORD

    ; -------------------------
    ; fill a LOGBRUSH structure
    ; -------------------------
      mov lb.lbStyle,BS_SOLID
      mov lb.lbColor,000000FFh  ; direct COLORREF nember
      mov lb.lbHatch,NULL

      invoke CreateBrushIndirect,ADDR lb
      mov brsh, eax

      szText szSplashName,"Splash_Class"

      mov spl.cbSize,         sizeof WNDCLASSEX
      mov spl.style,          CS_HREDRAW or CS_VREDRAW \
                                or CS_BYTEALIGNWINDOW
      mov spl.lpfnWndProc,    offset SplashProc
      mov spl.cbClsExtra,     NULL
      mov spl.cbWndExtra,     NULL
      m2m spl.hInstance,      hInst
      m2m spl.hbrBackground,  brsh  ; the brush in the required colour
      mov spl.lpszMenuName,   NULL
      mov spl.lpszClassName,  offset szSplashName
      mov spl.hIcon,          NULL
      mov spl.hCursor,        NULL
      mov spl.hIconSm,        NULL

      invoke RegisterClassEx, ADDR spl

      mov Wwd, 350
      mov Wht, 200

      invoke GetSystemMetrics,SM_CXSCREEN
      invoke TopXY,Wwd,eax
      mov Wtx, eax

      invoke GetSystemMetrics,SM_CYSCREEN
      invoke TopXY,Wht,eax
      mov Wty, eax

    ; ------------------------------------------------------------
    ; Create the Splash Screen window with WS_EX_TOPMOST attribute
    ; ------------------------------------------------------------
      invoke CreateWindowEx,WS_EX_TOPMOST,
                            ADDR szSplashName,
                            ADDR szDisplayName,
                            WS_POPUP or WS_BORDER,
                            Wtx,Wty,Wwd,Wht,
                            NULL,NULL,
                            hInst,NULL
      mov   hSplash,eax

      invoke ShowWindow,hSplash,SW_SHOWNORMAL
      invoke UpdateWindow,hSplash

      invoke GetTickCount   ; get a time reference
      mov tc, eax

    ; -------------------------------------------
    ; the following WNDCLASSEX structure and
    ; CreateWindowEx call are for the main window
    ; -------------------------------------------
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

    ;--------------------------------
    ; Centre window at following size
    ;--------------------------------
      mov Wwd, 500
      mov Wht, 350

      invoke GetSystemMetrics,SM_CXSCREEN
      invoke TopXY,Wwd,eax
      mov Wtx, eax

      invoke GetSystemMetrics,SM_CYSCREEN
      invoke TopXY,Wht,eax
      mov Wty, eax

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

      add tc, 2000  ; add 2 seconds to the time reference

    ; ------------------------------------------------
    ; loop until Tick count catches up with added time
    ; ------------------------------------------------
    @@:
      invoke GetTickCount
        .if tc > eax
          jmp @B
        .endif
    ; -------------------
    ; Close Splash screen
    ; -------------------
      invoke SendMessage,hSplash,WM_SYSCOMMAND,SC_CLOSE,NULL

    ;-----------------------------------
    ; Loop until PostQuitMessage is sent
    ;-----------------------------------
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
    LOCAL tbab   :TBADDBITMAP
    LOCAL tbb    :TBBUTTON
    LOCAL buffer1[128]:BYTE  ; these are two spare buffers
    LOCAL buffer2[128]:BYTE  ; for text manipulation etc..

    .if uMsg == WM_COMMAND
    ;======== toolbar commands ========

        .if wParam == 50
            szText tbMsg0,"WM_COMMAND ID 50"
            invoke MessageBox,hWin,ADDR tbMsg0,
                              ADDR szDisplayName,MB_OK

        .elseif wParam == 51
            szText tbMsg1,"WM_COMMAND ID 51"
            invoke MessageBox,hWin,ADDR tbMsg1,
                              ADDR szDisplayName,MB_OK

        .elseif wParam == 52
            szText tbMsg2,"WM_COMMAND ID 52"
            invoke MessageBox,hWin,ADDR tbMsg2,
                              ADDR szDisplayName,MB_OK

        .elseif wParam == 53
            szText tbMsg3,"WM_COMMAND ID 53"
            invoke MessageBox,hWin,ADDR tbMsg3,
                              ADDR szDisplayName,MB_OK

        .elseif wParam == 54
            szText tbMsg4,"WM_COMMAND ID 54"
            invoke MessageBox,hWin,ADDR tbMsg4,
                              ADDR szDisplayName,MB_OK

        .elseif wParam == 55
            szText tbMsg5,"WM_COMMAND ID 55"
            invoke MessageBox,hWin,ADDR tbMsg5,
                              ADDR szDisplayName,MB_OK

        .elseif wParam == 56
            szText tbMsg6,"WM_COMMAND ID 56"
            invoke MessageBox,hWin,ADDR tbMsg6,
                              ADDR szDisplayName,MB_OK

        .elseif wParam == 57
            szText tbMsg7,"WM_COMMAND ID 57"
            invoke MessageBox,hWin,ADDR tbMsg7,
                              ADDR szDisplayName,MB_OK

        .elseif wParam == 58
            szText tbMsg8,"WM_COMMAND ID 58"
            invoke MessageBox,hWin,ADDR tbMsg8,
                              ADDR szDisplayName,MB_OK

        .endif

    ;======== menu commands ========
        .if wParam == 1000
           jmp @F
             szTitleO   db "Open A File",0
             szFilterO  db "All files",0,"*.*",0,
                           "Text files",0,"*.TEXT",0,0
           @@:
    
           invoke FillBuffer,ADDR szFileName,length szFileName,0
           invoke GetFileName,hWin,ADDR szTitleO,ADDR szFilterO
    
           cmp szFileName[0],0   ;<< zero if cancel pressed in dlgbox
           je @F
           ; file name returned in szFileName
           invoke MessageBox,hWin,ADDR szFileName,
                             ADDR szDisplayName,MB_OK
           @@:

        .elseif wParam == 1001
           jmp @F
             szTitleS   db "Save file as",0
             szFilterS  db "All files",0,"*.*",0,
                           "Text files",0,"*.TEXT",0,0
           @@:
    
           invoke FillBuffer,ADDR szFileName,length szFileName,0
           invoke SaveFileName,hWin,ADDR szTitleS,ADDR szFilterS
    
           cmp szFileName[0],0   ;<< zero if cancel pressed in dlgbox
           je @F
           ; file name returned in szFileName
           invoke MessageBox,hWin,ADDR szFileName,
                             ADDR szDisplayName,MB_OK
           @@:

        .endif
        .if wParam == 1010
            invoke SendMessage,hWin,WM_SYSCOMMAND,SC_CLOSE,NULL
        .elseif wParam == 1900
            szText AboutMsg,"Prostart Pure Assembler Template",13,10,\
            "Copyright © Prostart 1999"
            invoke ShellAbout,hWin,ADDR szDisplayName,ADDR AboutMsg,hIcon
        .endif
    ;====== end menu commands ======

    .elseif uMsg == WM_SYSCOLORCHANGE
        invoke Do_ToolBar,hWin

    .elseif uMsg == WM_CREATE
        invoke Do_ToolBar,hWin

        invoke Do_Status,hWin

    .elseif uMsg == WM_SIZE
        invoke SendMessage,hToolBar,TB_AUTOSIZE,0,0
        invoke MoveWindow,hStatus,0,0,0,0,TRUE

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

SplashProc proc hWin   :DWORD,
                uMsg   :DWORD,
                wParam :DWORD,
                lParam :DWORD

    LOCAL hDC :DWORD
    LOCAL Rct :RECT
    LOCAL Ps  :PAINTSTRUCT

    .if uMsg == WM_PAINT
        invoke BeginPaint,hWin,ADDR Ps
        mov hDC, eax

      ; ----------------------------------------------------------
      ; This area is where you control what is put on the splash
      ; screen, text, BitBlt() bitmaps or GDI based graphics
      ; drawing functions.
      ; ----------------------------------------------------------

        invoke SetBkMode,hDC,TRANSPARENT
        invoke GetClientRect,hWin,ADDR Rct

        szText splashMsg,"Splash Screen"
        invoke DrawText,hDC,ADDR splashMsg,13,ADDR Rct,
                        DT_SINGLELINE or DT_VCENTER or DT_CENTER

      ; ----------------------------------------------------------

        invoke EndPaint,hWin,ADDR Ps
        return 0

    .endif

    invoke DefWindowProc,hWin,uMsg,wParam,lParam

    ret

SplashProc endp

; ########################################################################

end start
