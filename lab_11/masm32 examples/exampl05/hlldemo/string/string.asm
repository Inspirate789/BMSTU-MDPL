; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

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
      include \masm32\include\msvcrt.inc
      include \masm32\macros\macros.asm
      include \masm32\include\dialogs.inc

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
      includelib \masm32\lib\msvcrt.lib

      DlgProc PROTO :DWORD,:DWORD,:DWORD,:DWORD 

    ; -----------------------------
    ; macros for displaying results
    ; -----------------------------
      SBtext MACRO lpString
        invoke SendMessage,hStatus,SB_SETTEXT,255 or SBT_POPOUT,reparg(lpString)
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

    DlgButton "Test 1",WS_TABSTOP,5, 5,50,13,101
    DlgButton "Test 2",WS_TABSTOP,5,20,50,13,102
    DlgButton "Test 3",WS_TABSTOP,5,35,50,13,103
    DlgButton "Test 4",WS_TABSTOP,5,50,50,13,104
    DlgButton "Test 5",WS_TABSTOP,5,65,50,13,105
    DlgButton "Reset",WS_TABSTOP,60,65,50,13,106
    DlgButton "Close",WS_TABSTOP,192,65,50,13,IDCANCEL
    DlgStatus 110
    DlgEdit WS_TABSTOP or ES_MULTILINE or ES_WANTRETURN or ES_LEFT or WS_BORDER or WS_VSCROLL,60,5,182,58,111

    CallModalDialog hInstance,0,DlgProc,NULL

    ret

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

align 4

DlgProc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD 

    LOCAL str1  :DWORD
    LOCAL str2  :DWORD
    LOCAL str3  :DWORD
    LOCAL str4  :DWORD
    LOCAL str5  :DWORD
    LOCAL str6  :DWORD
    LOCAL str7  :DWORD
    LOCAL str8  :DWORD

    LOCAL var1  :DWORD
    LOCAL var2  :DWORD
    LOCAL var3  :DWORD
    LOCAL var4  :DWORD

    LOCAL hDC   :DWORD 
    LOCAL ps    :PAINTSTRUCT 
    LOCAL rct   :RECT 
    LOCAL crct  :RECT 
    LOCAL buffer1[512]:BYTE 
    LOCAL buffer2[260]:BYTE 
    LOCAL buffer3[260]:BYTE 
    LOCAL buffer4[260]:BYTE 

    STRING MainTitle,"High level string emulation demo"

    Switch uMsg
      Case WM_INITDIALOG
        invoke SendMessage,hWin,WM_SETICON,1,
                           FUNC(LoadIcon,NULL,IDI_ASTERISK)
        push hWin
        pop hWnd

        invoke SetWindowText,hWin,ADDR MainTitle

        mov hStatus, FUNC(GetDlgItem,hWnd,110)
        mov hEdit,   FUNC(GetDlgItem,hWnd,111)

        invoke SendMessage,hEdit,WM_SETFONT,
                           FUNC(GetStockObject,ANSI_FIXED_FONT),TRUE
        return 1

      Case WM_COMMAND
        Switch wParam
          Case 101
            mov str1, ptr$(buffer1)
            mov str2, lcase$(cat$(str1,pth$(),"settings.ini"))
            TBtext str2
            EDtext "Get app path and append a new INI file name to it."

          Case 102
            mov str1, ptr$(buffer1)
            mov str2, cat$(str1,"Current directory is ",lcase$(CurDir$()),SADD(13,10))
            mov str3, cat$(str2,"Windows directory is ",lcase$(WinDir$()),SADD(13,10))
            mov str4, cat$(str3,"System  directory is ",lcase$(SysDir$()))
            EDtext str4
            TBtext "Parsing directory functions"

          Case 103
            mov str1, ptr$(buffer1)
            mov str3, ptr$(buffer2)
            mov str2, CTXT("  data entry,  ")
            invoke szCopy,str2,str1
            mov str1, trim$(remove$(str1,","))
            mov str4, cat$(str3,SADD("Original string ",34),str2,SADD(34,13,10)) 
            mov str4, cat$(str4,SADD("Cleaned up string ",34),str1,SADD(34))
            EDtext str4
            TBtext "Remove unwanted characters and trim string"

          Case 104
            mov str1, ptr$(buffer1)
            mov str2, ptr$(buffer2)
            mov str3, CTXT("12345 this is a test of left$ and right$ 67890")
            invoke szCopy,str3,str1
            invoke szCopy,str3,str2
            mov str1, left$(str1,5)
            mov str2, right$(str2,5)
            mov str4, cat$(str1,str2)
            EDtext str4
            TBtext "left$ and right$ test"

          Case 105
            mov str1, CTXT("12345678")
            mov str2, CTXT("Original number ")
            mov str3, CTXT("With 125 added ")
            mov str4, ptr$(buffer1)
            mov str5, ptr$(buffer2)
            invoke szCopy,str1,str5
            mov str6, ustr$(ASM(add uval(str5), 125))
            mov str7, cat$(str4,str2,str1,SADD(13,10),str3,str6)

            EDtext str7
            TBtext "String to number, modify number, number to string"

          Case 106
            EDclear
            invoke SendMessage,hStatus,SB_SETTEXT,255,NULL
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

end start
