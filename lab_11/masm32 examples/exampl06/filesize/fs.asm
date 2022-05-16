; �������������������������������������������������������������������������
    include \masm32\include\masm32rt.inc
; �������������������������������������������������������������������������

comment * -----------------------------------------------------
                        Build this  template with
                       "CONSOLE ASSEMBLE AND LINK"
        ----------------------------------------------------- *

    .data
      fname db "\masm32\include\windows.inc",0

    .code

start:
   
; �������������������������������������������������������������������������

    call main
    inkey
    exit

; �������������������������������������������������������������������������

main proc

    LOCAL bytecount :DWORD

    .if rv(exist,ADDR fname) != 0               ; test if file exists
      mov bytecount, rv(filesize,ADDR fname)    ; use "filesize" procedure
      print "Size of WINDOWS.INC = "
      print str$(bytecount)," bytes",13,10      ; display the results
    .else
      print "Sorry, can't find that file",13,10 ; otherwise show error
    .endif

    ret

main endp

; �������������������������������������������������������������������������

end start
