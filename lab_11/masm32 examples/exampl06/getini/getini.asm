; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

comment * --------------------------------------------
        A simple example of how to use the linein$ and
        lineout$ macros to read and write an INI file.
        In this example you can start this exe file,
        change the values in the INI file and save the
        changes to disk.
        -------------------------------------------- *

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

      DlgProc PROTO :DWORD,:DWORD,:DWORD,:DWORD 
 
    .data?
      hWnd      dd ?
      hInstance dd ?
      hEdit1    dd ?
      hEdit2    dd ?
      hEdit3    dd ?
      hEdit4    dd ?
      hEdit5    dd ?

    .code

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

start:
  
      mov hInstance, FUNC(GetModuleHandle,NULL)

      call main

      invoke ExitProcess,eax

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

main proc

    Dialog "Load from INI File", \          ; caption
           "MS Sans Serif",10, \            ; font,pointsize
            WS_OVERLAPPED or \              ; styles for
            WS_SYSMENU or DS_CENTER, \      ; dialog window
            7, \                            ; number of controls
            50,50,155,105, \                ; x y co-ordinates
            1024                            ; memory buffer size

    DlgButton "Save",WS_TABSTOP,106,5,40,13,IDOK
    DlgButton "Close",WS_TABSTOP,106,20,40,13,IDCANCEL
    DlgEdit ES_LEFT or WS_BORDER or WS_TABSTOP,10,10,90,12,150
    DlgEdit ES_LEFT or WS_BORDER or WS_TABSTOP,10,25,90,12,151
    DlgEdit ES_LEFT or WS_BORDER or WS_TABSTOP,10,40,90,12,152
    DlgEdit ES_LEFT or WS_BORDER or WS_TABSTOP,10,55,90,12,153
    DlgEdit ES_LEFT or WS_BORDER or WS_TABSTOP,10,70,90,12,154

    CallModalDialog hInstance,0,DlgProc,NULL

    ret

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

DlgProc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD 

    LOCAL pMem  :DWORD
    LOCAL flen  :DWORD
    LOCAL rpos  :DWORD
    LOCAL wpos  :DWORD
    LOCAL buffer[128]:BYTE

    Switch uMsg
      Case WM_INITDIALOG
        invoke SendMessage,hWin,WM_SETICON,1,
                           FUNC(LoadIcon,NULL,IDI_ASTERISK)
        m2m hWnd, hWin
      ; -------------------------------------
      ; get the handles for the edit controls
      ; -------------------------------------
        mov hEdit1, FUNC(GetDlgItem,hWin,150)
        mov hEdit2, FUNC(GetDlgItem,hWin,151)
        mov hEdit3, FUNC(GetDlgItem,hWin,152)
        mov hEdit4, FUNC(GetDlgItem,hWin,153)
        mov hEdit5, FUNC(GetDlgItem,hWin,154)

        mov pMem, InputFile("getini.ini")   ; load the INI file into memory
        mov rpos, 0                         ; zero the read position pointer

      ; ------------------------------------------------------
      ; read each line of text and write it to an edit control
      ; ------------------------------------------------------
        mov rpos, linein$(pMem,ADDR buffer,rpos)
        invoke SendMessage,hEdit1,WM_SETTEXT,0,ADDR buffer

        mov rpos, linein$(pMem,ADDR buffer,rpos)
        invoke SendMessage,hEdit2,WM_SETTEXT,0,ADDR buffer

        mov rpos, linein$(pMem,ADDR buffer,rpos)
        invoke SendMessage,hEdit3,WM_SETTEXT,0,ADDR buffer

        mov rpos, linein$(pMem,ADDR buffer,rpos)
        invoke SendMessage,hEdit4,WM_SETTEXT,0,ADDR buffer

        mov rpos, linein$(pMem,ADDR buffer,rpos)
        invoke SendMessage,hEdit5,WM_SETTEXT,0,ADDR buffer

        free pMem                           ; free the memory

        return 1

      Case WM_COMMAND
        Switch wParam
          Case IDOK
            mov pMem, alloc(4096)           ; allocate a buffer for the INI data
            mov wpos, 0                     ; zero the write position pointer

          ; --------------------------------------------------------------------
          ; write the contents sequentially from the edit controls to the buffer
          ; --------------------------------------------------------------------
            invoke GetWindowText,hEdit1,ADDR buffer,128
            mov wpos, lineout$(ADDR buffer,pMem,wpos,0)

            invoke GetWindowText,hEdit2,ADDR buffer,128
            mov wpos, lineout$(ADDR buffer,pMem,wpos,0)

            invoke GetWindowText,hEdit3,ADDR buffer,128
            mov wpos, lineout$(ADDR buffer,pMem,wpos,0)

            invoke GetWindowText,hEdit4,ADDR buffer,128
            mov wpos, lineout$(ADDR buffer,pMem,wpos,0)

            invoke GetWindowText,hEdit5,ADDR buffer,128
            mov wpos, lineout$(ADDR buffer,pMem,wpos,0)

            cmp OutputFile("getini.ini",pMem,len(pMem)), 0

            free pMem

            jmp outa_here

          Case IDCANCEL
            outa_here:
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
