; #########################################################################

ofCallBack proc dwCookie:DWORD,pbBuff:DWORD,cb:DWORD,pcb:DWORD

    invoke ReadFile,dwCookie,pbBuff,cb,pcb,NULL

    mov eax, 0
    ret

ofCallBack endp

; #########################################################################
