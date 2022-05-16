; #########################################################################

Select_All Proc hEdit:DWORD

    LOCAL tl :DWORD
    LOCAL Cr :CHARRANGE

    mov Cr.cpMin,0

    invoke GetWindowTextLength,hEdit
    inc eax
    mov Cr.cpMax, eax

    invoke SendMessage,hEdit,EM_EXSETSEL,0,ADDR Cr

    ret

Select_All endp

; #########################################################################
