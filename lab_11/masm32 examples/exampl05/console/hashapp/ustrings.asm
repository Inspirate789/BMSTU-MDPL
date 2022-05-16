; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;                      Build as a console application
;
; Hash table based app to display unique strings to either the console or
; by redirection to a file.
;
;                  use >> Console Assemble & Link << use
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    .486
    .model flat, stdcall
    option casemap :none   ; case sensitive

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    dbg equ 0           ; change to 1 for timing and collision count

    include \masm32\include\windows.inc
    include \masm32\include\masm32.inc
    include \masm32\include\user32.inc
    include \masm32\include\kernel32.inc
    include \masm32\macros\macros.asm

    includelib \masm32\lib\masm32.lib
    includelib \masm32\lib\user32.lib
    includelib \masm32\lib\kernel32.lib

    main PROTO

    create_prime_table PROTO
    create_hash_table PROTO :DWORD,:DWORD
    write_to_table PROTO :DWORD,:DWORD,:DWORD,:DWORD
    hashkey PROTO :DWORD,:DWORD,:DWORD

    scanwords  PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
    scan_table PROTO :DWORD,:DWORD,:DWORD

.data
    align 4
    ctable \
      db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0     ; 31
      db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0     ; 63
      db 0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
      db 1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0     ; 95
      db 0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
      db 1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0     ; 127
      db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

    wcnt dd 0
    coll dd 0

    hsiz  equ <131072>  ; element count for hash table
    btcnt equ <32>      ; byte count for each element

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    .code

start:

    call main

    invoke ExitProcess,0

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

main proc

    LOCAL hprime :DWORD
    LOCAL harray :DWORD
    LOCAL hstrng :DWORD
    LOCAL hFile  :DWORD
    LOCAL fsiz   :DWORD
    LOCAL br     :DWORD
    LOCAL hmem$  :DWORD
    LOCAL fname$[260]:BYTE

    invoke GetCL,1,ADDR fname$
    cmp eax, 1
    je @F
    print SADD("No file specified")
    ret
  @@:
    invoke exist,ADDR fname$
    cmp eax, 0
    jne @F

    print SADD("Sorry, cannot find that file")
    ret
  @@:

    mov wcnt, 0

    invoke create_prime_table
    mov hprime, eax

    invoke create_hash_table,hsiz ,btcnt
    mov harray, eax
    mov hstrng, ecx

    invoke CreateFile,ADDR fname$,GENERIC_READ,FILE_SHARE_READ,
                      NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
    mov hFile, eax
    invoke GetFileSize,hFile,NULL
    mov fsiz , eax
    mov hmem$, alloc(fsiz )
    invoke ReadFile,hFile,hmem$,fsiz ,ADDR br,NULL

    ; ==============
    IF dbg
    ClockitStart
    ENDIF
    ; ==============

    invoke scanwords,hmem$,fsiz ,ADDR ctable,hsiz ,hprime,harray

    ; ==============
    IF dbg
    ClockitStop 0,1
    ENDIF
    ; ==============

    invoke CloseHandle,hFile

    invoke scan_table,hstrng,hsiz ,btcnt

    ; ==============
    IF dbg
    invoke MessageBox,0,str$(coll),SADD("collisions"),MB_OK
    ENDIF
    ; ==============

    free hmem$
    free hprime
    free harray
    free hstrng

    ret

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

align 4

scanwords proc src:DWORD,fl:DWORD,tbl:DWORD,acnt:DWORD,prms:DWORD,array:DWORD

    LOCAL cnt   :DWORD
    LOCAL hkey  :DWORD
    LOCAL dst[1024]:BYTE        ; local output buffer for words

    push ebx
    push esi
    push edi

    mov cnt, 0                  ; set counter to zero

    mov ebx, tbl                ; table address in EBX
    mov esi, src                ; source address in ESI
    lea edi, dst                ; output buffer address in edi
    mov ecx, fl                 ; byte count in ECX
    add ecx, esi                ; match ECX to exit
    xor eax, eax                ; zero EAX to prevent stall
    jmp lbl3                    ; jump to unacceptable character loop

  comment * ------------------------------
    1st block is acceptable character loop
    -------------------------------------- *

  align 4

  lbl1:
    mov al, [esi]
    inc esi
    cmp esi, ecx
    je lbout
    cmp BYTE PTR [ebx+eax], 1
    jne lbl2                    ; exit 1st loop on unacceptable character
  backin:
    mov [edi], al
    inc edi
    jmp lbl1

  lbl2:
    mov BYTE PTR [edi], 0           ; append terminator to word

  ; -------------------------------------------------------------------------

    push eax
    push ecx
    push edx

    invoke write_to_table,array,ADDR dst,acnt,prms

    pop edx
    pop ecx
    pop eax

  ; -------------------------------------------------------------------------

    inc cnt

    lea edi, dst                    ; reload the buffer address for the next word

  comment * --------------------------
    loop while unacceptable characters
    ---------------------------------- *
  lbl3:
    mov al, [esi]
    inc esi
    cmp esi, ecx
    je lbout
    cmp BYTE PTR [ebx+eax], 1
    jne lbl3
    jmp backin

  lbout:

    mov eax, cnt    ; return the number of words scanned

    pop edi
    pop esi
    pop ebx

    ret

scanwords endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

create_hash_table proc acnt:DWORD,asize:DWORD

comment * -------------------------------
    acnt  = number of items in hash table
    asize = byte count for each item ---- *

    LOCAL lparr:DWORD
    LOCAL lpmem:DWORD

    mov ecx, acnt
    shl ecx, 2                  ; multiply by 4
    mov lparr, alloc(ecx)       ; allocate array

    mov ecx, asize
    mov eax, acnt
    imul ecx                    ; multiply count by BYTE size for string memory length
    mov lpmem, alloc(eax)       ; allocate string memory

    mov eax, lpmem              ; string memory start address
    mov edx, lparr              ; array address
    mov ecx, acnt               ; item count
  @@:
    mov [edx], eax              ; load address in EAX into location in array
    add eax, asize              ; add "asize" for next start address
    add edx, 4                  ; set next array location
    sub ecx, 1
    jnz @B

comment * ----------------------------------
    deallocate both of the returned memory
    handles when the hash table is no longer
    required ------------------------------- *

    mov eax, lparr              ; return address of array of pointers in EAX
    mov ecx, lpmem              ; return string memory address in ECX

    ret

create_hash_table endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

align 4

scan_table proc sarr:DWORD, acnt:DWORD, bcnt:DWORD

comment * ---------------------------------
    sarr = string aray where data is stored
    acnt = count of items in array
    bcnt = length of each item in BYTES
    --------------------------------------- *
    push ebx
    push esi
    push edi

    xor ebx, ebx
    mov esi, sarr
  @@:
    cmp BYTE PTR [esi], 0
    je nxt
  ; =====================
    invoke StdOut,esi
    print SADD(13,10)
  ; =====================
  nxt:
    add esi, bcnt
    inc ebx
    cmp acnt, ebx
    jne @B

    pop edi
    pop esi
    pop ebx

    ret

scan_table endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

align 4

hashkey proc src:DWORD,cnt:DWORD,prms:DWORD

    LOCAL ttl:DWORD
    LOCAL lns:DWORD

    push ebx
    push esi
    push edi

    mov ttl, 0                  ; total

    mov esi, src
    mov edi, prms               ; array of primes address in EDI
    xor ecx, ecx                ; zero character counter
    xor ebx, ebx                ; prevent stall in EBX

  @@:
    movzx eax, BYTE PTR [esi+ecx]
    test eax, eax
    jz @F
    add ecx, 1                  ; increment the character position counter
    mov ebx, [edi+ecx*4]        ; get value of prime from character position
    imul bx                     ; mul char ascii value by prime
    add ttl, eax
    imul ax
    add ttl, eax
    imul cx
    add ttl, eax

    jmp @B

  @@:

  ; -------------------------------
  ; added to deliver larger numbers
  ; -------------------------------
    mov eax, ttl
    add eax, FUNC(lnstr,src)
    shl eax, 10
    add ttl, eax

  ; ------------------------------------------------------------
  ; divide total by array count and return the remainder in EAX
  ; ------------------------------------------------------------
    xor edx, edx
    mov eax, ttl
    div cnt
    mov eax, edx

    pop edi
    pop esi
    pop ebx

    ret

hashkey endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

create_prime_table proc

    mov eax, alloc(128)
    push eax

    mov DWORD PTR [eax],   103
    mov DWORD PTR [eax+4], 101
    mov DWORD PTR [eax+8],  97
    mov DWORD PTR [eax+12], 91
    mov DWORD PTR [eax+16], 89
    mov DWORD PTR [eax+20], 87
    mov DWORD PTR [eax+24], 83
    mov DWORD PTR [eax+28], 79
    mov DWORD PTR [eax+32], 73
    mov DWORD PTR [eax+36], 71
    mov DWORD PTR [eax+36], 67
    mov DWORD PTR [eax+40], 61
    mov DWORD PTR [eax+44], 59
    mov DWORD PTR [eax+48], 57
    mov DWORD PTR [eax+52], 53
    mov DWORD PTR [eax+56], 51
    mov DWORD PTR [eax+60], 47
    mov DWORD PTR [eax+64], 43
    mov DWORD PTR [eax+68], 41
    mov DWORD PTR [eax+72], 39
    mov DWORD PTR [eax+76], 37
    mov DWORD PTR [eax+80], 31
    mov DWORD PTR [eax+84], 29
    mov DWORD PTR [eax+88], 23
    mov DWORD PTR [eax+92], 19
    mov DWORD PTR [eax+96], 17
    mov DWORD PTR [eax+100], 13
    mov DWORD PTR [eax+104], 11
    mov DWORD PTR [eax+108], 7
    mov DWORD PTR [eax+112], 5
    mov DWORD PTR [eax+116], 2
    mov DWORD PTR [eax+120], 1

    pop eax

    ret

create_prime_table endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

align 4

write_to_table proc array:DWORD,src:DWORD,acnt:DWORD,prms:DWORD

comment * ----------------------------------------------
    array = array of pointers to string array locations
    src   = string to hash and write to table
    acnt  = is the number of items in the array
    prms  = the array of primes for the hash function
        ------------------------------------------------ *

    LOCAL item:DWORD
    LOCAL hkey:DWORD
    LOCAL lns :DWORD

    mov lns, FUNC(lnstr,src)
    mov hkey, FUNC(hashkey,src,acnt,prms)

  wttstart:
    mov eax, hkey
    cmp eax, acnt                   ; compare the hash key to the array
    jl @F                           ; count. Jump past if less.
    sub eax, acnt
    mov hkey, eax                   ; wrap around by the count over "acnt"

  @@:
    mov edx, array
    mov eax, hkey
    lea edx, [edx+eax*4]            ; get address of array plus hash key in EDX
    push [edx]
    pop item

comment * -------------------------------------------------------
    The logic here is as follows, if the table location selected
    by using the hash key is empty, write the string to it, if
    it has the same string written to it as is being tested, exit
    the procedure, if the string is different to the one at the
    tested location, try another string location to see if its
    blank.
        --------------------------------------------------------- *

    mov eax, item
    cmp BYTE PTR [eax], 0           ; if first byte is zero,
    je write_string                 ; jump to "write string"
    cmp FUNC(szCmp,item,src), 0    ; if string is aready written
    jnz wtEnd                       ; exit procedure

    mov eax, lns                    ; if collision,
    add eax, lns                    ; set next slot jump size
    rol eax, 1
    add hkey, eax                   ; add it to the hash key

    ; ==============
    IF dbg
    add coll, 1                     ; collision count here
    ENDIF
    ; ==============

    jmp wttstart                    ; try another location in hash table

  write_string:
    invoke szCopy,src, item         ; write string to location in hash table
    add wcnt, 1

  wtEnd:
    ret

write_to_table endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start