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
      includelib \masm32\lib\msvcrt.lib

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

    Dialog "New MASM32 Lib Demo", \         ; caption
           "MS Sans Serif",10, \            ; font,pointsize
            WS_OVERLAPPED or \              ; styles for
            WS_SYSMENU or DS_CENTER, \      ; dialog window
            3, \                            ; number of controls
            50,50,155,100, \                ; x y co-ordinates
            1024                            ; memory buffer size

    DlgButton "Test",WS_TABSTOP,106,5,40,13,IDOK
    DlgButton "Cancel",WS_TABSTOP,106,20,40,13,IDCANCEL
    DlgStatic "High level File IO Emulation",SS_LEFT,5,5,90,9,100

    CallModalDialog hInstance,0,DlgProc,NULL

    ret

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

DlgProc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD 

    LOCAL patn  :DWORD
    LOCAL pMem  :DWORD
    LOCAL flen  :DWORD
    LOCAL fname :DWORD
    LOCAL wmsg  :DWORD
    LOCAL str1  :DWORD
    LOCAL buffer[128]:BYTE

    Switch uMsg
      Case WM_INITDIALOG
        invoke SendMessage,hWin,WM_SETICON,1,
                           FUNC(LoadIcon,NULL,IDI_ASTERISK)
        m2m hWnd, hWin
        return 1
      Case WM_COMMAND
        Switch wParam
          Case IDOK
            mov patn, CTXT("all files",0,"*.*",0)
            mov fname, OpenFileDlg(hWin,hInstance,"Select File",patn)
            cmp BYTE PTR [eax], 0
            jne @F
            return 0
          @@:
            mov pMem, InputFile(fname)
          ; -------------------------------------
          ; 2 nested remove$ macros to remove 2
          ; different substrings from the source
          ; -------------------------------------
            mov pMem, remove$(pMem,"л")
            mov pMem, remove$(pMem,SADD("; ",13,10))
          ; -------------------------------------
            mov fname, SaveFileDlg(hWin,hInstance,"Save File",patn)
            cmp BYTE PTR [eax], 0
            jne @F
            return 0
          @@:
            mov flen, len(pMem)
            cmp OutputFile(fname,pMem,flen), 0
            jne @F
            MsgBox hWin,"Save operation failed","Problem",MB_OK or MB_ICONEXCLAMATION
            free pMem
            return 0
          @@:
            mov str1, ptr$(buffer)
            mov wmsg, cat$(str1,ustr$(flen)," bytes written to disk")
            MsgBox hWnd,wmsg,"File IO Result",MB_OK
            free pMem

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
