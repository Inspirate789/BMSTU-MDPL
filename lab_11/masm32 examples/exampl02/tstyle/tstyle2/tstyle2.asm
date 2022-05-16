; #########################################################################

;   This example emulates a technique used in older style TASM code
;   called a message despatcher. It hides the manual stack manipulation
;   in two macros and uses equates to make the stack parameters easier
;   to use. The manual push & call syntax is done in the normal STDCALL
;   calling convention of pushing parameters in reverse order.

; #########################################################################

      .386
      .model flat, stdcall  ; 32 bit memory model
      option casemap :none  ; case sensitive

;     include files
;     ~~~~~~~~~~~~~
      include \MASM32\INCLUDE\windows.inc
      include \MASM32\INCLUDE\user32.inc
      include \MASM32\INCLUDE\kernel32.inc
      include \masm32\include\shell32.inc

;     libraries
;     ~~~~~~~~~
      includelib \MASM32\LIB\user32.lib
      includelib \MASM32\LIB\kernel32.lib
      includelib \masm32\lib\shell32.lib

    ; ---------------------------------------------
    ; make stack parameters look half intelligible
    ; ---------------------------------------------
      hWin   equ <DWORD PTR [ebp + 8]>
      uMsg   equ <DWORD PTR [ebp + 12]>
      wParam equ <DWORD PTR [ebp + 16]>
      lParam equ <DWORD PTR [ebp + 20]>

      wWidth equ <DWORD PTR [ebp + 8]>
      sWidth equ <DWORD PTR [ebp + 12]>

      hInst  equ <DWORD PTR [ebp + 8]>

      EnterStack MACRO
        push ebp
        mov ebp, esp
      ENDM

      LeaveStack MACRO
        mov esp, ebp
        pop ebp
      ENDM

    .data?
      hIcon       dd ?
      hWnd        dd ?
      Wtx         dd ?
      Wty         dd ?
      wWid        dd ?
      wHgt        dd ?
      hMnu        dd ?

    .data
      wc          WNDCLASSEX <>
      msg         MSG <>
      message1    db "Leaving ?",0
      title1      db "TASM style message despatcher",0
      szClassName db "Old_TASM_Message_Despatcher_Class",0
      AboutMsg    db "Obsolete code design example.",13,10,\
                     "Copyright © 2000 MASM32",0

; #########################################################################

    .code

start:

    push NULL
    call GetModuleHandle
    push eax                ; the instance handle
    call main

    push 0
    call ExitProcess

; #########################################################################

main:

    EnterStack

    push 500
    push hInst
    call LoadIcon
    mov hIcon, eax

    mov wc.cbSize,         sizeof WNDCLASSEX
    mov wc.style,          CS_BYTEALIGNWINDOW
    mov wc.lpfnWndProc,    offset WndProc
    mov wc.cbClsExtra,     NULL
    mov wc.cbWndExtra,     NULL
    mov eax, hInst
    mov wc.hInstance,      eax
    mov wc.hbrBackground,  COLOR_BTNFACE+1
    mov wc.lpszMenuName,   NULL
    mov wc.lpszClassName,  offset szClassName
    mov eax, hIcon
    mov wc.hIcon, eax
    push IDC_ARROW
    push NULL
    call LoadCursor
    mov wc.hCursor, eax
    mov eax, hIcon
    mov wc.hIconSm, eax

    push offset wc
    call RegisterClassEx

    mov wWid, 450
    mov wHgt, 350

    push SM_CXSCREEN
    call GetSystemMetrics
    push eax
    push wWid
    call TopXY
    mov Wtx, eax

    push SM_CYSCREEN
    call GetSystemMetrics
    push eax
    push wHgt
    call TopXY
    mov Wty, eax

    push NULL
    push hInst
    push NULL
    push NULL
    push wHgt
    push wWid
    push Wty
    push Wtx
    push WS_OVERLAPPEDWINDOW
    push offset title1
    push offset szClassName
    push WS_EX_LEFT
    call CreateWindowEx
    mov  hWnd,eax

    push 100
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

    StartLoop:
      push 0
      push 0
      push NULL
      push offset msg
      call GetMessage

      cmp eax, 0
      je ExitLoop

      push offset msg
      call TranslateMessage

      push offset msg
      call DispatchMessage

      jmp StartLoop
    ExitLoop:

    LeaveStack

    ret

; #########################################################################

WndProc:

    EnterStack

  ; -----------------------
  ; The message despatcher
  ; -----------------------
    cmp uMsg, WM_COMMAND
    jne @F
    jmp DoCommand
  @@:
    cmp uMsg, WM_CLOSE
    jne @F
    jmp ConfirmExit
  @@:
    cmp uMsg, WM_DESTROY
    jne @F
    jmp CallQuit
  @@:
    jmp DoDefault           ; default processing
  ; -----------------------

    wpOut:                  ; exit without default processing

    LeaveStack

    ret

  DoDefault:
    push lParam
    push wParam
    push uMsg
    push hWin
    call DefWindowProc
    jmp wpOut

  ConfirmExit:
    push MB_YESNO
    push offset title1
    push offset message1
    push 0
    call MessageBox
    cmp eax, IDNO
    je wpOut
    jmp DoDefault

  CallQuit:
    push NULL
    call PostQuitMessage
    jmp wpOut

  DoCommand:
    cmp wParam, 1000
    jne @F
    push NULL
    push SC_CLOSE
    push WM_SYSCOMMAND
    push hWnd
    call SendMessage
    jmp DoDefault
  @@:

    cmp wParam, 2000
    jne @F
    push hIcon
    push offset AboutMsg
    push offset title1
    push hWnd
    call ShellAbout
    jmp DoDefault
  @@:
    jmp DoDefault


; ########################################################################

TopXY:

    EnterStack

    mov ecx, wWidth           ; win width
    mov eax, sWidth           ; screen wid

    shr ecx, 1
    shr eax, 1
    sub eax, ecx

    LeaveStack

    ret

; #########################################################################

end start