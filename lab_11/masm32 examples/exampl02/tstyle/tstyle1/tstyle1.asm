; #########################################################################

;   This example is written in the older TASM style of code, manually
;   coded stack frame, manually pushed parameters and call syntax, no
;   LOCAL variables on the stack and no macros or MASM pseudo high
;   level syntax to make the code clearer and more reliable.

;   This is the style of code that gave assembler a bad name, hard to
;   read, nearly impossible to maintain or modify, no parameter checking,
;   very slow to develop, inefficient use of memory without using stack
;   memory for transient parameters and it has no advantage when built.

; #########################################################################

      .386
      .model flat, stdcall  ; 32 bit memory model
      option casemap :none  ; case sensitive

;     include files
;     ~~~~~~~~~~~~~
      include \MASM32\INCLUDE\windows.inc
      include \MASM32\INCLUDE\user32.inc
      include \MASM32\INCLUDE\kernel32.inc

;     libraries
;     ~~~~~~~~~
      includelib \MASM32\LIB\user32.lib
      includelib \MASM32\LIB\kernel32.lib

    .data
      hIcon       dd 0
      hWnd        dd 0
      Wtx         dd 0
      Wty         dd 0
      wWid        dd 0
      wHgt        dd 0
      wc          WNDCLASSEX <0>
      msg         MSG <0>
      message1    db "Leaving ?",0
      title1      db "How to write 0xBADC0DE",0
      szClassName db "Old_TASM_Style_Class",0
    
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

    push ebp        ; preserve base pointer
    mov ebp, esp    ; stack pointer into ebp

    push 500
    push DWORD PTR [ebp + 8]  ; instance handle
    call LoadIcon
    mov hIcon, eax

    mov wc.cbSize,         sizeof WNDCLASSEX
    mov wc.style,          CS_BYTEALIGNWINDOW
    mov wc.lpfnWndProc,    offset WndProc
    mov wc.cbClsExtra,     NULL
    mov wc.cbWndExtra,     NULL
    mov eax, [ebp + 8]
    mov wc.hInstance,      eax
    mov wc.hbrBackground,  COLOR_BTNFACE+1
    mov wc.lpszMenuName,   NULL
    mov wc.lpszClassName,  offset szClassName
      push hIcon
      pop eax
    mov wc.hIcon, eax
      push IDC_ARROW
      push NULL
      call LoadCursor
    mov wc.hCursor, eax
      push hIcon
      pop eax
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
    push DWORD PTR [ebp + 8]
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

    mov esp, ebp    ; restore stack pointer
    pop ebp         ; restore base pointer

    ret

; #########################################################################

WndProc:

    push ebp                ; preserve base pointer
    mov ebp, esp            ; stack pointer into ebp

    cmp DWORD PTR [ebp + 12], WM_CLOSE
    jne @F

    push MB_YESNO
    push offset title1
    push offset message1
    push 0
    call MessageBox

    cmp DWORD PTR [ebp + 12], IDNO
    je wpOut

  @@:
    cmp DWORD PTR [ebp + 12], WM_DESTROY
    jne @F
    push NULL
    call PostQuitMessage
  @@:

    push DWORD PTR [ebp + 20]
    push DWORD PTR [ebp + 16]
    push DWORD PTR [ebp + 12]
    push DWORD PTR [ebp + 8]
    call DefWindowProc

    wpOut:                  ; exit without default processing

    mov esp, ebp            ; restore stack pointer
    pop ebp                 ; restore base pointer

    ret

; ########################################################################

TopXY:

    push ebp                ; preserve base pointer
    mov ebp, esp            ; stack pointer into ebp

    mov ecx, [ebp + 8]      ; win width
    mov eax, [ebp + 12]     ; screen wid

    shr ecx, 1
    shr eax, 1
    sub eax, ecx

    mov esp, ebp            ; restore stack pointer
    pop ebp                 ; restore base pointer

    ret

; #########################################################################

end start