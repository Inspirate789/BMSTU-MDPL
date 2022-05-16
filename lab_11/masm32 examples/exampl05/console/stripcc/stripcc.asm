; ¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤
;
;                              STRIPCC.EXE
;               Strip C and C++ comments from a source file
;            and output the source file with ".scc" extension
;
;           ----------------------------------------------------
;           Build this file as a console mode file
;           In MASM32, Project menu, "Console Assembler & Link"
;           ----------------------------------------------------
;
; ¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤

      .486
      .model flat, stdcall
      option casemap :none   ; case sensitive

      include stripcc.inc

      stripcc           PROTO :DWORD,:DWORD,:DWORD
      do_help           PROTO
      read_diskfile     PROTO :DWORD,:DWORD
      disk_write        PROTO :DWORD,:DWORD,:DWORD

; ¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤

    .code

start:

    call main
    invoke ExitProcess,0

; ¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤

main proc

    LOCAL hInput$      :DWORD   ; input buffer handle
    LOCAL hOutput$     :DWORD   ; output bufer handle
    LOCAL lof          :DWORD   ; length of file variable
    LOCAL bWritten     :DWORD   ; bytes written variable
    LOCAL infile [260] :BYTE    ; input file name buffer
    LOCAL display[512] :BYTE    ; display text buffer

  ; -------------------------------
  ; get 1st command line parameter
  ; -------------------------------
    invoke GetCL,1,ADDR infile
    .if eax != 1
      invoke StdOut,CTXT("No source file specified",13,10)
      call do_help
      jmp quit
    .endif

  ; ------------------
  ; test if it exists
  ; ------------------
    invoke exist,ADDR infile
    .if eax == 0
      invoke StdOut,CTXT("Cannot find source file",13,10)
      jmp quit
    .endif

  ; ------------------------------------------
  ; display file name that is being processed
  ; ------------------------------------------
    lea eax, display
    mov BYTE PTR [eax], 0
    invoke szCatStr,ADDR display,SADD("processing ")
    invoke szCatStr,ADDR display,ADDR infile
    invoke szCatStr,ADDR display,SADD(" ")
    invoke StdOut,ADDR display

  ; ----------------------------------
  ; read file into memory. hInput$ is
  ; allocated within the procedure
  ; ----------------------------------
    invoke read_diskfile,ADDR infile,ADDR hInput$
    mov lof, eax

  ; -----------------------
  ; allocate output buffer
  ; -----------------------
    stralloc lof
    mov hOutput$, eax

  ; --------------------------------------------
  ; strip the C/C++ comments from data in input
  ; buffer and write it to output buffer
  ; --------------------------------------------
    invoke stripcc,hInput$,lof,hOutput$
    mov bWritten, eax

    push esi
    push edi

    lea esi, infile
  @@:
    mov al, [esi]
    inc esi
    cmp al, "."     ; test for period
    je nxt
    cmp al, 0
    je nxt
    jmp @B
    
  nxt:
    dec esi
    mov DWORD PTR [esi], "ccs."
    add esi, 4
    mov BYTE PTR [esi], 0

    pop edi
    pop esi

  ; -------------------------------------------------------
  ; write the result to disk overwriting the original file
  ; -------------------------------------------------------
    invoke disk_write,ADDR infile,hOutput$,bWritten

  ; ------------------------------------------
  ; free both input and output memory buffers
  ; ------------------------------------------
    strfree hOutput$
    strfree hInput$

  ; ------------------------------------------------------------
  ; reuse display buffer to show the byte count written to disk
  ; ------------------------------------------------------------
    invoke dwtoa,bWritten,ADDR display
    invoke szCatStr,ADDR display,SADD(" bytes written",13,10)
    invoke StdOut,ADDR display

  quit:

    ret

main endp

; ¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤

do_help proc

    invoke StdOut,CTXT("STRIPCC.EXE",13,10)
    invoke StdOut,CTXT("strip C and C++ comments from source file",13,10)
    invoke StdOut,CTXT("EXAMPLE stripcc infile.c",13,10)
    invoke StdOut,CTXT("Result is filename with ",34,".scc",34," extension",13,10)

    ret

do_help endp

; ¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤

read_diskfile proc lpName:DWORD,lpMem:DWORD

    LOCAL hFile     :DWORD
    LOCAL fl        :DWORD
    LOCAL bRead     :DWORD
    LOCAL Mem       :DWORD

    invoke CreateFile,lpName,GENERIC_READ,0,NULL,OPEN_EXISTING,NULL,NULL
    mov hFile, eax

    invoke GetFileSize,hFile,NULL
    mov fl, eax

  ; -----------------------
  ; allocate string memory
  ; -----------------------
    invoke SysAllocStringByteLen,0,fl
    mov Mem, eax

  ; ---------------------------------------------------
  ; write handle to DWORD variable passed as parameter
  ; ---------------------------------------------------
    mov ecx, lpMem
    mov [ecx], eax

    invoke ReadFile,hFile,Mem,fl,ADDR bRead,NULL
    invoke CloseHandle,hFile

  ; -------------------------
  ; return bytes read in EAX
  ; -------------------------
    mov eax, bRead

    ret

read_diskfile endp

; ¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤

disk_write proc lpName:DWORD,lpData:DWORD,fl:DWORD

    LOCAL hOutput:DWORD
    LOCAL bw     :DWORD

    invoke CreateFile,lpName,GENERIC_WRITE,NULL,NULL,
                      CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
    mov hOutput, eax
    invoke WriteFile,hOutput,lpData,fl,ADDR bw,NULL
    invoke CloseHandle,hOutput

    mov eax, bw                 ; return written byte count
    ret

disk_write endp

; ¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤

stripcc proc lpsource:DWORD,lnsource:DWORD,lpresult:DWORD

; -------------------------------------------------------------
; stripcc removes C++ comments // and old style C comments
; /*------------- old style C comment -----------------*/
; removes trailing spaces on lines, with or without comments
; -------------------------------------------------------------

    push ebx
    push esi
    push edi

    mov esi, lpsource
    mov edi, lpresult
    mov ecx, lnsource
    add ecx, esi            ; exit condition in ECX

  lbl1:
    mov al, [esi]
    inc esi
    cmp al, "/"
    je comment1
  rtn:
    cmp al, 13              ; branch to trim trailing spaces
    je trimr
  nxt1:
    mov [edi], al
    inc edi
    cmp esi, ecx
    je outa_here            ; exit on source length
    jmp lbl1

  trimr:                    ; trim trailing spaces
    cmp BYTE PTR [edi-1], 32
    jne nxt1
    dec edi
    jmp trimr

  comment1:
    cmp BYTE PTR [esi], "/" ; read next character in ESI
    je cpp
    cmp BYTE PTR [esi], "*"
    je oldc
    jmp rtn                 ; if not a comment, write byte in AL to [EDI]

  cpp:
    mov al, [esi]
    inc esi
    cmp esi, ecx
    je outa_here            ; exit on source length
    cmp al, 13
    je rtn
    jmp cpp

  oldc:
    mov al, [esi]
    inc esi
    cmp esi, ecx
    je outa_here            ; exit on source length
    cmp al, "*"
    je last
    jmp oldc

  last:
    cmp BYTE PTR [esi], "/"
    jne oldc
    inc esi
    jmp lbl1

  outa_here:

    sub edi, lpresult       ; get the byte count written to [edi]
    mov eax, edi            ; set it as the return value

    pop edi
    pop esi
    pop ebx

    ret

stripcc endp

; ¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤

end start