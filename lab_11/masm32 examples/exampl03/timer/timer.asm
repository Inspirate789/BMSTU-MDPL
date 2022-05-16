; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

      .486                      ; create 32 bit code
      .model flat, stdcall      ; 32 bit memory model
      option casemap :none      ; case sensitive

      include timer.inc         ; local includes for this file

.code

start:

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    ; ------------------
    ; set global values
    ; ------------------
      mov hInstance,   FUNC(GetModuleHandle, NULL)
      mov CommandLine, FUNC(GetCommandLine)
      mov hIcon,       FUNC(LoadIcon,NULL,IDI_ASTERISK)
      mov hCursor,     FUNC(LoadCursor,NULL,IDC_ARROW)
      mov sWid,        FUNC(GetSystemMetrics,SM_CXSCREEN)
      mov sHgt,        FUNC(GetSystemMetrics,SM_CYSCREEN)

      call Main

      invoke ExitProcess,eax

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

Main proc

    LOCAL Wwd:DWORD,Wht:DWORD,Wtx:DWORD,Wty:DWORD

    STRING szClassName,"Timer_Demo_Class"

  ; --------------------------------------------
  ; register class name for CreateWindowEx call
  ; --------------------------------------------
    invoke RegisterWinClass,ADDR WndProc,ADDR szClassName,
                       hIcon,hCursor,COLOR_BTNFACE+1

    mov Wwd, 300
    mov Wht, 250
    invoke TopXY,Wwd,sWid
    mov Wtx, eax
    invoke TopXY,Wht,sHgt
    mov Wty, eax

    invoke CreateWindowEx,WS_EX_LEFT or WS_EX_ACCEPTFILES,
                          ADDR szClassName,
                          chr$("Display Local Time"),
                          WS_OVERLAPPEDWINDOW,
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

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

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

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

MsgLoop proc

    LOCAL msg:MSG

    jmp InLoop                              ; not needed but for "purists"

    StartLoop:
      invoke TranslateMessage, ADDR msg
      invoke DispatchMessage,  ADDR msg
    InLoop:
      invoke GetMessage,ADDR msg,NULL,0,0
      test eax, eax
      jnz StartLoop

    mov eax, msg.wParam
    ret

MsgLoop endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

WndProc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

    LOCAL buffer1[260]:BYTE

    Switch uMsg
      Case WM_CREATE
      ; ---------------------------------------------------
      ; set the timer with a 1000 MS (1 second) update rate
      ; ---------------------------------------------------
        invoke SetTimer,hWin,222,1000,NULL

      Case WM_TIMER
      ; -------------------------------
      ; receive the timer message every
      ; second, retrieve the local time
      ; and display it on the title bar
      ; -------------------------------
        invoke GetTimeFormat,LOCALE_USER_DEFAULT,NULL,NULL,NULL,ADDR buffer1,260
        fn SetWindowText,hWnd,ADDR buffer1
        return 0

      Case WM_CLOSE
      ; -------------------------
      ; destroy the timer on exit
      ; -------------------------
        invoke KillTimer,hWin,222

      Case WM_DESTROY
        invoke PostQuitMessage,NULL
        return 0

    Endsw

    invoke DefWindowProc,hWin,uMsg,wParam,lParam

    ret

WndProc endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

TopXY proc wDim:DWORD, sDim:DWORD

    shr sDim, 1      ; divide screen dimension by 2
    shr wDim, 1      ; divide window dimension by 2
    mov eax, wDim    ; copy window dimension into eax
    sub sDim, eax    ; sub half win dimension from half screen dimension

    return sDim

TopXY endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start
