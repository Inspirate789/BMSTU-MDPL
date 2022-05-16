; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
    include \masm32\include\masm32rt.inc
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

comment * -----------------------------------------------------
                        Build this  template with
                       "CONSOLE ASSEMBLE AND LINK"
        ----------------------------------------------------- *

    wsptrim PROTO :DWORD

    .code

start:
   
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    call main
    inkey
    exit

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

main proc

    LOCAL tststr    :DWORD

    sas tststr,"    this  	  is  	    a  	  test		     "

    print tststr,13,10

    print rv(wsptrim,tststr),13,10

    ret

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

OPTION PROLOGUE:NONE 
OPTION EPILOGUE:NONE 

align 4

wsptrim proc src:DWORD

  ; ---------------------------------------------------------------
  ; remove any white space duplicates and substitute a single space
  ; ---------------------------------------------------------------
    mov ecx, [esp+4]
    xor eax, eax
    sub ecx, 1
    mov edx, [esp+4]

  align 4
  stlp:
    add ecx, 1
    mov al, [ecx]
    cmp al, 9
    jne @F
    mov al, 32                      ; replace tabs with spaces
  @@:
    cmp al, 32
    jne @F
    cmp BYTE PTR [ecx+1], 32        ; test for next space
    je overit
    cmp BYTE PTR [ecx+1], 9         ; test for next tab
    je overit
  @@:
    mov [edx], al
    add edx, 1
  overit:
    test al, al                     ; test for zero AFTER its written.
    jnz stlp

    mov eax, [esp+4]

    ret 4

wsptrim endp

OPTION PROLOGUE:PrologueDef 
OPTION EPILOGUE:EpilogueDef 

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start
