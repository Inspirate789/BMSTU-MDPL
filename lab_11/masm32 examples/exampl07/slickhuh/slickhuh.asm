    .686p
    .model flat, stdcall
    option casemap :none
    externdef _imp__DispatchMessageA@4:PTR pr1
    m2wp equ <_imp__DispatchMessageA@4>
    externdef _imp__GetMessageA@16:PTR pr4
    gms equ <_imp__GetMessageA@16>
    externdef _imp__DefWindowProcA@16:PTR pr4
    dpro equ <_imp__DefWindowProcA@16>
    externdef _imp__PostQuitMessage@4:PTR pr1
    pqm equ <_imp__PostQuitMessage@4>
    externdef _imp__RegisterClassExA@4:PTR pr1
    scln equ <_imp__RegisterClassExA@4>
    externdef _imp__ShowWindow@8:PTR pr2
    wshw equ <_imp__ShowWindow@8>
    externdef _imp__LoadCursorA@8:PTR pr2
    lsc equ <_imp__LoadCursorA@8>
    externdef _imp__CreateWindowExA@48:PTR pr12
    crwe equ <_imp__CreateWindowExA@48>
    includelib \masm32\lib\user32.lib
  .code
    ims db "Slick Huh ?", 0
    pcl dd ims
  slick_huh:
    push ebp
    mov ebp, esp
    sub esp, 96
    push 32512
    xor edi, edi
    push edi
    mov esi, 4194304
    mov ebx, pcl
    call lsc
    mov DWORD PTR [ebp-96], 48
    mov DWORD PTR [ebp-92], 3
    mov DWORD PTR [ebp-88], OFFSET wpep
    mov DWORD PTR [ebp-84], edi
    mov DWORD PTR [ebp-80], edi
    mov DWORD PTR [ebp-76], esi
    mov DWORD PTR [ebp-72], edi
    mov DWORD PTR [ebp-68], eax
    mov DWORD PTR [ebp-64], 10h
    mov DWORD PTR [ebp-60], edi
    mov DWORD PTR [ebp-56], ebx
    mov DWORD PTR [ebp-52], edi
    lea eax, [ebp-96]
    push eax
    call scln
    mov ecx, -2147483648
    push 1
    push edi
    push esi
    push edi
    push edi
    push edi
    push ecx
    push edi
    push ecx
    push 13565952
    push ebx
    push ebx
    push edi
    call crwe
    push eax
    call wshw
    lea ebx, [ebp-48]
    push edi
    push edi
    push edi
    push ebx
    jmp mlep
  @@: push edi
    push edi
    push edi
    push ebx
    push ebx
    call m2wp
    mlep: call gms
    test al, al
    jnz @B
    leave
    retn
  wpep: cmp DWORD PTR [esp+8], 2
    jne @F
    push 0
    call pqm
  @@: jmp dpro
  end slick_huh
