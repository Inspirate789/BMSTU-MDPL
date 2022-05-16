; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
    include \masm32\include\masm32rt.inc
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

comment * -----------------------------------------------------
                        Build this  template with
                       "CONSOLE ASSEMBLE AND LINK"
        ----------------------------------------------------- *

    bubble_sort PROTO :DWORD,:DWORD

    printarr MACRO parr,cnt
      LOCAL lbl
      push ebx
      push esi
      mov esi, parr
      mov ebx, cnt
    lbl:
      print str$([esi]),13,10
      add esi, 4
      sub ebx, 1
      jnz lbl
      pop esi
      pop ebx
    ENDM

    .data?
      value dd ?

    .data
      narr dd 1,9,2,8,3,7,4,6,5,0   ; 10 unsorted numbers

    .code

start:
   
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    call main
    inkey
    exit

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

main proc

    print "Unsorted",13,10

    printarr OFFSET narr,LENGTHOF narr

    invoke bubble_sort,OFFSET narr,LENGTHOF narr

    print chr$(13,10)
    print "Sorted",13,10

    printarr OFFSET narr,LENGTHOF narr

    ret

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

bubble_sort proc parr:DWORD,cnt:DWORD

    push ebx
    push esi

    sub cnt, 1                  ; set count to 1 less than member count

  lbl0:
    mov esi, parr               ; load array address into ESI
    xor edx, edx                ; zero the "changed" flag
    mov ebx, cnt                ; set the loop counter to member count

  lbl1:
    mov eax, [esi]              ; load first pair of array numbers into registers
    mov ecx, [esi+4]
    cmp eax, ecx                ; compare which is higher
    jl lbl2                     

    mov [esi], ecx              ; swap if 1st number is higher
    mov [esi+4], eax
    mov edx, 1                  ; set the changed flag if any swap is performed

  lbl2:
    add esi, 4                  ; step up one to compare next adjoining pair
    sub ebx, 1                  ; decrement the counter
    jnz lbl1

    test edx, edx               ; test if the changed flag is set.
    jnz lbl0                    ; loop back if it is

    pop esi
    pop ebx

    ret

bubble_sort endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start
