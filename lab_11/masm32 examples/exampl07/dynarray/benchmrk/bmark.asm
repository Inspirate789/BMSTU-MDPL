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
    LOCAL setv  :DWORD
    LOCAL getv  :DWORD
    LOCAL hMem  :DWORD

    push ebx
    push esi
    push edi

  ; ===========================================

    mov acnt, 5000000

    print "5 million element test",13,10,13,10

  ; ------------
  ; create array
  ; ------------
    invoke GetTickCount
    push eax

    mov hArr, arralloc$(acnt)

    invoke GetTickCount
    pop ecx
    sub eax, ecx

    print str$(eax)," ms array create",13,10

  ; --------------------
  ; load array with data
  ; --------------------
    invoke GetTickCount
    push eax

    mov ebx, 1
  @@:
    mov setv, arrset$(hArr,ebx,str$(ebx))
    add ebx, 1
    cmp ebx, acnt
    jle @B

    invoke GetTickCount
    pop ecx
    sub eax, ecx

    print str$(eax)," ms array load data",13,10

  ; ---------------------------
  ; get data address from array
  ; ---------------------------
    invoke GetTickCount
    push eax

    mov ebx, 1
  @@:
    mov getv, arrget$(hArr,ebx)
    add ebx, 1
    cmp ebx, acnt
    jle @B

    invoke GetTickCount
    pop ecx
    sub eax, ecx

    print str$(eax)," ms array read",13,10

  ; ----------------
  ; delete the array
  ; ----------------
    invoke GetTickCount
    push eax

    mov acnt, arrfree$(hArr)

    invoke GetTickCount
    pop ecx
    sub eax, ecx

    print str$(eax)," ms array delete",13,10

    pop edi
    pop esi
    pop ebx

    ret

main endp

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

end start
