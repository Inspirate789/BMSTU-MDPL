; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
    include \masm32\include\masm32rt.inc
; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

comment * ---------------------------------------------------------------

        This example is a rewrite of one of the earliest masm32 examples
        that enumerates windows running within the operating system. It
        only uses fully documented API functions.

        Note that by closing certain windows within a running operating
        system that you may disable some capacity or make the operating
        system unstable.

        --------------------------------------------------------------- *

      ; ----------------
      ; Local prototypes
      ; ----------------
        WinMain     PROTO :DWORD,:DWORD,:DWORD,:DWORD
        WndProc     PROTO :DWORD,:DWORD,:DWORD,:DWORD
        TopXY       PROTO :DWORD,:DWORD
        EnmProc     PROTO :DWORD,:DWORD
        ListBox     PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
        Static      PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
        ListProc    PROTO :DWORD,:DWORD,:DWORD,:DWORD
        PushButton  PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD

    .data
        szDisplayName db "Enumerated Window Explorer",0
        szClassName   db "Enumerator_Class",0

    .data?
        CommandLine   dd ?
        hWnd          dd ?
        hIcon         dd ?
        hCursor       dd ?
        hInstance     dd ?
        hList         dd ?
        hStat1        dd ?
        hStat2        dd ?
        lpfnListProc  dd ?
        sWid          dd ?
        sHgt          dd ?

    .code

; ¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤

start:
      mov hInstance,   rv(GetModuleHandle, NULL)
      mov CommandLine, rv(GetCommandLine)
      mov hIcon,       rv(LoadIcon,hInstance,500)
      mov hCursor,     rv(LoadCursor,NULL,IDC_ARROW)

      invoke InitCommonControls ; <<<< needed because of manifest file

      invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT

      invoke ExitProcess,eax

; ¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤

WinMain proc hInst:DWORD,hPrevInst:DWORD,CmdLine:DWORD,CmdShow:DWORD

      LOCAL Wwd  :DWORD
      LOCAL Wht  :DWORD
      LOCAL Wtx  :DWORD
      LOCAL Wty  :DWORD
      LOCAL mWid :DWORD
      LOCAL wc   :WNDCLASSEX
      LOCAL msg  :MSG

    ; =================================================
    ; Fill WNDCLASSEX structure with required variables
    ; =================================================
      mov wc.cbSize,         sizeof WNDCLASSEX
      mov wc.style,          CS_BYTEALIGNWINDOW
      mov wc.lpfnWndProc,    offset WndProc
      mov wc.cbClsExtra,     NULL
      mov wc.cbWndExtra,     NULL
      m2m wc.hInstance,      hInst
      mov wc.hbrBackground,  COLOR_BTNFACE+1
      mov wc.lpszMenuName,   NULL
      mov wc.lpszClassName,  offset szClassName
      m2m wc.hIcon,          hIcon
      m2m wc.hCursor,        hCursor
      mov wc.hIconSm,        0

      invoke RegisterClassEx, ADDR wc

      mov sWid, rv(GetSystemMetrics,SM_CXSCREEN)
      mov sHgt, rv(GetSystemMetrics,SM_CYSCREEN)

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

      invoke CreateWindowEx,0,
                            ADDR szClassName,
                            ADDR szDisplayName,
                            WS_OVERLAPPEDWINDOW,
                            Wtx,Wty,Wwd,Wht,
                            NULL,NULL,
                            hInst,NULL
      mov   hWnd,eax

      invoke EnumWindows,ADDR EnmProc,0
      invoke ShowWindow,hWnd,SW_SHOWNORMAL
      invoke UpdateWindow,hWnd

    ; ===================================
    ; Loop until PostQuitMessage is sent
    ; ===================================

      jmp @F

    MsgLoop:
      invoke TranslateMessage, ADDR msg
      invoke DispatchMessage,  ADDR msg
    @@:
      invoke GetMessage,ADDR msg,NULL,0,0
      test eax, eax
      jnz MsgLoop

      return msg.wParam

WinMain endp

; ¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤

WndProc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

    LOCAL rLeft   :DWORD
    LOCAL rTop    :DWORD
    LOCAL rRight  :DWORD
    LOCAL rBottom :DWORD
    LOCAL pbuf    :DWORD
    LOCAL hItem   :DWORD
    LOCAL buffer[128]:BYTE
    LOCAL Rc      :RECT

    .if uMsg == WM_COMMAND
    ; ======== menu commands ========
      .if wParam == 1000
        invoke SendMessage,hWin,WM_SYSCOMMAND,SC_CLOSE,NULL

      .elseif wParam == 1001
        Refresh_It:
        invoke SendMessage,hList,LB_RESETCONTENT,0,0
        invoke EnumWindows,ADDR EnmProc,0

      .elseif wParam == 502     ; -------------------- refresh list
        jmp Refresh_It

      .elseif wParam == 503     ; -------------------- show selected window in list selection
        mov pbuf, ptr$(buffer)

        mov ecx, rv(SendMessage,hList,LB_GETCURSEL,0,0)
        cmp eax, LB_ERR
        jne @F
        ret
      @@:
        fn SendMessage,hList,LB_GETTEXT,ecx,pbuf
        cmp eax, LB_ERR
        jne @F
        ret
      @@:
        mov hItem, uval(trim$(left$(pbuf,11)))
        invoke ShowWindow,hItem,SW_SHOW
        invoke SetForegroundWindow,hItem
        invoke SetFocus,hList

      .elseif wParam == 504     ; -------------------- hide selected window
        mov pbuf, ptr$(buffer)

        mov ecx, rv(SendMessage,hList,LB_GETCURSEL,0,0)
        cmp eax, LB_ERR
        jne @F
        ret
      @@:
        fn SendMessage,hList,LB_GETTEXT,ecx,pbuf
        cmp eax, LB_ERR
        jne @F
        ret
      @@:
        mov hItem, uval(trim$(left$(pbuf,11)))
        invoke ShowWindow,hItem,SW_HIDE
        invoke SetFocus,hList

      .elseif wParam == 505     ; -------------------- close window in list
        mov pbuf, ptr$(buffer)

        mov ecx, rv(SendMessage,hList,LB_GETCURSEL,0,0)
        cmp eax, LB_ERR
        jne @F
        ret
      @@:
        fn SendMessage,hList,LB_GETTEXT,ecx,pbuf
        cmp eax, LB_ERR
        jne @F
        ret
      @@:
        mov hItem, uval(trim$(left$(pbuf,11)))
        invoke SendMessage,hItem,WM_SYSCOMMAND,SC_CLOSE,NULL
        jmp Refresh_It

      .elseif wParam == 506     ; -------------------- terminate this app.
        invoke SendMessage,hWnd,WM_SYSCOMMAND,SC_CLOSE,NULL

      .endif

    ; ====== end menu commands ======

    .elseif uMsg == WM_CREATE
      invoke ListBox,0,20,550,200,hWin,600
      mov hList, eax

      invoke SetWindowLong,hList,GWL_WNDPROC,ListProc
      mov lpfnListProc, eax

      fn Static," hWnd",hWin,5,5,52,18,500
      fn Static," Class Name",hWin,100,5,160,18,501

      fn PushButton,"Refresh List", hWin,250,2,100,22,502
      fn PushButton,"Show Window",hWin,350,2,100,22,503
      fn PushButton,"Hide Window",hWin,450,2,100,22,504
      fn PushButton,"Close Window",hWin,550,2,100,22,505
      fn PushButton,"Exit",hWin,650,2,100,22,506

    .elseif uMsg == WM_SIZE
      invoke GetClientRect,hWin,ADDR Rc
      m2m rLeft, Rc.left
      add rLeft, 5
      m2m rTop, Rc.top
      add rTop, 26
      m2m rRight, Rc.right
      sub rRight, 10
      m2m rBottom, Rc.bottom
      sub rBottom, 30
      invoke MoveWindow,hList,rLeft,rTop,rRight,rBottom,TRUE

    .elseif uMsg == WM_CLOSE

    .elseif uMsg == WM_DESTROY
        invoke PostQuitMessage,NULL
        return 0 
    .endif

    invoke DefWindowProc,hWin,uMsg,wParam,lParam

    ret

WndProc endp

; ¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤

ListBox proc a:DWORD,b:DWORD,wd:DWORD,ht:DWORD,hParent:DWORD,ID:DWORD

    fn CreateWindowEx,WS_EX_STATICEDGE,"LISTBOX",0, \
              WS_VSCROLL or WS_VISIBLE or \
              WS_CHILD or \
              LBS_HASSTRINGS or LBS_NOINTEGRALHEIGHT or \
              LBS_DISABLENOSCROLL, \
              a,b,wd,ht,hParent,ID,hInstance,NULL

    push esi
    mov esi, eax
    fn SendMessage,esi,WM_SETFONT,rv(GetStockObject,SYSTEM_FIXED_FONT), 0
    mov eax, esi
    pop esi

    ret

ListBox endp

; ¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤

EnmProc proc eHandle:DWORD,y:DWORD

    LOCAL pbuf  :DWORD
    LOCAL pcls  :DWORD
    LOCAL ptxt  :DWORD
    LOCAL Buffer[1024]:BYTE
    LOCAL tbuf[512]:BYTE
    LOCAL clName[128]:BYTE

    mov pbuf, ptr$(Buffer)
    mov pcls, ptr$(clName)
    mov ptxt, ptr$(tbuf)

    invoke GetClassName,eHandle,pcls,128
    invoke GetWindowText,eHandle,ptxt,512

    mov pbuf, cat$(pbuf,str$(eHandle),"        ")   ; the number + padding
    mov pbuf, left$(pbuf,12)                        ; chomp off the 1st 12 characters

  ; -----------------------------------------------------
  ; if the window does not have a title text just display
  ; its handle and class name otherwise append the window
  ; text to the handle and class name and display it.
  ; -----------------------------------------------------
    .if len(ptxt) == 0
      mov pbuf, cat$(pbuf,pcls)                                     ; just list handle and class name
    .else
      mov pbuf, cat$(pbuf,pcls,chr$(" Text => ",34),ptxt,chr$(34))  ; append the window text
    .endif

    mov eax, eHandle
    cmp hWnd, eax
    je nxt

    invoke SendMessage,hList,LB_ADDSTRING,0,pbuf

  nxt:
    mov eax, eHandle
    ret

EnmProc endp

; ¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤

Static proc lpText:DWORD,hParent:DWORD,a:DWORD,b:DWORD,wd:DWORD,ht:DWORD,ID:DWORD

    fn CreateWindowEx,WS_EX_LEFT, \
                      "STATIC",lpText, \
                      WS_CHILD or WS_VISIBLE or SS_LEFT, \
                      a,b,wd,ht,hParent,ID, \
                      hInstance,NULL
    push esi
    mov esi, eax
    invoke SendMessage,esi,WM_SETFONT,rv(GetStockObject,ANSI_FIXED_FONT), 0
    mov eax, esi
    pop esi

    ret

Static endp

; ¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤

ListProc proc hCtl:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

    LOCAL IndexItem  :DWORD
    LOCAL pbuf       :DWORD
    LOCAL ptxt       :DWORD
    LOCAL Buffer[1024]:BYTE
    LOCAL tbuf[1024]:BYTE

    .if uMsg == WM_CHAR
      .if wParam == 13
        call ShowItem
      .endif

    .elseif uMsg == WM_LBUTTONDBLCLK
        call ShowItem

    .endif

    invoke CallWindowProc,lpfnListProc,hCtl,uMsg,wParam,lParam

    ret

    ShowItem:
      mov pbuf, ptr$(Buffer)
      mov ptxt, ptr$(tbuf)
      invoke SendMessage,hCtl,LB_GETTEXT,rv(SendMessage,hCtl,LB_GETCURSEL,0,0),pbuf
      fn szRep,pbuf,ptxt,chr$(" Text => "),chr$(13,10,"--- Window Title ---",13,10)
      mov pbuf, ptr$(Buffer)
      mov pbuf, cat$(pbuf,"--- Handle and Class Name ---",chr$(13,10),ptxt)
      fn MessageBox,hWnd,pbuf,"Window Information",MB_OK
      invoke SetFocus,hCtl
    ret

ListProc endp

; ¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤

PushButton proc lpText:DWORD,hParent:DWORD,
                a:DWORD,b:DWORD,wd:DWORD,ht:DWORD,ID:DWORD

    fn CreateWindowEx,WS_EX_LEFT, \
                      "BUTTON",lpText, \
                      WS_CHILD or WS_VISIBLE, \
                      a,b,wd,ht,hParent,ID, \
                      hInstance,NULL

    push esi
    mov esi, eax
    fn SendMessage,esi,WM_SETFONT,rv(GetStockObject,ANSI_VAR_FONT), 0
    mov eax, esi
    pop esi

    ret

PushButton endp

; ¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤

end start
