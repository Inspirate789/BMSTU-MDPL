; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
    include \masm32\include\masm32rt.inc
    include \masm32\include\urlmon.inc
    includelib \masm32\lib\urlmon.lib
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

comment * -----------------------------------------------------
                        Build this  template with
                       "CONSOLE ASSEMBLE AND LINK"
        ----------------------------------------------------- *

    start_new_thread PROTO :DWORD, :DWORD
    new_thread       PROTO :DWORD

    tblock STRUCT
      strn1 db 260 dup (?)
      strn2 db 260 dup (?)
      reserved dd ?             ; this is used internally
      thcount  dd ?             ; thread counter
    tblock ENDS

    .code

start:
   
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    call main
    inkey
    exit

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

main proc

    LOCAL tblk:tblock

    mov tblk.thcount, 0     ; set counter to zero.

    cst ADDR tblk.strn1, "http://www.masm32.com/website/files/nre.zip"
    cst ADDR tblk.strn2, "nre.zip"
    invoke start_new_thread,OFFSET new_thread, ADDR tblk

    cst ADDR tblk.strn1, "http://www.masm32.com/website/files/owde.zip"
    cst ADDR tblk.strn2, "owde.zip"
    invoke start_new_thread,OFFSET new_thread, ADDR tblk

    cst ADDR tblk.strn1, "http://www.masm32.com/website/files/pfe101i.zip"
    cst ADDR tblk.strn2, "pfe101i.zip"
    invoke start_new_thread,OFFSET new_thread, ADDR tblk

    cst ADDR tblk.strn1, "http://www.masm32.com/website/files/random.zip"
    cst ADDR tblk.strn2, "random.zip"
    invoke start_new_thread,OFFSET new_thread, ADDR tblk

    cst ADDR tblk.strn1, "http://www.masm32.com/website/files/td_win32asm_all.zip"
    cst ADDR tblk.strn2, "td_win32asm_all.zip"
    invoke start_new_thread,OFFSET new_thread, ADDR tblk

  ; ---------------------------------
  ; wait until all threads are closed
  ; ---------------------------------
  spinlock:
    invoke SleepEx,1,0
    cmp tblk.thcount, 0
    jnz spinlock

    ret

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

start_new_thread proc pthread:DWORD, pstruct:DWORD

    LOCAL tID       :DWORD

    push esi

  ; -----------------------------------------
  ; load the "reserved" flag address into ESI
  ; -----------------------------------------
    mov eax, pstruct
    lea esi, (tblock PTR [eax]).reserved

  ; ----------------------------
  ; set the "reserved" flag to 1
  ; ----------------------------
    mov DWORD PTR [esi], 1

    invoke CreateThread,0,0,pthread,pstruct,0,ADDR tID

  ; ------------------------------------
  ; run a yielding loop until new thread
  ; sets "reserved" flag back to zero
  ; ------------------------------------
  spinlock:
    invoke SleepEx,1,0
    cmp DWORD PTR [esi], 0
    jne spinlock

    pop esi

    mov eax, tID
    ret

start_new_thread endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

new_thread proc pstruct:DWORD

    LOCAL pst1  :DWORD
    LOCAL pst2  :DWORD
    LOCAL flen  :DWORD
    LOCAL buffer1[260]:BYTE
    LOCAL buffer2[260]:BYTE

    mov pst1, ptr$(buffer1)
    mov pst2, ptr$(buffer2)

    push esi
    push edi

  ; *****************************************************
  ; copy arguments passed in structure to local variables
  ; *****************************************************
    mov edi, pstruct
    lea esi, (tblock PTR [edi]).reserved

  ; ----------------------------------
  ; copy each string to a local buffer
  ; ----------------------------------
    lea ecx, (tblock PTR [edi]).strn1
    cst pst1, ecx
    lea ecx, (tblock PTR [edi]).strn2
    cst pst2, ecx

  ; ---------------------------------
  ; reset the "reserved" flag back to
  ; zero to unlock calling thread
  ; ---------------------------------
    mov DWORD PTR [esi], 0
  ; *****************************************************

  ; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ; perform normal thread operations once the arguments have been written.
  ; - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    add (tblock PTR [edi]).thcount, 1       ; increment thread counter on start

    print "Downloading "
    print pst2,13,10

    fn URLDownloadToFile,0,pst1,pst2,0,0

    invoke filesize,pst2
    mov flen, eax

    print pst2," Downloaded at "
    print str$(flen)," bytes",13,10

    sub (tblock PTR [edi]).thcount, 1       ; decrement thread counter on exit

    pop edi
    pop esi

    ret

new_thread endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start
