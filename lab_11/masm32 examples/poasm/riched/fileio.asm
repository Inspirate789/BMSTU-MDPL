; #########################################################################

ofCallBack proc dwCookie:DWORD,pbBuff:DWORD,cb:DWORD,pcb:DWORD

    invoke ReadFile,dwCookie,pbBuff,cb,pcb,NULL

    mov eax, 0
    ret

ofCallBack endp

; #########################################################################

sfCallBack proc dwCookie:DWORD,pbBuff:DWORD,cb:DWORD,pcb:DWORD

    invoke WriteFile,dwCookie,pbBuff,cb,pcb,NULL

    mov eax, 0
    ret

sfCallBack endp

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

MergeFile proc hEdit:DWORD

    LOCAL hFile :DWORD
    LOCAL hMem  :DWORD
    LOCAL ln    :DWORD
    LOCAL br    :DWORD

    jmp @F
      szTitleM   db "Merge File",0
      szFilterM  db "All files",0,"*.*",0,
                    "Text files",0,"*.TEXT",0,0
    @@:

    mov szFileName[0],0
    invoke GetFileName,hWnd,ADDR szTitleM,ADDR szFilterM

    cmp szFileName[0],0  ;<< zero if cancel pressed in dlgbox
    je @F
      invoke CreateFile,ADDR szFileName,
                        GENERIC_READ,
                        FILE_SHARE_READ,
                        NULL,OPEN_EXISTING,
                        FILE_ATTRIBUTE_NORMAL,
                        NULL
      mov hFile, eax

      invoke GetFileSize,hFile,NULL
      mov ln, eax

      stralloc ln
      mov hMem, eax
    
      invoke ReadFile,hFile,hMem,ln,ADDR br,NULL
      invoke SendMessage,hEdit,EM_REPLACESEL,0,hMem

      strfree hMem
    @@:

    ret

MergeFile endp

; #########################################################################
