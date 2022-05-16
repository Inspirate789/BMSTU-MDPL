; ########################################################################

MergeFile proc hEdit:DWORD

    LOCAL poz   :DWORD
    LOCAL hFile :DWORD
    LOCAL hMem  :DWORD
    LOCAL ln    :DWORD
    LOCAL br    :DWORD
    LOCAL Cr    :CHARRANGE

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
