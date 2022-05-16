; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
    include \masm32\include\masm32rt.inc
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

comment * -----------------------------------------------------
                        Build this  template with
                       "CONSOLE ASSEMBLE AND LINK"

        The original design for this example was written by
        "c0d1f1ed" in Microsoft C++.

        It has been ported to MASM with a number of corrections
        and has been simplified to test on 1, 2 and 4 core
        processors. It is also one tenth of the size as is
        consistent with pure assembler programming.

        The design is to sequentially start 1 2 and 4 thread
        without using leading or interactive operating system
        thread synchronisation methods which removes a major
        timing delay and it uses an operating system
        synchronisation method on thread exit so the results
        can be displayed when all threads have terminated.

        On a single core machine the results of the two and four
        thread tests should be two and 4 times longer.

        On a dual core machine the two thread test should run in
        much the same time as the single thread test and the four
        thread test should be two times longer.

        On a quad core machine all three tests should have a
        similar timing.

        ----------------------------------------------------- *

    test_thread PROTO :DWORD

    .data?
      thread1 dd ?
      thread2 dd ?
      thread3 dd ?
      thread4 dd ?

    .data
      objcnt2 dd 0,0
      objcnt4 dd 0,0,0,0

    .code

start:
   
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    call main
    inkey
    exit

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

main proc

    LOCAL var   :DWORD

    push esi

  ; --------------------
  ; single thread timing
  ; --------------------

    print "===========================================",13,10
    print "Run a single thread on fixed test procedure",13,10
    print "===========================================",13,10

    invoke GetTickCount
    push eax

    invoke test_thread,0

    invoke GetTickCount
    pop ecx
    sub eax, ecx

    print str$(eax)," MS Single thread timing",13,10,13,10

    invoke SleepEx,500,0

  ; *******************************

    print "=======================================",13,10
    print "Run two threads on fixed test procedure",13,10
    print "=======================================",13,10

    invoke GetTickCount
    push eax

    mov esi, OFFSET objcnt2

    invoke CreateEvent,0,FALSE,FALSE,0
    mov [esi], eax
    invoke CreateEvent,0,FALSE,FALSE,0
    mov [esi+4], eax

    mov thread1, rv(CreateThread,NULL,NULL,ADDR test_thread,[esi],NULL,ADDR var)
    mov thread2, rv(CreateThread,NULL,NULL,ADDR test_thread,[esi+4],NULL,ADDR var)

  ; ------------------------------
  ; synchronise thread termination
  ; ------------------------------
    invoke WaitForMultipleObjects,2,OFFSET objcnt2,TRUE,INFINITE

    invoke CloseHandle,[esi]
    invoke CloseHandle,[esi+4]

    invoke CloseHandle,thread1
    invoke CloseHandle,thread2

    invoke GetTickCount
    pop ecx
    sub eax, ecx

    print str$(eax)," MS Two thread timing",13,10,13,10

    invoke SleepEx,500,0

  ; *******************************

    print "========================================",13,10
    print "Run four threads on fixed test procedure",13,10
    print "========================================",13,10

    invoke GetTickCount
    push eax

    mov esi, OFFSET objcnt4

    invoke CreateEvent,0,FALSE,FALSE,0
    mov [esi], eax
    invoke CreateEvent,0,FALSE,FALSE,0
    mov [esi+4], eax
    invoke CreateEvent,0,FALSE,FALSE,0
    mov [esi+8], eax
    invoke CreateEvent,0,FALSE,FALSE,0
    mov [esi+12], eax

    mov thread1, rv(CreateThread,NULL,NULL,ADDR test_thread,[esi],NULL,ADDR var)
    mov thread2, rv(CreateThread,NULL,NULL,ADDR test_thread,[esi+4],NULL,ADDR var)
    mov thread3, rv(CreateThread,NULL,NULL,ADDR test_thread,[esi+8],NULL,ADDR var)
    mov thread4, rv(CreateThread,NULL,NULL,ADDR test_thread,[esi+12],NULL,ADDR var)

  ; ------------------------------
  ; synchronise thread termination
  ; ------------------------------
    invoke WaitForMultipleObjects,4,OFFSET objcnt4,TRUE,INFINITE

    invoke CloseHandle,[esi]
    invoke CloseHandle,[esi+4]
    invoke CloseHandle,[esi+8]
    invoke CloseHandle,[esi+12]

    invoke CloseHandle,thread1
    invoke CloseHandle,thread2
    invoke CloseHandle,thread3
    invoke CloseHandle,thread4

    invoke GetTickCount
    pop ecx
    sub eax, ecx

    print str$(eax)," MS Four thread timing",13,10,13,10

  ; *******************************

    pop esi

    ret

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

test_thread proc nThread:DWORD

    LOCAL var   :DWORD

    mov var, 12345678

    push esi
    mov esi, 4000000000

  align 16
  @@:
    mov eax, var
    mov ecx, var
    mov edx, var
    sub esi, 1
    jnz @B

    pop esi

    invoke SetEvent,nThread

    ret

test_thread endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start
