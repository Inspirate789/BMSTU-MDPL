; #########################################################################

sfCallBack proc dwCookie:DWORD,pbBuff:DWORD,cb:DWORD,pcb:DWORD

    invoke WriteFile,dwCookie,pbBuff,cb,pcb,NULL

    mov eax, 0
    ret

sfCallBack endp

; #########################################################################
