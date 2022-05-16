comment * ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

                    Build as CONSOLE mode application

    strings.asm is a command line utility that writes the string sequences
    in any file to STDOUT. It is primarily used to extract strings data
    from a binary file to STDOUT which can be redirected to a file.

  ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл *

    include strings.inc

.code

start:

    call main
    invoke ExitProcess, 0

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

main proc

    LOCAL hFile:DWORD
    LOCAL fsiz :DWORD
    LOCAL hmem$:DWORD
    LOCAL br   :DWORD
    LOCAL buffer[260]:BYTE
    LOCAL par2  [16] :BYTE

  ; ------------------------------
  ; get 1st command line parameter
  ; ------------------------------
    invoke GetCL,1,ADDR buffer
    cmp eax, 1
    je @F
    print SADD("No command line specified",13,10)
    call help
    ret
  @@:
  ; -------------------
  ; test if file exists
  ; -------------------
    invoke exist,ADDR buffer
    cmp eax, 1
    je @F
    print SADD("Command line file does not exist",13,10)
    call help
  @@:
  ; -------------------------------------------
  ; get 2nd command line parameter if it exists
  ; -------------------------------------------
    invoke GetCL,2,ADDR par2        ; get threshold size
    cmp eax, 0
    je @F
    invoke atodw,ADDR par2
    jmp nxt1
  @@:
  ; ---------------------------------------------
  ; set default if none specified on command line
  ; ---------------------------------------------
    mov thold, 3                    ; default character count for word size
    jmp @F
  nxt1:
    mov thold, eax                  ; count set on command line
  @@:

    invoke CreateFile,ADDR buffer,GENERIC_READ,FILE_SHARE_READ,
                      NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
    mov hFile, eax
    invoke GetFileSize,hFile,NULL
    mov fsiz , eax
    mov hmem$, alloc(fsiz )
    invoke ReadFile,hFile,hmem$,fsiz ,ADDR br,NULL
    invoke scanwords,hmem$,fsiz ,ADDR ctable
    invoke CloseHandle,hFile
    free hmem$

    ret

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

scanwords proc src:DWORD,fl:DWORD,tbl:DWORD

    LOCAL cnt      :DWORD
    LOCAL dst[1024]:BYTE    ; local output buffer for words

    push ebx
    push esi
    push edi

    mov cnt, 0          ; set counter to zero

    mov ebx, tbl        ; table address in EBX
    mov esi, src        ; source address in ESI
    lea edi, dst        ; output buffer address in edi
    mov ecx, fl         ; byte count in ECX
    add ecx, esi        ; match ECX to exit
    xor eax, eax        ; zero EAX to prevent stall

  comment * ------------------------------
    1st block is acceptable character loop
    -------------------------------------- *
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
    mov BYTE PTR [edi], 0       ; append terminator to word
    invoke szLen,ADDR dst
    cmp eax, thold
    jl @F
    push edx
    push ecx
    invoke StdOut,ADDR dst
    print SADD(13,10)
    pop ecx
    pop edx
  @@:

    lea edi, dst                ; reload the buffer address for the next word

  comment * --------------------------
    loop while unacceptable characters
    ---------------------------------- *
  lbl3:
    mov al, [esi]
    inc esi
    cmp esi, ecx                ; length check
    je lbout
    cmp BYTE PTR [ebx+eax], 1
    jne lbl3
    jmp backin

  lbout:

    mov eax, cnt

    pop edi
    pop esi
    pop ebx

    ret

scanwords endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

help proc

    print SADD("STRINGS.EXE get string data from binary file",13,10)
    print SADD("parameters,",13,10)
    print SADD("      1. name of file to get strings from",13,10)
    print SADD("      2. character count for minimum size word",13,10)
    print SADD("         default is 3 characters long or greater",13,10,13,10)

    print SADD("Output : STDOUT to screen",13,10,13,10)

    print SADD("File output is by redirection",13,10)
    print SADD("EXAMPLE : strings yourfile.ext 3 ",62," testfile.ext",13,10)

    ret

help endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start
