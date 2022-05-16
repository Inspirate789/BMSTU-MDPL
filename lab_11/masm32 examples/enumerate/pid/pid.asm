; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
    include \masm32\include\masm32rt.inc
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

comment * -----------------------------------------------------
                        Build this  template with
                       "CONSOLE ASSEMBLE AND LINK"
        ----------------------------------------------------- *

    include \masm32\include\psapi.inc
    includelib \masm32\lib\psapi.lib

    ShowProcess PROTO pid:DWORD

    .code

start:
   
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    call main
    inkey
    exit

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

main proc

    LOCAL breq  :DWORD
    LOCAL pbuf  :DWORD
    LOCAL buffer[4096]:BYTE

    push esi
    push edi

    mov pbuf, ptr$(buffer)                          ; cast buffer address to a pointer

    invoke EnumProcesses,pbuf,4096,ADDR breq        ; enumerate processes
    shr breq, 2                                     ; get process count

    mov esi, pbuf
    mov edi, breq

  @@:
    invoke ShowProcess,[esi]
    add esi, 4
    sub edi, 1
    jnz @B

    pop edi
    pop esi

    ret

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

ShowProcess proc pid:DWORD

    LOCAL hProcess  :DWORD
    LOCAL hMod      :DWORD
    LOCAL cbNeeded  :DWORD
    LOCAL pbuf      :DWORD
    LOCAL ptxt      :DWORD
    LOCAL buf[260]  :BYTE
    LOCAL txt[260]  :BYTE

    mov pbuf, ptr$(buf)
    mov ptxt, ptr$(txt)

    mov hProcess, rv(OpenProcess,PROCESS_QUERY_INFORMATION or PROCESS_VM_READ,FALSE,pid)
                           
    .if hProcess != 0
      .if rv(EnumProcessModules,hProcess,ADDR hMod,4,ADDR cbNeeded) != 0
        invoke GetModuleBaseName,hProcess,hMod,pbuf,260
        mov ptxt, cat$(ptxt,"pid ",str$(pid)," ",pbuf)
      .else
        mov ptxt, cat$(ptxt,"pid ",str$(pid)," -fail- EnumProcessModules")
      .endif
    .else
      mov ptxt, cat$(ptxt,"pid ",str$(pid)," -fail- OpenProcess")
    .endif

    print ptxt,13,10

    invoke CloseHandle,hProcess

    ret

ShowProcess endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start