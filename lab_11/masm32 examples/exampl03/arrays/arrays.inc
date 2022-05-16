; #########################################################################

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
      include \MASM32\include\oleaut32.inc

;     libraries
;     ~~~~~~~~~
      includelib \masm32\lib\masm32.lib
      includelib \masm32\lib\gdi32.lib
      includelib \masm32\lib\user32.lib
      includelib \masm32\lib\kernel32.lib
      includelib \masm32\lib\Comctl32.lib
      includelib \masm32\lib\comdlg32.lib
      includelib \masm32\lib\shell32.lib
      includelib \MASM32\LIB\oleaut32.lib

; #########################################################################

        ;=================
        ; Local prototypes
        ;=================
        Main             PROTO
        WndProc          PROTO :DWORD,:DWORD,:DWORD,:DWORD
        TopXY            PROTO :DWORD,:DWORD
        Paint_Proc       PROTO :DWORD
        RegisterWinClass PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
        MsgLoop          PROTO

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

      DisplayMenu MACRO handl, IDnum
        invoke LoadMenu,hInstance,IDnum
        invoke SetMenu,handl,eax
      ENDM

      DisplayWindow MACRO handl, ShowStyle
        invoke ShowWindow,handl, ShowStyle
        invoke UpdateWindow,handl
      ENDM

      AutoScale MACRO swidth, sheight
        invoke GetPercent,sWid,swidth
        mov Wwd, eax
        invoke GetPercent,sHgt,sheight
        mov Wht, eax

        invoke TopXY,Wwd,sWid
        mov Wtx, eax

        invoke TopXY,Wht,sHgt
        mov Wty, eax
      ENDM

      SingleInstanceOnly MACRO lpClassName
        invoke FindWindow,lpClassName,NULL
        cmp eax, 0
        je @F
          push eax
          invoke ShowWindow,eax,SW_RESTORE
          pop eax
          invoke SetForegroundWindow,eax
          mov eax, 0
          ret
        @@:
      ENDM

    ; --------------------------------------------
    ; equates to use directly in the message loop
    ; --------------------------------------------
        m_hWnd   equ <msg.hwnd>
        m_Msg    equ <msg.message>
        m_wParam equ <msg.wParam>
        m_lParam equ <msg.lParam>

    .data
        szDisplayName db "test Arrays",0

    .data?
        hInstance dd ?
        CommandLine dd ?
        hIcon dd ?
        hCursor dd ?
        sWid dd ?
        sHgt dd ?
        hWnd dd ?


; ########################### Inserted modules ############################

      include tbmacros.asm
      include toolbar.asm
      include Statusbr.asm
      include Filedlgs.asm

; #########################################################################

