; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
    include \masm32\include\masm32rt.inc
    .686
    include \masm32\macros\timers.asm
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
    .data
      str1 db "This example compares the cycle counts, including the call "
           db "overhead, for the CRT strlen function and the MASM32 StrLen "
           db "proc.",0
    .code
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
start:
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
    invoke Sleep, 3000

    counter_begin 1000, HIGH_PRIORITY_CLASS
      invoke crt_strlen, ADDR str1
    counter_end
    print ustr$(eax)," cycles, strlen",13,10

    counter_begin 1000, HIGH_PRIORITY_CLASS
      invoke StrLen, ADDR str1
    counter_end
    print ustr$(eax)," cycles, StrLen",13,10,13,10

    inkey "Press any key to exit..."
    exit
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
end start
