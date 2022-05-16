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

    LOCAL hMem  :DWORD                          ; loaded file memory
    LOCAL flen  :DWORD                          ; loaded file length
    LOCAL hBuf  :DWORD                          ; buffer handle
    LOCAL rpos  :DWORD                          ; pointer to next read position
    LOCAL hArr  :DWORD                          ; array handle
    LOCAL pmain :DWORD                          ; array main memory handle
    LOCAL acnt  :DWORD                          ; count of arguments returned by tokeniser

    mov hMem, InputFile("tokenise.asm")
    mov flen, ecx
    mov hBuf, alloc(flen)

    mov hArr, rv(create_array,64,1024)          ; allow 64 args of 1k each
    mov pmain, ecx

    push esi

  ; *************************************

    mov rpos, 0
  stlp:
    mov rpos, rv(get_ml,hMem,hBuf,rpos)         ; get the next statement
    cmp rpos, 0
    jz stout
    mov acnt, rv(parse_line,hBuf,hArr)          ; split it into tokens

  ; -------------------------------------
   mov esi, hArr
  @@:
    print [esi],13,10                           ; loop through each array member and display each token
    add esi, 4
    sub acnt, 1
    jnz @B
  ; -------------------------------------

    print "-----------",13,10                   ; print a divider to seperate statements

    jmp stlp

  stout:

  ; *************************************

    pop esi

    free hArr
    free pmain

    free hMem
    free hBuf

    ret

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start

























