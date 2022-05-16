IF 0  ; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
                       Build this template with "CONSOLE ASSEMBLE AND LINK"
                    "switch$" and "switchi$" macros in both ASCII and UNICODE.
ENDIF ; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    __UNICODE__ equ 1

    include \masm32\include\masm32rt.inc

    .data?
      value dd ?

    .data
      item dd 0

    .code

start:
   
; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    call main
    inkey
    exit

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

main proc

    LOCAL str1  :DWORD
    LOCAL str2  :DWORD

    mov str1, chr$("one")

  ; ---------------------------
  ; case sensitive switch block
  ; ---------------------------
    switch$ str1
      case$ "zero"
        print "zero",13,10
      case$ "one"
        print "one",13,10
      case$ "two"
        print "two",13,10
      case$ "three"
        print "three",13,10
      else$
        print "None of the above",13,10
    endsw$

    mov str2, chr$("ThReE")

  ; -----------------------------
  ; case insensitive switch block
  ; -----------------------------
    switchi$ str2
      casei$ "zero"
        print "zero",13,10
      casei$ "one"
        print "one",13,10
      casei$ "two"
        print "two",13,10
      casei$ "three"
        print "three",13,10
      elsei$
        print "None of the above",13,10
    endswi$

    ret

main endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

end start
