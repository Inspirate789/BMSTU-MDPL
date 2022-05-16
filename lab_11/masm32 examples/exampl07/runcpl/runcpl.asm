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

      FUNC MACRO parameters:VARARG
        invoke parameters
        EXITM <eax>
      ENDM

      include \masm32\include\dialogs.inc

      dlgproc  PROTO :DWORD,:DWORD,:DWORD,:DWORD
      ListProc PROTO :DWORD,:DWORD,:DWORD,:DWORD

    .data?
        hInstance   dd ?
        hList       dd ?
        lpListProc  dd ?

    .code

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл


start:

      mov hInstance, FUNC(GetModuleHandle,NULL)
      invoke InitCommonControls ; <<<< needed because of manifest file

      call main

      invoke ExitProcess,eax

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

main proc

    Dialog "Mini Control Panel", \           ; caption
           "MS Sans Serif",8, \              ; font,pointsize
            WS_OVERLAPPED or \               ; styles for
            WS_SYSMENU or DS_CENTER, \       ; dialog window
            2, \                             ; number of controls
            50,50,250,155, \                 ; x y co-ordinates
            1024                             ; memory buffer size

    DlgButton "Cancel",WS_TABSTOP,190,5,50,15,IDCANCEL
    DlgList WS_BORDER or LBS_NOINTEGRALHEIGHT or WS_VSCROLL,5,5,180,126,105

    CallModalDialog hInstance,0,dlgproc,NULL

    ret

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

dlgproc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

    LOCAL hDC:DWORD
    LOCAL ps :PAINTSTRUCT
    LOCAL dirbuffer[260]:BYTE

    .if uMsg == WM_INITDIALOG
      invoke SendMessage,hWin,WM_SETICON,1,
                         FUNC(LoadIcon,NULL,IDI_ASTERISK)

      invoke GetDlgItem,hWin,105
      mov hList, eax

      invoke SetWindowLong,hList,GWL_WNDPROC,ListProc
      mov lpListProc, eax

      invoke GetSystemDirectory,ADDR dirbuffer,260
      invoke szCatStr,ADDR dirbuffer,SADD("\*.cpl")
      invoke LoadList,hList,ADDR dirbuffer

    .elseif uMsg == WM_PAINT
      invoke FrameWindow,hWin,0,1,1

    .elseif uMsg == WM_COMMAND
      .if wParam == IDCANCEL
        jmp quit_dialog
      .endif

    .elseif uMsg == WM_CLOSE
      quit_dialog:
      invoke EndDialog,hWin,0

    .endif

    xor eax, eax
    ret

dlgproc endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

ListProc proc hCtl   :DWORD,
              uMsg   :DWORD,
              wParam :DWORD,
              lParam :DWORD

    LOCAL xPos :DWORD
    LOCAL yPos :DWORD
    LOCAL buffer[64]:BYTE
    LOCAL path[260]:BYTE

  ; -----------------------------
  ; Process control messages here
  ; -----------------------------

    .if uMsg == WM_KEYUP
        cmp wParam, VK_RETURN
        je lbc

    .elseif uMsg == WM_LBUTTONDBLCLK
        lbc:
        mov BYTE PTR buffer[0], 0
        invoke SendMessage,hCtl,LB_GETCURSEL,0,0
        mov ecx, eax
        invoke SendMessage,hCtl,LB_GETTEXT,ecx,ADDR buffer
        invoke GetSystemDirectory,ADDR path,260

        STRING RunDLL,"rundll32.exe shell32.dll,Control_RunDLL "
        mov BYTE PTR path[0], 0
        invoke szMultiCat,2,ADDR path,ADDR RunDLL,ADDR buffer
        invoke WinExec,ADDR path,SW_SHOW

    .endif

    invoke CallWindowProc,lpListProc,hCtl,uMsg,wParam,lParam

    ret

ListProc endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start
