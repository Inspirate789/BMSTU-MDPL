; ��������������������������������������������������������������������������������������������������
    include \masm32\include\masm32rt.inc
IF 0  ; ��������������������������������������������������������������������������������������������

    Build this  template with
   "CONSOLE ASSEMBLE AND LINK"

    A very simple technique to prevent malicious users from
    trying to pass very long command lines to an application
    to cause a stack overflow exploit.

ENDIF ; ��������������������������������������������������������������������������������������������

    .code

start:
   
; ��������������������������������������������������������������������������������������������������

    call main
    inkey
    exit

; ��������������������������������������������������������������������������������������������������

main proc

    .if len(rv(GetCommandLine)) > 256
      print "Warning, Some idiot is trying a stack overflow exploit.",13,10
      ret
    .endif

    print "It appears the command line did not exceed the limit",13,10

    ret

main endp

; ��������������������������������������������������������������������������������������������������

end start
