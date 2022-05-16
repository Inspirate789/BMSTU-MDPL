; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

; This demo shows how to do a number of things.
;
; 1. How to use the DDPROTO macro to prototype an address for use with invoke
; 2. How to load the returned VTABLE from the DLL into .DATA section variables.
; 3. How to call the procedures at the addresses in the vtable with invoke.

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

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

; д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д

      includelib vtdll.lib                  ; include the library from the DLL

      vtquery PROTO                         ; prototype the query function

      ShowAboutBox DDPROTO(item1,2)         ; prototype the address in .DATA section
      SelectFile   DDPROTO(item2,2)         ; prototype the address in .DATA section
      UserIP       DDPROTO(item3,2)         ; prototype the address in .DATA section
      UserInput    DDPROTO(item4,2)         ; prototype the address in .DATA section

; д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д=ў=д

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
      ; --------------------------------------
      ; variables to write vtable addresses to.
      ; --------------------------------------
        item1     dd ?
        item2     dd ?
        item3     dd ?
        item4     dd ?

    .code

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

start: 
    mov hInstance, FUNC(GetModuleHandle,NULL)
    call main
    invoke ExitProcess,eax

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

main proc

    invoke vtquery      ; get the virtual table address from the DLL

  ; ------------------------------------------------------
  ; load the data section variables with each DLL function
  ; address from the virtual table returned from the DLL.
  ; ------------------------------------------------------

    mov ecx, [eax]      ; dereference it to get each function address
    mov item1, ecx      ; write address to variable in .DATA section

    mov ecx, [eax+4]
    mov item2, ecx

    mov ecx, [eax+8]
    mov item3, ecx

    mov ecx, [eax+12]
    mov item4, ecx

  ; ------------------------------------------------------

    invoke InitCommonControls

    Dialog "   ", \                         ; caption
           "MS Sans Serif",10, \            ; font,pointsize
            WS_OVERLAPPED or \              ; styles for
            WS_SYSMENU or DS_CENTER, \      ; dialog window
            9, \                            ; number of controls
            50,50,250,106, \                ; x y co-ordinates
            1024                            ; memory buffer size

    DlgButton "About Box",WS_TABSTOP,5, 5,50,13,101
    DlgButton "Select File",WS_TABSTOP,5,20,50,13,102
    DlgButton "Get IP",WS_TABSTOP,5,35,50,13,103
    DlgButton "Text Input",WS_TABSTOP,5,50,50,13,104
    DlgButton "Unused",WS_TABSTOP,5,65,50,13,105
    DlgButton "Clear",WS_TABSTOP,60,65,50,13,106
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

    STRING MainTitle,"Virtual Table Test Bed"

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
          ; -------------------------------------------------
          ; use the normal invoke syntax for the DLL function
          ; -------------------------------------------------
            invoke ShowAboutBox,hWnd,hInstance

          Case 102
          ; -------------------------------------------------
          ; use the normal invoke syntax for the DLL function
          ; -------------------------------------------------
            invoke SelectFile,hWnd,hInstance

          Case 103
          ; -------------------------------------------------
          ; use the normal invoke syntax for the DLL function
          ; -------------------------------------------------
            invoke UserIP,hWnd,hInstance

          Case 104
          ; -------------------------------------------------
          ; use the normal invoke syntax for the DLL function
          ; -------------------------------------------------
            invoke UserInput,hWnd,hInstance

          Case 105
            fn MessageBox,hWnd,"This entry REALLY is unused","Smile",MB_OK

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

end start
