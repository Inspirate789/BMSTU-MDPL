; «««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««
    include \masm32\include\masm32rt.inc
; «««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««

comment * -----------------------------------------------------
                        Build this  template with
                       "CONSOLE ASSEMBLE AND LINK"

        SHUFFLE ARRAY

        SA.EXE is a tool designed to shuffle lines in text files
        to produce a random order in the lines of text. Uses
        range fom a simple task of randomising sorted text data
        for placement in a tree structure to produce balanced
        trees up to a more complex idea of randomising the lines
        in the include file in the source code for an application
        so that each time the application is built the binary
        image is different.

        NOTE : This example shuffles the lines of text 100 times
        to test its speed, you can easily change the shuffle
        count to a much lower number with no effective loss of
        random line arrangement.

        ----------------------------------------------------- *

    shuffle_array PROTO :DWORD,:DWORD

    .code

start:
   
; «««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««

    call main
    exit

; «««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««

main proc

    LOCAL hMem  :DWORD      ; memory the source file is loaded into
    LOCAL flen  :DWORD      ; the length of the source file
    LOCAL parr  :DWORD      ; the array memory handle that "ltok" writes to
    LOCAL lcnt  :DWORD      ; the returned line count from "ltok"
    LOCAL hFile :DWORD      ; the output file handle
    LOCAL pinp  :DWORD      ; input filename pointer
    LOCAL pout  :DWORD      ; output filename pointer
    LOCAL buffer1[260]:BYTE ; input filename buffer
    LOCAL buffer2[260]:BYTE ; output filename buffer

    mov pinp, ptr$(buffer1) ; load pointer to input filename buffer
    mov pout, ptr$(buffer2) ; load pointer to output filename buffer

  ; ---------------------------------------------------------
  ; get the command line 1st argument and test if file exists
  ; ---------------------------------------------------------
    invoke GetCL,1,pinp
    invoke exist,pinp
    test eax, eax
    jne @F
    print "cannot find source file",13,10
    call help
    ret
  @@:

  ; ------------------------------------------
  ; test if target file name string is present
  ; ------------------------------------------
    invoke GetCL,2,pout
    cmp eax, 1
    je @F
    print "No target file name supplied",13,10
    call help
    ret
  @@:

  ; --------------------------------
  ; load the source file into memory
  ; --------------------------------
    mov hMem, InputFile(pinp)
    mov flen, ecx

    print "SA (Shuffle text file Array) Copyright (c) The MASM32 project 1998-2006",13,10,13,10

    print "Loading "
    print pinp," at "
    print str$(flen)," bytes",13,10

  ; ------------------------------------------
  ; tokenise the source into an array of lines
  ; ------------------------------------------
    mov lcnt, rv(ltok,hMem,ADDR parr)

    push esi
    push edi

    invoke nseed, rv(GetTickCount)          ; seed the random number generator

  ; ------------------------
  ; random shuffle the lines
  ; ------------------------
    print "Shuffling lines in source file 100 times",13,10
    mov esi, 100
  @@:
    invoke shuffle_array,parr,lcnt
    sub esi, 1
    jnz @B

  ; ----------------------
  ; create the output file
  ; ----------------------

    print "Writing output to "
    print pout,13,10

    mov hFile, fcreate(pout)

    mov esi, parr           ; load the array address into ESI
    mov edi, lcnt           ; copy the line count into EDI

  ; ------------------------------------------------------
  ; write each line of the shuffled array to the open file
  ; ------------------------------------------------------
  @@:
    fprint hFile,[esi]
    add esi, 4
    sub edi, 1
    jnz @B

    pop edi
    pop esi

  ; --------------
  ; close the file
  ; --------------
    fclose hFile

    print str$(lcnt), " shuffled lines written to "
    print pout,13,10

    free parr               ; free the pointer array memory
    free hMem               ; free the source memory

    ret

main endp

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

shuffle_array proc arr:DWORD,cnt:DWORD

    LOCAL lcnt  :DWORD

    mov eax, cnt            ; copy cnt to lcnt
    mov lcnt, eax

    push ebx
    push esi
    push edi

    mov esi, arr
    mov edi, arr
    xor ebx, ebx

  @@:
    invoke nrandom, cnt     ; get the random number within "cnt" range
    mov ecx, [esi+ebx*4]    ; get the incremental pointer
    mov edx, [edi+eax*4]    ; get the random pointer
    mov [esi+ebx*4], edx    ; write random pointer back to incremental location
    mov [edi+eax*4], ecx    ; write incremental pointer back to random location
    add ebx, 1              ; increment the original pointer
    sub lcnt, 1             ; decrement the loop counter
    jnz @B

    pop edi
    pop esi
    pop ebx

    ret

shuffle_array endp

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

help proc

    print "SA (Shuffle text file Array) Copyright (c) The MASM32 project 1998-2006",13,10,13,10
    print "    Arg1    : name of source text file to randomise",13,10
    print "    Arg2    : target file name to write to disk",13,10
    print "    example : sa sourcefile.ext targetfile.ext",13,10

    ret

help endp

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

end start
