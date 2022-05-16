; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;
;   This example shows the effect of data alignment on the cycle counts
;   for reading and writing the data. The recommended alignment is the
;   power of 2 >= the operand size, 4 bytes for a DWORD.
;
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
    include \masm32\include\masm32rt.inc
    .686
    include \masm32\macros\timers.asm
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
    .data
      aligned     dd 100 dup(0)
      db 0
      misaligned1 dd 100 dup(0)
      db 0
      misaligned2 dd 100 dup(0)
      db 0
      misaligned3 dd 100 dup(0)
    .code
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
start:
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    print uhex$(OFFSET aligned),"h",13,10,13,10

    invoke Sleep, 3000

    FOR src,<aligned,misaligned1,misaligned2,misaligned3>

      counter_begin 1000, HIGH_PRIORITY_CLASS
        N=0
        REPEAT 100
          mov eax, src+N*4
          N=N+1
        ENDM
      counter_end
      print ustr$(eax)," cycles, (mov reg,mem)*100 &src",13,10

    ENDM

    print chr$(13,10)

    FOR dest,<aligned,misaligned1,misaligned2,misaligned3>

      counter_begin 1000, HIGH_PRIORITY_CLASS
        N=0
        REPEAT 100
          mov dest+N*4, eax
          N=N+1
        ENDM
      counter_end
      print ustr$(eax)," cycles, (mov mem,reg)*100 &dest",13,10

    ENDM

    print chr$(13,10)

    inkey "Press any key to exit..."
    exit
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
end start

In case it is not clear what the statements in the FOR loops between the
counter_begin and counter_end macro calls do, this is a sample of the
generated code from the first FOR loop for the aligned parameter:

00401090 A100404000             mov     eax,[404000h]
00401095 A104404000             mov     eax,[404004h]
0040109A A108404000             mov     eax,[404008h]
...
