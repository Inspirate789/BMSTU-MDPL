; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

comment * ----------------------------------------------------------
        This demo shows the standard technique for using unicode
        by storing string data in the .DATA section which is unicode
        text format and subsequently retrieving the strings using
        the LoadStringW() unicode version and displaying the string
        data on the title bar and in a messagebox.

        The advantage of this technique is that the string data
        can be edited externally for purposes like the
        internationalisation of an application when the original
        author may not have the language skills to write the
        string data in another language.
        ---------------------------------------------------------- *

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

      unistr$ MACRO resID,buffer,ccount
        invoke LoadStringW,hInstance,resID,ADDR buffer,ccount
        EXITM <ADDR buffer>
      ENDM


      DlgProc PROTO :DWORD,:DWORD,:DWORD,:DWORD 
 
    .data?
      hWnd      dd ?
      hInstance dd ?

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
            50,50,175,100, \                ; x y co-ordinates
            1024                            ; memory buffer size

    DlgButton "OK",WS_TABSTOP,126,5,40,13,IDOK
    DlgButton "Cancel",WS_TABSTOP,126,20,40,13,IDCANCEL
    DlgStatic "Click OK for a UNICODE MessageBox",SS_LEFT,5,5,120,9,100

    CallModalDialog hInstance,0,DlgProc,NULL

    ret

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

DlgProc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD 

    LOCAL buffer1[128]:WORD     ; unicode character buffers
    LOCAL buffer2[128]:WORD

    Switch uMsg
      Case WM_INITDIALOG
        invoke SetWindowTextW,hWin,unistr$(1501,buffer1,128)

        invoke SendMessage,hWin,WM_SETICON,1,
                           FUNC(LoadIcon,NULL,IDI_ASTERISK)
        m2m hWnd, hWin
        return 1
      Case WM_COMMAND
        Switch wParam
          Case IDOK
            invoke LoadStringW,hInstance,1500,ADDR buffer1,128
            invoke LoadStringW,hInstance,1502,ADDR buffer2,128
            invoke MessageBoxW,hWnd,ADDR buffer1,ADDR buffer2,
                               MB_OK or MB_ICONINFORMATION
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
