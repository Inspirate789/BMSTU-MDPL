; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
    include \masm32\include\masm32rt.inc
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

comment * -----------------------------------------------------
                        Build this  template with
                       "CONSOLE ASSEMBLE AND LINK"
        ----------------------------------------------------- *

    get@name PROTO :DWORD

    .data
      txt1 db "<name> name@yourip.com",0
      txt2 db "<phony name> setname@yourip.com",0
      txt3 db "myrtle@yourip.com",0
      txt4 db "<Your Name>name@yourip.com",0
      txt5 db "text error",0

      align 4
      parr dd txt1,txt2,txt3,txt4,txt5

      nam1 db "name@yourip.com",0

    .code

start:
   
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    call main
    inkey
    exit

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

main proc

    push esi
    push edi

    mov esi, OFFSET parr                    ; load array address
    mov edi, LENGTHOF parr                  ; load array member count

  stlp:
    print "Testing  "
    print [esi],13,10                       ; dispay raw input text
    fn get@name,[esi]                       ; extract any @name from it
    test eax, eax
    jnz cmpit
    print "invalid email address",13,10     ; no "@" in name
    jmp @F

  cmpit:
    invoke Cmpi,[esi],ADDR nam1             ; casei compare against OK name
    test eax, eax
    jnz no_good
    print "Accept : "                       ; accept this address as matching
    print [esi],13,10
    jmp @F

  no_good:
    print "Reject : "
    print [esi],13,10                       ; reject this name as a fake

  @@:
    add esi, 4                              ; set next address in array
    sub edi, 1                              ; decrement counter
    jnz stlp

    pop edi
    pop esi

    ret

main endp

; ддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд

.data
  align 16
  filtr \
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0
    db 1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0
    db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
    db 1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,1
    db 0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
    db 1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
.code

align 16

get@name proc src:DWORD

    push ebx
    push esi
    push edi

    xor ebx, ebx                        ; zero EBX as flag for "@" character
    mov esi, src
    mov edi, src
    or ecx, -1

  miss:
    add ecx, 1
    movzx eax, BYTE PTR [esi+ecx]       ; zero extend the byte
    test eax, eax
    jz zero
    movzx edx, BYTE PTR [eax+filtr]     ; test its character class in table
    test edx, edx
    jz miss                             ; jump back on zero

    mov [edi], al                       ; write 1st byte to buffer
    add edi, 1

  hit:
    add ecx, 1
    movzx eax, BYTE PTR [esi+ecx]       ; get next byte
    test eax, eax
    jz zero
    movzx edx, BYTE PTR [eax+filtr]     ; test its character class in table
    test edx, edx
    jz tstit                            ; if zero test if flag is set
    mov [edi], al                       ; write next byte
    add edi, 1
    cmp al, "@"                         ; test if byte is @
    jne hit
    add ebx, 1                          ; set flag if it is
    jmp hit

  tstit:
    mov edi, src                        ; reload src address into EDI
    cmp ebx, 0                          ; test if flag is set
    test ebx, ebx                       ; go back and try next word if it not
    jz miss
    jmp close

  zero:
    test ebx, ebx
    jnz close
    xor eax, eax                        ; set EAX to ZERO on error
    jmp cleanup

  close:
    mov BYTE PTR [edi], 0               ; append terminator
    mov eax, src                        ; return the source address in EAX

  cleanup:
    pop edi
    pop esi
    pop ebx

    ret

get@name endp

; ддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд

end start























