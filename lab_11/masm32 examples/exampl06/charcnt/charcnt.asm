IF 0  ; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
                      Build this template with "CONSOLE ASSEMBLE AND LINK"
ENDIF ; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    include \masm32\include\masm32rt.inc

    char_count PROTO :DWORD,:DWORD

    .code

start:
   
; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    call main
    inkey
    exit

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

main proc

    LOCAL carr[256]:DWORD       ; array to hold character counts
    LOCAL hMem  :DWORD          ; handle of text memory

    push ebx
    push esi
    push edi

    mov hMem, InputFile("\masm32\include\windows.inc")

    invoke memfill,ADDR carr,1024,0     ; zero fill array
    invoke char_count,hMem,ADDR carr    ; count characters in source

    lea esi, carr
    xor ebx, ebx

  lbl:
    mov edi, [esi+ebx*4]
    print ustr$(ebx)," --- "
    print ustr$(edi),13,10

    add ebx, 1
    cmp ebx, 255
    jle lbl

    free hMem

    pop edi
    pop esi
    pop ebx

    ret

main endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

char_count proc psrc:DWORD,parr:DWORD

    mov ecx, psrc
    mov edx, parr
    sub ecx, 1

  ; -----------
  ; unroll by 4
  ; -----------
  align 4
  lbl0:
    add ecx, 1
    movzx eax, BYTE PTR [ecx]         ; zero extend each byte into EAX
    add DWORD PTR [edx+eax*4], 1      ; increment the count for that character
    test eax, eax
    jz lbl1

    add ecx, 1
    movzx eax, BYTE PTR [ecx]
    add DWORD PTR [edx+eax*4], 1
    test eax, eax
    jz lbl1

    add ecx, 1
    movzx eax, BYTE PTR [ecx]
    add DWORD PTR [edx+eax*4], 1
    test eax, eax
    jz lbl1

    add ecx, 1
    movzx eax, BYTE PTR [ecx]
    add DWORD PTR [edx+eax*4], 1
    test eax, eax
    jnz lbl0

  lbl1:
    sub ecx, psrc                     ; calculate the length of the source
    mov eax, ecx                      ; return it to the caller

    ret

char_count endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

end start
