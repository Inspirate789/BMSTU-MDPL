; �������������������������������������������������������������������������
    include \masm32\include\masm32rt.inc
; �������������������������������������������������������������������������

comment * -----------------------------------------------------
                        Build this  template with
                       "CONSOLE ASSEMBLE AND LINK"
        ----------------------------------------------------- *

    remspace PROTO :DWORD

    .code

start:
   
; �������������������������������������������������������������������������

    call main
    inkey
    exit

; �������������������������������������������������������������������������

main proc

    LOCAL ptxt  :DWORD

    sas ptxt,"This is a test"

    cls
    print ptxt,".",13,10
    invoke remspace,ptxt
    print ptxt,".",13,10

    ret

main endp

; �������������������������������������������������������������������������

remspace proc txt:DWORD

    mov ecx, txt
    mov edx, txt

  @@:
    mov al, [ecx]
    add ecx, 1
    cmp al, 32      ; is it a space
    je @B
    mov [edx], al
    add edx, 1
    test al, al     ; is AL zero
    jnz @B

    ret

remspace endp

; �������������������������������������������������������������������������

end start
