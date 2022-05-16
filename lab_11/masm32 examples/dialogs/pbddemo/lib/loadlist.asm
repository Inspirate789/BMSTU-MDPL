; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    .486                      ; create 32 bit code
    .model flat, stdcall      ; 32 bit memory model
    option casemap :none      ; case sensitive

    include \masm32\include\windows.inc
    include \masm32\include\kernel32.inc
    include \masm32\include\user32.inc

    .code

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

LoadList proc hWin:DWORD,pattern:DWORD

    LOCAL hSearch :DWORD
    LOCAL wfd :WIN32_FIND_DATA

    invoke SendMessage,hWin,WM_SETREDRAW,FALSE,0

    invoke FindFirstFile,pattern,ADDR wfd
    .if eax == INVALID_HANDLE_VALUE
      jmp TheEnd
    .else
      mov hSearch, eax
    .endif
    cmp BYTE PTR [wfd.cFileName], "."
    je @F
    cmp wfd.dwFileAttributes, FILE_ATTRIBUTE_DIRECTORY or FILE_ATTRIBUTE_READONLY
    je @F
    cmp wfd.dwFileAttributes, FILE_ATTRIBUTE_DIRECTORY
    je @F
    invoke SendMessage,hWin,LB_ADDSTRING,0,ADDR wfd.cFileName
  @@:
    invoke FindNextFile,hSearch,ADDR wfd
    cmp eax, 0
    je lpOut
    cmp BYTE PTR [wfd.cFileName], "."
    je @B
    cmp wfd.dwFileAttributes, FILE_ATTRIBUTE_DIRECTORY or FILE_ATTRIBUTE_READONLY
    je @B
    cmp wfd.dwFileAttributes, FILE_ATTRIBUTE_DIRECTORY
    je @B

    invoke SendMessage,hWin,LB_ADDSTRING,0,ADDR wfd.cFileName
    jmp @B

  lpOut:
    invoke FindClose,hSearch

  TheEnd:

    invoke SendMessage,hWin,WM_SETREDRAW,TRUE,0

    ret

LoadList endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end