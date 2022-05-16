; thanks to Scali .. he helped optimizing this

.386
.model flat, stdcall
option casemap:none

include     \masm32\include\windows.inc
include     \masm32\include\kernel32.inc
include     \masm32\include\user32.inc
includelib  \masm32\lib\kernel32.lib
includelib  \masm32\lib\user32.lib

inv     equ invoke

.data
hFile       dd  0
BW          dd  0
ofstruct    OFSTRUCT <>

szPrime     db  "%lu, ", 0
szCaption   db  "Done!", 0
szDone      db  "Done! The number of primes found is: %lu", 13, 10, \
                "Wrote primes to "
szFile      db  "PRIMES.TXT", 0

.data?
buffer      dw  0ffffh  dup (?)
szTemp      db  80 dup (?)

.code
start:

    mov     ecx, 0ffffh / 2         ; counter
    mov     edi, offset buffer      ; here: offset for where to put the numbers
    mov     eax, 00030002h          ; write 2 numbers at one time
    mov     esi, edi                ; where to read the numbers from (for the next step)
createbuffer_loop:
    mov     [edi], eax              ; put 2 numbers into the buffer
    add     eax, 00020002h          ; increase the number that gets put in the buffer
    add     edi, 4                  ; adjust the buffer pointer
    dec     ecx                     ; decrease the counter
    jnz     createbuffer_loop       ; counter <> zero? then do the whole thing again


    mov     edi, esi                ; now restore edi for later
    mov     ecx, 0ffffh / 2         ; counter
    xor     ebx, ebx                ; ebx will hold the number of primes
    xor     edx, edx                ; clear high part of edx, because it will be used as pointer
findprime_loop:
    mov     ax, [esi]               ; get the first word from the buffer
    add     esi, 2                  ; adjust the buffer pointer
    test    ax, ax                  ; ax == zero?
    jz      no_prime                ; then this is already a killed number

    inc     ebx                     ; we are here so this is a prime. increase the prime counter

    mov     dx, ax                  ; put the prime into dx
eliminatenonprime_loop:
    add     dx, ax                  ; now add the prime to the prime (prime*2, later prime*3 ..)
    jc      no_prime                ; if dx now grew over 0ffffh, there's nothing left to kill
    mov     word ptr [edx*2+buffer-4], 0    ; kill non-primes by marking them with zero
    jmp     eliminatenonprime_loop  ; jump back, till dx > 0ffffh

no_prime:
    dec     ecx                     ; decrease the counter
    jnz     findprime_loop          ; counter <> zero? then do it again


    push    ebx                     ; because some APIs change ebx, we have to save it on the stack
    inv     OpenFile, offset szFile, offset ofstruct, OF_CREATE     ; create new file
    mov     hFile, eax              ; save its handle
    mov     cx, 0ffffh              ; put counter to 0ffffh
    xor     eax, eax                ; clear high parts of eax.
write:
    push    cx                      ; save cx on the stack, because one of these APIs will change it
    mov     ax, [edi]               ; normally I'd use esi here, but I restored edi in the beginning
    add     edi, 2                  ; adjust ...
    test    ax, ax                  ; ax == zero?
    jz      skip_write              ; yes? so this is a killed number. do nothing
    inv     wsprintf, offset szTemp, offset szPrime, eax        ; else convert number to ASCII
    inv     WriteFile, hFile, offset szTemp, eax, offset BW, NULL   ; and write it to the file
skip_write:
    pop     cx                      ; restore the counter
    dec     cx                      ; and decrease it
    jnz     write                   ; zero? if not, then go back again

    inv     CloseHandle, hFile      ; close the file

    pop     ebx                     ; pop the prime counter from the stack
    inv     wsprintf, offset szTemp, offset szDone, ebx
    inv     MessageBox, 0, offset szTemp, offset szCaption, MB_OK

    inv     ExitProcess, 0

end start