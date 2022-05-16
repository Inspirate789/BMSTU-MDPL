; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
    include \masm32\include\masm32rt.inc
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

comment * -----------------------------------------------------
                        Build this  template with
                       "CONSOLE ASSEMBLE AND LINK"

        High precision intervals using a multimedia timer
        =================================================

        ----------------------------------------------------- *

  ; --------------------------------------
  ; include the Windows multimedia library
  ; --------------------------------------
    include \masm32\include\winmm.inc
    includelib \masm32\lib\winmm.lib

    .data?
      reference dd ?
      iteration dd ?
      interval  dd ?

    .code

start:
   
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    call main
    inkey
    exit

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

main proc

    cls

    mov interval, 5                 ; set the timer interval here in milliseconds

    push esi

    invoke timeBeginPeriod,1        ; set resolution to 1

    mov esi, 1000

    mov reference, rv(timeGetTime)

  @@:
    mov iteration, rv(timeGetTime)  ; get the current time
    sub eax, reference              ; subtract the reference from it
    print str$(eax),13,10           ; output the duration diference here
    mov eax, interval
    add iteration, eax              ; add the required interval to "iteration"
    sub eax, 1
    invoke SleepEx,eax,0            ; yield to the OS for almost the entire interval
    call spinlock                   ; call the spinlock proc to finally trim the time
    sub esi, 1
    jnz @B

    invoke timeEndPeriod,1

    pop esi

    ret

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

  spinlock:
    invoke timeGetTime              ; keep testing current time until it
    .if eax < iteration             ; matches "iteration"
      jmp spinlock
    .endif
    retn

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start
