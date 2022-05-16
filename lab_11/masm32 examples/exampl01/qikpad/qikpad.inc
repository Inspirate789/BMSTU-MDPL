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
      include \MASM32\INCLUDE\oleaut32.inc


;     libraries
;     ~~~~~~~~~
      includelib \MASM32\LIB\masm32.lib

      includelib \MASM32\LIB\gdi32.lib
      includelib \MASM32\LIB\user32.lib
      includelib \MASM32\LIB\kernel32.lib
      includelib \MASM32\LIB\Comctl32.lib
      includelib \MASM32\LIB\comdlg32.lib
      includelib \MASM32\LIB\shell32.lib
      includelib \MASM32\LIB\oleaut32.lib

; #########################################################################

        ;=================
        ; Local prototypes
        ;=================
        WinMain       PROTO :DWORD,:DWORD,:DWORD,:DWORD
        WndProc       PROTO :DWORD,:DWORD,:DWORD,:DWORD
        TopXY         PROTO :DWORD,:DWORD
        FillBuffer    PROTO :DWORD,:DWORD,:BYTE
        Paint_Proc    PROTO :DWORD,:DWORD
        EditML        PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
        Read_File_In  PROTO :DWORD,:DWORD
        Confirmation  PROTO :DWORD
        Write_2_Disk  PROTO :DWORD
        SaveFileAs    PROTO
        SaveFile      PROTO
        WordWrap      PROTO
        EditProc      PROTO :DWORD,:DWORD,:DWORD,:DWORD
        About         PROTO

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
        CommandLine   dd 0
        hWnd          dd 0
        hInstance     dd 0
        hIcon         dd 0
        hEdit         dd 0
        WrapFlag      dd 0
        lpEditProc    dd 0
        szDisplayName db "QikPad",0
        szUntitled    db "Untitled",0
        szOpenedAt    db "File opened at ",0
        szSavedAt     db "File saved at ",0
        bytes         db " bytes",0
        sizeBuffer    db 16 dup (?)
        PthBuffer     db 128 dup (?)


; ########################### Inserted modules ############################

    include toolbar.asm
    include filedlgs.asm
    include statusbr.asm

; #########################################################################
