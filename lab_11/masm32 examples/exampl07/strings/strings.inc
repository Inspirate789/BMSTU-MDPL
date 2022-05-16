
    .486                       ; create 32 bit code
    .model flat, stdcall       ; 32 bit memory model
    option casemap :none       ; case sensitive

    scanwords PROTO :DWORD,:DWORD,:DWORD

    include \masm32\include\windows.inc
    include \masm32\include\masm32.inc
    include \masm32\include\gdi32.inc
    include \masm32\include\user32.inc
    include \masm32\include\kernel32.inc
    include \masm32\include\Comctl32.inc
    include \masm32\include\comdlg32.inc
    include \masm32\include\shell32.inc
    include \masm32\include\oleaut32.inc
    include \masm32\macros\macros.asm

    includelib \masm32\lib\masm32.lib
    includelib \masm32\lib\gdi32.lib
    includelib \masm32\lib\user32.lib
    includelib \masm32\lib\kernel32.lib
    includelib \masm32\lib\Comctl32.lib
    includelib \masm32\lib\comdlg32.lib
    includelib \masm32\lib\shell32.lib
    includelib \masm32\lib\oleaut32.lib

.data

    align 4
    ctable \
      db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0     ; 31
      db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0     ; 63
      db 0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
      db 1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0     ; 95
      db 0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
      db 1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0     ; 127
      db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

      thold dd 0    ; threshold of character count
