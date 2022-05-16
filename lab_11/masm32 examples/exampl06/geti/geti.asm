IF 0  ; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
                      Build this template with "CONSOLE ASSEMBLE AND LINK"
ENDIF ; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    include \masm32\include\masm32rt.inc

    .686p

    mmi PROTO :DWORD

    X86ST STRUCT
      sse4a dd ?
      sse42 dd ?
      sse41 dd ?
      ssse3 dd ?
      sse3  dd ?
      sse2  dd ?
      sse   dd ?
      mmx   dd ?
      mmxx  dd ?
      amd3D dd ?
      amd3x dd ?
    X86ST ENDS

    .code

start:
   
; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    call main
    inkey
    exit

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

main proc

    LOCAL x86   :X86ST

    invoke mmi,ADDR x86

    print "-----",13,10
    print "INTEL",13,10
    print "-----",13,10

    print str$(x86.sse42)," sse4.2",13,10
    print str$(x86.sse41)," sse4.1",13,10
    print str$(x86.ssse3)," ssse3",13,10
    print str$(x86.sse3)," sse3",13,10

    print str$(x86.sse2)," sse2",13,10
    print str$(x86.sse)," sse",13,10
    print str$(x86.mmx)," mmx",13,10,13,10

    print "---",13,10
    print "AMD",13,10
    print "---",13,10

    print str$(x86.sse4a)," sse4a",13,10
    print str$(x86.mmxx)," mmx_ex",13,10
    print str$(x86.amd3D)," 3DNow",13,10
    print str$(x86.amd3x)," 3DNow_ex",13,10,13,10

    ret

main endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

; "mmi" Multi media Instructions

OPTION PROLOGUE:NONE
OPTION EPILOGUE:NONE

mmi proc pStruct:DWORD

  ; returns 0 if no CPUID, 1 if it is supported.
  ; if supported tests from MMX to SSE4.2 and
  ; writes results to structure

  ; -------------------------------------------------
  ; test for CPUID so it does not crash on old timers
  ; -------------------------------------------------
    pushfd
    pop eax

    mov ecx, eax
    xor eax, 00000000001000000000000000000000b          ; set bit 21 of eflags
    push eax
    popfd
    pushfd
    pop eax

    xor eax, ecx            ; test if its changed
    jnz exists              ; if changed then CPUID
    xor eax, eax            ; returns 0 if no CPUID
    ret 4
  ; -------------------------------------------------

  exists:
  ; -------------------
  ; zero fill structure
  ; -------------------
    mov ecx, SIZEOF X86ST / 4

    mov eax, [esp+4]        ; pStruct
  @@:
    mov DWORD PTR [eax], 0
    add eax, 4
    sub ecx, 1
    jnz @B

  ; INTEL

    mov eax, 1
    cpuid

    mov eax, [esp+4]                                ; pStruct

    bt ecx, 20                                      ; sse4.2
    setc BYTE PTR (X86ST PTR [eax]).sse42

    bt ecx, 19                                      ; sse4.1
    setc BYTE PTR (X86ST PTR [eax]).sse41

    bt ecx, 9                                       ; ssse3
    setc BYTE PTR (X86ST PTR [eax]).ssse3

    bt ecx, 0                                       ; sse3
    setc BYTE PTR (X86ST PTR [eax]).sse3

    bt edx, 26                                      ; sse2
    setc BYTE PTR (X86ST PTR [eax]).sse2

    bt edx, 25                                      ; sse
    setc BYTE PTR (X86ST PTR [eax]).sse

    bt edx, 23                                      ; mmx
    setc BYTE PTR (X86ST PTR [eax]).mmx

  ; AMD

    mov eax, 80000001h
    cpuid

    mov eax, [esp+4]                                ; pStruct

    bt edx, 22                                      ; AMD mmx extended
    setc BYTE PTR (X86ST PTR [eax]).mmxx

    bt ecx, 6                                       ; AMD sse4a
    setc BYTE PTR (X86ST PTR [eax]).sse4a

    bt edx, 31                                      ; AMD 3DNow
    setc BYTE PTR (X86ST PTR [eax]).amd3D

    bt edx, 30                                      ; AMD 3DNowExt
    setc BYTE PTR (X86ST PTR [eax]).amd3x

    mov eax, 1
    ret 4

mmi endp

OPTION PROLOGUE:PrologueDef
OPTION EPILOGUE:EpilogueDef

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

end start
















