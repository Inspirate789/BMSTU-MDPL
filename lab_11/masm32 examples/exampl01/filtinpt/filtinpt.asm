; #########################################################################

      .386
      .model flat, stdcall
      option casemap :none   ; case sensitive

; #########################################################################

      include \masm32\include\windows.inc
      include \masm32\include\user32.inc
      include \masm32\include\kernel32.inc

      includelib \masm32\lib\user32.lib
      includelib \masm32\lib\kernel32.lib

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
        EditSl PROTO  :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
        Static PROTO  :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
        Ed1Proc PROTO :DWORD,:DWORD,:DWORD,:DWORD
        Ed2Proc PROTO :DWORD,:DWORD,:DWORD,:DWORD
        Ed3Proc PROTO :DWORD,:DWORD,:DWORD,:DWORD

    .data
        szDisplayName db " Filtered Input DEMO",0
        CommandLine   dd 0
        hWnd          dd 0
        hInstance     dd 0
        hEdit1        dd 0
        hEdit2        dd 0
        hEdit3        dd 0
        lpfnEd1Proc   dd 0
        lpfnEd2Proc   dd 0
        lpfnEd3Proc   dd 0

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

        mov Wwd, 340
        mov Wht, 250

        invoke GetSystemMetrics,SM_CXSCREEN
        invoke TopXY,Wwd,eax
        mov Wtx, eax

        invoke GetSystemMetrics,SM_CYSCREEN
        invoke TopXY,Wht,eax
        mov Wty, eax

        szText szClassName,"Template_Class"

        invoke CreateWindowEx,WS_EX_OVERLAPPEDWINDOW,
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

    .if uMsg == WM_COMMAND
    ;======== menu commands ========
        .if wParam == 1000
            invoke SendMessage,hWin,WM_SYSCOMMAND,SC_CLOSE,NULL
        .elseif wParam == 1900
            szText TheMsg,"Assembler, Pure & Simple"
            invoke MessageBox,hWin,ADDR TheMsg,ADDR szDisplayName,MB_OK
        .endif
    ;====== end menu commands ======


    .elseif uMsg == WM_CREATE

        jmp wpLbl
          txt1    db " Numeric",0
          txt2    db " Lcase",0
          txt3    db " Ucase",0
          nulbyte db 0
        wpLbl:

        invoke Static,ADDR txt1,hWin,10,10,100,22,500
        invoke Static,ADDR txt2,hWin,10,40,100,22,501
        invoke Static,ADDR txt3,hWin,10,70,100,22,502

        invoke EditSl,ADDR nulbyte,120,10,200,23,hWin,200
        mov hEdit1, eax
        invoke EditSl,ADDR nulbyte,120,40,200,23,hWin,201
        mov hEdit2, eax
        invoke EditSl,ADDR nulbyte,120,70,200,23,hWin,202
        mov hEdit3, eax

        invoke SetWindowLong,hEdit1,GWL_WNDPROC,Ed1Proc
        mov lpfnEd1Proc, eax

        invoke SetWindowLong,hEdit2,GWL_WNDPROC,Ed2Proc
        mov lpfnEd2Proc, eax

        invoke SetWindowLong,hEdit3,GWL_WNDPROC,Ed3Proc
        mov lpfnEd3Proc, eax

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

; ########################################################################

EditSl proc szMsg:DWORD,a:DWORD,b:DWORD,
               wd:DWORD,ht:DWORD,hParent:DWORD,ID:DWORD

; EditSl PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
; invoke EditSl,adrTxt:DWORD,200,10,150,250,hWnd,700

    szText slEdit,"EDIT"

    invoke CreateWindowEx,WS_EX_CLIENTEDGE,ADDR slEdit,szMsg,
                WS_VISIBLE or WS_CHILDWINDOW or \
                ES_AUTOHSCROLL or ES_NOHIDESEL,
              a,b,wd,ht,hParent,ID,hInstance,NULL

    ret

EditSl endp

; ########################################################################

Static proc lpText:DWORD,hParent:DWORD,
                 a:DWORD,b:DWORD,wd:DWORD,ht:DWORD,ID:DWORD

    szText statClass,"STATIC"

    invoke CreateWindowEx,WS_EX_STATICEDGE,
            ADDR statClass,lpText,
            WS_CHILD or WS_VISIBLE or SS_LEFT,
            a,b,wd,ht,hParent,ID,
            hInstance,NULL

    ret

Static endp

; ########################################################################

Ed1Proc proc hCtl   :DWORD,
             uMsg   :DWORD,
             wParam :DWORD,
             lParam :DWORD

    LOCAL Buffer[32]:BYTE

    ; -----------------------------
    ; Process control messages here
    ; -----------------------------

    .if uMsg == WM_CHAR
        .if wParam == 8             ; backspace
            jmp accept
        .endif

        .if wParam == "."           ; only allow one decimal point

            invoke SendMessage,hCtl,WM_GETTEXT,sizeof Buffer,ADDR Buffer

            mov ecx, sizeof Buffer  ; byte count in ecx
            lea esi, Buffer         ; address in esi
          @xxx:
            lodsb                   ; load byte into al

            cmp al, "."             ; if decimal point already in Buffer
            jne @xx1
              return 0              ; throw it away
            @xx1:

            dec ecx
            cmp ecx, 0
            jne @xxx

            jmp accept
        .endif

        .if wParam < "0"
            return 0
        .endif

        .if wParam > "9"
            return 0
        .endif

    .endif

    accept:

    invoke CallWindowProc,lpfnEd1Proc,hCtl,uMsg,wParam,lParam

    ret

Ed1Proc endp

; #########################################################################

Ed2Proc proc hCtl   :DWORD,
             uMsg   :DWORD,
             wParam :DWORD,
             lParam :DWORD

    ; -----------------------------
    ; Process control messages here
    ; -----------------------------

    .if uMsg == WM_CHAR
        .if wParam >= "A"
          .if wParam <= "Z"
            add wParam, 32
          .endif
        .endif
    .endif

    invoke CallWindowProc,lpfnEd2Proc,hCtl,uMsg,wParam,lParam

    ret

Ed2Proc endp

; #########################################################################

Ed3Proc proc hCtl   :DWORD,
             uMsg   :DWORD,
             wParam :DWORD,
             lParam :DWORD

    ; -----------------------------
    ; Process control messages here
    ; -----------------------------

    .if uMsg == WM_CHAR
        .if wParam >= "a"
          .if wParam <= "z"
            sub wParam, 32
          .endif
        .endif
    .endif

    invoke CallWindowProc,lpfnEd3Proc,hCtl,uMsg,wParam,lParam

    ret

Ed3Proc endp

; #########################################################################

end start
