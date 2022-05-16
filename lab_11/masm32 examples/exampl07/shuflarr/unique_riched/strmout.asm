; #########################################################################

StreamFileOut proc hEdit:DWORD,lpszFileName:DWORD

    LOCAL hFile :DWORD
    LOCAL fSiz  :DWORD
    LOCAL ofs   :OFSTRUCT
    LOCAL est   :EDITSTREAM
    LOCAL buffer[32]:BYTE
    LOCAL aval[8]:BYTE

    invoke GetWindowTextLength,hEdit
    mov fSiz, eax

    szText CloseMsg,"Saved at "
    szText CloseByt," bytes"

    mov buffer[0], 0

    invoke szCatStr,ADDR buffer,ADDR CloseMsg

    invoke dwtoa,fSiz,ADDR aval
    invoke szCatStr,ADDR buffer,ADDR aval
    invoke szCatStr,ADDR buffer,ADDR CloseByt

    szText sfTest,"Test"

    invoke SendMessage,hStatus,SB_SETTEXT,3,ADDR buffer

    invoke OpenFile,lpszFileName,ADDR ofs,OF_CREATE
    mov hFile, eax

    mov est.dwCookie, eax
    mov est.dwError, 0
    mov eax, offset sfCallBack
    mov est.pfnCallback, eax

    invoke SendMessage,hEdit,EM_STREAMOUT,SF_TEXT,ADDR est
    invoke CloseHandle,hFile

    invoke SendMessage,hEdit,EM_SETMODIFY,0,0

    mov eax, 0
    ret

StreamFileOut endp

; ########################################################################
