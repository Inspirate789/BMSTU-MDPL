; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    .486                      ; create 32 bit code
    .model flat, stdcall      ; 32 bit memory model
    option casemap :none      ; case sensitive

    include masm1k.inc        ; local includes for this file

  .code
    szClassName db "MASM 1k", 0

  start:

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

Main proc

    LOCAL msg      :MSG
    LOCAL wc       :WNDCLASSEX

    xor edi, edi
    mov esi, 400000h

    mov ebx, OFFSET szClassName

    invoke LoadCursor,edi,IDC_ARROW

    mov wc.cbSize,         sizeof WNDCLASSEX
    mov wc.style,          CS_VREDRAW or CS_HREDRAW
    mov wc.lpfnWndProc,    offset WndProc
    mov wc.cbClsExtra,     edi
    mov wc.cbWndExtra,     edi
    mov wc.hInstance,      esi
    mov wc.hbrBackground,  COLOR_BTNFACE+1
    mov wc.lpszMenuName,   edi
    mov wc.lpszClassName,  ebx
    mov wc.hIcon,          edi
    mov wc.hCursor,        eax
    mov wc.hIconSm,        edi

    invoke RegisterClassEx, ADDR wc

    mov ecx, CW_USEDEFAULT

    invoke CreateWindowEx,edi,ebx,ebx,
                          WS_OVERLAPPEDWINDOW,
                          ecx,edi,
                          ecx,edi,
                          edi,edi,
                          esi,edi

    invoke ShowWindow,eax,SW_SHOWNORMAL

    lea ebx, msg
    jmp inloop

  StartLoop:
    invoke DispatchMessage,ebx
  inloop:
    invoke GetMessage,ebx,edi,edi,edi
    test al, al
    jnz StartLoop

    ret

Main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

WndProc proc hWin   :DWORD,
             uMsg   :DWORD,
             wParam :DWORD,
             lParam :DWORD

    cmp DWORD PTR uMsg, WM_DESTROY
    jne @F
      invoke PostQuitMessage,NULL
    @@:

    invoke DefWindowProc,hWin,uMsg,wParam,lParam

    ret

WndProc endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start
