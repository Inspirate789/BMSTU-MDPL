IF 0  ; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
                       Build this template with "CONSOLE ASSEMBLE AND LINK"
                          Stream APPEND text in either ASCII or UNICODE
ENDIF ; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    __UNICODE__ equ 1

    include \masm32\include\masm32rt.inc

    .code

start:
   
; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    call main
    inkey
    exit

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

main proc

    LOCAL buffer[260]:TCHAR
    LOCAL bptr  :DWORD
    LOCAL str1  :DWORD
    LOCAL str2  :DWORD
    LOCAL str3  :DWORD
    LOCAL cloc  :DWORD

    mov bptr, ptr$(buffer)

    mov str1, chr$("one ")
    mov str2, chr$("two ")
    mov str3, chr$("three ")

    mov cloc, 0

    mov cloc, append$(bptr,str1,cloc)
    mov cloc, append$(bptr,str2,cloc)
    mov cloc, append$(bptr,str3,cloc)

    mov cloc, append$(bptr,str1,cloc)
    mov cloc, append$(bptr,str2,cloc)
    mov cloc, append$(bptr,str3,cloc)

    mov cloc, append$(bptr,str1,cloc)
    mov cloc, append$(bptr,str2,cloc)
    mov cloc, append$(bptr,str3,cloc)

    mov cloc, append$(bptr,str1,cloc)
    mov cloc, append$(bptr,str2,cloc)
    mov cloc, append$(bptr,str3,cloc)

    print bptr,13,10

    ret

main endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

end start
