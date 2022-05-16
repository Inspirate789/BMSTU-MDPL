; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
    include \masm32\include\masm32rt.inc
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

comment * -----------------------------------------------------
                        Build this  template with
                       "CONSOLE ASSEMBLE AND LINK"

        This example shows how to use the preprocessor code
        (macros) supplied with the latest service pack for
        MASM32 for file IO code.
        ----------------------------------------------------- *

    .code

start:
   
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    call main
    inkey
    exit

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

main proc

    LOCAL hFile :DWORD                          ; file handle
    LOCAL bwrt  :DWORD                          ; variable for bytes written
    LOCAL cloc  :DWORD                          ; current location variable
    LOCAL txt   :DWORD                          ; text handle
    LOCAL flen  :DWORD                          ; file length variable
    LOCAL hMem  :DWORD                          ; allocated memory handle

    sas txt,"Test String"                       ; assign string to local variable

    .if rv(exist,"testfile.txt") != 0           ; if file already exists
      test fdelete("testfile.txt"), eax         ; delete it
    .endif

  ; ----------------------------------
  ; create a file and write data to it
  ; ----------------------------------
    mov hFile, fcreate("testfile.txt")          ; create the file
    mov bwrt, fwrite(hFile,txt,len(txt))        ; write data to it
    fclose hFile                                ; close the file

  ; -------------------------------------
  ; reopen the file and append data to it
  ; -------------------------------------
    mov hFile, fopen("testfile.txt")            ; open the existing file
    mov cloc, fseek(hFile,0,FILE_END)           ; set the file pointer to the end
    fprint hFile," Additional data appended"    ; append text to existing data
    fclose hFile                                ; close the file

  ; -------------------------------------------------
  ; open the file again, read and display its content
  ; -------------------------------------------------
    mov hFile, fopen("testfile.txt")            ; open the existing file again
    mov flen, fsize(hFile)                      ; get its length
    mov hMem, alloc(flen)                       ; allocate a buffer of that size
    mov bwrt, fread(hFile,hMem,flen)            ; read data from file into buffer
    fclose hFile                                ; close the file

    invoke StripLF,hMem

    print hMem,13,10                            ; display text to console

    free hMem                                   ; free the allocated memory

    ret

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start
