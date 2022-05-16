; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;
;   This example shows why the xchg reg,[mem] and xchg [mem],reg
;   instructions should be avoided in code where speed matters.
;
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
    include \masm32\include\masm32rt.inc
    .686
    include \masm32\macros\timers.asm
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
    .data
      mem dd 0
    .code
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
start:
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
    invoke Sleep, 3000

    counter_begin 1000, HIGH_PRIORITY_CLASS
      lea ebx, mem
      REPEAT 100
        xchg ecx, edx
      ENDM
    counter_end
    print ustr$(eax)," cycles, (xchg reg,reg)*100",13,10

    counter_begin 1000, HIGH_PRIORITY_CLASS
      lea ebx, mem
      REPEAT 100
        xchg edx, [ebx]
      ENDM
    counter_end
    print ustr$(eax)," cycles, (xchg reg,mem)*100",13,10

    counter_begin 1000, HIGH_PRIORITY_CLASS
      lea ebx, mem
      REPEAT 100
        xchg [ebx], edx
      ENDM
    counter_end
    print ustr$(eax)," cycles, (xchg mem,reg)*100",13,10

    counter_begin 1000, HIGH_PRIORITY_CLASS
      lea ebx, mem
      REPEAT 100
        mov eax, edx
        mov edx, ecx
        mov ecx, eax
      ENDM
    counter_end
    print ustr$(eax)," cycles, (exchange reg,reg)*100 using mov",13,10

    counter_begin 1000, HIGH_PRIORITY_CLASS
      lea ebx, mem
      REPEAT 100
        mov eax, [ebx]
        mov [ebx], edx
        mov edx, eax
      ENDM
    counter_end
    print ustr$(eax)," cycles, (exchange reg,mem)*100 using mov",13,10,13,10

    inkey "Press any key to exit..."
    exit
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
end start
