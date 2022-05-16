IF 0  ; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
                      Build this template with "CONSOLE ASSEMBLE AND LINK"
ENDIF ; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    include \masm32\include\masm32rt.inc

    format_num_string PROTO :DWORD,:DWORD

    .code

start:
   
; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    call main
    inkey
    exit

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

main proc

    LOCAL buffer[64]:BYTE
    LOCAL pbuf  :DWORD

    mov pbuf, ptr$(buffer)

    fn format_num_string,"1234567890",pbuf
    print pbuf,13,10

    fn format_num_string,"123456789",pbuf
    print pbuf,13,10

    fn format_num_string,"12345678",pbuf
    print pbuf,13,10

    fn format_num_string,"1234567",pbuf
    print pbuf,13,10

    fn format_num_string,"123456",pbuf
    print pbuf,13,10

    fn format_num_string,"12345",pbuf
    print pbuf,13,10

    fn format_num_string,"1234",pbuf
    print pbuf,13,10

    fn format_num_string,"123",pbuf
    print pbuf,13,10

    fn format_num_string,"12",pbuf
    print pbuf,13,10

    fn format_num_string,"1",pbuf
    print pbuf,13,10


    ret

main endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    .data
  ; --------------------------------------------------
  ; store the initial spacing counter value in a table
  ; --------------------------------------------------
      align 4
      tbl1 dd 0,0,0,0,1,2,3,1,2,3,1,0

 ;     1=0 0
 ;     2=0 00
 ;     3=0 000
 ;     4=1 0000
 ;     5=2 00000
 ;     6=3 000000
 ;     7=1 0000000
 ;     8=2 00000000
 ;     9=3 000000000
 ;    10=1 0000000000

    .code

OPTION PROLOGUE:NONE
OPTION EPILOGUE:NONE

format_num_string proc src:DWORD,dst:DWORD

  ; -----------------
  ; get source length
  ; -----------------
    mov ecx, [esp+4]
    sub ecx, 1
  @@:
    add ecx, 1
    cmp BYTE PTR [ecx], 0
    jne @B
    sub ecx, [esp+4]
  ; -----------------

    push esi

    mov ecx, [tbl1+ecx*4]       ; set the initial spacing from the table

    mov esi, [esp+4][4]
    mov edx, [esp+8][4]
    sub esi, 1

  stlp:
    add esi, 1
    movzx eax, BYTE PTR [esi]
    test eax, eax
    jz bye
    mov [edx], al
    add edx, 1
    sub ecx, 1                  ; dec the spacing counter
    jnz stlp                    ; loop back if its not zero

    cmp BYTE PTR [esi+1], 0     ; 1 byte look ahead
    je bye                      ; exit if char its zero terminator
    mov BYTE PTR [edx], ","     ; write the spacer. <<<<<< change the character here
    add edx, 1
    mov ecx, 3                  ; reset the spacing counter to 3
    jmp stlp

  bye:
    mov BYTE PTR [edx], 0       ; write terminator
    pop esi
    ret 8

format_num_string endp

OPTION PROLOGUE:PrologueDef
OPTION EPILOGUE:EpilogueDef

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

end start






















