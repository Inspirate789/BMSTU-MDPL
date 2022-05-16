; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

;                      Build this as a console app

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    .486
    .model flat, stdcall
    option casemap :none   ; case sensitive

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    include \masm32\include\windows.inc
    include \masm32\include\user32.inc
    include \masm32\include\kernel32.inc
    include \masm32\include\masm32.inc
    include \masm32\macros\macros.asm

    includelib \masm32\lib\user32.lib
    includelib \masm32\lib\kernel32.lib
    includelib \masm32\lib\masm32.lib

    main PROTO

    create_array     PROTO :DWORD,:DWORD
    prime64          PROTO
    parse_equate     PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
    scanner_callback PROTO :DWORD,:DWORD,:DWORD
    get_hash_bucket  PROTO :DWORD,:DWORD,:DWORD
    get_hash_slot    PROTO :DWORD,:DWORD
    get_hashkey      PROTO :DWORD,:DWORD,:DWORD
    replace_equates  PROTO :DWORD,:DWORD,:DWORD,:DWORD

  ; -----------------------------------------
  ; structure to pass arguments to procedures
  ; -----------------------------------------
    htargs STRUCT
      arr   dd ?        ; address of array of pointers from "create_array"
      cnt   dd ?        ; member count in array
      prm   dd ?        ; address of array of primes from "create_prime_table"
    htargs ENDS

    .data
    ; ------------------------
    ; table for word pair file
    ; numbers, upper and lower
    ; case, plus . + _
    ; ------------------------
  align 4
  eqtbl \
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0     ; 15
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0     ; 31
    db 0,0,0,0,0,0,0,0,0,0,0,1,0,1,1,0     ; 47
    db 1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0     ; 63
    db 0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1     ; 79
    db 1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,1     ; 95
    db 0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1     ; 111
    db 1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0     ; 127
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

    ; --------------------------------
    ; table for source scanner. larger
    ; range of characters but excludes
    ; normal seperators.
    ; --------------------------------
  sctbl \
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,1,1,1,1,1,1,0,0,0,1,1,0,1,1,0
    db 1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,1
    db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
    db 1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,1
    db 0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
    db 1,1,1,1,1,1,1,1,1,1,1,0,0,0,1,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

    RTERROR dd 0

    bsiz equ <64>
    isiz equ <bsiz+bsiz>
    asiz equ <65536*2+1>

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    .code

start:

    call main

    invoke ExitProcess,0

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

main proc

    LOCAL fname1:DWORD
    LOCAL fname2:DWORD
    LOCAL fname3:DWORD
    LOCAL pMem  :DWORD
    LOCAL hMem  :DWORD
    LOCAL flen  :DWORD
    LOCAL blen  :DWORD
    LOCAL mmain :DWORD
    LOCAL args  :DWORD
    LOCAL pSrc  :DWORD
    LOCAL lSrc  :DWORD
    LOCAL hta   :htargs
    LOCAL buffer1[260]:BYTE 
    LOCAL buffer2[260]:BYTE 
    LOCAL buffer3[260]:BYTE 

    mov fname1, ptr$(buffer1)
    mov fname2, ptr$(buffer2)
    mov fname3, ptr$(buffer3)

    invoke GetCL,1,fname1
    invoke exist,fname1
    cmp eax, 0
    jne @F
    print chr$("Missing first argument 'word file'",13,10)
    call help
  @@:

    invoke GetCL,2,fname2
    invoke exist,fname2
    cmp eax, 0
    jne @F
    print chr$("Missing second argument 'source file'",13,10)
    call help
  @@:

    invoke GetCL,3,fname3
    cmp eax, 2
    jne @F
    print chr$("Missing third argument 'target file'",13,10)
    call help
  @@:

    mov pMem, InputFile(fname1)                 ; EQUATES FILE
    mov flen, ecx

    invoke create_array,asiz,128
    mov mmain, ecx
    mov hta.arr, eax
    mov hta.cnt, asiz

    invoke prime64
    mov hta.prm, eax

    invoke create_array,16,128
    mov args, eax

    invoke parse_equate,pMem,args,OFFSET eqtbl,OFFSET scanner_callback,ADDR hta

    free pMem

    cmp RTERROR, 0
    jne quit_now

    mov pSrc, InputFile(fname2)                 ; SOURCE FILE
    mov lSrc, ecx
    add ecx, ecx
    mov blen, ecx
    mov hMem, alloc(blen)

    mov eax, pSrc
    add eax, lSrc

    cmp BYTE PTR [eax-1], 10
    je @F
    mov BYTE PTR [eax],   13                    ; append a CRLF if there
    mov BYTE PTR [eax+1], 10                    ; is not one there
    mov BYTE PTR [eax+2], 0
  @@:

    invoke replace_equates,pSrc,hMem,OFFSET sctbl,ADDR hta

    mov blen, len(hMem)

    cmp OutputFile(fname3,hMem,blen), 0         ; RESULT FILE

    print fname3
    print " written at "
    print str$(blen)
    print chr$(" bytes",13,10)

  quit_now:

    free pSrc
    free hMem
    free args
    free hta.prm
    free hta.arr
    free mmain

    ret

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

help proc

    print chr$("WREP : 'Word Replace' Version 3 Copyright (c) MASM32 1998-2004",13,10,13,10)
    print chr$("ARGUMENTS",13,10)
    print chr$("  1. File with word pairs 'this that' or 'this = that'",13,10)
    print chr$("  2. Source file to replace word in",13,10)
    print chr$("  3. Target file to write results to",13,10,13,10)
    print chr$("EXAMPLE : wrep myequate.equ mysource.asm myresult.asm",13,10)

    invoke ExitProcess,0

    ret

help endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

align 4

create_array proc acnt:DWORD,asize:DWORD

comment * ---------------------------
    acnt  = number of items in array
    asize = byte count for each item
    ------------------------------- *

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

comment * --------------------------
    deallocate both of the returned
    memory handles when the array is
    no longer required
    ------------------------------ *

    mov eax, lparr              ; return address of array of pointers in EAX
    mov ecx, lpmem              ; return string memory address in ECX

    ret

create_array endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

prime64 proc

  ; -----------------------------------
  ; Member count is 64 items
  ; Use GlobalFree() to deallocate the
  ; return value from this procedure
  ; -----------------------------------

    mov eax, alloc(256)
    push eax

    mov DWORD PTR [eax+252], 2
    mov DWORD PTR [eax+248], 3
    mov DWORD PTR [eax+244], 5
    mov DWORD PTR [eax+240], 7
    mov DWORD PTR [eax+236], 11
    mov DWORD PTR [eax+232], 13
    mov DWORD PTR [eax+228], 17
    mov DWORD PTR [eax+224], 19
    mov DWORD PTR [eax+220], 23
    mov DWORD PTR [eax+216], 29
    mov DWORD PTR [eax+212], 31
    mov DWORD PTR [eax+208], 37
    mov DWORD PTR [eax+204], 41
    mov DWORD PTR [eax+200], 43
    mov DWORD PTR [eax+196], 47
    mov DWORD PTR [eax+192], 53
    mov DWORD PTR [eax+188], 59
    mov DWORD PTR [eax+184], 61
    mov DWORD PTR [eax+180], 67
    mov DWORD PTR [eax+176], 71
    mov DWORD PTR [eax+172], 73
    mov DWORD PTR [eax+168], 79
    mov DWORD PTR [eax+164], 83
    mov DWORD PTR [eax+160], 89
    mov DWORD PTR [eax+156], 97
    mov DWORD PTR [eax+152], 101
    mov DWORD PTR [eax+148], 103
    mov DWORD PTR [eax+144], 107
    mov DWORD PTR [eax+140], 109
    mov DWORD PTR [eax+136], 113
    mov DWORD PTR [eax+132], 127
    mov DWORD PTR [eax+128], 131
    mov DWORD PTR [eax+124], 137
    mov DWORD PTR [eax+120], 139
    mov DWORD PTR [eax+116], 149
    mov DWORD PTR [eax+112], 151
    mov DWORD PTR [eax+108], 157
    mov DWORD PTR [eax+104], 163
    mov DWORD PTR [eax+100], 167
    mov DWORD PTR [eax+96], 173
    mov DWORD PTR [eax+92], 179
    mov DWORD PTR [eax+88], 181
    mov DWORD PTR [eax+84], 191
    mov DWORD PTR [eax+80], 193
    mov DWORD PTR [eax+76], 197
    mov DWORD PTR [eax+72], 199
    mov DWORD PTR [eax+68], 211
    mov DWORD PTR [eax+64], 223
    mov DWORD PTR [eax+60], 227
    mov DWORD PTR [eax+56], 229
    mov DWORD PTR [eax+52], 233
    mov DWORD PTR [eax+48], 239
    mov DWORD PTR [eax+44], 241
    mov DWORD PTR [eax+40], 251
    mov DWORD PTR [eax+36], 257
    mov DWORD PTR [eax+32], 263
    mov DWORD PTR [eax+28], 269
    mov DWORD PTR [eax+24], 271
    mov DWORD PTR [eax+20], 277
    mov DWORD PTR [eax+16], 281
    mov DWORD PTR [eax+12], 283
    mov DWORD PTR [eax+8], 293
    mov DWORD PTR [eax+4], 307
    mov DWORD PTR [eax], 311

    pop eax

    ret

prime64 endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

align 4

get_hash_bucket proc src:DWORD,hkey:DWORD,lpargs:DWORD

    LOCAL bucket:DWORD
    LOCAL lns   :DWORD
    LOCAL icnt  :DWORD
    LOCAL larr  :DWORD

    mov lns, FUNC(szLen,src)        ; get the word length

    mov eax, lpargs
    mov edx, (htargs PTR [eax]).arr ; get array address from structure address
    mov larr, edx
    mov ecx, (htargs PTR [eax]).cnt ; get bucket count from structure address
    mov icnt, ecx

  wttstart:
    mov eax, hkey                   ; hash key in EAX
    cmp eax, icnt                   ; compare the hash key to the parray count.
    jl @F                           ; Jump past if less.
    sub eax, icnt
    mov hkey, eax                   ; wrap around by the count above "icnt"
  @@:
    mov edx, larr
    lea edx, [edx+eax*4]            ; calculate bucket pointer from array plus hash key
    mov ecx, [edx]                  ; dereference EDX to get bucket start address
    mov bucket, ecx                 ; copy it to local variable
    cmp BYTE PTR [ecx], 0           ; if first byte is zero,
    je unused                       ; exit to "unused"
    cmp FUNC(szCmp,bucket,src), 0   ; if string is aready written
    jnz iswritten                   ; exit procedure
    mov eax, lns                    ; if collision,
    add eax, lns                    ; set next slot jump size
    rol eax, 1
    add hkey, eax                   ; add it to the hash key
    jmp wttstart                    ; try another location in hash table

  unused:
    xor ecx, ecx                    ; return zero in ECX if bucket is unused
    jmp wtEnd
  iswritten:
    mov ecx, 1                      ; return non zero if bucket is already used
  wtEnd:
    mov eax, bucket                 ; return bucket address

    ret

get_hash_bucket endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

align 4

get_hashkey proc src:DWORD,cnt:DWORD,prms:DWORD

    LOCAL ttl:DWORD
    LOCAL lns:DWORD

    push ebx
    push esi
    push edi

    mov lns, len(src)

    mov ttl, 0                  ; total

    mov esi, src
    mov edi, prms               ; array of primes address in EDI
    xor ecx, ecx                ; zero character counter
    xor ebx, ebx                ; prevent stall in EBX

  @@:
    movzx eax, BYTE PTR [esi+ecx]
    test eax, eax               ; test for zero terminator
    jz @F                       ; exit loop if zero
    add ecx, 1                  ; increment the character position counter
    mov ebx, [edi+ecx*4]        ; get value of prime from character position
    imul bx                     ; mul char ascii value by prime
    add eax, lns                ; add word length to result
    add ttl, eax                ; add result to total
    jmp @B

  @@:

    xor edx, edx
    mov eax, ttl
    div cnt
    mov eax, edx

    pop edi
    pop esi
    pop ebx

    ret

get_hashkey endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

align 4

get_hash_slot proc wrd:DWORD,lpargs:DWORD

    LOCAL icnt  :DWORD
    LOCAL pprime:DWORD
    LOCAL hkey  :DWORD
    LOCAL bucket:DWORD
    LOCAL flag  :DWORD

    mov eax, lpargs
    mov ecx, (htargs PTR [eax]).cnt
    mov icnt, ecx
    mov ecx, (htargs PTR [eax]).prm
    mov pprime, ecx

    invoke get_hashkey,wrd,icnt,pprime  ; get hash value of word
    mov hkey, eax

    invoke get_hash_bucket,wrd,hkey,lpargs

    ret

  ; EAX contains the address
  ; ECX contains the result
  ; 0 = unused location in hash table 
  ; 1 = location with value written to it

get_hash_slot endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    align 4

parse_equate proc string:DWORD,array:DWORD,table:DWORD,callback:DWORD,lpargs:DWORD

    LOCAL acnt      :DWORD      ; argument counter
    LOCAL eflag     :DWORD      ; exit flag for last statement
    LOCAL lnum      :DWORD

    push ebx
    push esi
    push edi

    mov lnum, 0                 ; zero line counter

    mov esi, string             ; source address in ESI
    mov ebx, table              ; character table in EBX
    mov eflag, 0                ; set exit flag to zero
    jmp reload
  ; ***************************
  align 4
  reload:
    mov acnt, 0                 ; set argument counter to zero
    mov edx, array              ; load array address into local variable
    sub edx, 4
    xor eax, eax                ; prevent stall
    jmp jumpin                  ; jump to badchar entry point
  ; ***************************
  ; scan non allowable characters
  ; ***************************
  align 4
  terminate:
    mov BYTE PTR [edi], 0       ; zero terminate arg in array member
  badchar:
    sub al, 10                  ; test end of line condition
    jz setend                   ; set end if al = 10
  jumpin:
    mov al, [esi]
    add esi, 1
    test al, al                 ; test for zero
    je setexit                  ; exit if it is
    cmp BYTE PTR [ebx+eax], 0   ; is char in table ?
    je badchar
    add edx, 4                  ; set array to next member
    mov edi, [edx]              ; dereference it to get start address
    add acnt, 1                 ; increment argument counter
    sub esi, 1
  ; ***************************
  ; write allowable characters
  ; ***************************
  goodchar:
    mov al, [esi]
    add esi, 1
    cmp BYTE PTR [ebx+eax], 0   ; is char in table ?
    je terminate
    mov [edi], al
    add edi, 1
    jmp goodchar
  ; ***************************
  align 4
  setexit:
    mov eflag, 1                ; set exit flag
  setend:
    add lnum, 1
    add edx, 4                  ; set array to next member
    mov edi, [edx]              ; dereference it to get start address
    mov BYTE PTR [edi], 0       ; write zero to next buffer

  ; ----------------------------------------
  ; call the user defined callback procedure
  ; ----------------------------------------
    push lpargs
    push acnt
    push array
    call callback
  ; ----------------------------------------
    test eax, eax               ; test EAX for ZERO
    jnz nonzero                    ; exit with user defined value in EAX if not

    cmp eflag, 0
    je reload
    jmp pequit
  ; ***************************
  nonzero:
    print "Line Number "
    print str$(lnum)

  pequit:

    pop edi
    pop esi
    pop ebx

    ret

parse_equate endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

scanner_callback proc array:DWORD,acnt:DWORD,lpargs:DWORD

    ; array  = scanner array containing words
    ; acnt   = word count
    ; lpargs = structure of args for hash table
    ;
    ;          return zero to continue
    ;          other to stop scanner

    LOCAL bucket    :DWORD
    LOCAL wrd1      :DWORD
    LOCAL wrd2      :DWORD

    cmp acnt, 2
    je @F
    jl lower
    jg greater
  lower:
    print chr$("ERROR: MISSING SECOND ARGUMENT",13,10)
    mov RTERROR, 1
    mov eax, 1
    ret
  greater:
    print chr$("ERROR: TOO MANY ARGUMENTS",13,10)
    mov RTERROR, 1
    mov eax, 1
    ret
  @@:

    push ebx
    push esi
    push edi

    mov esi, array
    mov edi, [esi]
    mov wrd1, edi

    fn szCmp,"exit",edi
    test eax, eax
    je @F
    mov eax, 1
    jmp quit
  @@:

    mov ebx, [esi+4]
    mov wrd2, ebx

    invoke get_hash_slot,wrd1,lpargs
    mov bucket, eax

    .if ecx == 0                    ; if slot is unused write 1st & 2nd words
      invoke szCopy,wrd1,bucket
      add bucket, bsiz
      invoke szCopy,wrd2,bucket
    .else                           ; if used, check for redefinition
      add bucket, bsiz
      invoke szCmp,bucket,wrd2      ; if 2nd words don't match, "redefinition"
      test eax, eax
      jnz normal_exit

      print chr$("ERROR: SYMBOL REDEFINITION ",34)
      print wrd1
      print chr$(34,13,10)
      mov RTERROR, 1
      mov eax, 1                    ; stop scanner with NON zero
      jmp quit
    .endif

  normal_exit:

    xor eax, eax                    ; return zero to keep scanning

  quit:

    pop edi
    pop esi
    pop ebx

    ret

scanner_callback endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    align 4

replace_equates proc src:DWORD,dst:DWORD,table:DWORD,lpargs:DWORD

    LOCAL pbuf  :DWORD
    LOCAL bucket:DWORD
    LOCAL rslt  :DWORD
    LOCAL buffer[128]:BYTE

    push ebx
    push esi
    push edi

    mov pbuf, ptr$(buffer)
    mov edx, pbuf

    xor eax, eax
    mov esi, src
    mov edi, dst
    mov ebx, table
    jmp badchar

  ; *************************************************************
  align 4
  wbc:
    mov [edi], al
    add edi, 1
  badchar:
    mov al, [esi]
    add esi, 1
    test al, al                         ; exit if AL = 0
    je lastbyte
    cmp BYTE PTR [ebx+eax], 1           ; is it a good char ?
    jne wbc
    mov edx, pbuf
    mov [edx], al
    add edx, 1
  goodchar:
    mov al, [esi]
    add esi, 1
    test al, al
    je lastbyte
    cmp BYTE PTR [ebx+eax], 0           ; is it a bad char ?
    je testword
    mov [edx], al
    add edx, 1
    jmp goodchar
  ; *************************************************************
  align 4
  testword:
    mov BYTE PTR [edx], 0

    invoke get_hash_slot,pbuf,lpargs
    mov bucket, eax
    mov rslt, ecx

  .if rslt == 0         ; if word is NOT in hash table, write it to destination
    mov edx, pbuf
  @@:
    mov al, [edx]
    add edx, 1
    test al, al
    je cleanup
    mov [edi], al
    add edi, 1
    jmp @b
  .else                 ; if word IS in hash table, write replacement to destination
    add bucket, bsiz
    mov edx, bucket
  @@:
    mov al, [edx]
    add edx, 1
    test al, al
    je cleanup
    mov [edi], al
    add edi, 1
    jmp @b
  .endif

  cleanup:
    xor eax, eax        ; clear EAX again
    sub esi, 1
    jmp badchar

  lastbyte:

    pop edi
    pop esi
    pop ebx

    ret

replace_equates endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start