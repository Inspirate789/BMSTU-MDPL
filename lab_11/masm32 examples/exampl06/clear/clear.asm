; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
    include \masm32\include\masm32rt.inc
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

comment * -----------------------------------------------------
                        Build this  template with
                       "CONSOLE ASSEMBLE AND LINK"
        ----------------------------------------------------- *

    memory_clear PROTO :DWORD,:DWORD,:BYTE

    .code

start:
   
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    call main

    exit

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

main proc

    .data
      string db "This is a test ?",0
    .code

    invoke memory_clear,ADDR string,LENGTHOF string,"x"

    print ADDR string,13,10

    ret

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

align 4

memory_clear proc lpMem:DWORD, count:DWORD, fill:BYTE

    push edi

    mov edi, lpMem              ; Pointer to memory
    xor edx, edx                ; prevent stall on WORD write
    mov dl, fill                ; Value to initialize memory with
    mov dh, fill

    mov ecx, count              ; number of bytes to write
    push ecx

    mov WORD PTR count[0], dx   ; reuse "count" variable
    mov WORD PTR count[2], dx

    mov eax, count
    shr ecx,2                   ; numbers of dwords to write
    rep stosd

    pop ecx
    and ecx,3                   ; number of remaining bytes to write

    xor eax, eax                ; prevent stall on following BYTE write
    mov al, fill
    rep stosb

    pop edi

    ret

memory_clear endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start
