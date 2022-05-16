; #########################################################################

;     include files
;     ~~~~~~~~~~~~~
      include \MASM32\INCLUDE\windows.inc
      include \MASM32\INCLUDE\masm32.inc
      include \MASM32\INCLUDE\gdi32.inc
      include \MASM32\INCLUDE\user32.inc
      include \MASM32\INCLUDE\kernel32.inc
      include \MASM32\INCLUDE\Comctl32.inc
      include \MASM32\INCLUDE\comdlg32.inc
      include \MASM32\INCLUDE\shell32.inc

;     libraries
;     ~~~~~~~~~
      includelib \MASM32\LIB\masm32.lib

      includelib \MASM32\LIB\gdi32.lib
      includelib \MASM32\LIB\user32.lib
      includelib \MASM32\LIB\kernel32.lib
      includelib \MASM32\LIB\Comctl32.lib
      includelib \MASM32\LIB\comdlg32.lib
      includelib \MASM32\LIB\shell32.lib

; #########################################################################

        ;=================
        ; Local prototypes
        ;=================
        WinMain PROTO :DWORD,:DWORD,:DWORD,:DWORD
        WndProc PROTO :DWORD,:DWORD,:DWORD,:DWORD
        TopXY PROTO   :DWORD,:DWORD
        FillBuffer   PROTO :DWORD,:DWORD,:BYTE
        Paint_Proc   PROTO :DWORD,:DWORD
        IconButton PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
        BmpButton  PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
        BtnProc PROTO :DWORD,:DWORD,:DWORD,:DWORD
        SetBmpColor PROTO :DWORD
        bmpProc PROTO :DWORD,:DWORD,:DWORD,:DWORD

      ;=============
      ; Local macros
      ;=============

      szText MACRO Name, Text:VARARG
        LOCAL lbl
          jmp lbl
            Name db Text,0
          lbl:
        ENDM

      m2m MACRO M1, M2
        push M2
        pop  M1
      ENDM

      return MACRO arg
        mov eax, arg
        ret
      ENDM

    .data
        szDisplayName db "Icon & Bitmap buttons",0
        CommandLine   dd 0
        hWnd          dd 0
        hInstance     dd 0
        hIcon         dd 0
        lpBtnProc     dd 0
        hBtn1         dd 0
        hBtn2         dd 0
        hBtn3         dd 0
        hBtn4         dd 0
        hBmp1         dd 0
        hBmp2         dd 0
        lpfnbmpProc   dd 0



; ########################### Inserted modules ############################


; #########################################################################
