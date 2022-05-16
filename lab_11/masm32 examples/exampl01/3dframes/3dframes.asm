; #########################################################################
;
; The framing affects are drawn on the client area by a single procedure,
; "Frame3D". In the WmdProc message handling Proc, the WM_PAINT message
; calls another Proc called "Paint_Proc" which contains the procedure calls
; to "Frame3D".
;
; #########################################################################

      .386
      .model flat, stdcall
      option casemap :none   ; case sensitive

; #########################################################################

      include \masm32\include\windows.inc
      include \masm32\include\user32.inc
      include \masm32\include\kernel32.inc
      include \masm32\include\gdi32.inc
      
      includelib \masm32\lib\user32.lib
      includelib \masm32\lib\kernel32.lib
      includelib \masm32\lib\gdi32.lib

; #########################################################################

      ;=============
      ; Local macros
      ;=============

      szText MACRO Name, Text:VARARG
        LOCAL lbl
          jmp lbl
            Name db Text,0
          lbl:
        ENDM

      m2m MACRO M1, M2
        push M2
        pop  M1
      ENDM

      return MACRO arg
        mov eax, arg
        ret
      ENDM

        ;=================
        ; Local prototypes
        ;=================
        WinMain PROTO :DWORD,:DWORD,:DWORD,:DWORD
        WndProc PROTO :DWORD,:DWORD,:DWORD,:DWORD
        TopXY PROTO   :DWORD,:DWORD
        Paint_Proc PROTO :DWORD, hDC:DWORD
        Frame3D PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
        PushButton PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD

    .data
        szDisplayName db "3D Frames",0
        CommandLine   dd 0
        hWnd          dd 0
        hInstance     dd 0

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

        mov wc.cbSize,         sizeof WNDCLASSEX
        mov wc.style,          CS_HREDRAW or CS_VREDRAW \
                               or CS_BYTEALIGNWINDOW
        mov wc.lpfnWndProc,    offset WndProc
        mov wc.cbClsExtra,     NULL
        mov wc.cbWndExtra,     NULL
        m2m wc.hInstance,      hInst   ;<< NOTE: macro not mnemonic
        mov wc.hbrBackground,  COLOR_BTNFACE+1
        mov wc.lpszMenuName,   NULL
        mov wc.lpszClassName,  offset szClassName
          invoke LoadIcon,hInst,500    ; icon ID
        mov wc.hIcon,          eax
          invoke LoadCursor,NULL,IDC_ARROW
        mov wc.hCursor,        eax
        mov wc.hIconSm,        0

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

        szText szClassName,"Template_Class"

        invoke CreateWindowEx,WS_EX_LEFT,
                              ADDR szClassName,
                              ADDR szDisplayName,
                              WS_OVERLAPPEDWINDOW,
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

        LOCAL hDC  :DWORD
        LOCAL Ps   :PAINTSTRUCT


    .if uMsg == WM_COMMAND
    ;======== menu commands ========
        .if wParam == 1000
            invoke SendMessage,hWin,WM_SYSCOMMAND,SC_CLOSE,NULL
        .elseif wParam == 1900
            szText TheMsg,"Assembler, Pure & Simple"
            invoke MessageBox,hWin,ADDR TheMsg,ADDR szDisplayName,MB_OK
        .endif
    ;====== end menu commands ======

    .elseif uMsg == WM_PAINT
        invoke BeginPaint,hWin,ADDR Ps
          mov hDC, eax
          invoke Paint_Proc,hWin,hDC
        invoke EndPaint,hWin,ADDR Ps
        return 0

    .elseif uMsg == WM_CREATE

        jmp @F
          Butn1 db "&Save",0
          Butn2 db "&Cancel",0
          Butn3 db "&Help",0
        @@:

        invoke PushButton,ADDR Butn1,hWin,350,30,100,25,500
        invoke PushButton,ADDR Butn2,hWin,350,60,100,25,500
        invoke PushButton,ADDR Butn3,hWin,350,90,100,25,500


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

    ; --------------------------------------------------------
    ; The following 2 calls draw the border around the buttons
    ; --------------------------------------------------------
    invoke Frame3D,hDC,btn_lo,btn_hi,340,20,460,125,2
    invoke Frame3D,hDC,btn_hi,btn_lo,337,17,463,128,2

    ; -----------------------------------------------------
    ; The following 2 calls draw the left window frame area
    ; -----------------------------------------------------
    invoke Frame3D,hDC,btn_lo,btn_hi,17,17,328,290,2
    invoke Frame3D,hDC,btn_hi,btn_lo,20,20,325,287,1

    ; ----------------------------------------------------------
    ; The following code draws the border around the client area
    ; ----------------------------------------------------------
    invoke GetClientRect,hWin,ADDR Rct

    add Rct.left,   1
    add Rct.top,    1
    sub Rct.right,  1
    sub Rct.bottom, 1

    invoke Frame3D,hDC,btn_lo,btn_hi,
                   Rct.left,Rct.top,
                   Rct.right,Rct.bottom,2

    add Rct.left,   4
    add Rct.top,    4
    sub Rct.right,  4
    sub Rct.bottom, 4

    invoke Frame3D,hDC,btn_hi,btn_lo,
                   Rct.left,
                   Rct.top,Rct.right,Rct.bottom,2

    return 0

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

Frame3D proc hDC:DWORD,btn_hi:DWORD,btn_lo:DWORD,
             tx:DWORD, ty:DWORD, lx:DWORD, ly:DWORD,bdrWid:DWORD

  ; --------------------------------
  ; prototype and example usage code
  ; --------------------------------

  ; LOCAL btn_hi   :DWORD
  ; LOCAL btn_lo   :DWORD

  ; invoke GetSysColor,COLOR_BTNHIGHLIGHT
  ; mov btn_hi, eax

  ; invoke GetSysColor,COLOR_BTNSHADOW
  ; mov btn_lo, eax

  ; invoke Frame3D,hDC,btn_lo,btn_hi,50,50,150,100,2
  ; invoke Frame3D,hDC,btn_hi,btn_lo,47,47,153,103,2
  ; --------------------------------

    LOCAL hPen     :DWORD
    LOCAL hPen2    :DWORD
    LOCAL hpenOld  :DWORD

    invoke CreatePen,0,1,btn_hi
    mov hPen, eax
  
    invoke SelectObject,hDC,hPen
    mov hpenOld, eax

    ; ------------------------------------
    ; Save copy of parameters for 2nd loop
    ; ------------------------------------
    push tx
    push ty
    push lx
    push ly
    push bdrWid

    ; ------------

       lpOne:

        invoke MoveToEx,hDC,tx,ty,NULL
        invoke LineTo,hDC,lx,ty

        invoke MoveToEx,hDC,tx,ty,NULL
        invoke LineTo,hDC,tx,ly

        dec tx
        dec ty
        inc lx
        inc ly

        dec bdrWid
        cmp bdrWid, 0
        je lp1Out
        jmp lpOne
      lp1Out:

    ; ------------
    invoke CreatePen,0,1,btn_lo
    mov hPen2, eax
    invoke SelectObject,hDC,hPen2
    mov hPen, eax
    invoke DeleteObject,hPen
    ; ------------

    pop bdrWid
    pop ly
    pop lx
    pop ty
    pop tx

       lpTwo:

        invoke MoveToEx,hDC,tx,ly,NULL
        invoke LineTo,hDC,lx,ly

        invoke MoveToEx,hDC,lx,ty,NULL
        inc ly        
        invoke LineTo,hDC,lx,ly
        dec ly

        dec tx
        dec ty
        inc lx
        inc ly

        dec bdrWid
        cmp bdrWid, 0
        je lp2Out
        jmp lpTwo
      lp2Out:

    ; ------------
    invoke SelectObject,hDC,hpenOld
    invoke DeleteObject,hPen2

    ret

Frame3D endp

; #########################################################################

end start
