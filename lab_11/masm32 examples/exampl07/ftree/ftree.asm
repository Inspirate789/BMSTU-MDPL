; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
    include \masm32\include\masm32rt.inc
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

comment * --------------------------------------------------------

                         Build this utility with
                       "CONSOLE ASSEMBLE AND LINK"

        This utility recurses the directory tree from its current
        location and lists all files within the directory tree
        from the current location upwards.

        -------------------------------------------------------- *

    file_tree    PROTO :DWORD,:DWORD,:DWORD
    cb_file_tree PROTO :DWORD,:DWORD,:DWORD ; user defined callback procedure
    get_pattern  PROTO :DWORD

    .code

start:
   
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    call main
    inkey
    exit

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

main proc

    LOCAL pbuf  :DWORD
    LOCAL pcmd  :DWORD
    LOCAL buffer1[128]:BYTE
    LOCAL buffer2[128]:BYTE

    mov pbuf, ptr$(buffer1)
    mov pcmd, ptr$(buffer2)

    invoke GetCL,1,pcmd
    .if eax != 1
      sas pbuf, "*.*"
    .else
      mov pbuf, lcase$(pcmd)
    .endif

    fn file_tree,OFFSET cb_file_tree,rv(get_pattern,pbuf),0

    ret

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

get_pattern proc src:DWORD

    push esi

    mov esi, src

  stlp:
    cmp BYTE PTR [esi], "."
    jne @F
    mov edx, esi                ; store period position in EDX
  @@:
    cmp BYTE PTR [esi], 0
    je nxt
    add esi, 1
    jmp stlp

  nxt:
    test edx, edx
    jz quit
    add edx, 1                  ; step past period
    mov esi, src
    mov ecx, -1

  cpy:
    add ecx, 1
    mov al, [edx+ecx]           ; write bare pattern back to SRC
    mov [esi+ecx], al
    test al, al
    jnz cpy

    mov eax, src

  quit:
    pop esi

    ret

get_pattern endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

file_tree proc lpcb:DWORD,upatn:DWORD,flag:DWORD

    LOCAL hSrch :DWORD
    LOCAL wfd   :WIN32_FIND_DATA
    LOCAL pbuf  :DWORD
    LOCAL buffer[260]:BYTE

    add flag, 1

    mov pbuf, ptr$(buffer)

    mov hSrch, rv(FindFirstFile,"*.*",ADDR wfd)
    .if hSrch != INVALID_HANDLE_VALUE
      lea eax, wfd.cFileName
      switch$ eax
        case$ "."                           ; bypass current directory character
          jmp @F
      endsw$
      .if wfd.dwFileAttributes == FILE_ATTRIBUTE_DIRECTORY
        chdir ADDR wfd.cFileName
        invoke file_tree,lpcb,upatn,flag    ; recurse to next directory level
      .endif

      push upatn
      lea eax, wfd
      push eax
      lea eax, wfd.cFileName
      push eax
      call lpcb

    @@:
      test rv(FindNextFile,hSrch,ADDR wfd), eax
      jz close_file
      lea eax, wfd.cFileName
      switch$ eax
        case$ ".."                          ; bypass previous directory characters
          jmp @F
      endsw$
      .if wfd.dwFileAttributes == FILE_ATTRIBUTE_DIRECTORY
        chdir ADDR wfd.cFileName
        invoke file_tree,lpcb,upatn,flag    ; recurse to next directory level
      .endif

      push upatn
      lea eax, wfd
      push eax
      lea eax, wfd.cFileName
      push eax
      call lpcb

    @@:                                     ; loop through the rest
      test rv(FindNextFile,hSrch,ADDR wfd), eax
      jz close_file

      push upatn
      lea eax, wfd
      push eax
      lea eax, wfd.cFileName
      push eax
      call lpcb

      .if wfd.dwFileAttributes == FILE_ATTRIBUTE_DIRECTORY
        chdir ADDR wfd.cFileName
        invoke file_tree,lpcb,upatn,flag    ; recurse to next directory level
      .endif
      jmp @B

    close_file:
      invoke FindClose,hSrch
    .endif

    .if flag > 0                            ; flag controlled tail recursion
      chdir ".."                            ; drop back to next lower directory
    .endif

    ret

file_tree endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

cb_file_tree proc pfilename:DWORD,pwfd:DWORD,upatn:DWORD

    LOCAL pbuf  :DWORD
    LOCAL pdir  :DWORD
    LOCAL buffer1[260]:BYTE
    LOCAL buffer2[260]:BYTE

  ; ----------------------
  ; don't list a directory
  ; ----------------------
    cmp rv(GetFileAttributes,pfilename), FILE_ATTRIBUTE_DIRECTORY
    jne @F
    ret
  @@:

    mov pbuf,  ptr$(buffer1)
    mov pdir,  ptr$(buffer2)

    cst pbuf, pfilename                     ; copy file name to buffer
    mov pbuf, rv(get_pattern,lcase$(pbuf))  ; get filename pattern

  ; --------------------------
  ; user file extension is *.*
  ; --------------------------
    fn szCmp,upatn,"*"
    test eax, eax
    jz @F
    invoke GetCurrentDirectory,260,pdir
    print pdir,"\"
    print pfilename,13,10                   ; display the file name
    ret
  @@:

  ; --------------------------------
  ; user file extension is specified
  ; --------------------------------
    fn szCmp,upatn,pbuf
    test eax, eax
    jz @F
    invoke GetCurrentDirectory,260,pdir
    print pdir,"\"
    print pfilename,13,10                   ; display the lower case name

  @@:
    ret

cb_file_tree endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start