IF 0  ; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

                      Build this template with "CONSOLE ASSEMBLE AND LINK"

                                       Random Pad Generator

    Algorith is designed to produce a user selected size random pad that does not have any
    routine method of reproducing it.

    It creates a starting random seed from 2 serialised calls to RDTSC
    The random sequence generator creates a pad of twice the size then XORs the second
    half to the first to produce a pad the size the user required.

    This process is repeated to produce a second random pad with a seed that is produced
    by the same method but sampled from the seed generator with some time lapse from the
    first sample. The two pads are then xorred together to make a single pad.

    The logic of this technique is that every computer is sufficiently different to not have
    identical durations for processes which will in turn yield variations in the spacing
    between calls to RDTSC that produce the random seeds.

    A single seed is the weakest point in producing a random pad. It can be broken by brute
    force by running the entire DWORD range, a trivial task for later dedicated hardware.

    By using an unpredictable interval spacing between requests for seeds, the order of
    complexity increases.

    1 seed  4 gig range
    2 seeds 4 gig ^ 4 gig.


ENDIF ; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    include \masm32\include\masm32rt.inc

    get_random_seed PROTO
    create_random_pad PROTO :DWORD

    .code

start:
   
; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    call main
    inkey chr$(13,10)
    exit

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

main proc

    LOCAL pmem1  :DWORD
    LOCAL pmem2  :DWORD
    LOCAL blen   :DWORD
    LOCAL pbuf  :DWORD
    LOCAL buffer[32]:BYTE
    LOCAL mult  :DWORD

    mov pbuf, ptr$(buffer)      ; command line buffer

    invoke GetCL,1,pbuf

    .if eax != 1
      print "Random Pad Generator",13,10,13,10
      print "With no command line, pad size is set to 4 megabytes",13,10
      print "To change this size enter the number of megabytes at",13,10
      print "the command line.",13,10,13,10
      print "rpg 10 = 10 megabytes pad size etc ....",13,10,13,10

      mov blen, 1024*1024*4
    .else
      mov edx, uval(pbuf)

      .if edx == 0
        mov mult, 4
      .else
        mov mult, edx
      .endif
      mov blen, rv(IntMul,mult,1024*1024)
    .endif

    print "Creating a random pad of "
    print ustr$(blen)," bytes",13,10

  ; -----------------------------
  ; create 2 seperate random pads
  ; -----------------------------
    pushad
    print "pass 1 of 3",13,10
    popad
    invoke create_random_pad, blen
    mov pmem1, eax
    pushad
    print "pass 2 of 3",13,10
    popad
    invoke create_random_pad, blen
    mov pmem2, eax

    mov esi, pmem1
    mov edi, pmem2
    mov ebx, blen
    or edx, -1

  ; -------------------------
  ; xor the two pads together
  ; -------------------------
    pushad
    print "pass 3 of 3",13,10
    popad

  xorloop:
    add edx, 1
    movzx eax, BYTE PTR [esi+edx]
    movzx ecx, BYTE PTR [edi+edx]
    xor eax, ecx
    mov [esi], al
    add edx, 1
    cmp edx, ebx
    jb xorloop

    mov eax, OutputFile("random.pad",pmem1,blen)

    free pmem1
    free pmem2

    fn WinExec,"ent random.pad",1

    ret

main endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

get_random_seed proc

    LOCAL num   :DWORD
    LOCAL rcnt  :DWORD
    LOCAL number$ :DWORD

    LOCAL pbuf  :DWORD
    LOCAL buffer[64]:BYTE

    LOCAL imnum1 :DWORD

    cpuid                           ; serialising instruction for wider seperation
                                    ; of results from RDTSC
    pause                           ; spinlock delay instruction

    invoke SleepEx,10,0

    cpuid                           ; serialising instruction for wider seperation
                                    ; of results from RDTSC
    pause                           ; spinlock delay instruction


    rdtsc
    mov num, eax                    ; use the low dword of RDTSC return value
    mov number$, rev$(ustr$(num))   ; convert to string and reverse string
    mov num, uval(left$(number$,10)); read up to 10 characters from left side of string

    mov pbuf, ptr$(buffer)          ; get buffer address
    cst pbuf, number$               ; copy result to buffer
    mov pbuf, left$(pbuf,2)         ; get the left 2 bytes  0 - 99
    mov rcnt, uval(pbuf)            ; create the rotation count

    cpuid                           ; serialising instruction for wider seperation
                                    ; of results from RDTSC
    pause                           ; spinlock delay instruction

    invoke SleepEx,10,0

    cpuid                           ; serialising instruction for wider seperation
                                    ; of results from RDTSC
    pause                           ; spinlock delay instruction

    mov eax, num
    mov ecx, rcnt
    rol eax, cl                     ; rotate LEFT 1st result by CL count
    mov imnum1, eax

    rdtsc
    mov num, eax
    mov number$, rev$(ustr$(num))   ; convert to string and reverse string
    mov num, uval(left$(number$,10)); read up to 10 characters from left side of string

    mov eax, num
    mov ecx, rcnt
    ror eax, cl                     ; rotate RIGHT 2nd result by CL count

    xor eax, imnum1                 ; XOR the two results

    ret

get_random_seed endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

align 4

create_random_pad PROC count:DWORD

    LOCAL range :DWORD
    LOCAL pmem  :DWORD
    LOCAL xtra  :DWORD
    LOCAL rseed :DWORD
    LOCAL icnt  :DWORD
    LOCAL lcnt  :DWORD

    push ebx
    push esi
    push edi

    mov eax, count
    add eax, eax                    ; double the original count
    mov lcnt, eax                   ; store result in lcnt

    mov range, 255                  ; byte range
    mov pmem, alloc(lcnt)           ; allocate a buffer for the pad size

    mov rseed, rv(get_random_seed)  ; get an initial seed
    xor ebx, ebx                    ; set the loop lcnter
    mov edi, pmem                   ; put the buffer address into EDI

; ------------------
; NaN's nrandom algo
; ------------------
  lpstart:
    mov eax, rseed
    test eax, 80000000h
    jz  @F
    add eax, 7FFFFFFFh
  @@:   
    xor edx, edx
    mov ecx, 127773
    div ecx
    mov ecx, eax
    mov eax, 16807
    mul edx
    mov edx, ecx
    mov ecx, eax
    mov eax, 2836
    mul edx
    sub ecx, eax
    xor edx, edx
    mov eax, ecx
    mov rseed, ecx
    div range

    mov [edi], dl                   ; write BYTE result to buffer
    add edi, 1

    add rseed, 1

    add icnt, 1
    add ebx, 1
    cmp ebx, lcnt
    jl lpstart

; --------------------------------------------------------------------------------------------------

    mov xtra, alloc(count)          ; allocate a buffer for the pad size

    mov esi, pmem                   ; loaded random buffer
    mov edi, xtra
    mov ebx, count
    sub esi, 1
    mov edx, ebx
    neg edx

  cploop:
    add esi, 1
    movzx eax, BYTE PTR [esi]
    movzx ecx, BYTE PTR [esi+ebx]
    xor eax, ecx
    mov [edi], al
    add edi, 1
    add edx, 1
    jnz cploop

    free pmem

    pop edi
    pop esi
    pop ebx

    mov eax, xtra                   ; return the pad address
    ret

create_random_pad ENDP

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

end start



