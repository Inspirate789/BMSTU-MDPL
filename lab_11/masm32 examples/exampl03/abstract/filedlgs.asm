; ########################################################################

    GetFileName  PROTO :DWORD, :DWORD, :DWORD
    SaveFileName PROTO :DWORD, :DWORD, :DWORD
    FillBuffer   PROTO :DWORD, :DWORD, :BYTE

    .data
      szFileName    db 260 dup(0)
      ofn           OPENFILENAME <>  ; structure

    .code

; ########################################################################

GetFileName proc hParent:DWORD,lpTitle:DWORD,lpFilter:DWORD

    mov ofn.lStructSize,        sizeof OPENFILENAME
    m2m ofn.hWndOwner,          hParent
    m2m ofn.hInstance,          hInstance
    m2m ofn.lpstrFilter,        lpFilter
    m2m ofn.lpstrFile,          offset szFileName
    mov ofn.nMaxFile,           sizeof szFileName
    m2m ofn.lpstrTitle,         lpTitle
    mov ofn.Flags,              OFN_EXPLORER or OFN_FILEMUSTEXIST or \
                                OFN_LONGNAMES

    invoke GetOpenFileName,ADDR ofn

    ret

GetFileName endp

; #########################################################################

SaveFileName proc hParent:DWORD,lpTitle:DWORD,lpFilter:DWORD

    mov ofn.lStructSize,        sizeof OPENFILENAME
    m2m ofn.hWndOwner,          hParent
    m2m ofn.hInstance,          hInstance
    m2m ofn.lpstrFilter,        lpFilter
    m2m ofn.lpstrFile,          offset szFileName
    mov ofn.nMaxFile,           sizeof szFileName
    m2m ofn.lpstrTitle,         lpTitle
    mov ofn.Flags,              OFN_EXPLORER or OFN_LONGNAMES
                                
    invoke GetSaveFileName,ADDR ofn

    ret

SaveFileName endp

; ########################################################################

FillBuffer proc lpBuffer:DWORD,lenBuffer:DWORD,TheChar:BYTE

    push edi

    mov edi, lpBuffer   ; address of buffer
    mov ecx, lenBuffer  ; buffer length
    mov  al, TheChar    ; load al with character
    rep stosb           ; write character to buffer until ecx = 0

    pop edi

    ret

FillBuffer endp

; #########################################################################

