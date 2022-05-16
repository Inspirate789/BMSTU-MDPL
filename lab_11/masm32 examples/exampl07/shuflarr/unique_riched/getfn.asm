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
