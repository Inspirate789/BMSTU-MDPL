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

    .data
        szDisplayName db "Template",0
        CommandLine   dd 0
        hWnd          dd 0
        hInstance     dd 0
        TheMsg        db "Assembler, Pure & Simple",0
        TheText       db "Please Confirm Exit",0
        szClassName   db "Template_Class",0

    .code

start:
        push NULL
        call GetModuleHandle
        mov hInstance, eax

        call GetCommandLine
        mov CommandLine, eax

        push SW_SHOWDEFAULT
        push CommandLine
        push NULL
        push hInstance
        call WinMain

        push eax
        call ExitProcess

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
        m2m wc.hInstance,      hInst
        mov wc.hbrBackground,  COLOR_BTNFACE+1
        mov wc.lpszMenuName,   NULL
        mov wc.lpszClassName,  offset szClassName

        push 500
        push hInst
        call LoadIcon
        mov wc.hIcon, eax
        
        push IDC_ARROW
        push NULL
        call LoadCursor
        mov wc.hCursor, eax
        mov wc.hIconSm, 0

        lea eax, wc
        push eax
        call RegisterClassEx

        ;================================
        ; Centre window at following size
        ;================================

        mov Wwd, 500
        mov Wht, 350

        push SM_CXSCREEN
        call GetSystemMetrics

        push eax
        push Wwd
        call TopXY
        mov Wtx, eax

        push SM_CYSCREEN
        call GetSystemMetrics

        push eax
        push Wht
        call TopXY
        mov Wty, eax

        push NULL
        push hInst
        push NULL
        push NULL
        push Wht
        push Wwd
        push Wty
        push Wtx
        push WS_OVERLAPPEDWINDOW
        push offset szDisplayName
        push offset szClassName
        push WS_EX_OVERLAPPEDWINDOW
        call CreateWindowEx

        mov   hWnd,eax

        push 600
        push hInst
        call LoadMenu

        push eax
        push hWnd
        call SetMenu

        push SW_SHOWNORMAL
        push hWnd
        call ShowWindow

        push hWnd
        call UpdateWindow

      ;===================================
      ; Loop until PostQuitMessage is sent
      ;===================================

    StartLoop:
      push 0
      push 0
      push NULL
      lea eax, msg
      push eax
      call GetMessage

      cmp eax, 0
      je ExitLoop

      lea eax, msg
      push eax
      call TranslateMessage

      lea eax, msg
      push eax
      call DispatchMessage

      jmp StartLoop
    ExitLoop:

      mov eax, msg.wParam
      ret

WinMain endp

; #########################################################################

WndProc proc hWin   :DWORD,
             uMsg   :DWORD,
             wParam :DWORD,
             lParam :DWORD

    cmp uMsg, WM_COMMAND
    jne nxt1
      cmp wParam, 1000
      jne cmd1
        push NULL
        push SC_CLOSE
        push WM_SYSCOMMAND
        push hWin
        call SendMessage
        
      cmd1:
      cmp wParam, 1900
      jne cmd2
        push MB_OK
        push offset szDisplayName   ; in .data section
        push offset TheMsg          ; in .data section
        push hWin
        call MessageBox

      cmd2:

    nxt1:
    cmp uMsg, WM_CLOSE
    jne nxt2
      push MB_YESNO
      push offset szDisplayName     ; in .data section
      push offset TheText           ; in .data section
      push hWin
      call MessageBox
        cmp eax, IDNO
        jne nxt2
          xor eax, eax              ; put zero in eax
          ret                       ; exit the proc

    nxt2:
    cmp uMsg, WM_DESTROY
    jne nxt3
      push NULL
      call PostQuitMessage
      xor eax, eax                  ; put zero in eax
      ret                           ; exit the proc

    nxt3:
      push lParam
      push wParam
      push uMsg
      push hWin
      call DefWindowProc

    ret

WndProc endp

; ########################################################################

TopXY proc wDim:DWORD, sDim:DWORD

    shr sDim, 1      ; divide screen dimension by 2
    shr wDim, 1      ; divide window dimension by 2
    mov eax, wDim    ; copy window dimension into eax
    sub sDim, eax    ; sub half win dimension from half screen dimension

    mov eax, sDim
    ret

TopXY endp

; ########################################################################

end start
