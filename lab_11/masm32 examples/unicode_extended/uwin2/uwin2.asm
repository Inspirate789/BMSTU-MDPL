; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
;                                Build this project with MAKEIT.BAT
; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    __UNICODE__ equ 1           ; enable UNICODE API functions

    .686p                       ; create 32 bit code
    .mmx                        ; enable MMX instructions
    .xmm                        ; enable SSE instructions
    .model flat, stdcall        ; 32 bit memory model
    option casemap :none        ; case sensitive

    include uwin2.inc           ; local includes for this file

.data?
    szDisplayName dd ?

.code

start:

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

  ; ------------------
  ; set global values
  ; ------------------
    mov hInstance,   rvx(GetModuleHandle, NULL)
    mov CommandLine, rvx(GetCommandLine)
    mov hIcon,       rvx(LoadIcon,hInstance,500)
    mov hCursor,     rvx(LoadCursor,NULL,IDC_ARROW)
    mov sWid,        rvx(GetSystemMetrics,SM_CXSCREEN)
    mov sHgt,        rvx(GetSystemMetrics,SM_CYSCREEN)

    call Main

    invoke ExitProcess,eax

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

Main proc

    LOCAL Wwd:DWORD,Wht:DWORD,Wtx:DWORD,Wty:DWORD,mWid:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL icce:INITCOMMONCONTROLSEX
    LOCAL szClassName   :DWORD

  ; --------------------------------------
  ; comment out the styles you don't need.
  ; --------------------------------------
    mov icce.dwSize, SIZEOF INITCOMMONCONTROLSEX            ; set the structure size
    xor eax, eax                                            ; set EAX to zero

    or eax, ICC_BAR_CLASSES                                 ; toolbar & status bar
    or eax, ICC_WIN95_CLASSES

 ;     or eax, ICC_ANIMATE_CLASS                               ; OR as many styles as you need to it
 ;     or eax, ICC_COOL_CLASSES
 ;     or eax, ICC_DATE_CLASSES
 ;     or eax, ICC_HOTKEY_CLASS
 ;     or eax, ICC_INTERNET_CLASSES
 ;     or eax, ICC_LISTVIEW_CLASSES
 ;     or eax, ICC_PAGESCROLLER_CLASS
 ;     or eax, ICC_PROGRESS_CLASS
 ;     or eax, ICC_TAB_CLASSES
 ;     or eax, ICC_TREEVIEW_CLASSES
 ;     or eax, ICC_UPDOWN_CLASS
 ;     or eax, ICC_USEREX_CLASSES

  ; --------------------------------------------
  ; NOTE : It is marginally more efficient to OR
  ; required styles together at assembly time.
  ; --------------------------------------------

    mov icce.dwICC, eax
    invoke InitCommonControlsEx,ADDR icce                   ; initialise the common control library
  ; --------------------------------------

    mov szClassName,   uc$("Application_Class")
    mov szDisplayName, uc$("Unicode Window")

  ; ---------------------------------------------------
  ; set window class attributes in WNDCLASSEX structure
  ; ---------------------------------------------------
    mov wc.cbSize,         sizeof WNDCLASSEX
    mov wc.style,          CS_BYTEALIGNCLIENT or CS_BYTEALIGNWINDOW
    m2m wc.lpfnWndProc,    OFFSET WndProc
    mov wc.cbClsExtra,     NULL
    mov wc.cbWndExtra,     NULL
    m2m wc.hInstance,      hInstance
    m2m wc.hbrBackground,  COLOR_BTNFACE+1
    mov wc.lpszMenuName,   NULL
    m2m wc.lpszClassName,  szClassName
    m2m wc.hIcon,          hIcon
    m2m wc.hCursor,        hCursor
    m2m wc.hIconSm,        hIcon

  ; ------------------------------------
  ; register class with these attributes
  ; ------------------------------------
    invoke RegisterClassEx, ADDR wc

  ; ---------------------------------------------
  ; set width and height as percentages of screen
  ; ---------------------------------------------
    invoke GetPercent,sWid,70
    mov Wwd, eax
    invoke GetPercent,sHgt,70
    mov Wht, eax

  ; ----------------------
  ; set aspect ratio limit
  ; ----------------------
    FLOAT4 aspect_ratio, 1.4    ; set the maximum startup aspect ratio

    fild Wht                    ; load source
    fld aspect_ratio            ; load multiplier
    fmul                        ; multiply source by multiplier
    fistp mWid                  ; store result in variable

    mov eax, Wwd
    .if eax > mWid              ; if the default window width is > aspect ratio
      m2m Wwd, mWid             ; set the width to the maximum aspect ratio
    .endif

  ; ------------------------------------------------
  ; Top X and Y co-ordinates for the centered window
  ; ------------------------------------------------
    mov eax, sWid
    sub eax, Wwd                ; sub window width from screen width
    shr eax, 1                  ; divide it by 2
    mov Wtx, eax                ; copy it to variable

    mov eax, sHgt
    sub eax, Wht                ; sub window height from screen height
    shr eax, 1                  ; divide it by 2
    mov Wty, eax                ; copy it to variable

IF 0  ; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    create the main window with the size and attributes defined above

    WS_OVERLAPPEDWINDOW         = a sizable window with a system menu
    WS_OVERLAPPED               = a fixed size window
    WS_OVERLAPPED or WS_SYSMENU = a fixed window with a system menu

    OR the styles from CreateWindowEx() together to get the window characteristics you require

ENDIF ; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    invoke CreateWindowEx,WS_EX_LEFT or WS_EX_ACCEPTFILES,
                          szClassName,
                          szDisplayName,
                          WS_OVERLAPPEDWINDOW,
                          Wtx,Wty,Wwd,Wht,
                          NULL,NULL,
                          hInstance,NULL
    mov hWnd,eax

    invoke LoadMenu,hInstance,600
    invoke SetMenu,hWnd,eax

    invoke ShowWindow,hWnd, SW_SHOWNORMAL
    invoke UpdateWindow,hWnd

    call MsgLoop
    ret

Main endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

MsgLoop proc

    LOCAL msg:MSG

    push ebx
    lea ebx, msg
    jmp getmsg

  msgloop:
    invoke TranslateMessage, ebx
    invoke DispatchMessage,  ebx
  getmsg:
    invoke GetMessage,ebx,0,0,0
    test eax, eax
    jnz msgloop

    pop ebx
    ret

MsgLoop endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

WndProc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

    LOCAL var    :DWORD
    LOCAL caW    :DWORD
    LOCAL caH    :DWORD
    LOCAL fname  :DWORD
    LOCAL opatn  :DWORD
    LOCAL spatn  :DWORD
    LOCAL rct    :RECT
    LOCAL buffer1[260]:BYTE  ; these are two spare buffers
    LOCAL buffer2[260]:BYTE  ; for text manipulation etc..

    Switch uMsg
      Case WM_COMMAND
      ; -------------------------------------------------------------------
        Switch wParam

          case 1999
          app_close:
            invoke SendMessage,hWin,WM_SYSCOMMAND,SC_CLOSE,NULL

        Endsw
      ; -------------------------------------------------------------------

      case WM_DROPFILES
      ; --------------------------
      ; process dropped files here
      ; --------------------------
        mov fname, DropFileName(wParam)
        fnx MsgboxI,hWin,fname,"WM_DROPFILES",MB_OK,500
        return 0

      case WM_CREATE

      case WM_SIZE
      case WM_CLOSE
      ; -----------------------------
      ; perform any required cleanups
      ; here before closing.
      ; -----------------------------

      case WM_DESTROY
        invoke PostQuitMessage,NULL
        return 0

    Endsw

    invoke DefWindowProc,hWin,uMsg,wParam,lParam

    ret

WndProc endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

MsgboxI proc hParent:DWORD,pText:DWORD,pTitle:DWORD,mbStyle:DWORD,IconID:DWORD

    LOCAL mbp   :MSGBOXPARAMS

    or mbStyle, MB_USERICON

    mov mbp.cbSize,             SIZEOF mbp
    m2m mbp.hwndOwner,          hParent
    mov mbp.hInstance,          rvx(GetModuleHandle,0)
    m2m mbp.lpszText,           pText
    m2m mbp.lpszCaption,        pTitle
    m2m mbp.dwStyle,            mbStyle
    m2m mbp.lpszIcon,           IconID
    mov mbp.dwContextHelpId,    NULL
    mov mbp.lpfnMsgBoxCallback, NULL
    mov mbp.dwLanguageId,       NULL

    invoke MessageBoxIndirect,ADDR mbp

    ret

MsgboxI endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

end start
