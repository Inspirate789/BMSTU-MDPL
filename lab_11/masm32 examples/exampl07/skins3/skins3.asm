; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

    .686p                       ; create 32 bit code
    .XMM
    .model flat, stdcall        ; 32 bit memory model
    option casemap :none        ; case sensitive

    include skins3.inc          ; local includes for this file

    Static          PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
    txtbutn         PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
    txtbutn_proc    PROTO :DWORD,:DWORD,:DWORD,:DWORD
    clear_text      PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
    ttxtProc        PROTO :DWORD,:DWORD,:DWORD,:DWORD
    SetWindowTitle  PROTO :DWORD

    tbarProc PROTO :DWORD,:DWORD,:DWORD,:DWORD
    resizeProc PROTO :DWORD,:DWORD,:DWORD,:DWORD

  ; --------------------------------
  ; macros for changing text colours
  ; --------------------------------
    SetUpColor MACRO hndl,colorref
      invoke SetWindowLong,hndl,0,colorref      ; up colour
    ENDM

    SetUpShadow MACRO hndl,colorref
      invoke SetWindowLong,hndl,4,colorref      ; up shadow
    ENDM

    SetDownColor MACRO hndl,colorref
      invoke SetWindowLong,hndl,8,colorref      ; down colour
    ENDM

    SetDownShadow MACRO hndl,colorref
      invoke SetWindowLong,hndl,12,colorref     ; down shadow
    ENDM

    SetFontHandle MACRO hndl,hFont
      invoke SetWindowLong,hndl,16,hFont        ; font handle
    ENDM

    COLORSTRUCT STRUCT
      butnup dd ?
      shadup dd ?
      butndn dd ?
      shaddn dd ?
    COLORSTRUCT ENDS

    .const
      tbht equ <25>             ; title bar height
      sbht equ <25>             ; status bar height
      vwid equ <4>              ; side border width

    .data?
      ttlbmp dd ?
      sidbmp dd ?
      stabmp dd ?
      resize dd ?
      icosml dd ?

      lpttxtProc dd ?
      lpresizeProc dd ?

      htbar  dd ?
      hstat  dd ?
      hleft  dd ?
      hrigt  dd ?
      httxt  dd ?

      butn1  dd ?
      butn2  dd ?
      butn3  dd ?
      butn4  dd ?
      qbutn  dd ?
      mbutn  dd ?
      ibutn  dd ?
      apptitle db 260 dup (?)

      hWebding dd ?
      hWingdg3 dd ?

      lptbarProc dd ?

    .data
      ptitle dd apptitle

    .code

start:

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

  ; ------------------
  ; set global values
  ; ------------------
    mov hInstance,   rv(GetModuleHandle, NULL)
    mov CommandLine, rv(GetCommandLine)
    mov hIcon,       rv(LoadIcon,hInstance,500)
    mov icosml,      rv(LoadIcon,hInstance,600)

    mov hCursor,     rv(LoadCursor,NULL,IDC_ARROW)
    mov sWid,        rv(GetSystemMetrics,SM_CXSCREEN)
    mov sHgt,        rv(GetSystemMetrics,SM_CYSCREEN)
    mov ttlbmp,      FUNC(LoadImage,hInstance,150,IMAGE_BITMAP,sWid,tbht,LR_DEFAULTCOLOR)
    mov sidbmp,      FUNC(LoadImage,hInstance,155,IMAGE_BITMAP,vwid,sHgt,LR_DEFAULTCOLOR)
    mov stabmp,      FUNC(LoadImage,hInstance,160,IMAGE_BITMAP,sWid,sbht,LR_DEFAULTCOLOR)

    call Main

    invoke ExitProcess,eax

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

Main proc

    LOCAL Wwd:DWORD,Wht:DWORD,Wtx:DWORD,Wty:DWORD,mWid:DWORD

    STRING szClassName,"Skins3_Class"

  ; --------------------------------------------
  ; register class name for CreateWindowEx call
  ; --------------------------------------------
    invoke CreateSolidBrush,005EAEFFh   ; 00FF6666h
    invoke RegisterWinClass,ADDR WndProc,
           ADDR szClassName,hIcon,hCursor,eax

  ; ---------------------------------------------
  ; set width and height as percentages of screen
  ; ---------------------------------------------
    mov Wwd, 640
    mov Wht, 480

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

    fn CreateWindowEx,WS_EX_LEFT or WS_EX_ACCEPTFILES, \
                      ADDR szClassName,"Skinned Window", \
                      WS_POPUP,Wtx,Wty,Wwd,Wht, \
                      NULL,NULL,hInstance,NULL
    mov hWnd,eax

  ; ---------------------------
  ; macros for unchanging code
  ; ---------------------------

    fn SetWindowTitle,"Untitled"

    invoke ShowWindow,hWnd,SW_SHOW
    invoke UpdateWindow,hWnd

    call MsgLoop
    ret

Main endp

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

RegisterWinClass proc lpWndProc:DWORD, lpClassName:DWORD,
                      Icon:DWORD, Cursor:DWORD, bColor:DWORD

    LOCAL wc:WNDCLASSEX

    mov wc.cbSize,         sizeof WNDCLASSEX
    mov wc.style,          CS_BYTEALIGNCLIENT or \
                           CS_BYTEALIGNWINDOW or CS_DBLCLKS
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

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

MsgLoop proc

    LOCAL msg:MSG

    push esi
    push edi
    xor edi, edi                        ; clear EDI
    lea esi, msg                        ; Structure address in ESI
    jmp jumpin

  StartLoop:
    invoke TranslateMessage, esi
    invoke DispatchMessage,esi
  jumpin:
    invoke GetMessage,esi,edi,edi,edi
    test eax, eax
    jnz StartLoop

    mov eax, msg.wParam
    pop edi
    pop esi

    ret

MsgLoop endp

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

WndProc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

    LOCAL var    :DWORD
    LOCAL caW    :DWORD
    LOCAL caH    :DWORD
    LOCAL fname  :DWORD
    LOCAL rct    :RECT
    LOCAL pt     :POINT
    LOCAL buffer1[260]:BYTE  ; these are two spare buffers
    LOCAL buffer2[260]:BYTE  ; for text manipulation etc..
    LOCAL cstruct    :COLORSTRUCT

    Switch uMsg
      case WM_NCLBUTTONDBLCLK
        movzx ecx, WORD PTR [ebp+20]
        movzx edx, WORD PTR [ebp+22]

        mov pt.x, ecx
        mov pt.y, edx

        invoke ScreenToClient,hWin,ADDR pt

        mov edx, pt.y
        .if edx < tbht
          .if rv(IsZoomed,hWin)
            invoke ShowWindow,hWin,SW_SHOWNORMAL            ; yes
          .else
            invoke PostMessage,hWin,WM_COMMAND,99,0         ; no. Send Message to Maximise window
          .endif
        .endif

      case WM_NCHITTEST
        push esi
        push edi

        invoke GetClientRect,hWin,ADDR rct
        movsx eax, WORD PTR [ebp+20]        ; get X-Y coordinates
        mov pt.x, eax
        movsx eax, WORD PTR [ebp+22]
        mov pt.y, eax
        invoke ScreenToClient,hWin,ADDR pt  ; convert to client coordinates

        sub rct.right, 5
        mov esi, rct.right

        sub rct.bottom, 5
        mov edi, rct.bottom

        invoke GetClientRect,hWin,ADDR rct

        mov eax, sbht

        sub rct.right, eax
        mov ecx, rct.right

        sub rct.bottom, eax
        mov edx, rct.bottom

        mov eax, tbht

        .if pt.x < eax && pt.y < eax
          mov eax, HTTOPLEFT
          ret
        .elseif pt.x > esi && pt.y < eax
          mov eax, HTTOPRIGHT
          ret
        .elseif pt.x < 5 && pt.y > edi
          mov eax, HTBOTTOMLEFT
          ret
        .elseif pt.x > ecx && pt.y > edx
          mov eax, HTBOTTOMRIGHT
          ret
        .elseif pt.x < 5 && pt.y > eax
          mov eax, HTLEFT
          ret
        .elseif pt.y < 5
          mov eax, HTTOP
          ret
        .elseif pt.x > esi
          mov eax, HTRIGHT
          ret
        .elseif pt.y > edi
          mov eax, HTBOTTOM
          ret
        .elseif pt.y < eax
          mov eax, HTCAPTION
          ret
        .endif

        pop edi
        pop esi

      Case WM_COMMAND
        switch wParam
          case 99
            invoke SleepEx,0,0

            invoke SetWindowText,mbutn,"2"

            invoke ShowWindow,hWin,SW_SHOWMAXIMIZED             ; no

          case 100
            .if lParam == 0
              fn SetWindowTitle,"New Title"
            .else
              ; usused                                          ; button DOWN action
            .endif

          case 101
            .if lParam == 0
              fn MessageBox,hWin,str$(eax),"button 2",MB_OK
            .else
              ; usused
            .endif

          case 102
            .if lParam == 0
              fn MessageBox,hWin,str$(eax),"button 3",MB_OK
            .else
              ; usused
            .endif

          case 103
            .if lParam == 0
              fn SendMessage,hWin,WM_SYSCOMMAND,SC_CLOSE,0
            .else
              ; usused
            .endif

          case 110
            .if lParam == 0
              fn SendMessage,hWin,WM_SYSCOMMAND,SC_CLOSE,0
            .else
              ; usused
            .endif

          case 111
            .if lParam == 0
              .if rv(IsZoomed,hWin)
                invoke ShowWindow,hWin,SW_SHOWNORMAL            ; yes
                invoke SetWindowText,mbutn,"1"
              .else
                invoke PostMessage,hWin,WM_COMMAND,99,0         ; no. Send Message to Maximise window
              .endif
            .else
              ; usused
            .endif

          case 112
            .if lParam == 0
              invoke ShowWindow,hWin,SW_MINIMIZE
            .else
              ; usused
            .endif

        endsw

      Case WM_DROPFILES
        mov fname, DropFileName(wParam)
        fn MessageBox,hWin,fname,"WM_DROPFILES",MB_OK

      Case WM_CREATE
        mov hWebding, GetFontHandle("webdings",18,500)
        mov hWingdg3, GetFontHandle("wingdings 3",sbht,500)
      ; --------------------------------------------------------
      ; titlebar and left side are located by their co-ordinates
      ; --------------------------------------------------------
        mov htbar, rv(Static,NULL,hWin,0,0,100,25,500)
        invoke SendMessage,htbar,STM_SETIMAGE,IMAGE_BITMAP,ttlbmp

        invoke SetWindowLong,htbar,GWL_WNDPROC,tbarProc
        mov lptbarProc, eax

        mov hleft, rv(Static,NULL,hWin,0,tbht,100,25,501)
        invoke SendMessage,hleft,STM_SETIMAGE,IMAGE_BITMAP,sidbmp

      ; --------------------------------------------------------------
      ; status bar and right side are positioned by WM_SIZE processing
      ; --------------------------------------------------------------
        mov hrigt, rv(Static,NULL,hWin,0,tbht,100,25,502)
        invoke SendMessage,hrigt,STM_SETIMAGE,IMAGE_BITMAP,sidbmp

        mov hstat, rv(Static,NULL,hWin,0,tbht,100,25,503)
        invoke SendMessage,hstat,STM_SETIMAGE,IMAGE_BITMAP,stabmp

    ; ¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤
    ; ¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤

        mov cstruct.butnup, 00FFFFFFh
        mov cstruct.shadup, 00000000h
        mov cstruct.butndn, 00999999h
        mov cstruct.shaddn, 00000000h

        btwid equ <55>      ; butn width
        bthgt equ <22>      ; butn height
        bttop equ <25>      ; drop from top
        sspc  equ <5>       ; initial side space

        mov butn1, rv(txtbutn,"&File",hInstance,hWin,"butn1",hCursor,sspc,bttop,btwid,bthgt,100,ADDR cstruct)
        mov butn2, rv(txtbutn,"&Edit",hInstance,hWin,"butn2",hCursor,sspc+btwid,bttop,btwid,bthgt,101,ADDR cstruct)
        mov butn3, rv(txtbutn,"&Find",hInstance,hWin,"butn3",hCursor,sspc+btwid*2,bttop,btwid,bthgt,102,ADDR cstruct)
        mov butn4, rv(txtbutn,"E&xit",hInstance,hWin,"butn4",hCursor,sspc+btwid*3,bttop,btwid,bthgt,103,ADDR cstruct)

        mov ibutn, rv(txtbutn,"6", hInstance,hWin,"iconic_class",hCursor,250,tbht,20,20,112,ADDR cstruct)
        SetUpColor ibutn,00FFFFFFh
        SetUpShadow ibutn,00000000h
        SetDownColor ibutn,00000000h
        SetDownShadow ibutn,00FFFFFFh
        SetFontHandle ibutn,hWebding

        mov mbutn, rv(txtbutn,"2", hInstance,hWin,"maxmin_class",hCursor,250,tbht,20,20,111,ADDR cstruct)
        SetUpColor mbutn,00FFFFFFh
        SetUpShadow mbutn,00000000h
        SetDownColor mbutn,00000000h
        SetDownShadow mbutn,00FFFFFFh
        SetFontHandle mbutn,hWebding

        mov qbutn, rv(txtbutn,"r", hInstance,hWin,"quit_class",hCursor,250,tbht,20,20,110,ADDR cstruct)
        SetUpColor qbutn,00FFFFFFh
        SetUpShadow qbutn,00000000h
        SetDownColor qbutn,00000000h
        SetDownShadow qbutn,00FFFFFFh
        SetFontHandle qbutn,hWebding

    ; ¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤
    ; ¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤*¤

        mov httxt, rv(clear_text,"Window Title",htbar,tbht,0,400,tbht,555)
        invoke SetWindowLong,httxt,GWL_WNDPROC,ttxtProc
        mov lpttxtProc, eax

        mov resize, rv(clear_text,"y",hstat,0,0,tbht,tbht,556)
        invoke SetWindowLong,resize,GWL_WNDPROC,resizeProc
        mov lpresizeProc, eax

      Case WM_SIZE
        invoke GetClientRect,hWin,ADDR rct

        push rct.right

        mov eax, vwid
        sub rct.right, eax
        invoke MoveWindow,hrigt,rct.right,tbht,vwid,sHgt,TRUE

        mov eax, sbht
        sub rct.bottom, eax
        invoke MoveWindow,hstat,0,rct.bottom,sWid,sbht,TRUE

        pop rct.right
        sub rct.right, 20
        add rct.top, 3
        invoke MoveWindow,qbutn,rct.right,rct.top,15,15,TRUE

        sub rct.right, 18
        invoke MoveWindow,mbutn,rct.right,rct.top,15,15,TRUE

        sub rct.right, 18
        invoke MoveWindow,ibutn,rct.right,rct.top,15,15,TRUE

        invoke GetClientRect,hWin,ADDR rct

        sub rct.right, 90
        invoke MoveWindow,httxt,tbht,0,rct.right,tbht,TRUE

        invoke GetClientRect,hWin,ADDR rct
        mov eax, sbht
        sub rct.right, eax
        mov eax, vwid
        sub eax, 4
        add rct.right, eax

        invoke MoveWindow,resize,rct.right,0,sbht,sbht,TRUE

      Case WM_PAINT
        invoke Paint_Proc,hWin
        return 0

      Case WM_CLOSE

      Case WM_DESTROY
        invoke PostQuitMessage,NULL
        return 0

    Endsw

    invoke DefWindowProc,hWin,uMsg,wParam,lParam

    ret

WndProc endp

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

Paint_Proc proc hWin:DWORD

    LOCAL hDC      :DWORD
    LOCAL rct      :RECT
    LOCAL Ps       :PAINTSTRUCT
    LOCAL pbuf     :DWORD
    LOCAL buffer[260]:BYTE
    LOCAL tbwd     :DWORD

    push ebx
    push esi
    push edi

    mov hDC, rv(BeginPaint,hWin,ADDR Ps)

  ; ----------------------------------------


  ; ----------------------------------------

    invoke EndPaint,hWin,ADDR Ps

    pop edi
    pop esi
    pop ebx

    ret

Paint_Proc endp

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

Static proc lpText:DWORD,hParent:DWORD,
                 a:DWORD,b:DWORD,wd:DWORD,ht:DWORD,ID:DWORD

    LOCAL hStat1    :DWORD
    LOCAL style     :DWORD

    fn CreateWindowEx,WS_EX_LEFT,"STATIC",NULL, \
            WS_CHILD or WS_VISIBLE or SS_BITMAP, \
            a,b,wd,ht,hParent,ID,hInstance,NULL

 ;     mov hStat1, eax
 ; 
 ;     invoke GetClassLong,hStat1,GCL_STYLE
 ; 
 ;     or eax, CS_DBLCLKS
 ; 
 ;     invoke SetClassLong,hStat1,GCL_STYLE,eax
 ; 
 ;     mov eax, hStat1

    ret

Static endp

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

txtbutn proc ptxt:DWORD,instance:DWORD,parent:DWORD,
             classname:DWORD,cursor:DWORD,tx:DWORD,
             ty:DWORD,wd:DWORD,ht:DWORD,ID:DWORD,pcst:DWORD

    LOCAL hndl  :DWORD
    LOCAL wc:WNDCLASSEX

    mov wc.cbSize,         sizeof WNDCLASSEX
    mov wc.style,          CS_BYTEALIGNCLIENT or CS_BYTEALIGNWINDOW  ;; or CS_VREDRAW or CS_HREDRAW
    mrm wc.lpfnWndProc,    OFFSET txtbutn_proc
    mov wc.cbClsExtra,     40
    mov wc.cbWndExtra,     40
    mrm wc.hInstance,      instance
    mrm wc.hbrBackground,  rv(GetStockObject,HOLLOW_BRUSH)
    mov wc.lpszMenuName,   NULL
    mrm wc.lpszClassName,  classname
    mrm wc.hIcon,          NULL
    mrm wc.hCursor,        cursor
    mrm wc.hIconSm,        NULL

    invoke RegisterClassEx, ADDR wc

    fn CreateWindowEx,WS_EX_LEFT or WS_EX_TRANSPARENT, \
                      classname,ptxt,WS_CHILD, \
                      tx,ty,wd,ht,parent,ID, \
                      hInstance,NULL
    mov hndl, eax
    invoke ShowWindow,hndl,SW_SHOW
    invoke UpdateWindow,hndl

    push esi
    mov esi, pcst
    invoke SetWindowLong,hndl, 0,(COLORSTRUCT PTR [esi]).butnup     ; up colour
    invoke SetWindowLong,hndl, 4,(COLORSTRUCT PTR [esi]).shadup     ; up shadow
    invoke SetWindowLong,hndl, 8,(COLORSTRUCT PTR [esi]).butndn     ; down colour
    invoke SetWindowLong,hndl,12,(COLORSTRUCT PTR [esi]).shaddn     ; down shadow
    invoke SetWindowLong,hndl,16,0
    pop esi

    mov eax, hndl

    ret

txtbutn endp

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

txtbutn_proc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

    LOCAL parent :DWORD
    LOCAL ID     :DWORD
    LOCAL hDC    :DWORD
    LOCAL pbuf   :DWORD
    LOCAL rct    :RECT
    LOCAL ps     :PAINTSTRUCT
    LOCAL pt     :POINT
    LOCAL buffer[128]:BYTE
    LOCAL hOld   :DWORD

    switch uMsg
      case WM_LBUTTONDOWN

        push esi
        mov hDC, rv(GetDC,hWin)
        invoke SetBkMode,hDC,TRANSPARENT
        mov pbuf, ptr$(buffer)
        invoke GetWindowText,hWin,pbuf,128
        invoke GetClientRect,hWin,ADDR rct

        mov esi, rv(GetWindowLong,hWin,16)
        test esi, esi
        jz @F
        mov hOld, rv(SelectObject,hDC,esi)
      @@:

        invoke SetTextColor,hDC,rv(GetWindowLong,hWin,12)
        fn DrawText,hDC,pbuf,-1,ADDR rct,DT_CENTER or DT_VCENTER or \
                                         DT_NOCLIP or DT_SINGLELINE
        add rct.left, 1
        add rct.top, 1
        add rct.right, 1
        add rct.bottom, 1
        invoke SetTextColor,hDC,rv(GetWindowLong,hWin,8)
        fn DrawText,hDC,pbuf,-1,ADDR rct,DT_CENTER or DT_VCENTER or \
                                         DT_NOCLIP or DT_SINGLELINE

        mov esi, rv(GetWindowLong,hWin,16)
        test esi, esi
        jz @F
        invoke SelectObject,hDC,hOld
      @@:

        mov ID, rv(GetWindowLong,hWin,GWL_ID)
        invoke PostMessage,rv(GetParent,hWin),WM_COMMAND,ID,1
        fn SetCapture,hWin
        invoke ReleaseDC,hWin,hDC
        pop esi

      case WM_LBUTTONUP
        invoke GetClientRect,hWin,ADDR rct
        movzx eax, WORD PTR [ebp+20]
        movzx ecx, WORD PTR [ebp+22]
        .if eax < rct.right && ecx < rct.bottom
          .if rv(GetCapture) == hWin
            mov ID, rv(GetWindowLong,hWin,GWL_ID)
            invoke PostMessage,rv(GetParent,hWin),WM_COMMAND,ID,0
          .endif
        .endif
        invoke ReleaseCapture
        call refresh

      case WM_MOVE
        call refresh

      case WM_PAINT
        push esi
        mov hDC, rv(BeginPaint,hWin,ADDR ps)
        invoke GetClientRect,hWin,ADDR rct
        invoke SetBkMode,hDC,TRANSPARENT
        mov pbuf, ptr$(buffer)
        invoke GetWindowText,hWin,pbuf,128

        mov esi, rv(GetWindowLong,hWin,16)
        test esi, esi
        jz @F
        mov hOld, rv(SelectObject,hDC,esi)
      @@:

        invoke GetClientRect,hWin,ADDR rct
        add rct.left, 1
        add rct.top, 1
        add rct.right, 1
        add rct.bottom, 1
        invoke SetTextColor,hDC,rv(GetWindowLong,hWin,4)
        fn DrawText,hDC,pbuf,-1,ADDR rct,DT_CENTER or DT_VCENTER or \
                                         DT_NOCLIP or DT_SINGLELINE

        invoke GetClientRect,hWin,ADDR rct
        invoke SetTextColor,hDC,rv(GetWindowLong,hWin,0)
        fn DrawText,hDC,pbuf,-1,ADDR rct,DT_CENTER or DT_VCENTER or \
                                         DT_NOCLIP or DT_SINGLELINE

        mov esi, rv(GetWindowLong,hWin,16)
        test esi, esi
        jz @F
        invoke SelectObject,hDC,hOld
      @@:

        invoke EndPaint,hWin,ADDR ps
        pop esi

    endsw

    invoke DefWindowProc,hWin,uMsg,wParam,lParam

    ret

  refresh:
    mov parent, rv(GetParent,hWin)
    invoke GetClientRect,hWin,ADDR rct
    invoke ClientToScreen,hWin,ADDR rct.left
    invoke ClientToScreen,hWin,ADDR rct.right
    invoke ScreenToClient,parent,ADDR rct.left
    invoke ScreenToClient,parent,ADDR rct.right
    invoke InvalidateRect,parent,ADDR rct,TRUE
    retn

txtbutn_proc endp

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

clear_text proc lpText:DWORD,hParent:DWORD,
                 a:DWORD,b:DWORD,wd:DWORD,ht:DWORD,ID:DWORD

    fn CreateWindowEx,WS_EX_TRANSPARENT,"STATIC",lpText, \
            WS_CHILD or WS_VISIBLE, \
            a,b,wd,ht,hParent,ID,hInstance,NULL

    ret

clear_text endp

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

ttxtProc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

    LOCAL hDC  :DWORD 
    LOCAL Ps   :PAINTSTRUCT
    LOCAL rct   :RECT

  ; -----------------------------
  ; Process control messages here
  ; -----------------------------

    .if uMsg == WM_PAINT
      mov hDC, rv(BeginPaint,hWin,ADDR Ps)

      invoke GetClientRect,hWin,ADDR rct

      fn SetBkMode,hDC,TRANSPARENT

      add rct.left, 1
      add rct.top, 1
      add rct.right, 1
      add rct.bottom, 1
      invoke SetTextColor,hDC,00000000h
      fn DrawText,hDC,ptitle,-1,ADDR rct,DT_LEFT or DT_VCENTER or \
                                       DT_NOCLIP or DT_SINGLELINE
      invoke GetClientRect,hWin,ADDR rct

      invoke SetTextColor,hDC,00FFFFFFh
      fn DrawText,hDC,ptitle,-1,ADDR rct,DT_LEFT or DT_VCENTER or \
                                       DT_NOCLIP or DT_SINGLELINE
      invoke EndPaint,hWin,ADDR Ps
      mov eax, 0
      ret
    .endif

    invoke CallWindowProc,lpttxtProc,hWin,uMsg,wParam,lParam

    ret

ttxtProc endp

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

SetWindowTitle proc ptxt:DWORD

    LOCAL rct   :RECT

    fn szCopy,ptxt,ptitle
    fn SendMessage,httxt,WM_SETTEXT,0,ptxt
    invoke GetClientRect,htbar,ADDR rct
    fn InvalidateRect,hWnd,ADDR rct,TRUE

    ret

SetWindowTitle endp

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

tbarProc proc hCtl:DWORD,uMsg:DWORD,wParam :DWORD,lParam :DWORD

  ; -----------------------------
  ; Process control messages here
  ; -----------------------------

    .if uMsg == WM_LBUTTONDBLCLK
      invoke SendMessage,hWnd,WM_LBUTTONDBLCLK,wParam,lParam
      fn MessageBox,0,str$(eax),"Title",MB_OK

    .endif

    invoke CallWindowProc,lptbarProc,hCtl,uMsg,wParam,lParam

    ret

tbarProc endp

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

resizeProc proc hWin   :DWORD,
                uMsg   :DWORD,
                wParam :DWORD,
                lParam :DWORD

    LOCAL hDC  :DWORD 
    LOCAL Ps   :PAINTSTRUCT
    LOCAL ptxt  :DWORD
    LOCAL buffer[64]:BYTE
    LOCAL rct   :RECT
    LOCAL hOld  :DWORD

    .if uMsg == WM_PAINT
        invoke BeginPaint,hWin,ADDR Ps
        mov hDC, eax
      ; -------------------

        mov hOld, rv(SelectObject,hDC,hWingdg3)

        mov ptxt, ptr$(buffer)
        invoke GetWindowText,hWin,ptxt,64

        invoke GetClientRect,hWin,ADDR rct
  
        fn SetBkMode,hDC,TRANSPARENT
  
        add rct.left, 2
        add rct.top, 2
        add rct.right, 2
        add rct.bottom, 2
  
        invoke SetTextColor,hDC,00000000h
        fn DrawText,hDC,ptxt,-1,ADDR rct,DT_LEFT or DT_VCENTER or \
                                         DT_NOCLIP or DT_SINGLELINE
        invoke GetClientRect,hWin,ADDR rct
        invoke SetTextColor,hDC,00FFFFFFh
        fn DrawText,hDC,ptxt,-1,ADDR rct,DT_LEFT or DT_VCENTER or \
                                         DT_NOCLIP or DT_SINGLELINE

        invoke SelectObject,hDC,hOld

      ; -------------------
        invoke EndPaint,hWin,ADDR Ps
        mov eax, 0
        ret

    .endif

    invoke CallWindowProc,lpresizeProc,hWin,uMsg,wParam,lParam

    ret

resizeProc endp

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

end start

























