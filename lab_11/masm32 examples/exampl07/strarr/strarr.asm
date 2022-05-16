; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
    include \masm32\include\masm32rt.inc
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

comment * -----------------------------------------------------

        Two methods of displaying seperate arguments, the
        1st as an argument list, the second as a string array.
        The first is more powerful and flexible, the second is
        simpler and faster.

        ----------------------------------------------------- *

    .data
    ; ------------------------------------
    ; simple space delimited argument list
    ; ------------------------------------
      sptext   db "arg1 arg2 arg3",0

    ; -------------------------
    ; seperate string arguments
    ; -------------------------
      string1  db "arg1",0
      string2  db "arg2",0
      string3  db "arg3",0

    ; --------------------------------------------
    ; create DWORD array of the 3 string arguments
    ; --------------------------------------------
      tarr dd string1,string2,string3

    .code

start:
   
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

main proc

    LOCAL ptxt  :DWORD              ; address of source text
    LOCAL parr  :DWORD              ; variable to use for array memory
    LOCAL acnt  :DWORD              ; array element counter
    LOCAL lcnt  :DWORD              ; loop counter

    push esi

  ; -------------------------------------------------------------
  ; METHOD 1  Tokenise the space delimited argument list into an
  ; array of pointers and loop through each argument in the list.
  ; -------------------------------------------------------------
    mov ptxt, OFFSET sptext         ; get the address of the text array
    invoke wtok,ptxt,ADDR parr      ; tokenise it writing an array of pointers
    mov lcnt, eax                   ; get the array member count
    mov esi, parr                   ; put the array address into ESI

  ; ----------------------------------------------------------------------
  ; NOTE that in both of the following loops the text data is
  ; accessed by "dereferencing" the address stored in the array.
  ; mov esi, parr   ; load the array address in ESI
  ; .......
  ; [esi] contains the start address of the text data in each array member
  ; add esi, 4      ; step up to the next array member address.
  ; ----------------------------------------------------------------------

  lbl0:
    fn MessageBox,0,[esi],"Method 1",MB_OK    ; call the message box
    add esi, 4                      ; increment ESI up to next array member address
    sub lcnt, 1                     ; decrement the loop counter
    jnz lbl0

    free parr                       ; release the memory from the tokeniser.

  ; --------------------------------------------------------------
  ; METHOD 2  Loop directly through the array of string arguments.
  ; --------------------------------------------------------------
    mov esi, OFFSET tarr            ; load array address into ESI
    mov lcnt, LENGTHOF tarr         ; get the arguments count in array

  lbl1:
    fn MessageBox,0,[esi],"Method 2",MB_OK
    add esi, 4
    sub lcnt, 1
    jnz lbl1

    pop esi

    invoke ExitProcess,0            ; bye

    main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start


















