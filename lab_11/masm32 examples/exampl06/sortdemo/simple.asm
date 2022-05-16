comment * ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    This is a simple demo of how to set up and use the string sorting
    algorithms in the MASM32 library. The raw string data is stored as
    a sequence of zero terminated strings and the address of each string
    is stored in an array of pointers. Both string sorting algorithms
    sort an array of string pointers.

    ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл *

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

      DlgProc PROTO :DWORD,:DWORD,:DWORD,:DWORD 

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

    .data
  ; ----------------------------------------
  ; This is the raw string data to be sorted
  ; ----------------------------------------
      t0  db "fly",0
      t1  db "dog",0
      t2  db "cat",0
      t3  db "bird",0
      t4  db "cow",0
      t5  db "horse",0
      t6  db "wombat",0
      t7  db "pig",0
      t8  db "rat",0
      t9  db "mouse",0
      t10 db "flea",0
      t11 db "aardvark",0
      t12 db "elephant",0
      t13 db "zebra",0
      t14 db "platypus",0
      t15 db "chook",0
      t16 db "lion",0
      t17 db "tiger",0
      t18 db "kiwi",0
      t19 db "bear",0

      align 4
    ; ----------------------------------------------------
    ; This is the array of pointers to the raw string data.
    ; ----------------------------------------------------
      pstrings dd t0,t1,t2,t3,t4,t5,t6,t7,t8,t9,t10,t11,t12,t13,t14,t15,t16,t17,t18,t19

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
            7, \                            ; number of controls
            50,50,250,200, \                ; x y co-ordinates
            1024                            ; memory buffer size

    DlgButton "Unsorted",WS_TABSTOP,5, 5,50,13,101
    DlgButton "Ascending",WS_TABSTOP,5,20,50,13,102
    DlgButton "Descending",WS_TABSTOP,5,35,50,13,103
    DlgButton "Clear",WS_TABSTOP,5,50,50,13,104
    DlgButton "Close",WS_TABSTOP,5,65,50,13,IDCANCEL
    DlgStatus 110
    DlgEdit WS_TABSTOP or ES_MULTILINE or ES_WANTRETURN or \
            ES_LEFT or WS_BORDER or WS_VSCROLL,60,5,182,164,111

    CallModalDialog hInstance,0,DlgProc,NULL

    ret

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

align 4

DlgProc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD 

    LOCAL hDC   :DWORD
    LOCAL hMem  :DWORD
    LOCAL hMain :DWORD
    LOCAL pBuf1 :DWORD
    LOCAL ps    :PAINTSTRUCT 
    LOCAL rct   :RECT 
    LOCAL crct  :RECT 
    LOCAL buffer1[260]:BYTE 
    LOCAL buffer2[260]:BYTE 
    LOCAL buffer3[260]:BYTE 
    LOCAL buffer4[260]:BYTE 

    STRING MainTitle,"Simple Sorting Demo"

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
          ; ************************
          ; display unsorted strings
          ; ************************
            invoke create_array,LENGTHOF pstrings,16    ; create a dynamic array
            mov hMem, eax
            mov hMain, ecx

            push ebx
            push esi
            push edi

            mov esi, OFFSET pstrings
            mov edi, hMem
            sub esi, 4
            sub edi, 4
            mov ebx, LENGTHOF pstrings                  ; get the count of pointers

          @@:
            add esi, 4
            add edi, 4
            invoke szCopy,[esi],[edi]                   ; copy static array to dynamic array
            sub ebx, 1
            jnz @B

            mov pBuf1, ptr$(buffer1)                    ; get the pointer to the output buffer
            mov esi, hMem
            mov edi, LENGTHOF pstrings                  ; get the pointer count from the static array
          @@:
            invoke szCatStr,pBuf1,[esi]                 ; append each string to the output buffer
            invoke szCatStr,pBuf1,chr$(13,10)
            add esi, 4
            sub edi, 1
            jnz @B

            EDtext pBuf1                                ; display the output buffer

            pop edi
            pop esi
            pop ebx

            free hMain
            free hMem

          Case 102
          ; ********************************
          ; display ascending sorted strings
          ; ********************************
            invoke create_array,LENGTHOF pstrings,16
            mov hMem, eax
            mov hMain, ecx

            push ebx
            push esi
            push edi

            mov esi, OFFSET pstrings
            mov edi, hMem
            sub esi, 4
            sub edi, 4
            mov ebx, LENGTHOF pstrings

          @@:
            add esi, 4
            add edi, 4
            invoke szCopy,[esi],[edi]
            sub ebx, 1
            jnz @B
          ; --------------------------------------
            invoke assort,hMem,LENGTHOF pstrings,0
          ; --------------------------------------
            mov pBuf1, ptr$(buffer1)
            mov esi, hMem
            mov edi, LENGTHOF pstrings
          @@:
            invoke szCatStr,pBuf1,[esi]
            invoke szCatStr,pBuf1,chr$(13,10)
            add esi, 4
            sub edi, 1
            jnz @B

            EDtext pBuf1

            pop edi
            pop esi
            pop ebx

            free hMain
            free hMem

          Case 103
          ; *********************************
          ; display descending sorted strings
          ; *********************************
            invoke create_array,LENGTHOF pstrings,16
            mov hMem, eax
            mov hMain, ecx

            push ebx
            push esi
            push edi

            mov esi, OFFSET pstrings
            mov edi, hMem
            sub esi, 4
            sub edi, 4
            mov ebx, LENGTHOF pstrings

          @@:
            add esi, 4
            add edi, 4
            invoke szCopy,[esi],[edi]
            sub ebx, 1
            jnz @B
          ; --------------------------------------
            invoke dssort,hMem,LENGTHOF pstrings,0
          ; --------------------------------------
            mov pBuf1, ptr$(buffer1)
            mov esi, hMem
            mov edi, LENGTHOF pstrings
          @@:
            invoke szCatStr,pBuf1,[esi]
            invoke szCatStr,pBuf1,chr$(13,10)
            add esi, 4
            sub edi, 1
            jnz @B

            EDtext pBuf1

            pop edi
            pop esi
            pop ebx

            free hMain
            free hMem

          Case 104
            EDclear

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

end start
