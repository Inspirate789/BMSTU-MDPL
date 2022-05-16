IF 0  ; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
                      Build this template with "CONSOLE ASSEMBLE AND LINK"
ENDIF ; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    include \masm32\include\masm32rt.inc

    line_tokenize PROTO :DWORD,:DWORD

    .code

start:
   
; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    call main
    exit

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

main proc

    LOCAL hMem  :DWORD
    LOCAL flen  :DWORD
    LOCAL hArr  :DWORD
    LOCAL lcnt  :DWORD

    LOCAL bptr  :DWORD
    LOCAL tvar  :DWORD

    LOCAL pbuf  :DWORD
    LOCAL buffer[32]:BYTE

    push ebx
    push esi
    push edi

    mov hMem, InputFile("\masm32\include\windows.inc")
    mov flen, ecx

    mov lcnt, rv(line_tokenize,hMem,ADDR hArr)  ; <<<< NOTE the ADDR of hArr

    mov bptr, alloc(4096)

    mov esi, hArr
    mov edi, lcnt
    xor ebx, ebx

  lbl0:
  ; ----------------------------------------------
  ; create the zero padded string from the counter
  ; ----------------------------------------------
    mov pbuf, ptr$(buffer)
    mov pbuf, right$(cat$(pbuf,"0000000",ustr$(ebx)),8)

  ; ----------------------
  ; zero the output buffer
  ; ----------------------
    mov eax, bptr
    mov BYTE PTR [eax], 0       ; clear the buffer

  ; -------------------------
  ; join the strings together
  ; -------------------------
    mov bptr, cat$(bptr,pbuf,":     ",DWORD PTR [esi],chr$(13,10))

    fn StdOut,bptr

    add ebx, 1
    add esi, 4
    cmp ebx, edi
    jl lbl0

    free bptr
    free hArr
    free hMem

    pop edi
    pop esi
    pop ebx

    ret

main endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

OPTION PROLOGUE:NONE
OPTION EPILOGUE:NONE

    align 16

line_tokenize proc ptxt:DWORD,hArr:DWORD

  ; -----------------------------------------------------------------------
  ; in place tokenise CRLF delimited text and write an array of pointers
  ; to each line to a passed address and return the line count in EAX

  ; ********************************************************************
  ; invoke line_tokenize,pTxt,ADDR hArray  ; <<< note the ADDR of hArray
  ; ********************************************************************

  ; --------
  ; On ENTRY
  ; --------
  ; ptxt is the address of the text to tokenize.
  ; hArr is the address of a variable to receive the pointer array address

  ; -------
  ; On EXIT
  ; -------
  ; 1. pointer array has the address of each line
  ; 2. the return value in EAX is the line count

  ; -------------------------------
  ; When data is no longer required
  ; -------------------------------
  ; The passed variable "hArr" must be freed with GlobalFree()
  ; or the macro "free"

  ; NOTE: An empty line of text has ZERO as its first character
  ; and the array pointer for that line points to that ZERO.
  ; When you process the content or the array you must be able
  ; to safely deal with pointers to null terminated zero length strings.
  ; -----------------------------------------------------------------------

    mov ecx, [esp+4]            ; ptxt
    xor edx, edx                ; zero counter
    sub ecx, 1

  ; --------------------------
  ; count the carriage returns
  ; --------------------------
  cntloop:
    add ecx, 1
    movzx eax, BYTE PTR [ecx]   ; zero extend each byte into EAX
    test eax, eax               ; test for zero
    jz lout                     ; exit loop on zero
    cmp eax, 13                 ; test for carriage return
    jne cntloop                 ; loop back if not
    add edx, 1                  ; increment counter
    jmp cntloop                 ; loop back

  ; -----------------------------------
  ; set buffer size and allocate memory
  ; -----------------------------------
  lout:
    add edx, 1                  ; allow for no trailing CRLF
    push edx                    ; preserve count on stack
    lea edx, [edx*4]            ; mul edx * 4
    mov edx, alloc(edx)         ; allocate the pointer array memory
    mov eax, [esp+8][4]         ; hArr - write the passed handle address to EAX
    mov [eax], edx              ; write the allocated memory handle to it
    mov ecx, [esp+4][4]         ; ptxt - text address in ECX
    mov [edx], ecx              ; 1st line address in 1st DWORD in EDX
    add edx, 4
    sub ecx, 1

  mainloop:
    add ecx, 1
  backin:
    movzx eax, BYTE PTR [ecx]   ; test each byte
    test eax, eax               ; exit on zero
    jz lpout
    cmp eax, 13                 ; test for CR
    jne mainloop                ; loop back if not

    mov BYTE PTR [ecx], 0       ; overwrite 13 with 0
    add ecx, 2                  ; set next line start
    mov [edx], ecx              ; store it in the pointer array
    add edx, 4
    jmp backin
    
  lpout:
    pop eax                     ; restore count into EAX as return value

    ret 8

line_tokenize endp

OPTION PROLOGUE:PrologueDef
OPTION EPILOGUE:EpilogueDef

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

end start
