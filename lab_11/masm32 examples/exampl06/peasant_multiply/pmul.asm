IF 0  ; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
                      Build this template with "CONSOLE ASSEMBLE AND LINK"
ENDIF ; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    include \masm32\include\masm32rt.inc

    peasant_multiply PROTO :DWORD,:DWORD

    .code

start:
   
; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    call main
    inkey
    exit

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

main proc

    invoke peasant_multiply,65536,16
    print ustr$(eax),13,10

    invoke peasant_multiply,9,9
    print ustr$(eax),13,10

    invoke peasant_multiply,1024,16
    print ustr$(eax),13,10

    invoke peasant_multiply,13,59
    print ustr$(eax),13,10

    invoke peasant_multiply,1024,65536*16
    print ustr$(eax),13,10,13,10

    print "benchmarking and testing algorithm on (1024*1024*1024) iterations",13,10

    push ebx
    push esi
    push edi

    invoke GetTickCount
    mov ebx, eax

    mov esi, 1024*1024*1024
    mov edi, 2

  lbl0:
    invoke peasant_multiply,esi,edi
    push eax

    invoke IntMul,esi,edi

  ; ------------------------------------------------
  ; test if the two methods deliver the same results
  ; ------------------------------------------------
    pop ecx
    cmp eax, ecx
    je @F

    print str$(eax)," -- "
    print str$(ecx),13,10

  @@:
  ; ------------------------------------------------


    sub esi, 1
    jnz lbl0
  
    invoke GetTickCount
    sub eax, ebx

    print str$(eax),13,10

  quit:
    pop edi
    pop esi
    pop ebx

    ret

main endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

OPTION PROLOGUE:NONE
OPTION EPILOGUE:NONE

peasant_multiply proc arg1:DWORD,arg2:DWORD

    mov ecx, [esp+4]        ; arg1           ; load 1st arg into ECX
    mov edx, [esp+8]        ; arg2           ; load 2nd arg into EDX
    xor eax, eax            ; zero EAX
    jmp testit              ; jump to test if arg2 is ODD or EVEN

  lbl0:
    add ecx, ecx            ; double arg1
    shr edx, 1              ; div arg2 by 2
    cmp edx, 1              ; compare it to 1
    jbe lbl1                ; exit loop if below or equal

  testit:
    test edx, 00000000000000000000000000000001b
    je lbl0                 ; jump back if its even

    add eax, ecx            ; accumulate ECX in EAX if EDX is odd
    jmp lbl0

  lbl1:
    add eax, ecx            ; add last ECX to EAX and exit

    ret 8

peasant_multiply endp

OPTION PROLOGUE:PrologueDef
OPTION EPILOGUE:EpilogueDef

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

end start
