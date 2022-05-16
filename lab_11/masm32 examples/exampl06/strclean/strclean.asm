IF 0  ; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
                      Build this template with "CONSOLE ASSEMBLE AND LINK"
ENDIF ; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    include \masm32\include\masm32rt.inc

    strclean    PROTO :DWORD,:DWORD,:DWORD,:DWORD

    .data
      txt$ db "    this  ,,.  .,, <is> ,,, . , . , a test    ",0
      ptrtxt dd txt$
      lentxt dd LENGTHOF txt$

      txt2$ db "this  ,,.  .,, <is> ,,, . , . , a test",0
      ptrtxt2 dd txt2$
      lentxt2 dd LENGTHOF txt2$

    .code

start:
   
; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    call main
    inkey
    exit

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

main proc

    LOCAL pMem  :DWORD

    print "BEFORE :"
    print ptrtxt,13,10

    fn strclean,ptrtxt,lentxt," ,.<>"," -=*=- "
    mov pMem, eax
    print "AFTER  :"
    print pMem,13,10,13,10
    free pMem

    print "*** Ends test ***",13,10
    fn strclean,ptrtxt2,lentxt2," ,.<>"," =0= "
    mov pMem, eax
    print "AFTER  :"
    print pMem,13,10,13,10
    free pMem

    print "*** Remove test ***",13,10
    fn strclean,ptrtxt2,lentxt2," ,.<>",0
    mov pMem, eax
    print "AFTER  :"
    print pMem,13,10

    free pMem

    ret

main endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

strclean proc psrc:DWORD,lsrc:DWORD,pcharlist:DWORD,prepchars:DWORD

  ; MESS CLEANER UPPER
  ; ---------------------------------------------------------
  ; psrc        the text you want to clean up
  ; lsrc        the length of the source text
  ; pcharlist   the characters you want removed from the text
  ; prepchars   the string you wish to replace the junk with
  ;             or ZERO (0) to just remove the characters
  ;
  ; release the memory pointer return value with GlobalFree()
  ;
  ; ERROR return values
  ;     -1 no source supplied
  ;     -2 no character list
  ; ---------------------------------------------------------

    LOCAL pdst :DWORD                   ; destination pointer
    LOCAL rchl :DWORD                   ; length of replacement characters

    LOCAL ptbl :DWORD                   ; pointer to table
    LOCAL ctbl[260]:BYTE                ; character table

    LOCAL ccnt  :DWORD                  ; character counter pointer
    LOCAL pcnt[1024]:BYTE               ; 1024 byte counter array


    .if len(psrc) == 0
      mov eax, -1                       ; ERROR -1 no source supplied
      ret
    .endif

    .if len(pcharlist) == 0
      mov eax, -2                       ; ERROR -2 no character list
      ret
    .endif

    push ebx
    push esi
    push edi

    mov pdst, len(pcharlist)

    .if pdst > 1
      fild lsrc                         ; load source
      fild pdst                         ; load multiplier
      fmul                              ; multiply source by multiplier
      fistp pdst                        ; store result in variable
      mov eax, pdst
      add eax, 16384
      mov pdst, alloc(eax)
    .else
      mov pdst, alloc(lsrc)
    .endif

    lea eax, ctbl                       ; load address of character table into pointer
    mov ptbl, eax
    xor ecx, ecx
    mov edx, 8
    sub eax, 32
  zfill:                                ; zero fill the table
    add eax, 32
    mov [eax], ecx
    mov [eax+4], ecx
    mov [eax+8], ecx
    mov [eax+12], ecx
    mov [eax+16], ecx
    mov [eax+20], ecx
    mov [eax+24], ecx
    mov [eax+28], ecx
    sub edx, 1
    jnz zfill

    .if prepchars != 0
      mov rchl, len(prepchars)
    .endif

  ; -------------------------
  ; load pcharlist into table
  ; -------------------------
    mov esi, pcharlist
    mov ebx, ptbl
    sub esi, 1
  lbl0:
    add esi, 1
    movzx eax, BYTE PTR [esi]
    test eax, eax
    jz lbl1
    mov BYTE PTR [ebx+eax], 1
    jmp lbl0

  lbl1:
    mov esi, psrc
    mov edi, pdst
    sub esi, 1

  lpst:
    add esi, 1
  backin:
    movzx eax, BYTE PTR [esi]           ; get the src byte
    test eax, eax
    jz quit
    cmp BYTE PTR [ebx+eax], 0           ; check it against table
    jne collector
    mov [edi], al
    add edi, 1
    jmp lpst

  collector:
    add esi, 1
    movzx eax, BYTE PTR [esi]           ; get the src byte
    test eax, eax
    jz colout
    cmp BYTE PTR [ebx+eax], 0           ; check it against table
    jne collector

  ; ----------------------------
  ; write the replacement string
  ; ----------------------------
    .if prepchars == 0
      jmp backin
    .endif

    mov edx, prepchars
    sub edx, 1
  cl1:
    add edx, 1
    movzx eax, BYTE PTR [edx]
    test eax, eax
    jz backin
    mov BYTE PTR [edi], al
    add edi, 1
    jmp cl1

  ; ---------------------------------
  ; write the last replacement string
  ; ---------------------------------
  colout:
    .if prepchars == 0
      jmp quit
    .endif

    mov edx, prepchars
    sub edx, 1
  co1:
    add edx, 1
    movzx eax, BYTE PTR [edx]
    test eax, eax
    jz quit
    mov BYTE PTR [edi], al
    add edi, 1
    jmp co1

  quit:
    mov BYTE PTR [edi], 0               ; terminate the string
    mov eax, pdst                       ; return the memory handle

    pop edi
    pop esi
    pop ebx

    ret

strclean endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

end start

