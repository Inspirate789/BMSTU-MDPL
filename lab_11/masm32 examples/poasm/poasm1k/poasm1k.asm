; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

comment * -------------------------------------------------------------
    This example is written in pure Intel mnemonics to demonstrate that
    Pelle's Macro Assembler can build code at the lowest level possible

         Build this example from the PROJECT menu with MAKEIT.BAT

    ----------------------------------------------------------------- *

    .486
    .model flat, stdcall      ; 32 bit memory model
    option casemap :none      ; case sensitive

    include poasm1k.inc       ; local includes for this file

  .code
    szClassName db "POASM 1k", 0

  start:

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    push ebp                                ; set up a stack frame
    mov ebp, esp

    sub esp, 96                             ; create stack space for locals

    xor edi, edi
    mov esi, 400000h                        ; use constant for the hInstance

    mov ebx, OFFSET szClassName

    push IDC_ARROW
    push edi
    call LoadCursor

  ; -----------------------------------
  ; manually coded WNDCLASSEX structure
  ; -----------------------------------
    mov DWORD PTR [ebp-96], 48
    mov DWORD PTR [ebp-92], CS_VREDRAW or CS_HREDRAW
    mov DWORD PTR [ebp-88], OFFSET MyWndProc
    mov DWORD PTR [ebp-84], edi
    mov DWORD PTR [ebp-80], edi
    mov DWORD PTR [ebp-76], esi
    mov DWORD PTR [ebp-72], edi
    mov DWORD PTR [ebp-68], eax
    mov DWORD PTR [ebp-64], COLOR_BTNFACE+1
    mov DWORD PTR [ebp-60], edi
    mov DWORD PTR [ebp-56], ebx
    mov DWORD PTR [ebp-52], edi

    lea eax, [ebp-96]
    push eax
    call RegisterClassEx                    ; register the window class

    mov ecx, CW_USEDEFAULT

    push edi
    push esi
    push edi
    push edi
    push edi
    push ecx
    push edi
    push ecx
    push WS_OVERLAPPEDWINDOW
    push ebx
    push ebx
    push edi
    call CreateWindowEx                     ; create the main window

    push SW_SHOWNORMAL
    push eax
    call ShowWindow                         ; display it

    lea ebx, [ebp-48]                       ; load stack space for the
                                            ; MSG structure in EBX
    jmp jmpin

  StartLoop:
    push ebx
    call DispatchMessage
  jmpin:
    push edi
    push edi
    push edi
    push ebx
    call GetMessage                         ; process messages until
                                            ; GetMessage returns zero
    test al, al
    jnz StartLoop

    leave                                   ; exit the stack frame
    retn                                    ; make a NEAR return

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

MyWndProc:

    push ebp                                ; set up a stack frame
    mov ebp, esp

    cmp DWORD PTR [ebp+12], WM_DESTROY
    jne @F
      push NULL
      call PostQuitMessage
    @@:

    push DWORD PTR [ebp+20]
    push DWORD PTR [ebp+16]
    push DWORD PTR [ebp+12]
    push DWORD PTR [ebp+8]
    call DefWindowProc

    leave                                   ; exit the stack frame
    ret 16                                  ; balance stack on exit

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start