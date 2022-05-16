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

    mov hArr, arralloc$(8)                      ; create the pointer array with empty members
    mov acnt, arrcnt$(hArr)                     ; get the member count back from the array

    mov void, arrset$(hArr,1,"item 1")
    mov void, arrset$(hArr,2,"item 2")
    mov void, arrset$(hArr,3,"item 3")
    mov void, arrset$(hArr,4,"item 4")
    mov void, arrset$(hArr,5,"item 5")
    mov void, arrset$(hArr,6,"item 6")
    mov void, arrset$(hArr,7,"item 7")
    mov void, arrset$(hArr,8,"item 8")

    print "Display the original array",13,10
    print "--------------------------",13,10

    mov ebx, 1
  @@:
    print arrget$(hArr,ebx),13,10
    add ebx, 1
    cmp ebx, acnt
    jle @B

  ; -----------------------------------------

    print "realloc to 4 members and display",13,10
    print "--------------------------------",13,10

    mov hArr, arrealloc$(hArr,4)

  ; -----------------------------------------

    mov acnt, arrcnt$(hArr)                     ; get the new member count

    mov ebx, 1
  @@:
    print arrget$(hArr,ebx),13,10
    add ebx, 1
    cmp ebx, acnt
    jle @B

  ; -----------------------------------------

    print "realloc to 8 members and display",13,10
    print "--------------------------------",13,10

    mov hArr, arrealloc$(hArr,8)

  ; -----------------------------------------

    mov acnt, arrcnt$(hArr)                     ; get the new member count

    mov void, arrset$(hArr,5,"new item 5")
    mov void, arrset$(hArr,6,"new item 6")
    mov void, arrset$(hArr,7,"new item 7")
    mov void, arrset$(hArr,8,"new item 8")

    mov ebx, 1
  @@:
    print arrget$(hArr,ebx),13,10
    add ebx, 1
    cmp ebx, acnt
    jle @B

    mov void, arrfree$(hArr)                    ; delete all of the array members and the main pointer array

    pop edi
    pop esi
    pop ebx

    ret

main endp

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

end start

























