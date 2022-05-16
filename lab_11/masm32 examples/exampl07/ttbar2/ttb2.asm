; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    __UNICODE__ equ 1           ; uncomment to enable UNICODE build

    .686p                       ; create 32 bit code
    .mmx                        ; enable MMX instructions
    .xmm                        ; enable SSE instructions
    .model flat, stdcall        ; 32 bit memory model
    option casemap :none        ; case sensitive

  ; -------------------------------------------------------------
  ; equates for controlling the toolbar button size and placement
  ; -------------------------------------------------------------
    rbht     equ <24>           ; rebar height in pixels
    vpad     equ  <0>           ; *** unused in this example ***
    hpad     equ  <0>           ; set to zero to allow manual spacing
    lind     equ  <5>           ; left side initial indent in pixels

    bColor   equ  <00999999h>   ; client area brush colour

    include ttb2.inc            ; local includes for this file

.code

start:

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

  ; ------------------
  ; set global values
  ; ------------------
    mov hInstance,   rv(GetModuleHandle, NULL)
    mov CommandLine, rv(GetCommandLine)
    mov hIcon,       rv(LoadIcon,hInstance,500)
    mov hCursor,     rv(LoadCursor,NULL,IDC_ARROW)
    mov sWid,        rv(GetSystemMetrics,SM_CXSCREEN)
    mov sHgt,        rv(GetSystemMetrics,SM_CYSCREEN)

  ; ----------------------------------------------------------------
  ; load the rebar background tile stretching it to the rebar height
  ; ----------------------------------------------------------------
    mov tbTile, rv(LoadImage,hInstance,800,IMAGE_BITMAP,sWid,rbht,LR_DEFAULTCOLOR)

    call Main

    invoke ExitProcess,eax

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

Main proc

    LOCAL Wwd:DWORD,Wht:DWORD,Wtx:DWORD,Wty:DWORD,mWid:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL icce:INITCOMMONCONTROLSEX

  ; --------------------------------------
  ; comment out the styles you don't need.
  ; --------------------------------------
    mov icce.dwSize, SIZEOF INITCOMMONCONTROLSEX            ; set the structure size
    xor eax, eax                                            ; set EAX to zero
    or eax, ICC_WIN95_CLASSES
    or eax, ICC_BAR_CLASSES                                 ; comment out the rest
    ; or eax, ICC_TREEVIEW_CLASSES
    ; or eax, ICC_LISTVIEW_CLASSES
    ; or eax, ICC_COOL_CLASSES
    ; or eax, ICC_DATE_CLASSES
    ; or eax, ICC_PROGRESS_CLASS
    ; or eax, ICC_TAB_CLASSES
    ; or eax, ICC_HOTKEY_CLASS
    ; or eax, ICC_INTERNET_CLASSES
    ; or eax, ICC_PAGESCROLLER_CLASS
    ; or eax, ICC_UPDOWN_CLASS
    ; or eax, ICC_ANIMATE_CLASS                               ; OR as many styles as you need to it
    ; or eax, ICC_USEREX_CLASSES
    mov icce.dwICC, eax
    invoke InitCommonControlsEx,ADDR icce                   ; initialise the common control library
  ; --------------------------------------

    STRING szClassName,   "TTB_Class"
    STRING szDisplayName, "Text Toolbar"

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
    mov wc.lpszClassName,  OFFSET szClassName
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

  ; -----------------------------------------------------------------
  ; create the main window with the size and attributes defined above
  ; -----------------------------------------------------------------
    invoke CreateWindowEx,WS_EX_LEFT or WS_EX_ACCEPTFILES,
                          ADDR szClassName,
                          ADDR szDisplayName,
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
    LOCAL buffer1[260]:TCHAR  ; these are two spare buffers
    LOCAL buffer2[260]:TCHAR  ; for text manipulation etc..

    Switch uMsg
      Case WM_COMMAND
      ; -------------------------------------------------------------------
        Switch wParam
          case 50
            fn MsgboxI,hWin,"Button ID  50      ",ustr$(eax),MB_OK,500

          case 51
            fn MsgboxI,hWin,"Button ID  51      ",ustr$(eax),MB_OK,500

          case 52
            fn MsgboxI,hWin,"Button ID  52      ",ustr$(eax),MB_OK,500

          case 53
            fn MsgboxI,hWin,"Button ID  53      ",ustr$(eax),MB_OK,500

          case 54
            fn MsgboxI,hWin,"Button ID  54      ",ustr$(eax),MB_OK,500

          case 55
            fn MsgboxI,hWin,"Button ID  55      ",ustr$(eax),MB_OK,500

          case 56
            jmp app_close

          case 1090
          app_close:
            invoke SendMessage,hWin,WM_SYSCOMMAND,SC_CLOSE,NULL

          case 10000
            invoke DialogBoxParam,hInstance,5000,hWin,ADDR AboutProc,0

        Endsw
      ; -------------------------------------------------------------------

      case WM_DROPFILES
      ; --------------------------
      ; process dropped files here
      ; --------------------------
        mov fname, DropFileName(wParam)
        fn MsgboxI,hWin,fname,"WM_DROPFILES",MB_OK,500
        return 0

      case WM_CREATE
        mov hRebar,   rv(rebar,hInstance,hWin,rbht)     ; create the rebar control
        mov hToolBar, rv(addband,hInstance,hRebar)      ; add the toolbar band to it

 ;         invoke SendMessage,hToolBar,TB_SETINDENT,lind,0

      ; ------------------------------------------------------------------
      ; set vertical and horizontal padding for buttons (units are pixels)
      ; ------------------------------------------------------------------
        mov ax, vpad            ; vertical padding
        rol eax, 16
        mov ax, hpad            ; horizontal padding
        invoke SendMessage,hToolBar,TB_SETPADDING,0,eax

        mov hStatus,  rv(StatusBar,hWin)                ; create the status bar

      case WM_SIZE
        invoke MoveWindow,hStatus,0,0,0,0,TRUE

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

TBcreate proc hParent:DWORD

    TB_BEGIN hParent
    TxtItem  0,  50, "   New   "
    TxtItem  1,  51, "   Open   "
    TxtItem  2,  52, "   Save   "
    TxtItem  3,  53, "   Cut   "
    TxtItem  4,  54, "   Copy   "
    TxtItem  5,  55, "   Paste   "
    TxtItem  6,  56, "   Exit   "
    TB_END

TBcreate endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

StatusBar proc hParent:DWORD

    LOCAL handl :DWORD
    LOCAL sbParts[4] :DWORD

    mov handl, rv(CreateStatusWindow,WS_CHILD or WS_VISIBLE or SBS_SIZEGRIP,NULL,hParent,200)

  ; --------------------------------------------
  ; set the width of each part, -1 for last part
  ; --------------------------------------------
    mov [sbParts+0], 100
    mov [sbParts+4], 200
    mov [sbParts+8], 300
    mov [sbParts+12],-1

    invoke SendMessage,handl,SB_SETPARTS,4,ADDR sbParts

    mov eax, handl

    ret

StatusBar endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

end start
