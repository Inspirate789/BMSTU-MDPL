IF 0  ; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
                      Build this template with "CONSOLE ASSEMBLE AND LINK"
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

    LOCAL pinput    :DWORD

    mov pinput, input("Enter Text Here :",62," ")

    print pinput,13,10,13,10

    print "Simple Text.",13,10,13,10

    print "This is a test of",13,10,"UNICODE console code.",13,10,13,10

    printc "This is a test of\nusing C style escapes\nat the console.\n\n"

    printc "This is a test using\nthe C style macro \qprintc\q\nwith UNICODE text.\n\n"

    ret

main endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

end start
