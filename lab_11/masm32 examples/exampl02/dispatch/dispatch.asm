; #########################################################################

;     This example has the architecture of a message despatcher which
;     has an individual procedure for each required message. It may
;     appeal to some people as it shifts towards "event" style
;     programming. It is neither efficient nor particularly flexible
;     but it demonstrates that assembler can be written in the "event"
;     style as well.

; #########################################################################

      .386
      .model flat, stdcall  ; 32 bit memory model
      option casemap :none  ; case sensitive

      include dispatch.inc  ; local includes for this file

    ; -------------------
    ; handler call macros
    ; -------------------

      Do_WM_CREATE MACRO
        .elseif uMsg == WM_CREATE
        invoke WM_CREATE_Handler,hWin,uMsg,wParam,lParam
      ENDM

      Do_WM_COMMAND MACRO
        .elseif uMsg == WM_COMMAND
        invoke WM_COMMAND_Handler,hWin,uMsg,wParam,lParam
      ENDM

      Do_WM_PAINT MACRO
        .elseif uMsg == WM_PAINT
        invoke WM_PAINT_Handler,hWin,uMsg,wParam,lParam
        mov eax, 0
        ret
      ENDM

      Do_WM_CLOSE MACRO
        .elseif uMsg == WM_CLOSE
        invoke WM_CLOSE_Handler,hWin,uMsg,wParam,lParam
        .if eax == 0
          ret
        .endif
      ENDM

      Do_WM_DESTROY MACRO
        .elseif uMsg == WM_DESTROY
        invoke WM_DESTROY_Handler,hWin,uMsg,wParam,lParam
        mov eax, 0
        ret
      ENDM

    ; -----------------------------
    ; local prototypes and equates
    ; -----------------------------
    
      pd equ <:DWORD>
      p4 equ <PROTO :DWORD,:DWORD,:DWORD,:DWORD>

      PushButton PROTO pd,pd,pd,pd,pd,pd,pd

      WM_CREATE_Handler   p4
      WM_COMMAND_Handler  p4
      WM_PAINT_Handler    p4
      WM_CLOSE_Handler    p4
      WM_DESTROY_Handler  p4

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

      szText szClassName,"Dispatch_Class"

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

    .if uMsg == WM_NCHITTEST

    ; -------------------
    ; handler call macros
    ; -------------------
      Do_WM_CREATE
      Do_WM_COMMAND
      Do_WM_PAINT
      Do_WM_CLOSE
      Do_WM_DESTROY

  ; -------------------
  ; any other done here
  ; -------------------
    .elseif uMsg == WM_SIZE

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

WM_CREATE_Handler proc hWin   :DWORD,
                       uMsg   :DWORD,
                       wParam :DWORD,
                       lParam :DWORD

    szText btnMsg,"Push Button"
    invoke PushButton,ADDR btnMsg,hWin,50,50,150,25,500

    ret

WM_CREATE_Handler endp

; ########################################################################

WM_COMMAND_Handler proc hWin   :DWORD,
                        uMsg   :DWORD,
                        wParam :DWORD,
                        lParam :DWORD

    .if wParam == 500
      szText Pressed,"Button Pressed"
      szText prTitle,"WM_COMMAND here"
      invoke MessageBox,hWin,ADDR Pressed,ADDR prTitle,MB_OK

    .endif

    ret

WM_COMMAND_Handler endp

; ########################################################################

WM_PAINT_Handler proc hWin   :DWORD,
                      uMsg   :DWORD,
                      wParam :DWORD,
                      lParam :DWORD

    LOCAL btn_hi :DWORD
    LOCAL btn_lo :DWORD
    LOCAL hDC    :DWORD
    LOCAL Ps     :PAINTSTRUCT
    LOCAL Rct    :RECT

    invoke BeginPaint,hWin,ADDR Ps
    mov hDC, eax

    invoke GetSysColor,COLOR_BTNHIGHLIGHT
    mov btn_hi, eax

    invoke GetSysColor,COLOR_BTNSHADOW
    mov btn_lo, eax

  ; ---------------------------

  ; Yukkies here

  ; ---------------------------
  
    invoke EndPaint,hWin,ADDR Ps

    return 0

WM_PAINT_Handler endp

; ########################################################################

WM_CLOSE_Handler proc hWin   :DWORD,
                      uMsg   :DWORD,
                      wParam :DWORD,
                      lParam :DWORD

    szText TheText,"Please Confirm Exit"
    invoke MessageBox,hWin,ADDR TheText,ADDR szDisplayName,MB_YESNO

    .if eax == IDNO
      mov eax, 0
      ret
    .endif

    ret

WM_CLOSE_Handler endp

; ########################################################################

WM_DESTROY_Handler proc hWin   :DWORD,
                        uMsg   :DWORD,
                        wParam :DWORD,
                        lParam :DWORD

    invoke PostQuitMessage,NULL

    ret

WM_DESTROY_Handler endp

; ########################################################################

PushButton proc lpText:DWORD,hParent:DWORD,
                a:DWORD,b:DWORD,wd:DWORD,ht:DWORD,ID:DWORD

    szText btnClass,"BUTTON"

    invoke CreateWindowEx,0,
            ADDR btnClass,lpText,
            WS_CHILD or WS_VISIBLE,
            a,b,wd,ht,hParent,ID,
            hInstance,NULL

    ret

PushButton endp

; ########################################################################

end start
