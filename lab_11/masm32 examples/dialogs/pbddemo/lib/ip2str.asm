; #########################################################################

    .486                      ; force 32 bit code
    .model flat, stdcall      ; memory model & calling convention
    option casemap :none      ; case sensitive

    include \masm32\include\masm32.inc

    IPtoString PROTO :DWORD,:DWORD

    .code

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

IPtoString proc IP:DWORD,lpBuffer:DWORD

    LOCAL dot [4]:BYTE
    LOCAL val1[4]:BYTE
    LOCAL val2[4]:BYTE
    LOCAL val3[4]:BYTE
    LOCAL val4[4]:BYTE

    push esi
    push edi

    mov DWORD PTR dot, 00202E20h    ; zero terminated " . "

    movzx esi, BYTE PTR IP[3]
    invoke dwtoa,esi,ADDR val1
    movzx esi, BYTE PTR IP[2]
    invoke dwtoa,esi,ADDR val2
    movzx esi, BYTE PTR IP[1]
    invoke dwtoa,esi,ADDR val3
    movzx esi, BYTE PTR IP[0]
    invoke dwtoa,esi,ADDR val4

    mov edi, lpBuffer
    mov BYTE PTR [edi], 0

    invoke szMultiCat,7,lpBuffer,ADDR val1,ADDR dot,ADDR val2,ADDR dot,
                                 ADDR val3,ADDR dot,ADDR val4
    pop edi
    pop esi

    ret

IPtoString endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end