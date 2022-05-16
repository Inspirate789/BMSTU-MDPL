; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
    include \masm32\include\masm32rt.inc
; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

comment * -----------------------------------------------------
                        Build this  template with
                       "CONSOLE ASSEMBLE AND LINK"
        ----------------------------------------------------- *

    .code

start:
   
; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

    call main
    inkey
    exit

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

main proc

    LOCAL hArr  :DWORD
    LOCAL acnt  :DWORD
    LOCAL void  :DWORD
    LOCAL hMem  :DWORD
    LOCAL flen  :DWORD
    LOCAL atot  :DWORD

    push ebx
    push esi
    push edi

    mov acnt, 100
    mov hArr, arralloc$(acnt)               ; create the pointer array with empty members

  ; --------------------------------
  ; write ascending numbers 1 to 100
  ; --------------------------------
    mov ebx, 1                              ; set EBX as a 1 based index
  @@:
    mov void, arrset$(hArr,ebx,str$(ebx))   ; write zero terminated data to each array member
    add ebx, 1
    cmp ebx, acnt
    jle @B

    mov atot, arrtotal$(hArr,0)             ; get length to allocate without CRLF included
    mov hMem, alloc(atot)                   ; allocate that amount of memory
    mov void, arr2mem$(hArr,hMem)           ; write entire array to memory

    mov void, OutputFile("testit.txt",hMem,atot)    ; write buffer to disk

    free hMem                               ; free the buffer memory

    print "File written with no CRLF",13,10
    print str$(atot)," bytes written to disk",13,10

    mov atot, arrtotal$(hArr,1)             ; get length to allocate including trailing CRLF
    mov hMem, alloc(atot)                   ; allocate that amount of memory
    mov void, arr2text$(hArr,hMem)          ; write entire array to memory with CRLF appended to each line

    mov void, OutputFile("testtxt.txt",hMem,atot)   ; write buffer to disk

    free hMem                               ; free the buffer memory

    print "File written with CRLF",13,10
    print str$(atot)," bytes written to disk",13,10

    mov void, arrfree$(hArr)                ; delete all of the array members and the main pointer array

    pop edi
    pop esi
    pop ebx

    ret

main endp

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

end start
