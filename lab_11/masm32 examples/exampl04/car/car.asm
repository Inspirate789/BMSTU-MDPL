; #########################################################################

      .486                      ; create 32 bit code
      .model flat, stdcall      ; 32 bit memory model
      option casemap :none      ; case sensitive

      include car.inc        ; local includes for this file

.code

; #########################################################################

start:

    ; ------------------
    ; set global values
    ; ------------------
      invoke GetModuleHandle, NULL
      mov hInstance, eax

      invoke GetCommandLine
      mov CommandLine, eax

      invoke LoadIcon,hInstance,500    ; icon ID
      mov hIcon, eax

      invoke LoadCursor,NULL,IDC_ARROW
      mov hCursor, eax

      invoke GetSystemMetrics,SM_CXSCREEN
      mov sWid, eax

      invoke GetSystemMetrics,SM_CYSCREEN
      mov sHgt, eax

      call Main

      invoke ExitProcess,eax

; #########################################################################

Main proc

    LOCAL Wwd:DWORD,Wht:DWORD,Wtx:DWORD,Wty:DWORD

    STRING szClassName,"car_Class"

  ; --------------------------------------------
  ; register class name for CreateWindowEx call
  ; --------------------------------------------
    invoke RegisterWinClass,ADDR WndProc,ADDR szClassName,
                       hIcon,hCursor,COLOR_BTNFACE+1

    mov Wwd, 530
    mov Wht, 250
    invoke TopXY,Wwd,sWid
    mov Wtx, eax
    invoke TopXY,Wht,sHgt
    mov Wty, eax

    invoke CreateWindowEx,WS_EX_LEFT,
                          ADDR szClassName,
                          ADDR szDisplayName,
                          WS_POPUP or WS_SYSMENU or WS_CAPTION,
                          Wtx,Wty,Wwd,Wht,
                          NULL,NULL,
                          hInstance,NULL
    mov hWnd,eax

  ; ---------------------------
  ; macros for unchanging code
  ; ---------------------------
    DisplayWindow hWnd,SW_SHOWNORMAL

    call MsgLoop
    ret

Main endp

; #########################################################################

RegisterWinClass proc lpWndProc:DWORD, lpClassName:DWORD,
                      Icon:DWORD, Cursor:DWORD, bColor:DWORD

    LOCAL wc:WNDCLASSEX

    mov wc.cbSize,         sizeof WNDCLASSEX
    mov wc.style,          CS_BYTEALIGNCLIENT or \
                           CS_BYTEALIGNWINDOW
    m2m wc.lpfnWndProc,    lpWndProc
    mov wc.cbClsExtra,     NULL
    mov wc.cbWndExtra,     NULL
    m2m wc.hInstance,      hInstance
    m2m wc.hbrBackground,  bColor
    mov wc.lpszMenuName,   NULL
    m2m wc.lpszClassName,  lpClassName
    m2m wc.hIcon,          Icon
    m2m wc.hCursor,        Cursor
    m2m wc.hIconSm,        Icon

    invoke RegisterClassEx, ADDR wc

    ret

RegisterWinClass endp

; ########################################################################

MsgLoop proc

  ; ------------------------------------------
  ; The following 4 equates are available for
  ; processing messages directly in the loop.
  ; m_hWnd - m_Msg - m_wParam - m_lParam
  ; ------------------------------------------

    LOCAL msg:MSG

    StartLoop:
      invoke GetMessage,ADDR msg,NULL,0,0
      cmp eax, 0
      je ExitLoop
      invoke TranslateMessage, ADDR msg
      invoke DispatchMessage,  ADDR msg
      jmp StartLoop
    ExitLoop:

    mov eax, msg.wParam
    ret

MsgLoop endp

; #########################################################################

WndProc proc hWin   :DWORD,
             uMsg   :DWORD,
             wParam :DWORD,
             lParam :DWORD

    LOCAL var    :DWORD
    LOCAL caW    :DWORD
    LOCAL caH    :DWORD
    LOCAL Rct    :RECT
    LOCAL buffer1[128]:BYTE  ; these are two spare buffers
    LOCAL buffer2[128]:BYTE  ; for text manipulation etc..

    .if uMsg == WM_COMMAND
    ;======== toolbar commands ========
        .if wParam == 50
            invoke MessageBox,hWin,SADD("JPG file handling in win32 assembler"),
                              SADD("About Ernie Murphy's new library"),MB_OK
        .endif

    .elseif uMsg == WM_CREATE
        invoke BitmapFromResource, hInstance, 2000
        mov hBmp, eax

        invoke PushButton,SADD("About"),hWin,210,180,100,25,50

    .elseif uMsg == WM_SYSCOLORCHANGE

    .elseif uMsg == WM_SIZE

    .elseif uMsg == WM_PAINT
        invoke Paint_Proc,hWin

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

Paint_Proc proc hWin:DWORD

    LOCAL hDC   :DWORD
    LOCAL hOld  :DWORD
    LOCAL memDC :DWORD
    LOCAL ps    :PAINTSTRUCT

    invoke BeginPaint,hWnd,ADDR ps
    mov hDC, eax

    invoke CreateCompatibleDC,hDC
    mov memDC, eax
    
    invoke SelectObject,memDC,hBmp
    mov hOld, eax

    invoke BitBlt,hDC,0,1,550,175,memDC,0,0,SRCCOPY

    invoke SelectObject,hDC,hOld
    invoke DeleteDC,memDC

    invoke EndPaint,hWin,ADDR ps

    ret

Paint_Proc endp

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
