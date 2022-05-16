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
      include \masm32\include\shlwapi.inc
      include \MASM32\include\oleaut32.inc

;     libraries
;     ~~~~~~~~~
      includelib \MASM32\LIB\masm32.lib

      includelib \MASM32\LIB\gdi32.lib
      includelib \MASM32\LIB\user32.lib
      includelib \MASM32\LIB\kernel32.lib
      includelib \MASM32\LIB\Comctl32.lib
      includelib \MASM32\LIB\comdlg32.lib
      includelib \MASM32\LIB\shell32.lib
      includelib \masm32\lib\shlwapi.lib
      includelib \MASM32\LIB\oleaut32.lib

      include tbmacros.asm


; #########################################################################

        ;=================
        ; Local prototypes
        ;=================
        WinMain PROTO :DWORD,:DWORD,:DWORD,:DWORD
        WndProc PROTO :DWORD,:DWORD,:DWORD,:DWORD
        TopXY PROTO   :DWORD,:DWORD
        FillBuffer     PROTO :DWORD,:DWORD,:BYTE
        Paint_Proc     PROTO :DWORD,:DWORD
        EditControl    PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
        hEditProc      PROTO :DWORD,:DWORD,:DWORD,:DWORD
        Select_All     PROTO :DWORD
        TextFind       PROTO :DWORD,:DWORD
        SearchProc     PROTO :DWORD,:DWORD,:DWORD,:DWORD
        CallSearchDlg  PROTO
        StreamFileOut  PROTO :DWORD,:DWORD
        StreamFileIn   PROTO :DWORD,:DWORD
        ofCallBack     PROTO :DWORD,:DWORD,:DWORD,:DWORD
        sfCallBack     PROTO :DWORD,:DWORD,:DWORD,:DWORD
        Confirmation   PROTO :DWORD
        MergeFile      PROTO :DWORD
        Do_Status      PROTO :DWORD
        Do_ToolBar     PROTO :DWORD
        SetBmpColor    PROTO :DWORD
        GetFileName    PROTO :DWORD, :DWORD, :DWORD
        SaveFileName   PROTO :DWORD, :DWORD, :DWORD

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

      stralloc MACRO ln
        invoke SysAllocStringByteLen,0,ln
      ENDM

      strfree MACRO strhandle
        invoke SysFreeString,strhandle
      ENDM

    .data
      include idat.asm

    .data?
      include udat.asm

      szFileName    db 260 dup(?)
      ofn           OPENFILENAME <>  ; structure

      SearchText    db 128 dup(?)
