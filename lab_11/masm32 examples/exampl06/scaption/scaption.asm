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

      DlgProc PROTO :DWORD,:DWORD,:DWORD,:DWORD
      rotate_caption PROTO :DWORD
 
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

    Dialog "Scrolling Caption in MASM32 Dialog", \                ; caption
           "MS Sans Serif",10, \            ; font,pointsize
            WS_OVERLAPPED or \              ; styles for
            WS_SYSMENU or DS_CENTER, \      ; dialog window
            3, \                            ; number of controls
            50,50,200,100, \                ; x y co-ordinates
            1024                            ; memory buffer size

    DlgButton "Scroll",WS_TABSTOP,150,5,40,13,IDOK
    DlgButton "Cancel",WS_TABSTOP,150,20,40,13,IDCANCEL
    DlgStatic "MASM32 Dialog",SS_LEFT,5,5,60,9,100

    CallModalDialog hInstance,0,DlgProc,NULL

    ret

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

DlgProc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD 

    LOCAL pbuf  :DWORD
    LOCAL tlen  :DWORD
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
            mov pbuf, ptr$(buffer)
            invoke GetWindowText,hWin,pbuf,128
            mov tlen, len(pbuf)
          @@:
            Invoke Sleep,50
            invoke rotate_caption,pbuf
            invoke SetWindowText,hWin,pbuf
            sub tlen, 1
            jnz @B

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

OPTION PROLOGUE:NONE                ; turn off the stack frame
OPTION EPILOGUE:NONE 

rotate_caption proc pbuf:DWORD

    mov edx, [esp+4]                ; load string address in EDX
    mov cl, [edx]                   ; get 1st byte of string
    add edx, 1                      ; move to next location in string

  @@:
    mov al, [edx]                   ; read character into AL
    add edx, 1                      ; increment addess
    test al, al                     ; test if AL = 0
    jz @F                           ; exit loop if it is
    mov [edx-2], al                 ; write AL back to buffer
    jmp @B

  @@:
    mov [edx-2], cl                 ; write 1st byte to end
    mov BYTE PTR [edx-1], 0         ; write terminator

    ret 4                           ; balance the stack

rotate_caption endp

OPTION PROLOGUE:PrologueDef         ; turn it back on again
OPTION EPILOGUE:EpilogueDef 

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start
