; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
    include \masm32\include\masm32rt.inc
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

;               Demonstrates the use of the two specialised
;                  prototyping macros SPROTO and CPROTO

    .code

start:
   
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    call main

    exit

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

main proc

    LOCAL user  :DWORD
    LOCAL msvc  :DWORD
    LOCAL pbuf  :DWORD
    LOCAL buffer[64]:BYTE

    mov pbuf, ptr$(buffer)

  ; ---------------------------
  ; prototype the two functions
  ; ---------------------------
    .const
      mbox  SPROTO(adr1,:DWORD,:DWORD,:DWORD,:DWORD)
      _l2a  CPROTO(adr2,:DWORD,:DWORD,:DWORD)
    .code

  ; -------------
  ; load the DLLs
  ; -------------
    mov user, rv(LoadLibrary,"user32.dll")
    mov msvc, rv(LoadLibrary,"msvcrt.dll")

  ; -----------------------------------
  ; load the procedure address into the
  ; variable specified in the prototype
  ; -----------------------------------
    mov adr1, rv(GetProcAddress,user,"MessageBoxA")
    mov adr2, rv(GetProcAddress,msvc,"_ltoa")

  ; -----------------------
  ; call the two procedures
  ; -----------------------
    invoke _l2a,1234,pbuf,10
    fn mbox,0,pbuf,"title",MB_OK

  ; -----------------
  ; free the two DLLs
  ; -----------------
    invoke FreeLibrary,user
    invoke FreeLibrary,msvc

    ret

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start
