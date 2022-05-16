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

    LOCAL pmem  :DWORD
    LOCAL flen  :DWORD
    LOCAL rval  :DWORD

    print ustr$(rv(filesizeW,"\masm32\include\windows.inc"))," File Size",13,10

    mov pmem, InputFile("\masm32\include\windows.inc")
    mov flen, ecx
    print ustr$(flen),13,10

    mov rval, OutputFile("WININC.INC",pmem,flen)
    mov flen, eax
    print ustr$(flen),13,10

    free pmem               ; release the memory from the InputFile() macro call

    ret

main endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

end start
