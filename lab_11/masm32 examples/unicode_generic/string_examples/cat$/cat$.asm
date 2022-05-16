IF 0  ; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
                      Build this template with "CONSOLE ASSEMBLE AND LINK"
                         Join multiple string in both ASCII and UNICODE
ENDIF ; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    __UNICODE__ equ 1

    include \masm32\include\masm32rt.inc

    .data?
      itemW TCHAR 260 dup (?)

    .code

start:
   
; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    call main
    inkey
    exit

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

main proc

    LOCAL str1  :DWORD
    LOCAL str2  :DWORD
    LOCAL str3  :DWORD
    LOCAL str4  :DWORD
    LOCAL spac  :DWORD
    LOCAL pbuf  :DWORD
    LOCAL buffer[512] :TCHAR
 
    mov str1, chr$("Text one")
    mov str2, chr$("Text two")
    mov str3, chr$("Text three")
    mov str4, cfm$("\qText four\q -- using C escapes")
    mov spac, chr$(" ")

    mov pbuf, ptr$(buffer)

    mov pbuf, cat$(pbuf,"quoted text.... ",str1,spac,str2,chr$(32,"--",32),str3,spac,str4," ....quoted text")

    print pbuf,13,10

    mov pbuf, ptr$(buffer)

    strcat pbuf,"quoted text.... ",str1,spac,str2," -- ",str3,spac,str4," ....quoted text"

    print pbuf,13,10

    ret

main endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

end start
