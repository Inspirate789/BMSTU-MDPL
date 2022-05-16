; «««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
    include \masm32\include\masm32rt.inc
; «««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««

comment * -----------------------------------------------------
                        Build this  template with
                       "CONSOLE ASSEMBLE AND LINK"

                An algorithm to convert text with standard
                control characters into C style escapes.
        ----------------------------------------------------- *

    escmake PROTO :DWORD,:DWORD

    .data
      txt db "		Hello,",13,10,'		"World"',13,10,0

    .code

start:
   
; «««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««

    call main
    inkey
    exit

; «««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««

main proc

    LOCAL slen  :DWORD
    LOCAL blen  :DWORD
    LOCAL pmem  :DWORD

    mov slen, LENGTHOF txt

    mov eax, slen
    add eax, eax
    mov blen, eax

    mov pmem, alloc(blen)

    print "Before",13,10,"--------------------",13,10

    print OFFSET txt

    invoke escmake,OFFSET txt,pmem

    print "After",13,10,"--------------------",13,10,34

    print pmem,34,13,10

    free pmem

    ret

main endp

; ¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤

align 4

escmake proc src:DWORD,dst:DWORD

comment @ ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
        convert a string to ANSI C escapes.
        ----------------------------------
        Note: output buffer (dst) must be large
        enough to hold the longer string data.
        At most the converted string can be twice as long
        so allocating double the source length is safe.
        ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤ @

    mov ecx, src
    mov edx, dst
    sub ecx, 1

  lbl0:
    add ecx, 1
    movzx eax, BYTE PTR [ecx]

    cmp al, 9   ; ------------------------ TAB
    jne @F
    mov WORD PTR [edx], "t\"                ; note the reverse order
    add edx, 2
    jmp lbl0
  @@:
    cmp al, 10  ; ------------------------ line feed
    jne @F
    mov WORD PTR [edx], "n\"                ; note the reverse order
    add edx, 2
    jmp lbl0
  @@:
    cmp al, 13  ; ------------------------ carriage return
    jne @F
    mov WORD PTR [edx], "r\"                ; note the reverse order
    add edx, 2
    jmp lbl0
  @@:
    cmp al, 34  ; ------------------------ double quote
    jne @F
    mov WORD PTR [edx], '"\'                ; note the reverse order
    add edx, 2
    jmp lbl0
  @@:
    cmp al, 39  ; ------------------------ single quote
    jne @F
    mov WORD PTR [edx], "'\"                ; note the reverse order
    add edx, 2
    jmp lbl0
  @@:
    cmp al, 92  ; ------------------------ backslash
    jne @F
    mov WORD PTR [edx], "\\"                ; note the reverse order
    add edx, 2
    jmp lbl0
  @@:

    mov [edx], al
    add edx, 1
    test al, al
    jnz lbl0

    ret

escmake endp

; ¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤÷¤

end start


























