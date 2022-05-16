IF 0  ; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
                          Build this template with "ASSEMBLE AND LINK"
ENDIF ; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    include \masm32\include\masm32rt.inc

    app_path PROTO :DWORD
    app_name PROTO :DWORD

    .code

start:
   
; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    call main
    exit

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

main proc

    LOCAL buffer[260]:BYTE
    LOCAL pbuf  :DWORD

    mov pbuf, ptr$(buffer)

    invoke app_path,pbuf
    fn MessageBox,0,pbuf,"app_path",MB_OK

    invoke app_name,pbuf
    fn MessageBox,0,pbuf,"app_path",MB_OK

    ret

main endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

app_path proc buffer:DWORD

  ; ---------------------------------------------------------
  ; call this procedure with the address of a 260 byte buffer
  ; return the path with a trailing "\" at address "buffer"
  ; ---------------------------------------------------------
    invoke GetModuleFileName,NULL,buffer,260

    mov ecx, buffer
    add ecx, eax            ; add length
    add ecx, 1

  @@:                       ; scan backwards to find last "\"
    sub ecx, 1
    cmp BYTE PTR [ecx], "\"
    je @F
    cmp ecx, buffer
    jge @B

  @@:
    mov BYTE PTR [ecx+1], 0 ; truncate string after last "\"

    ret

app_path endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

app_name proc buffer:DWORD

  ; ---------------------------------------------------------
  ; call this procedure with the address of a 260 byte buffer
  ; returns the file name at address "buffer"
  ; ---------------------------------------------------------
    push ebx

    invoke GetModuleFileName,NULL,buffer,260

    mov ecx, buffer
    add ecx, eax                    ; add length
    add ecx, 1

  @@:                               ; scan backwords to find last "\"
    sub ecx, 1
    cmp BYTE PTR [ecx], "\"
    je @F
    cmp ecx, buffer
    jge @B

  @@:
    add ecx, 1
    mov eax, buffer
    or ebx, -1

  @@:                               ; overwrite buffer with file name
    add ebx, 1
    movzx edx, BYTE PTR [ecx+ebx]
    mov [eax+ebx], dl
    test dl, dl
    jnz @B

    pop ebx

    ret

app_name endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

end start






















