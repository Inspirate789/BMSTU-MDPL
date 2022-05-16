; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
    include \masm32\include\masm32rt.inc
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

comment * -----------------------------------------------------
                        Build this  template with
                       "CONSOLE ASSEMBLE AND LINK"
        ----------------------------------------------------- *

  ; ------------------------------------------------------------------
  ; Feeling left out of it because you cannot produce bloated garbage
  ; like most compilers do ? Here is a simple solution so you can
  ; compete with the bloated size of compiler output, the BLOAT macro.
  ; Use this macro and you can tell your friends that you have learnt
  ; to write code like C++, Delphi or any other visual garbage generator
  ; ------------------------------------------------------------------

    bloat MACRO lang
      LOCAL cntr
      IFIDN <lang>,<CPP>
        echo Emulating C++
        cntr = 50000
      ELSEIFIDN <lang>,<DELPHI>
        echo Emulating Delphi
        cntr = 50000
      ELSEIFIDN <lang>,<C>
        echo Emulating C with standard runtime libraries
        cntr = 25000
      ELSEIFIDN <lang>,<PASCAL>
        echo Emulating procedural Pascal
        cntr = 20000
      ELSEIFIDN <lang>,<BASIC>
        echo Emulating procedural Basic
        cntr = 5000
      ELSEIFIDN <lang>,<CNRT>
        echo Emulating C without the runtime library
        cntr = 1000
      ELSEIFIDN <lang>,<ASM>
        EXITM
      ELSE
        echo "Please wait, this OP is slow"
        cntr = 100000
      ENDIF
      
      REPEAT cntr
        nop
      ENDM
      align 16
    ENDM

    .code

start:

    bloat CNRT
   
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    call main
    inkey
    exit

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

main proc

    cls
    print "Hello World",13,10

    ret

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start
