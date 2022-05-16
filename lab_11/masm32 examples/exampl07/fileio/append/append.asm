; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
    include \masm32\include\masm32rt.inc
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

comment * -----------------------------------------------------
                        Build this  template with
                       "CONSOLE ASSEMBLE AND LINK"
        ----------------------------------------------------- *

    .code

start:
   
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    call main

    exit

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

main proc

    LOCAL cloc  :DWORD
    LOCAL wcnt  :DWORD
    LOCAL fname :DWORD
    LOCAL txt   :DWORD
    LOCAL hFile :DWORD

    sas fname,"MyFile.txt"              ; assign strings to local variables
    sas txt,"1234567890"

    push esi
    mov esi, 50                         ; use ESI as a loop counter

    .if rv(exist,fname) != 0            ; test if file exists
      mov hFile, fopen(fname)           ; open it if it does
    .else
      mov hFile, fcreate(fname)         ; otherwise create a new file
    .endif

    mov cloc, fseek(hFile,0,FILE_END)   ; set the file pointer to the end

  @@:
    fprint hFile,txt
    sub esi, 1
    jnz @B

    fclose hFile

    pop esi
    ret

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start
