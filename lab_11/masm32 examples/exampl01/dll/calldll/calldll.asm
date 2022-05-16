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
        PushButton PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD

    .data
        szDisplayName db "Direct Call DLL",0
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

        szText szClassName,"CallDLL_Class"

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

    LOCAL hLib  :DWORD

    .if uMsg == WM_COMMAND
    ;======== menu commands ========
        .if wParam == 1000
            invoke SendMessage,hWin,WM_SYSCOMMAND,SC_CLOSE,NULL

        .elseif wParam == 500
            ; -------------------
            ; Direct call the DLL
            ; -------------------
            jmp @F
              libName  db "tstdll.dll",0
              FuncName db "TestProc",0
            @@:

            invoke LoadLibrary,ADDR libName
            mov hLib, eax

            invoke GetProcAddress,hLib,ADDR FuncName
            call eax

            invoke FreeLibrary,hLib

        .elseif wParam == 1900
            szText TheMsg,"Assembler, Pure & Simple"
            invoke MessageBox,hWin,ADDR TheMsg,ADDR szDisplayName,MB_OK
        .endif
    ;====== end menu commands ======

    .elseif uMsg == WM_CREATE

        szText Butn1,"Call DLL Direct"
        invoke PushButton,ADDR Butn1,hWin,20,20,140,25,500


    .elseif uMsg == WM_CLOSE
        szText TheText,"Please Confirm Exit"
        invoke MessageBox,hWin,ADDR TheText,ADDR szDisplayName,MB_YESNO
          .if eax == IDNO
            return 0
          .endif
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
