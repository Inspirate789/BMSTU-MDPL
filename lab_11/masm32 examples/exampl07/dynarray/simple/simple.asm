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

    LOCAL hArr  :DWORD
    LOCAL void  :DWORD
    LOCAL acnt  :DWORD
    LOCAL pbuf  :DWORD
    LOCAL buffer[512]:BYTE

    push ebx
    push esi
    push edi

    mov acnt, 1024
    mov hArr, arralloc$(acnt)           ; allocate an empty array

    mov ebx, 1                          ; set index to 1 for 1 based array
  @@:
    mov pbuf, ptr$(buffer)              ; clear the buffer
  ; --------------------------------------
  ; write text to each member of the array
  ; --------------------------------------
    mov void, arrset$(hArr,ebx,cat$(pbuf,"This is line ",str$(ebx)))
    add ebx, 1
    cmp ebx, acnt
    jle @B

    mov ebx, 1                          ; set index to 1 for 1 based array
  @@:
    print arrget$(hArr,ebx),13,10       ; display each line in the array
    add ebx, 1
    cmp ebx, acnt
    jle @B

    mov void, arrfree$(hArr)            ; deallocate the entire array

    pop edi
    pop esi
    pop ebx

    ret

main endp

; ддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд

end start
