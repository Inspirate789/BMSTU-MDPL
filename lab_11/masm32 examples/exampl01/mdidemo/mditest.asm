; #########################################################################

      .386
      .model flat, stdcall  ; 32 bit memory model
      option casemap :none  ; case sensitive

      include mditest.inc     ; local includes for this file

    ; ---------------------------------------
    ; new MDI windows are started by clicking
    ; the left button in the toolbar.
    ; ---------------------------------------

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
      LOCAL msg  :MSG
      LOCAL Wwd  :DWORD
      LOCAL Wht  :DWORD
      LOCAL Wtx  :DWORD
      LOCAL Wty  :DWORD

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
      mov wc.hbrBackground,  NULL   ; Stops flickering
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

    LOCAL var       :DWORD
    LOCAL caW       :DWORD
    LOCAL caH       :DWORD
    LOCAL hDC       :DWORD
    LOCAL tbH       :DWORD
    LOCAL sbH       :DWORD
    LOCAL mdihWnd   :DWORD
    LOCAL Rct       :RECT
    LOCAL Ps        :PAINTSTRUCT
    LOCAL tbab      :TBADDBITMAP
    LOCAL tbb       :TBBUTTON
    LOCAL cc        :CLIENTCREATESTRUCT
    LOCAL buffer1[128]:BYTE  ; these are two spare buffers
    LOCAL buffer2[128]:BYTE  ; for text manipulation etc..

    .if uMsg == WM_COMMAND
    ;======== toolbar commands ========

        .if wParam == 50
            invoke MakeMDIwin

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
                           "Text files",0,"*.TXT",0,0
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
                           "Text files",0,"*.TXT",0,0
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

        .elseif wParam == 1800
            invoke SendMessage,hClient,WM_MDITILE,MDITILE_HORIZONTAL,0

        .elseif wParam == 1801
            invoke SendMessage,hClient,WM_MDICASCADE,0,0

        .elseif wParam == 1802
            invoke SendMessage,hClient,WM_MDIICONARRANGE,0,0

        .elseif wParam == 1803
            invoke SendMessage,hClient,WM_MDINEXT,NULL,0

        .elseif wParam == 1804
            @@:
            invoke SendMessage,hClient,WM_MDIGETACTIVE,0,0
            cmp eax, 0
            je @F
            invoke SendMessage,hClient,WM_MDIDESTROY,eax,0
            jmp @B
            @@:

        .elseif wParam == 1900
            szText AboutMsg,"MASM32 MDI Sample",13,10,\
            "Copyright © MASM32 1999"
            invoke ShellAbout,hWin,ADDR szDisplayName,ADDR AboutMsg,hIcon
        .endif
    ;====== end menu commands ======

    .elseif uMsg == WM_SYSCOLORCHANGE
        invoke Do_ToolBar,hWin

    .elseif uMsg == WM_CREATE

        invoke Do_ToolBar,hWin
        invoke Do_Status,hWin

        invoke MDIclass

        invoke LoadMenu,hInstance,600  ; menu ID
        mov hMenu, eax
        invoke SetMenu,hWin,hMenu

        invoke GetSubMenu,hMenu,1   ; put submenu number in structure
        mov cc.hWindowMenu,eax

        szText mdiCl,"MDICLIENT"

        invoke CreateWindowEx,WS_EX_CLIENTEDGE,
                              ADDR mdiCl,NULL,
                              WS_CHILD or WS_CLIPCHILDREN or \ 
                              WS_VISIBLE or WS_VSCROLL or WS_HSCROLL,
                              0,0,0,0,hWin,NULL,hInstance,ADDR cc
        mov hClient, eax

    .elseif uMsg == WM_SIZE
        invoke SendMessage,hToolBar,TB_AUTOSIZE,0,0
        invoke MoveWindow,hStatus,0,0,0,0,TRUE

        invoke GetWindowRect,hToolBar,ADDR Rct
        mov eax, Rct.top
        sub Rct.bottom, eax
        m2m tbH, Rct.bottom

        invoke GetWindowRect,hStatus,ADDR Rct
        mov eax, Rct.top
        sub Rct.bottom, eax
        m2m sbH, Rct.bottom

        invoke GetClientRect,hWnd,ADDR Rct

        mov eax, Rct.bottom
        sub eax, tbH
        sub eax, sbH
        mov sbH, eax

        invoke MoveWindow,hClient,0,tbH,Rct.right,sbH,TRUE
        return 0

    .elseif uMsg == WM_PAINT
        invoke BeginPaint,hWin,ADDR Ps
          mov hDC, eax
          invoke Paint_Proc,hWin,hDC
        invoke EndPaint,hWin,ADDR Ps
        return 0

    .elseif uMsg == WM_CLOSE
        szText TheText,"Please Confirm Exit"
        invoke MessageBox,hWin,ADDR TheText,ADDR szDisplayName,MB_YESNO
          .if eax == IDNO
            return 0
          .endif

    .elseif uMsg == WM_DESTROY
        invoke PostQuitMessage,NULL
        return 0 
    .endif

    invoke DefFrameProc,hWin,hClient,uMsg,wParam,lParam

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

MakeMDIwin proc

    LOCAL mdihWnd :DWORD
    LOCAL Rct     :RECT

    invoke GetClientRect,hWnd,ADDR Rct

    sub Rct.right, 24

    sub Rct.bottom, 75

    szText mdiTitle,"Untitled"

    invoke CreateWindowEx,WS_EX_MDICHILD,
                          ADDR cName,
                          ADDR mdiTitle,
                          MDIS_ALLCHILDSTYLES,
                          10,10,Rct.right,Rct.bottom,
                          hClient,NULL,hInstance,NULL
    mov mdihWnd, eax

    invoke ShowWindow,mdihWnd,SW_SHOW

    ret

MakeMDIwin endp

; #########################################################################

MDIclass proc

    mov mdi.cbSize,         sizeof WNDCLASSEX
    mov mdi.style,          CS_HREDRAW or CS_VREDRAW or CS_BYTEALIGNWINDOW
    mov mdi.lpfnWndProc,    offset MDIproc
    mov mdi.cbClsExtra,     NULL
    mov mdi.cbWndExtra,     NULL
    m2m mdi.hInstance,      hInstance
    mov mdi.hbrBackground,  COLOR_BTNFACE+1
    mov mdi.lpszMenuName,   NULL
    mov mdi.lpszClassName,  offset cName
    m2m mdi.hIcon,          hIcon
      invoke LoadCursor,NULL,IDC_ARROW
    mov mdi.hCursor,        eax
    m2m mdi.hIconSm,        hIcon

    invoke RegisterClassEx, ADDR mdi

    ret

MDIclass endp

; #########################################################################

MDIproc proc hWin   :DWORD,
             uMsg   :DWORD,
             wParam :DWORD,
             lParam :DWORD

    .if uMsg == WM_CREATE

    .elseif uMsg == WM_KEYUP
        .if wParam == VK_F6
            invoke SendMessage,hClient,WM_MDINEXT,NULL,0
        .endif
    .endif

    invoke DefMDIChildProc,hWin,uMsg,wParam,lParam

    ret

MDIproc endp

; #########################################################################

end start
