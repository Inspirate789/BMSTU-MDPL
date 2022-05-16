comment * -------------------------------------------------------
        This is an example of how to use the jump table tool
        "tproc.exe". With this method you can have a very large
        number of choices that are selected by a single DWORD
        value. It is a high speed automated method that is far
        faster than sequentially testing the number to determine
        where to branch to for the specific data.
        ------------------------------------------------------- *

      .486                      ; create 32 bit code
      .model flat, stdcall      ; 32 bit memory model
      option casemap :none      ; case sensitive 

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
      include \masm32\include\dialogs.inc
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

      DlgProc  PROTO :DWORD,:DWORD,:DWORD,:DWORD
      jmptable PROTO :DWORD

    ; -----------------------------
    ; macros for displaying results
    ; -----------------------------
      SBtext MACRO part,lpString
        invoke SendMessage,hStatus,SB_SETTEXT,part-1,reparg(lpString)
      ENDM

      TBtext MACRO lpString
        invoke SetWindowText,FUNC(GetActiveWindow),reparg(lpString)
      ENDM

      EDtext MACRO lpString
        invoke SetWindowText,hEdit,reparg(lpString)
      ENDM

      EDclear equ <EDtext 0>

    .data?
        hWnd      dd ?
        hInstance dd ?
        hStatus   dd ?
        hEdit     dd ?

    .code

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

start: 
    mov hInstance, FUNC(GetModuleHandle,NULL)
    call main
    invoke ExitProcess,eax

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

main proc

    invoke InitCommonControls

    Dialog "   ", \                         ; caption
           "MS Sans Serif",10, \            ; font,pointsize
            WS_OVERLAPPED or \              ; styles for
            WS_SYSMENU or DS_CENTER, \      ; dialog window
            9, \                            ; number of controls
            50,50,250,106, \                ; x y co-ordinates
            1024                            ; memory buffer size

    DlgButton "Simple",WS_TABSTOP,5, 5,50,13,101
    DlgButton "Out of range",WS_TABSTOP,5,20,50,13,102
    DlgButton "Benchmark",WS_TABSTOP,5,35,50,13,103
    DlgButton "Unused",WS_TABSTOP,5,50,50,13,104
    DlgButton "Unused",WS_TABSTOP,5,65,50,13,105
    DlgButton "Reset",WS_TABSTOP,60,65,50,13,106
    DlgButton "Close",WS_TABSTOP,192,65,50,13,IDCANCEL
    DlgStatus 110
    DlgEdit WS_TABSTOP or ES_MULTILINE or ES_WANTRETURN or \
            ES_LEFT or WS_BORDER or WS_VSCROLL,60,5,182,58,111

    CallModalDialog hInstance,0,DlgProc,NULL

    ret

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

align 4

DlgProc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD 

    LOCAL hDC   :DWORD 
    LOCAL ps    :PAINTSTRUCT 
    LOCAL rct   :RECT 
    LOCAL crct  :RECT 
    LOCAL buffer1[260]:BYTE 
    LOCAL buffer2[260]:BYTE 
    LOCAL buffer3[260]:BYTE 
    LOCAL buffer4[260]:BYTE 

    STRING MainTitle,"Test Jump Table"

    Switch uMsg
      Case WM_INITDIALOG
        m2m hWnd, hWin
        invoke SendMessage,hWnd,WM_SETICON,1,
                           FUNC(LoadIcon,NULL,IDI_ASTERISK)
        invoke SetWindowText,hWnd,ADDR MainTitle

        mov hStatus, FUNC(GetDlgItem,hWnd,110)
        GLOBAL sbarray dd 100,200,300,400,-1
        invoke SendMessage,hStatus,SB_SETPARTS,5,ADDR sbarray

        mov hEdit,   FUNC(GetDlgItem,hWnd,111)
        invoke SendMessage,hEdit,WM_SETFONT,
                           FUNC(GetStockObject,ANSI_FIXED_FONT),TRUE
        mov eax, 1

      Case WM_COMMAND
        Switch wParam
          Case 101
            invoke jmptable,13
            fn MessageBox,hWnd,str$(eax),"Get value at label 13",MB_OK

          Case 102
            invoke jmptable,25
            fn MessageBox,hWnd,str$(eax),"Sorry, number out of range",MB_OK

          Case 103

            invoke GetTickCount
            push eax

            push esi
            mov esi, 1000000

          @@:
            invoke jmptable,14
            invoke jmptable,2
            invoke jmptable,7
            invoke jmptable,13
            invoke jmptable,10
            invoke jmptable,4
            invoke jmptable,9
            invoke jmptable,6
            invoke jmptable,15
            invoke jmptable,8
            sub esi, 1
            jnz @B

            pop esi

            invoke GetTickCount
            pop ecx
            sub eax, ecx

            fn MessageBox,hWnd,"Milliseconds for 10 million data reads",str$(eax),MB_OK

          Case 104
            TBtext "ID 104"
            SBtext 4,"Test 4"
            EDtext "The 4th button was pressed"

          Case 105
            TBtext "ID 105"
            SBtext 5,"Test 5"
            EDtext "OK, you pressed button 5"

          Case 106
            EDclear
            SBtext 1,0
            SBtext 2,0
            SBtext 3,0
            SBtext 4,0
            SBtext 5,0
            TBtext ADDR MainTitle

          Case IDCANCEL
            jmp quit_dialog
        Endsw

      Case WM_PAINT
        mov hDC, FUNC(BeginPaint,hWin,ADDR ps)
        invoke GetClientRect,hWin,ADDR rct
        invoke GetWindowRect,hStatus,ADDR crct
        mov eax, crct.bottom
        sub eax, crct.top
        sub rct.bottom, eax
        invoke DrawEdge,hDC,ADDR rct,EDGE_ETCHED,BF_RECT
        invoke EndPaint,hWin,ADDR ps

      Case WM_CLOSE
        quit_dialog: 
        invoke EndDialog,hWin,0
    Endsw

    xor eax, eax
    ret

DlgProc endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

comment * --------------------------------------------------------
        This jump table was autocreated with the "tproc.exe" tool
        -------------------------------------------------------- *
align 4

jmptable proc value:DWORD

  .data
    align 4
    deftbl \
      dd l0,l1,l2,l3,l4,l5,l6,l7,l8,l9,l10,l11,l12,l13,l14,l15
  .code

    mov eax, value
    cmp eax, 15
    ja error
    jmp DWORD PTR [deftbl+eax*4]

  align 4
  error:
    mov eax, -1
    jmp quit_default

  align 4
  l0:
    mov eax, 0
    jmp quit_default

  align 4
  l1:
    mov eax, 1
    jmp quit_default

  align 4
  l2:
    mov eax, 2
    jmp quit_default

  align 4
  l3:
    mov eax, 3
    jmp quit_default

  align 4
  l4:
    mov eax, 4
    jmp quit_default

  align 4
  l5:
    mov eax, 5
    jmp quit_default

  align 4
  l6:
    mov eax, 6
    jmp quit_default

  align 4
  l7:
    mov eax, 7
    jmp quit_default

  align 4
  l8:
    mov eax, 8
    jmp quit_default

  align 4
  l9:
    mov eax, 9
    jmp quit_default

  align 4
  l10:
    mov eax, 10
    jmp quit_default

  align 4
  l11:
    mov eax, 11
    jmp quit_default

  align 4
  l12:
    mov eax, 12
    jmp quit_default

  align 4
  l13:
    mov eax, 13
    jmp quit_default

  align 4
  l14:
    mov eax, 14
    jmp quit_default

  align 4
  l15:
    mov eax, 15
    jmp quit_default

  quit_default:

    ret

jmptable endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start
