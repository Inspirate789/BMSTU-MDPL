; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;
;   This example shows the effect of unrolling a loop on the loop
;   cycle count. The optimal unroll factor will depend on the loop
;   code and the processor it is running on.
;
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
    include \masm32\include\masm32rt.inc
    .686
    include \masm32\macros\timers.asm
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
    .data
    .code
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
start:
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
    MOVE_COUNT EQU 800h           ; =2048

    mov edi, halloc(MOVE_COUNT*4)

    invoke Sleep, 3000

    FOR unroll_factor,<1,2,4,8,16,32,64,128,256>

      counter_begin 1000, HIGH_PRIORITY_CLASS
          xor eax, eax
          xor edx, edx
          mov ecx, MOVE_COUNT/unroll_factor
        @@:
          N=0
          REPEAT unroll_factor
            mov [edi+edx+N], eax
            N=N+4
          ENDM
          add edx, unroll_factor*4
          dec ecx
          jnz @B
      counter_end
      print ustr$(eax)," cycles, unrolled by "
      print ustr$(unroll_factor),13,10

    ENDM

    print chr$(13,10)

    hfree edi

    inkey "Press any key to exit..."
    exit
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
end start

In case it is not clear what the statements in the FOR loop between the
counter_begin and counter_end macro calls do, for an unroll factor of 4
this is the generated code:

004012A0 33C0                   xor     eax,eax
004012A2 33D2                   xor     edx,edx
004012A4 B900020000             mov     ecx,200h
004012A9                    loc_004012A9:
004012A9 89043A                 mov     [edx+edi],eax
004012AC 89443A04               mov     [edx+edi+4],eax
004012B0 89443A08               mov     [edx+edi+8],eax
004012B4 89443A0C               mov     [edx+edi+0Ch],eax
004012B8 83C210                 add     edx,10h
004012BB 49                     dec     ecx
004012BC 75EB                   jnz     loc_004012A9
