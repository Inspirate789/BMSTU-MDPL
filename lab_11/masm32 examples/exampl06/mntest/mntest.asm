; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
    include \masm32\include\masm32rt.inc
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

comment * -----------------------------------------------------
                        Build this  template with
                       "CONSOLE ASSEMBLE AND LINK"
        ----------------------------------------------------- *

    .code

start:
   
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    call main
    inkey
    exit

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

main proc

    push esi

    mov esi, 11000000h
    or  esi, 00220000h
    or  esi, 00003300h
    or  esi, 00000044h

    print "OR COMBINING demo "
    print hex$(esi),13,10

    mov esi, 99999999h
    and esi, 0000FFFFh

    print "AND MASKING  demo "
    print hex$(esi),13,10

    mov esi, 9999FFFFh
    xor esi, 33335555h

    print "XOR   DWORD  demo "
    print hex$(esi),13,10

    mov esi, 1024
    shr esi, 1              ; SHR by 1 is integer div by 2

    print "SHR DIV demo "
    print str$(esi),13,10

    mov esi, 512
    shl esi, 1              ; SHL by 1 is mul by 2
                            ; note that ADD ESI, ESI is faster
    print "SHL MUL demo "
    print str$(esi),13,10

    xor esi, esi            ; clear a register (set to ZERO)
    test esi, esi           ; test if register is ZERO (if zero flag is set by TEST)
    jz @F                   ; jump if zero flag is ZERO to next @@: label
    nop                     ; do nothing here
    nop
  @@:
    print "register is zero and ZERO flag is ZERO",13,10

    pop esi

    ret

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start
