; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

;     include files
;     ~~~~~~~~~~~~~
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

;     libraries
;     ~~~~~~~~~
      includelib \masm32\lib\masm32.lib
      includelib \masm32\lib\gdi32.lib
      includelib \masm32\lib\user32.lib
      includelib \masm32\lib\kernel32.lib
      includelib \masm32\lib\Comctl32.lib
      includelib \masm32\lib\comdlg32.lib
      includelib \masm32\lib\shell32.lib
      includelib \masm32\lib\oleaut32.lib

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

        ;=================
        ; Local prototypes
        ;=================
        WinMain          PROTO :DWORD,:DWORD,:DWORD,:DWORD
        WndProc          PROTO :DWORD,:DWORD,:DWORD,:DWORD
        TopXY            PROTO :DWORD,:DWORD
        RegisterWinClass PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
        MsgLoop          PROTO
        Main             PROTO

      DisplayWindow MACRO handl, ShowStyle
        invoke ShowWindow,handl, ShowStyle
        invoke UpdateWindow,handl
      ENDM

    .data?
        hInstance dd ?
        CommandLine dd ?
        hIcon dd ?
        hCursor dd ?
        sWid dd ?
        sHgt dd ?
        hWnd dd ?

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

