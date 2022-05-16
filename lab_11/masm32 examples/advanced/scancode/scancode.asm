; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;                  Build as a console mode application
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

comment * -----------------------------------------------------------------

        This is an example of a source code scanner that parses multiple
        line statements into their component arguments and displays the
        results to STDOUT.

        ----------------------------------------------------------------- *

    .486
    .model flat, stdcall
    option casemap :none   ; case sensitive

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    include \masm32\include\windows.inc
    include \masm32\include\user32.inc
    include \masm32\include\kernel32.inc
    include \masm32\include\gdi32.inc
    include \masm32\macros\macros.asm
    include \masm32\include\masm32.inc

    includelib \masm32\lib\user32.lib
    includelib \masm32\lib\kernel32.lib
    includelib \masm32\lib\gdi32.lib
    includelib \masm32\lib\masm32.lib

    source_scanner PROTO :DWORD,:DWORD,:DWORD
    create_array   PROTO :DWORD,:DWORD
    show_array     PROTO :DWORD
    detab          PROTO :DWORD

  .data
    ; ---------------------------------
    ; characters SET in following table
    ; ---------------------------------
    ;   !   logical NOT 33
    ;   "   quote       34
    ;   $   dollar      36
    ;   &   ampersand   38
    ;   *   multiply    42
    ;   +   plus        43
    ;   -   minus       45
    ;   .   period      46
    ;   :   semicolon   58
    ;       numbers     48 to 57
    ;   <   less than   60
    ;   =   equals      61
    ;   >   greater     62
    ;   ?   question    63
    ;   @   at symbol   64
    ;       ucase       65 to 90
    ;   [   lsquare     91
    ;   ]   rsquare     93
    ;   _   underscore  95
    ;       lcase       96 to 122
    ;   {   lcurlyb     123
    ;   |   pipe        124
    ;   }   rcurlyb     125
    ;   ~   tilde       126

    align 4
    ctable \
      db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0     ; 15
      db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0     ; 31
      db 0,1,1,0,1,0,1,1,0,0,1,1,0,1,1,0     ; 47
      db 1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1     ; 63
      db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1     ; 79
      db 1,1,1,1,1,1,1,1,1,1,1,1,0,1,0,1     ; 95
      db 0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1     ; 111
      db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0     ; 127
      db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0


; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    .code

start:

    call main

    invoke ExitProcess,0

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

main proc

    LOCAL fname :DWORD
    LOCAL pMem  :DWORD
    LOCAL pArray:DWORD
    LOCAL pMain :DWORD
    LOCAL buffer[260]:BYTE

  ; -----------------------------------
  ; array has 1024 members of 128 bytes
  ; -----------------------------------
    invoke create_array,1024,128    ; create array in dynamic memory
    mov pArray, eax                 ; return address of array of pointers in EAX
    mov pMain, ecx                  ; return string memory address in ECX

    mov fname, ptr$(buffer)         ; get pointer to buffer
    invoke GetCL,1, fname           ; get 1st command line argument

    invoke exist,fname              ; check if the command line file exists
    cmp eax, 0
    je not_exist                    ; display error if not

    mov pMem, InputFile(fname)      ; load the file into memory
    invoke detab,pMem               ; convert tabs to spaces

    invoke source_scanner,          ; scan the source in memory
           pMem,pArray,
           OFFSET ctable

    jmp pexit

  not_exist:
    print chr$("Cannot find that file",13,10)
    print chr$("SYNTAX: scan3 filename.ext [ ",62," filename.txt ]",13,10)

  pexit:

    free pMem                       ; free the source memory
    free pMain                      ; free main array memory
    free pArray                     ; free array of pointers memory

    ret

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

align 4

detab proc string:DWORD

  ; -----------------------------
  ; replace each tab with a space
  ; -----------------------------
    mov eax, string
    sub eax, 1
    jmp stlp

  align 4
  wrt:
    mov BYTE PTR [eax], 32  ; substitute a space if it is
  stlp:
    add eax, 1
    cmp BYTE PTR [eax], 9   ; is it a tab
    je wrt                  ; jump prediction is BACK
    cmp BYTE PTR [eax], 0
    jnz stlp                ; jump prediction is BACK

    ret

detab endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

align 4

create_array proc acnt:DWORD,asize:DWORD

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

align 4

show_array proc hArr:DWORD

    LOCAL str1  :DWORD
    LOCAL buffer1[1024]:BYTE

    push esi

    mov str1, ptr$(buffer1)

    mov esi, hArr
    mov esi, [esi]
    cmp BYTE PTR [esi], 0   ; don't display empty line
    jne @F
    pop esi
    ret

  @@:
    mov esi, hArr
    mov esi, [esi]
    cmp BYTE PTR [esi], 0
    je @F
    mov str1, cat$(str1,esi,chr$(13,10))
    add hArr, 4
    jmp @B
  @@:

    mov str1, cat$(str1,chr$(13,10))
    invoke StdOut,str1

    pop esi

    ret

show_array endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

source_scanner proc string:DWORD,array:DWORD,table:DWORD

    LOCAL lcflag    :DWORD      ; line continuation flag
    LOCAL zflag     :DWORD      ; flag for ascii zero exit
    LOCAL lparr     :DWORD      ; local array variable

    push ebx
    push esi
    push edi

    mov esi, string
    sub esi, 1
    mov ebx, table
  ; ============================
  ; loop starts and restarts here
  ; ============================
  restart:
    push array
    pop lparr                   ; copy array address to local
    mov edi, lparr
    mov edi, [edi]              ; 1st string array address
  ; ============================
  ; strip leading spaces on line
  ; ============================
  pre:
    add esi, 1
    cmp BYTE PTR [esi], 9
    je pre
    cmp BYTE PTR [esi], 10
    je pre
    cmp BYTE PTR [esi], 13
    je pre
    cmp BYTE PTR [esi], 32
    je pre

    sub esi, 1
    xor eax, eax                ; prevent stall
  ; ============================
  ; main loop for writing
  ; characters to array members
  ; ============================
  sstart:
    add esi, 1
    mov al, [esi]
    test al, al                 ; test end of file
    je iszero
    cmp al, 34                  ; test for leading quote
    je quotes
    cmp al, "'"                 ; test for leading single quote
    je squote
    cmp al, "["                 ; test for opening square bracket
    je squareb
    cmp BYTE PTR [ebx+eax], 1   ; is char in table ?
    jne presub
  swrite:
    mov [edi], al
    add edi, 1
    jmp sstart
  ; ============================
  ; main subloop for processing
  ; non acceptable characters
  ; ============================
  align 4
  presub:
    mov BYTE PTR [edi], 0       ; zero terminate arg in array member
  ssublp:
    test al, al                 ; test end of file
    je iszero
    cmp al, ";"                 ; test for comment
    je commnt
    cmp al, "\"                 ; test for line continuation
    jne @F
    mov lcflag, 1               ; set line continuation flag
  @@:
    cmp al, ","                 ; test for line continuation
    jne @F
    mov lcflag, 1               ; set line continuation flag
  @@:
    cmp al, 10                  ; test end of line condition
    jne @F
    cmp lcflag, 0               ; if flag is clear with ascii
    je setarrend                ; 10 as last char, no further
  @@:                           ; args in source statement
    add esi, 1
    mov al, [esi]
    cmp BYTE PTR [ebx+eax], 1   ; is char in table ?
    jne ssublp

    add lparr, 4
    mov edi, lparr
    mov edi, [edi]
    mov lcflag, 0               ; clear line continuation flag
    sub esi, 1                  ; before jumping back to start
    jmp sstart
  ; ============================
  ; square brackets [ ]
  ; ============================
  align 4
  squareb:
    mov [edi], al               ; write opening square bracket
    add edi, 1
  sqsub:
    add esi, 1
    mov al, [esi]
    cmp al, "]"                 ; test for closing ] bracket
    je swrite
    mov [edi], al
    add edi, 1
    cmp al, 10
    jbe sberror                 ; exit on 0 or 10
    jmp sqsub
  ; ============================
  ; single quotation marks  'text'
  ; ============================
    align 4
  squote:
    mov [edi], al               ; write 1st singe quote
    add edi, 1
  sisub:
    add esi, 1
    mov al, [esi]
    cmp al, "'"                 ; test for closing singe quote
    je swrite
    mov [edi], al
    add edi, 1
    cmp al, 10
    jbe qerror                  ; exit on 0 or 10
    jmp sisub
  ; ============================
  ; double quotation marks  "text"
  ; ============================
  align 4
  quotes:
    mov [edi], al               ; write 1st quote
    add edi, 1
  subq:
    add esi, 1
    mov al, [esi]
    cmp al, 34                  ; test for closing quote
    je swrite
    mov [edi], al
    add edi, 1
    cmp al, 10
    jbe qerror                  ; exit on 0 or 10
    jmp subq
  ; ============================
  ; strip comments  ; comments
  ; ============================
  align 4
  commnt:                       ; loop from ; until ascii 10 is read
    add esi, 1
    cmp BYTE PTR [esi], 0       ; exit on zero
    je iszero
    cmp BYTE PTR [esi], 10      ; loop back if not LF
    jne commnt
    sub esi, 1
    jmp sstart
  ; ============================
  ; set the end of file flag on 0
  ; zero the following array member
  ; ============================
  align 4
  iszero:                       ; end of file condition
    mov zflag, 1                ; set zero flag
    mov BYTE PTR [edi], 0       ; terminate last line
  setarrend:               
    add lparr, 4
    mov edi, lparr              ; reuse EDI
    mov edi, [edi]              ; dereference memory location to EDI
    mov DWORD PTR [edi], 0      ; write a zero in next array

  output:

  ; -------------------------------------------------------------------------

    invoke show_array,array     ; call the array display proc
    cmp zflag, 1                ; test for end of file condition
    jne restart                 ; jump back if not

  ; -------------------------------------------------------------------------
    xor eax, eax                ; set return to 0 for normal exit
    jmp ssexit

  qerror:                       ; non matching quotes
    mov eax, -1
    jmp ssexit
  sberror:                      ; non matching [ ]
    mov eax, -2
    jmp ssexit
  ssexit: 

    pop edi
    pop esi
    pop ebx

    ret

source_scanner endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start