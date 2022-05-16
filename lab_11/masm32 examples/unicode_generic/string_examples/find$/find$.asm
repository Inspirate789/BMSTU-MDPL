IF 0  ; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
                      Build this template with "CONSOLE ASSEMBLE AND LINK"
                    Find sub string in main string in either ASCII or UNICODE
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

    LOCAL rslt  :DWORD
    LOCAL main$ :DWORD
    LOCAL sub$  :DWORD

    mov main$, chr$("This is a test of find$")
    mov sub$,  chr$("a test of")

    mov rslt, find$(1,main$,sub$)

    print "The sub string was found at character position "
    print ustr$(rslt),13,10

    ret

main endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

end start
