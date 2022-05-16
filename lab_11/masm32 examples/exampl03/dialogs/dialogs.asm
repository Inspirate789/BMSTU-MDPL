; #########################################################################
;
;      This demo shows how to use the system dialog functions added to
;                                MASM32.LIB
;
;     Common dialog function need to have comdlg32.inc & LIB and the
;     BrowseForFolder function needs to have shell32.inc & LIB and
;     ole32.inc & LIB.
;
; #########################################################################

      .386
      .model flat, stdcall  ; 32 bit memory model
      option casemap :none  ; case sensitive

      include dialogs.inc   ; local includes for this file

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
    LOCAL color  :DWORD
    LOCAL hDC    :DWORD
    LOCAL Rct    :RECT
    LOCAL Ps     :PAINTSTRUCT
    LOCAL buffer1[128]:BYTE  ; these are two spare buffers
    LOCAL buffer2[128]:BYTE  ; for text manipulation etc..
    LOCAL lfnt   :LOGFONT
    LOCAL psd    :PAGESETUPDLG
    LOCAL pd     :PRINTDLG

    .if uMsg == WM_COMMAND
    ;======== menu commands ========
        .if wParam == 1010
            invoke SendMessage,hWin,WM_SYSCOMMAND,SC_CLOSE,NULL
        .elseif wParam == 1900
            szText AboutMsg,"Prostart Pure Assembler Template",13,10,\
            "Copyright © Prostart 1999"
            invoke ShellAbout,hWin,ADDR szDisplayName,ADDR AboutMsg,hIcon
        .endif
        
    ;====== button commands ======

        ; ***********************************************************************

        .if wParam == 500
            szText tstring,"Testing Browse For Folder"
            szText bstring,"Select A Folder"
            mov buffer1[0], 0
            invoke BrowseForFolder,hWin,ADDR buffer1,ADDR tstring,ADDR bstring
            .if buffer1[0] != 0
              invoke SetWindowText,hWin,ADDR buffer1
            .endif

        .elseif wParam == 501
            invoke FontDialog,hWin,ADDR lfnt,CF_BOTH or CF_FIXEDPITCHONLY

            szText tbMsg1,"Selected Font"
            invoke MessageBox,hWin,ADDR lfnt.lfFaceName,
                              ADDR tbMsg1,MB_OK

        .elseif wParam == 502
          ; ----------------------------------------------------
          ; return value in EAX is COLORREF for selected color.
          ; ----------------------------------------------------
            invoke ColorDialog,hWin,hInstance,0 ; CC_FULLOPEN
            mov color, eax

            .data
              colref db 12 dup(?)   ; 12 byte buffer
            .code

            invoke dw2hex, color, ADDR colref
            invoke MessageBox,hWin,ADDR colref,
                              ADDR szDisplayName,MB_OK

        .elseif wParam == 503
          ; ------------------------------------------------
          ; returned values are in the "psd" structure,
          ; one item is displayed, the left margin setting.
          ; ------------------------------------------------
            invoke PageSetupDialog,hWin,ADDR psd,0,1000,750,1000,750
            invoke dw2a,psd.rtMargin.left, ADDR buffer1
            invoke MessageBox,hWin,ADDR buffer1,ADDR szDisplayName,MB_OK

        .elseif wParam == 504
          ; ------------------------------------------
          ; returned values are in the pd" structure,
          ; the page range top value is displayed.
          ; ------------------------------------------
            invoke PrintDialog,hWin,ADDR pd,PD_SHOWHELP
            mov ax, pd.nToPage
            movzx ecx, ax
            invoke dw2a,ecx, ADDR buffer1
            invoke MessageBox,hWin,ADDR buffer1,ADDR szDisplayName,MB_OK

        .endif

        ; ***********************************************************************

    .elseif uMsg == WM_CREATE
        szText bTxt1,"Browse For Folder"
        invoke PushButton,ADDR bTxt1,hWin,20,20,150,25,500

        szText bTxt2,"Font Dialog"
        invoke PushButton,ADDR bTxt2,hWin,20,50,150,25,501

        szText bTxt3,"Color Dialog"
        invoke PushButton,ADDR bTxt3,hWin,20,80,150,25,502

        szText bTxt4,"Page Setup Dialog"
        invoke PushButton,ADDR bTxt4,hWin,20,110,150,25,503

        szText bTxt5,"Print Dialog"
        invoke PushButton,ADDR bTxt5,hWin,20,140,150,25,504


    .elseif uMsg == WM_SIZE

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

end start
