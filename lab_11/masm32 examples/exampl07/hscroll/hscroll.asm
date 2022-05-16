; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    .486                       ; create 32 bit code
    .model flat, stdcall       ; 32 bit memory model
    option casemap :none       ; case sensitive
 
    include \masm32\include\windows.inc
    include \masm32\include\masm32.inc
    include \masm32\include\gdi32.inc
    include \masm32\include\user32.inc
    include \masm32\include\kernel32.inc
    include \masm32\macros\macros.asm

    includelib \masm32\lib\masm32.lib
    includelib \masm32\lib\gdi32.lib
    includelib \masm32\lib\user32.lib
    includelib \masm32\lib\kernel32.lib

    .code

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

start:

main proc

    LOCAL swid  :DWORD
    LOCAL shgt  :DWORD
    LOCAL dwid  :DWORD
    LOCAL hDC   :DWORD
    LOCAL cDC   :DWORD
    LOCAL hScr  :DWORD
    LOCAL hBmp  :DWORD
    LOCAL hOld  :DWORD

    mov hScr, 0                                         ; screen handle is zero
    mov hDC,  rv(GetDC,hScr)                            ; get its DC
    mov swid, rv(GetSystemMetrics,SM_CXSCREEN)          ; get screen width
    add eax,  eax                                       ; double it
    mov dwid, eax                                       ; store it in a variable
    mov shgt, rv(GetSystemMetrics,SM_CYSCREEN)          ; get the screen height
    mov hBmp, rv(CreateCompatibleBitmap,hDC,dwid,shgt)  ; make double width bitmap
    mov cDC,  rv(CreateCompatibleDC,hDC)                ; create a DC for it
    mov hOld, rv(SelectObject,cDC,hBmp)                 ; select compatible bitmap into compatible DC

  ; ----------------------------------------
  ; blit 2 copies of the current screen side
  ; by side onto the compatible bitmap.
  ; ----------------------------------------
    invoke BitBlt,cDC,0,0,swid,shgt,hDC,0,0,SRCCOPY
    invoke BitBlt,cDC,swid,0,swid,shgt,hDC,0,0,SRCCOPY

  ; --------------------------------------------------------
  ; repeatedly blit the shifting image to the current screen
  ; --------------------------------------------------------
    push esi
    mov esi, swid
  @@:
    invoke BitBlt,hDC,0,0,swid,shgt,cDC,esi,0,SRCCOPY
    invoke Sleep, 20                                    ; slow it up a bit
    sub esi, 8
    jns @B

    pop esi

    invoke SendMessage,0,WM_PAINT,hDC,0                 ; clean up the mess after

    invoke DeleteObject,hBmp                            ; delete the compatible bitmap
    invoke SelectObject,cDC,hOld                        ; reselect the old one
    invoke DeleteDC,cDC                                 ; delete the compatible DC
    invoke ReleaseDC,hScr,hDC                           ; release the screen DC

    exit

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start
