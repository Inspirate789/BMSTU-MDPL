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
      include \masm32\macros\macros.asm
      include \masm32\macros\ucmacros.asm       ;<<<< unicode macros

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

      include \masm32\include\dialogs.inc

      DlgProc PROTO :DWORD,:DWORD,:DWORD,:DWORD 

    .data?
      hWnd      dd ?
      hInstance dd ?

    .data
      WSTR winmsg,"UNICODE test piece"          ;<<<< unicode data section macro

    .code

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

start:
  
      mov hInstance, FUNC(GetModuleHandle,NULL)

      call main

      invoke ExitProcess,eax

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

main proc

    Dialog " ", \                           ; caption
           "MS Sans Serif",10, \            ; font,pointsize
            WS_OVERLAPPED or \              ; styles for
            WS_SYSMENU or DS_CENTER, \      ; dialog window
            3, \                            ; number of controls
            50,50,155,100, \                ; x y co-ordinates
            1024                            ; memory buffer size

    DlgButton "Test Me",WS_TABSTOP,106,5,40,13,IDOK
    DlgButton "Cancel",WS_TABSTOP,106,20,40,13,IDCANCEL
    DlgStatic "UNICODE string test",SS_LEFT,5,5,60,9,100

    CallModalDialog hInstance,0,DlgProc,NULL

    ret

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

DlgProc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD 

    LOCAL hwchar:DWORD

    Switch uMsg
      Case WM_INITDIALOG
        invoke SetWindowTextW,hWin,OFFSET winmsg            ;<<<< unicode API

        invoke SendMessage,hWin,WM_SETICON,1,
                           FUNC(LoadIcon,NULL,IDI_ASTERISK)
        m2m hWnd, hWin
        return 1
      Case WM_COMMAND
        Switch wParam
          Case IDOK

            .data
            ; -------------------------------------------------------------------------
            ; these control characters are placed directly in the DATA section to
            ; avoid any MASM macros that use the control characters. This allows any
            ; character to be displayed without conflict with the macro system in MASM.
            ; -------------------------------------------------------------------------
              ustring$ db "Control characters ) ( <> ! & ",0
            .code

            invoke a2wc,ADDR ustring$                       ;<<<< convert ANSI to UNICODE
            mov hwchar, eax
          ; -----------
          ; unicode API
          ; -----------
            invoke MessageBoxW,hWnd,uni$("This is a test of the uni$ macro to write unicode directly in a function call"),
                                    hwchar,
                                    MB_OK or MB_ICONINFORMATION
            free$ hwchar    ; deallocate memory for unicode string

          Case IDCANCEL
            jmp quit_dialog
        EndSw
      Case WM_CLOSE
        quit_dialog:
         invoke EndDialog,hWin,0
    EndSw

    return 0

DlgProc endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start















