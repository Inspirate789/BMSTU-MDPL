; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
    include \masm32\include\masm32rt.inc
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

comment * -----------------------------------------------------
                        Build this  template with
                       "CONSOLE ASSEMBLE AND LINK"

        Example demonstrates a number of useful technques
        -------------------------------------------------
        1. Scan a source file for seperate words.
        2. Build a character based word tree to test for duplicates.
        3. A method of loading pointers to words into an array.
        4. Sorting the words in either order.
        5. Writing the sorted output to a disk file.
        ----------------------------------------------------- *

    wordscan    PROTO :DWORD,:DWORD,:DWORD
    bld_tree    PROTO :DWORD,:DWORD,:DWORD,:DWORD
    loadptrs    PROTO :DWORD,:DWORD

    .code

start:
   
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    call main
    exit

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

main proc

    LOCAL pSrc  :DWORD
    LOCAL pDst  :DWORD
    LOCAL pArr  :DWORD
    LOCAL wCnt  :DWORD
    LOCAL flen  :DWORD
    LOCAL tc1   :DWORD
    LOCAL tc2   :DWORD
    LOCAL tc3   :DWORD
    LOCAL tc4   :DWORD
    LOCAL tc5   :DWORD
    LOCAL hFile :DWORD
    LOCAL file1 :DWORD
    LOCAL file2 :DWORD
    LOCAL sort  :DWORD
    LOCAL buffer1[260]:BYTE
    LOCAL buffer2[260]:BYTE
    LOCAL buffer3[16]:BYTE

    mov file1, ptr$(buffer1)
    mov file2, ptr$(buffer2)
    mov sort,  ptr$(buffer3)

    invoke GetCL,1,file1
    .if eax != 1
      print "Missing command line argument",13,10
      call help
      ret
    .endif

    test rv(exist,file1), eax
    jne @F
      print "Sorry, cannot find source file",13,10
      call help
      ret
    @@:

    invoke GetCL,2,file2
    .if eax != 1
      print "No target file supplied",13,10
      call help
      ret
    .endif

    mov tc1, rv(GetTickCount)

    mov pSrc, InputFile(file1)          ; load source file
    mov flen, ecx                       ; save its length
    mov pDst, alloc(flen)               ; allocate destination buffer

    mov tc2, rv(GetTickCount)

    invoke wordscan,pSrc,pDst,flen      ; return list of unique words in pDst
    mov wCnt, eax                       ; get count of unique written words
    free pSrc                           ; deallocate source memory

    mov tc3, rv(GetTickCount)

    invoke loadptrs,pDst,wCnt           ; load word addresses as an array of pointers
    mov pArr, eax

  ; ---------------------------------
  ; get sort order option if its used
  ; ---------------------------------
    invoke GetCL,3,sort
    switch$ sort
      case$ "/r"
        invoke dssort,pArr,wCnt,0       ; sort the words in decending order
      else$
        invoke assort,pArr,wCnt,0       ; sort the words in ascending order
    endsw$

    mov tc4, rv(GetTickCount)

  ; --------------------------
  ; write words to output file
  ; --------------------------
    mov hFile, fcreate(file2)
    push esi
    push edi
    mov esi, pArr
    xor edi, edi
  @@:
    fprint hFile,[esi]
    add esi, 4
    add edi, 1
    cmp edi, wCnt
    jl @B
    pop edi
    pop esi
    fclose hFile
  ; --------------------------

    mov tc5, rv(GetTickCount)

    free pArr
    free pDst

    print str$(flen)," Source file length in bytes",13,10
    print str$(wCnt)," unique words in file",13,10
    mov eax, tc2
    sub eax, tc1
    print str$(eax)," MS file input",13,10
    mov eax, tc3
    sub eax, tc2
    print str$(eax)," MS scan and list unique words",13,10
    mov eax, tc4
    sub eax, tc3
    print str$(eax)," MS load and sort array of unique words",13,10
    mov eax, tc5
    sub eax, tc4
    print str$(eax)," MS write output to file",13,10

    ret

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

align 4

loadptrs proc psrc:DWORD,wcnt:DWORD

    LOCAL parr  :DWORD

    push ebx
    push esi
    push edi

    mov eax, wcnt
    add eax, eax
    add eax, eax                        ; eax * 4
    mov parr, alloc(eax)                ; allocate array of pointers for unique words

    mov esi, psrc                       ; source address
    mov edi, parr                       ; pointer array address

    mov [edi], esi                      ; load 1st pointer
    add edi, 4
    sub esi, 1
    mov ebx, 1                          ; add count for 1st pointer

  align 4
  @@:
    add esi, 1
    cmp BYTE PTR [esi], 0               ; test if you are at the next zero seperator
    jne @B
    add esi, 1                          ; get the next address past the ZERO
    mov [edi], esi                      ; store it at locaion in EDI
    add edi, 4                          ; set EDI to next pointer location
    add ebx, 1                          ; increment the pointer count
    cmp ebx, wcnt                       ; test if its equal to the wordcount
    jle @B

    mov eax, parr

    pop edi
    pop esi
    pop ebx

    ret

loadptrs endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    BCNT  equ <12>
    tchar equ <BYTE  PTR [ecx]>
    lnode equ <DWORD PTR [ecx+4]>
    rnode equ <DWORD PTR [ecx+8]>

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

align 4

bld_tree proc txt:DWORD,hmem:DWORD,cloc:DWORD,rval:DWORD

    LOCAL next  :DWORD

    push ebx
    push esi
    push edi

    mov eax, cloc                   ; load current location pointer into EAX
    mov edx, [eax]                  ; dereference it into EDX
    mov next, edx                   ; copy EDX to local variable

    xor eax, eax                    ; prevent stall in AL

    mov edi, txt                    ; load text address in EDI
    mov ecx, hmem                   ; load base address in ECX
    jmp strt

  align 4
  pre:
    add edi, 1
  align 4
  strt:
    mov al, [edi]

    ; ============================

    .if al != 0

      .if tchar == 0
        .if lnode == 0              ; empty node
          mov tchar, al             ; WRITE character
            add next, BCNT
            mov edx, hmem
            add edx, next
            mov lnode, edx
            mov ecx, edx
            jmp pre                 ; get next character
        .else                       ; used node
          .if rnode != 0
            mov ecx, rnode          ; load rnode and loop back
            jmp strt                ; loop back
          .else                     ; if rnode != 0
            add next, BCNT
            mov edx, hmem
            add edx, next
            mov rnode, edx
            mov ecx, edx
            jmp strt                ; loop back
          .endif
        .endif

      .elseif tchar != 0
        .if tchar == al             ; if match
          .if lnode != 0
            mov ecx, lnode          ; load left node and loop back
            jmp pre                 ; get next character
          .else
            add next, BCNT
            mov edx, hmem
            add edx, next
            mov rnode, edx
            mov ecx, edx
            jmp strt
          .endif

        .elseif tchar != al
          .if rnode != 0
            mov ecx, rnode          ; load rnode and loop back
            jmp strt                ; loop back
          .else                     ; if rnode != 0
            add next, BCNT
            mov edx, hmem
            add edx, next
            mov rnode, edx
            mov ecx, edx
            jmp strt                ; loop back
          .endif
        .endif

      .endif

    ; ============================

    .else
      align 4
      iszero:

      .if tchar == 0
        .if lnode == 0
          mov tchar, al
          mov edx, rval             ; write return value if empty node
          mov lnode, edx
          jmp btout
        .endif
      .endif

      .if tchar != 0
        .if rnode != 0
          mov ecx, rnode            ; traverse right and loop back
          jmp iszero
        .else
          add next, BCNT
          mov edx, hmem
          add edx, next
          mov rnode, edx
          mov ecx, edx
          jmp iszero
        .endif
      .endif

    .endif

  ; ------------------------------
  ; set return value for duplicate
  ; ------------------------------
    mov ecx, lnode

    .if ecx == rval
      mov eax, -1                   ; return value for simple exact duplicate
    .else
      mov eax, -2                   ; return value for NON benign redefinition
    .endif

  btout:

  ; -----------------------------------
  ; update the current location pointer
  ; -----------------------------------
    mov ecx, cloc
    mov edx, next
    mov [ecx], edx

    pop edi
    pop esi
    pop ebx

    ret

bld_tree endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    .data
      align 4
      actable \
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0      ; 31
        db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0      ; 47
        db 1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0      ; 63
        db 0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1      ; 79
        db 1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0
        db 0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
        db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
        db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
        db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
        db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
        db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
        db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
        db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
        db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
        db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

    .code

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

align 4

wordscan proc psrc:DWORD,pdst:DWORD,lsrc:DWORD

    LOCAL pbuf  :DWORD                      ; local buffer pointer
    LOCAL tree  :DWORD                      ; memory for tree
    LOCAL cloc  :DWORD                      ; currect location pointer in tree
    LOCAL bptr  :DWORD                      ; buffer pointer for output buffer
    LOCAL wcnt  :DWORD                      ; counter for words
    LOCAL buffer[128]:BYTE                  ; local buffer

    lea eax, buffer
    mov pbuf, eax
    mov cloc, 0                             ; set location pointer to ZERO
    mov wcnt, 0                             ; set word counter to ZERO

    push ebx
    push esi
    push edi

    mov tree, alloc(rv(IntMul,lsrc,12))     ; tree buffer is file length * 12

    xor eax, eax
    mov esi, psrc
    sub esi, 1
    mov edi, pbuf
    mov ebx, pdst

  align 4
  badchar:
    add esi, 1
    movzx eax, BYTE PTR [esi]
    test eax, eax                           ; test for zero byte
    jz lastbyte
    cmp [actable+eax], 0                    ; tst if character is not allowed in table
    je badchar                              ; jump back if it is not allowed
    mov [edi], al                           ; write byte to output buffer
    add edi, 1

  align 4
  goodchar:
    add esi, 1
    movzx eax, BYTE PTR [esi]
    test eax, eax                           ; test for zero byte
    jz lastbyte
    cmp [actable+eax], 1
    jne nxt1
    mov [edi], al                           ; write byte to output buffer
    add edi, 1
    jmp goodchar

  nxt1:
  ; -----------------------------------------
    mov BYTE PTR [edi], 0                   ; append terminator to LOCAL buffer
    invoke bld_tree,pbuf,tree,ADDR cloc,1   ; add word to tree if it is unique
    test eax, eax                           ; test for normal return value (not duplicate)
    jnz ovr
    add ebx, rv(szCopy,pbuf,ebx)            ; copy local to dest buffer + add length to dest buffer location
    mov BYTE PTR [ebx], 0                   ; append seperator/terminator
    add ebx, 1
    add wcnt, 1
  ovr:
  ; -----------------------------------------
    mov edi, pbuf                           ; reset EDI to buffer address
    jmp badchar

  lastbyte:
  ; -----------------------------------------
    mov BYTE PTR [edi], 0                   ; append terminator to LOCAL buffer
    test rv(tstline,pbuf), eax              ; test if last line contains a word
    jz ovr1
    invoke bld_tree,pbuf,tree,ADDR cloc,1   ; add word to tree if it is unique
    test eax, eax                           ; test for normal return value (not duplicate)
    jnz ovr1
    add ebx, rv(szCopy,pbuf,ebx)
    add wcnt, 1
  ovr1:
    mov WORD PTR [ebx], 0                   ; append double terminator to OUTPUT buffer
  ; -----------------------------------------

    free tree                               ; deallocate the tree memory
    mov eax, wcnt                           ; return the written word count

    pop edi
    pop esi
    pop ebx

    ret

wordscan endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

help proc

    print "uwords.exe (c) The masm32 Project 1998 - 2005",13,10
    print "Scans unique words in source file and outputs",13,10
    print "sorted results to the destination file",13,10,13,10
    print "SYNTAX: uwords srcfile dstfile [/r]",13,10
    print "srcfile  : The file to scan for unique words",13,10
    print "dstfile  : The target file for the result",13,10
    print "/r       : Optional sort order reversal",13,10
    print "           Default is ascending, option /r is decending",13,10

    ret

help endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start
