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

    push ebx
    push esi
    push edi

    invoke GetTickCount
    push eax

  ; --------------------
  ; load file into array
  ; --------------------
    mov hArr, arrfile$("\masm32\include\windows.inc")

    mov acnt, arrcnt$(hArr)             ; get the array member count

    invoke GetTickCount
    pop ecx
    sub eax, ecx

    print str$(eax)," ms disk read and array load",13,10,13,10

    print "File is now loaded, do you want to display it ? 'y' for yes",13,10

    getkey                              ; wait for a key stroke

    switch eax
      case "y"                          ; if it is "y" display the file
        mov ebx, 1                      ; set index to 1 for 1 based array
      @@:
        print arrget$(hArr,ebx),13,10   ; display each line in the array
        add ebx, 1
        cmp ebx, acnt
        jle @B
    endsw

    mov void, arrfree$(hArr)            ; deallocate the entire array

    pop edi
    pop esi
    pop ebx

    ret

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start
