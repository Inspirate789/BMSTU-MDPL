; ##########################################################################

    Do_Status PROTO :DWORD

    .data
        hStatus       dd 0

    .code

; ##########################################################################

Do_Status proc hParent:DWORD

    LOCAL sbParts[4] :DWORD

    invoke CreateStatusWindow,WS_CHILD or WS_VISIBLE or \
                              SBS_SIZEGRIP,NULL, hParent, 200
    mov hStatus, eax
      
    ; -------------------------------------
    ; sbParts is a DWORD array of 4 members
    ; -------------------------------------
    mov [sbParts +  0],   125    ; pixels from left
    mov [sbParts +  4],   250    ; pixels from left
    mov [sbParts +  8],   375    ; pixels from left
    mov [sbParts + 12],    -1    ; last part

    invoke SendMessage,hStatus,SB_SETPARTS,4,ADDR sbParts

    ret

Do_Status endp

; ##########################################################################
