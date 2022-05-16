; #########################################################################
;
; This example program show how to use a macro that works very similar
; to the older TASM CALL syntax in the place of the MASM "invoke"
; syntax. "invoke" is more reliable in that it performs parameter
; checking but this example show in part the power of the MACRO capacity
; of MASM.

; #########################################################################

      .386
      .model flat, stdcall  ; 32 bit memory model
      option casemap :none  ; case sensitive

      include scall.inc     ; local includes for this file

; ------------------------------------------------------------------
; macro for making STDCALL procedure and API calls.
; ------------------------------------------------------------------

Scall MACRO name:REQ,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12, \
                     p13,p14,p15,p16,p17,p18,p19,p20,p21,p22

    ;; ---------------------------------------
    ;; loop through arguments backwards, push
    ;; NON blank ones and call the function.
    ;; ---------------------------------------

    FOR arg,<p22,p21,p20,p19,p18,p17,p16,p15,p14,p13,\
             p12,p11,p10,p9,p8,p7,p6,p5,p4,p3,p2,p1>
      IFNB <arg>    ;; If not blank
        push arg    ;; push parameter
      ENDIF
    ENDM

    call name       ;; call the procedure

ENDM

; ------------------------------------------------------------------

; #########################################################################

.code

start:
      Scall GetModuleHandle, NULL
      mov hInstance, eax

      Scall GetCommandLine
      mov CommandLine, eax

      Scall WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT
      Scall ExitProcess,eax

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
      LOCAL lpMsg:DWORD

      lea eax, msg
      mov lpMsg, eax

      ;==================================================
      ; Fill WNDCLASSEX structure with required variables
      ;==================================================

      Scall LoadIcon,hInst,500    ; icon ID
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
        Scall LoadCursor,NULL,IDC_ARROW
      mov wc.hCursor,        eax
      m2m wc.hIconSm,        hIcon

      lea eax, wc
      Scall RegisterClassEx, eax

      ;================================
      ; Centre window at following size
      ;================================

      mov Wwd, 500
      mov Wht, 350

      Scall GetSystemMetrics,SM_CXSCREEN
      Scall TopXY,Wwd,eax
      mov Wtx, eax

      Scall GetSystemMetrics,SM_CYSCREEN
      Scall TopXY,Wht,eax
      mov Wty, eax

      Scall CreateWindowEx,WS_EX_LEFT,\
                           OFFSET szClassName,\
                           OFFSET szDisplayName,\
                           WS_OVERLAPPEDWINDOW,\
                           Wtx,Wty,Wwd,Wht,\
                           NULL,NULL,\
                           hInst,NULL
      mov   hWnd,eax

      Scall LoadMenu,hInst,600  ; menu ID
      Scall SetMenu,hWnd,eax

      Scall ShowWindow,hWnd,SW_SHOWNORMAL
      Scall UpdateWindow,hWnd

      ;===================================
      ; Loop until PostQuitMessage is sent
      ;===================================

    StartLoop:
      Scall GetMessage,lpMsg,NULL,0,0
      cmp eax, 0
      je ExitLoop
      Scall TranslateMessage,lpMsg
      Scall DispatchMessage,lpMsg
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
            Scall SendMessage,hWin,WM_SYSCOMMAND,SC_CLOSE,NULL
        .elseif wParam == 1900
            szText AboutMsg,"Prostart Pure Assembler Template",13,10,\
            "Copyright © Prostart 1999"
            Scall ShellAbout,hWin,OFFSET szDisplayName,OFFSET AboutMsg,hIcon
        .endif
    ;====== end menu commands ======

    .elseif uMsg == WM_CREATE

    .elseif uMsg == WM_SIZE

    .elseif uMsg == WM_PAINT
        lea edx, Ps
        Scall BeginPaint,hWin,edx
          mov hDC, eax
          Scall Paint_Proc,hWin,hDC
        Scall EndPaint,hWin,edx
        return 0

    .elseif uMsg == WM_CLOSE

    .elseif uMsg == WM_DESTROY
        Scall PostQuitMessage,NULL
        return 0 
    .endif

    Scall DefWindowProc,hWin,uMsg,wParam,lParam

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

    Scall GetSysColor,COLOR_BTNHIGHLIGHT
    mov btn_hi, eax

    Scall GetSysColor,COLOR_BTNSHADOW
    mov btn_lo, eax

    return 0

Paint_Proc endp

; ########################################################################

end start
