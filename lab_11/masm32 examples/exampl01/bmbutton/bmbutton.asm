; #########################################################################

      .386
      .model flat, stdcall  ; 32 bit memory model
      option casemap :none  ; case sensitive

      include bmbutton.inc     ; local includes for this file

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

      invoke LoadIcon,hInst,1    ; icon ID
      mov hIcon, eax

      szText szClassName,"bmbtn_Class"

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

      mov Wwd, 250
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

        .if wParam == 400
        szText icoMsg1,"Single Icon Button"
            invoke MessageBox,hWin,ADDR icoMsg1,
                              ADDR szDisplayName,MB_OK
        .elseif wParam == 401
        szText icoMsg2,"Two Icon Button"
            invoke MessageBox,hWin,ADDR icoMsg2,
                              ADDR szDisplayName,MB_OK

        .elseif wParam == 402
        szText bmpMsg1,"Single Bitmap Button"
            invoke MessageBox,hWin,ADDR bmpMsg1,
                              ADDR szDisplayName,MB_OK

        .elseif wParam == 403
        szText bmpMsg2,"Two Bitmap Button"
            invoke MessageBox,hWin,ADDR bmpMsg2,
                              ADDR szDisplayName,MB_OK

        .endif

    ;======== menu commands ========
    .elseif uMsg == WM_CREATE
        invoke IconButton,hWin,20,20,36,36,400
        mov hBtn1, eax
        invoke LoadIcon,hInstance,2
        invoke SendMessage,hBtn1,BM_SETIMAGE,1,eax

        invoke IconButton,hWin,20,60,36,36,401
        mov hBtn2, eax
        invoke SetWindowLong,hBtn2,GWL_WNDPROC,BtnProc
        mov lpBtnProc, eax

        invoke LoadIcon,hInstance,2
        invoke SendMessage,hBtn2,BM_SETIMAGE,1,eax

        invoke LoadBitmap,hInstance,10
        mov hBmp1, eax
        invoke SetBmpColor,hBmp1
        mov hBmp1,eax

        invoke LoadBitmap,hInstance,11
        mov hBmp2, eax
        invoke SetBmpColor,hBmp2
        mov hBmp2,eax

        invoke BmpButton,hWin,120,20,100,36,402
        mov hBtn3, eax
        invoke SendMessage,hBtn3,BM_SETIMAGE,0,hBmp1

        invoke BmpButton,hWin,120,60,100,36,403
        mov hBtn4, eax
        invoke SendMessage,hBtn4,BM_SETIMAGE,0,hBmp1

        invoke SetWindowLong,hBtn4,GWL_WNDPROC,bmpProc
        mov lpfnbmpProc, eax


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

IconButton proc hParent:DWORD,a:DWORD,b:DWORD,wd:DWORD,ht:DWORD,ID:DWORD

; IconButton PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
; invoke IconButton,hWnd,20,20,100,25,500

    szText icoBtnCl,"BUTTON"
    szText blnk1,0

    invoke CreateWindowEx,0,
            ADDR icoBtnCl,ADDR blnk1,
            WS_CHILD or WS_VISIBLE or BS_ICON,
            a,b,wd,ht,hParent,ID,
            hInstance,NULL

    ret

IconButton endp

; ########################################################################

BmpButton proc hParent:DWORD,a:DWORD,b:DWORD,wd:DWORD,ht:DWORD,ID:DWORD

; BmpButton PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
; invoke BmpButton,hWnd,20,20,100,25,500

    szText bmpBtnCl,"BUTTON"
    szText blnk2,0

    invoke CreateWindowEx,0,
            ADDR bmpBtnCl,ADDR blnk2,
            WS_CHILD or WS_VISIBLE or BS_BITMAP,
            a,b,wd,ht,hParent,ID,
            hInstance,NULL

    ret

BmpButton endp

; #########################################################################

BtnProc proc hCtl   :DWORD,
             uMsg   :DWORD,
             wParam :DWORD,
             lParam :DWORD

    .if uMsg == WM_KEYDOWN
        jmp lbd
    .elseif uMsg == WM_KEYUP
        jmp lbu
    .elseif uMsg == WM_LBUTTONDOWN
        lbd:
        invoke LoadIcon,hInstance,3
        invoke SendMessage,hBtn2,BM_SETIMAGE,1,eax
    .elseif uMsg == WM_LBUTTONUP
        lbu:
        invoke LoadIcon,hInstance,2
        invoke SendMessage,hBtn2,BM_SETIMAGE,1,eax
    .endif

    invoke CallWindowProc,lpBtnProc,hCtl,uMsg,wParam,lParam

    ret

BtnProc endp

; #########################################################################

SetBmpColor proc hBitmap:DWORD

    LOCAL mDC       :DWORD
    LOCAL hBrush    :DWORD
    LOCAL hOldBmp   :DWORD
    LOCAL hReturn   :DWORD
    LOCAL hOldBrush :DWORD

      invoke CreateCompatibleDC,NULL
      mov mDC,eax

      invoke SelectObject,mDC,hBitmap
      mov hOldBmp,eax

      invoke GetSysColor,COLOR_BTNFACE
      invoke CreateSolidBrush,eax
      mov hBrush,eax

      invoke SelectObject,mDC,hBrush
      mov hOldBrush,eax

      invoke GetPixel,mDC,1,1
      invoke ExtFloodFill,mDC,1,1,eax,FLOODFILLSURFACE

      invoke SelectObject,mDC,hOldBrush
      invoke DeleteObject,hBrush

      invoke SelectObject,mDC,hBitmap
      mov hReturn,eax
      invoke DeleteDC,mDC

      mov eax,hReturn

    ret

SetBmpColor endp

; #########################################################################

bmpProc proc hCtl   :DWORD,
             uMsg   :DWORD,
             wParam :DWORD,
             lParam :DWORD

    .if uMsg == WM_KEYDOWN
        jmp lbda
    .elseif uMsg == WM_KEYUP
        jmp lbua
    .elseif uMsg == WM_LBUTTONDOWN
        lbda:
        invoke SendMessage,hBtn4,BM_SETIMAGE,0,hBmp2
    .elseif uMsg == WM_LBUTTONUP
        lbua:
        invoke SendMessage,hBtn4,BM_SETIMAGE,0,hBmp1
    .endif

    invoke CallWindowProc,lpfnbmpProc,hCtl,uMsg,wParam,lParam

    ret

bmpProc endp

; #########################################################################


	

end start
