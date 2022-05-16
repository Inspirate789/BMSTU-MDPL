; #########################################################################

StreamFileIn proc hEdit:DWORD,lpszFileName:DWORD

    LOCAL hFile :DWORD
    LOCAL fSiz  :DWORD
    LOCAL ofs   :OFSTRUCT
    LOCAL est   :EDITSTREAM
    LOCAL buffer[32]:BYTE
    LOCAL aval[8]:BYTE

    invoke OpenFile,lpszFileName,ADDR ofs,OF_READ
    mov hFile, eax

    mov est.dwCookie, eax
    mov est.dwError, 0
    mov eax, offset ofCallBack
    mov est.pfnCallback, eax

    invoke SendMessage,hEdit,EM_STREAMIN,SF_TEXT,ADDR est

    invoke GetFileSize,hFile,NULL
    mov fSiz, eax

    invoke CloseHandle,hFile

    szText OpenMsg,"Opened at "
    szText OpenByt," bytes"

    mov buffer[0], 0

    invoke szCatStr,ADDR buffer,ADDR OpenMsg

    invoke dwtoa,fSiz,ADDR aval
    invoke szCatStr,ADDR buffer,ADDR aval
    invoke szCatStr,ADDR buffer,ADDR OpenByt

    invoke SendMessage,hStatus,SB_SETTEXT,3,ADDR buffer

    invoke SendMessage,hEdit,EM_SETMODIFY,0,0

    mov eax, 0
    ret

StreamFileIn endp

; #########################################################################
