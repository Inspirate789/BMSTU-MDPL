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

      DlgProc  PROTO :DWORD,:DWORD,:DWORD,:DWORD
      ListProc PROTO :DWORD,:DWORD,:DWORD,:DWORD
 
    .data?
      hWnd          dd ?
      hInstance     dd ?
      hList         dd ?
      lpListProc    dd ?

    .code

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

start:
  
      mov hInstance, FUNC(GetModuleHandle,NULL)

      call main

      invoke ExitProcess,eax

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

main proc

    Dialog "Set Desktop Wallpaper", \       ; caption
           "MS Sans Serif",10, \            ; font,pointsize
            WS_OVERLAPPED or \              ; styles for
            WS_SYSMENU or DS_CENTER, \      ; dialog window
            3, \                            ; number of controls
            50,50,223,138, \                ; x y co-ordinates
            1024                            ; memory buffer size

    DlgList LBS_DISABLENOSCROLL or LBS_SORT or WS_BORDER or WS_VSCROLL,10,16,200,85,100
    DlgButton "Close",WS_TABSTOP,170,103,40,12,IDCANCEL
    DlgStatic "Double click file to select",SS_LEFT,10,6,200,10,999

    CallModalDialog hInstance,0,DlgProc,NULL

    ret

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

DlgProc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD 

    LOCAL hLabel    :DWORD
    LOCAL hButn     :DWORD
    LOCAL hFont     :DWORD

    Switch uMsg

      case WM_PAINT
        invoke FrameWindow,hWin,4,1,1

      Case WM_INITDIALOG
        invoke SendMessage,hWin,WM_SETICON,1,rv(LoadIcon,NULL,IDI_ASTERISK)

        mov hLabel, rv(GetDlgItem,hWin,999)
        mov hButn,  rv(GetDlgItem,hWin,IDCANCEL)
        mov hList,  rv(GetDlgItem,hWin,100)  ; get the list box handle

        mov hFont, rv(GetStockObject,ANSI_VAR_FONT)

        fn SendMessage,hLabel,WM_SETFONT,hFont,TRUE
        fn SendMessage,hButn,WM_SETFONT,hFont,TRUE
        fn SendMessage,hList,WM_SETFONT,hFont,TRUE

      ; -----------
      ; subclass it
      ; -----------
        invoke SetWindowLong,hList,GWL_WNDPROC,ListProc
        mov lpListProc, eax

        chdir WinDir$()                     ; change to the Windows directory
        fn LoadList,hList,"*.bmp"           ; load all of the bitmap names into the list box

        m2m hWnd, hWin
        return 1
      Case WM_COMMAND
        Switch wParam
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

ListProc proc hCtl   :DWORD,
              uMsg   :DWORD,
              wParam :DWORD,
              lParam :DWORD

    LOCAL pFile :DWORD
    LOCAL buffer[260]:BYTE

    ; ------------------------------------------------
    ; double click on bitmap file name to select image
    ; ------------------------------------------------
    .if uMsg == WM_LBUTTONDBLCLK
      lbl1:
      mov pFile, ptr$(buffer)
      invoke SendMessage,hCtl,LB_GETTEXT,rv(SendMessage,hCtl,LB_GETCURSEL,0,0),pFile
      invoke SystemParametersInfo,SPI_SETDESKWALLPAPER,NULL,pFile,SPIF_UPDATEINIFILE

    .elseif uMsg == WM_KEYUP
      .if wParam == VK_RETURN
        jmp lbl1
      .endif
    .endif

    invoke CallWindowProc,lpListProc,hCtl,uMsg,wParam,lParam

    ret

ListProc endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start
