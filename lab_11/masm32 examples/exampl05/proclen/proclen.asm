IF 0  ; ��������������������������������������������������������������������������������������������
                      Build this template with "CONSOLE ASSEMBLE AND LINK"
ENDIF ; ��������������������������������������������������������������������������������������������

    include \masm32\include\masm32rt.inc

    .data
      item dd glbl1 - glbl0

    .code

start:
   
; ��������������������������������������������������������������������������������������������������

    print str$(item),13,10      ; static result, calculated at assembly time

    mov eax, OFFSET glbl1
    sub eax, OFFSET glbl0
    print str$(eax),13,10       ; dynamic result, calculated at runtime

    call main

    inkey
    exit

; ��������������������������������������������������������������������������������������������������

    align 16

    glbl0::

main proc

    print "Get Procedure Length",13,10

    nop     ; add an extra byte

    ret

main endp

    glbl1::

; ��������������������������������������������������������������������������������������������������

end start
