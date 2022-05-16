; #########################################################################
;
;                              GDI Animate
;
; This is a simple example of a GDI based animation technique. It uses the
; API function BitBlt to read different portions of a double bitmap and
; displays them on the client area of the window. The function is fast
; enough with a small bitmap to need a delay between each BLIT and the
; logic used is to have a double bitmap of the same image which is read
; in blocks that step across 1 pixel at a time until the width of the
; bitmap is completely read. This allows a continuous scrolling of the
; bitmap image.

; #########################################################################

      .386
      .model flat, stdcall  ; 32 bit memory model
      option casemap :none  ; case sensitive

      include animate.inc   ; local includes for this file

; #########################################################################

.code

start:
      invoke GetModuleHandle, NULL
      mov hInstance, eax

      invoke LoadBitmap,hInstance,100
      mov hBmp, eax

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
      mov wc.style,          CS_BYTEALIGNWINDOW or CS_BYTEALIGNCLIENT
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

      mov Wwd, 192
      mov Wht, 150

      invoke GetSystemMetrics,SM_CXSCREEN
      invoke TopXY,Wwd,eax
      mov Wtx, eax

      invoke GetSystemMetrics,SM_CYSCREEN
      invoke TopXY,Wht,eax
      mov Wty, eax

      invoke CreateWindowEx,WS_EX_LEFT,
                            ADDR szClassName,
                            ADDR szDisplayName,
                            WS_OVERLAPPED or WS_SYSMENU,
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
    LOCAL Rct    :RECT
    LOCAL hDC    :DWORD
    LOCAL Ps     :PAINTSTRUCT
    LOCAL buffer1[128]:BYTE  ; these are two spare buffers
    LOCAL buffer2[128]:BYTE  ; for text manipulation etc..

    .if uMsg == WM_COMMAND
      .if wParam == 500
          invoke GetDC,hWin
          mov hDC, eax
          invoke Paint_Proc,hWin,hDC,1
          invoke ReleaseDC,hWin,hDC
        return 0
      .endif

    ;======== menu commands ========
    .elseif uMsg == WM_CREATE
        szText RunIt,"Run"
        invoke PushButton,ADDR RunIt,hWin,40,90,100,25,500

    .elseif uMsg == WM_SIZE

    .elseif uMsg == WM_PAINT
        invoke BeginPaint,hWin,ADDR Ps
          mov hDC, eax
          invoke Paint_Proc,hWin,hDC,0
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

Paint_Proc proc hWin:DWORD, hDC:DWORD, movit:DWORD

    LOCAL hOld :DWORD
    LOCAL memDC:DWORD
    LOCAL var1 :DWORD
    LOCAL var2 :DWORD
    LOCAL var3 :DWORD

    invoke CreateCompatibleDC,hDC
    mov memDC, eax
    
    invoke SelectObject,memDC,hBmp
    mov hOld, eax

    .if movit == 0
  ; -------------------
  ; for normal repaint
  ; -------------------
      invoke BitBlt,hDC,10,10,166,68,memDC,0,0,SRCCOPY

    .else
  ; --------------------------
  ; when you press the button
  ; --------------------------
    ; ********************************************************

    mov var3, 0

    .while var3 < 1     ;<< set the number of times image is looped

      mov var1, 0
      .while var1 < 166 ;<<  Bitmap width
      ; ------------------------------------------------
      ; Read across the double bitmap 1 pixel at a time
      ; and display a set rectangle size on the screen
      ; ------------------------------------------------
        invoke BitBlt,hDC,10,10,166,68,memDC,var1,0,SRCCOPY

      ; -----------------------
      ; Simple delay technique
      ; -----------------------
        invoke GetTickCount
        mov var2, eax
        add var2, 10    ; nominal milliseconds delay

        .while eax < var2
          invoke GetTickCount
        .endw

        inc var1
      .endw

    inc var3
    .endw

    ; ********************************************************

    .endif

    invoke SelectObject,hDC,hOld
    invoke DeleteDC,memDC

    return 0

Paint_Proc endp

; ########################################################################

end start
