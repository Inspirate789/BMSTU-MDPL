; #########################################################################

      .386
      .model flat, stdcall
      option casemap :none   ; case sensitive

; #########################################################################

      include \masm32\include\windows.inc
      include \masm32\include\user32.inc
      include \masm32\include\kernel32.inc
      include \masm32\include\gdi32.inc
      include \masm32\include\masm32.inc

      includelib \masm32\lib\user32.lib
      includelib \masm32\lib\kernel32.lib
      includelib \masm32\lib\gdi32.lib
      includelib \masm32\lib\masm32.lib

; #########################################################################

        ;=============
        ; Local macros
        ;=============
  
        szText MACRO Name, Text:VARARG
          LOCAL lbl
            jmp lbl
              Name db Text,0
            lbl:
          ENDM
          
        ;=================
        ; Local prototypes
        ;=================
        WndProc   PROTO :DWORD,:DWORD,:DWORD,:DWORD
        Edit1Proc PROTO :DWORD,:DWORD,:DWORD,:DWORD

        
    .data
        hWnd        dd 0
        hEdit1      dd 0
        hEdit2      dd 0
        hButn1      dd 0
        hButn2      dd 0
        hInstance   dd 0
        hIconImage  dd 0
        hIcon       dd 0
        lpfnEdit1Proc dd 0

        dlgname     db "TESTWIN",0
        fMtStrinG   db "%lu",0      ; this is for wsprintf


; #########################################################################

    .code

start:

      invoke GetModuleHandle, NULL
      mov hInstance, eax
      
      ; -------------------------------------------
      ; Call the dialog box stored in resource file
      ; -------------------------------------------
      invoke DialogBoxParam,hInstance,ADDR dlgname,0,ADDR WndProc,0

      invoke ExitProcess,eax

; #########################################################################

WndProc proc hWin   :DWORD,
             uMsg   :DWORD,
             wParam :DWORD,
             lParam :DWORD

      LOCAL TheValue     :DWORD     ; use LOCAL variable on the
      LOCAL inBuffer[64] :BYTE      ; stack as they are more
      LOCAL outBuffer[64]:BYTE      ; efficient with file size.

      .if uMsg == WM_INITDIALOG
      ; --------------------------------
      ; set up required items at startup
      ; --------------------------------

        mov eax, hWin
        mov hWnd, eax

        szText dlgTitle,"Register Key"
        invoke SendMessage,hWin,WM_SETTEXT,0,ADDR dlgTitle

        invoke LoadIcon,hInstance,200
        mov hIcon, eax

        invoke SendMessage,hWin,WM_SETICON,1,hIcon

      ; --------------------
      ; edit control handles
      ; --------------------
        invoke GetDlgItem,hWin,100
        mov hEdit1, eax

      ; ----------------------------------------
      ; subclass 1st one so text can be filtered
      ; ----------------------------------------
        invoke SetWindowLong,hEdit1,GWL_WNDPROC,Edit1Proc
        mov lpfnEdit1Proc, eax

        invoke GetDlgItem,hWin,101
        mov hEdit2, eax

      ; --------------
      ; button handles
      ; --------------
        invoke GetDlgItem,hWin,1000
        mov hButn1, eax

        invoke GetDlgItem,hWin,1001
        mov hButn2, eax

      ; -----------------------------------------
      ; process the messages from the two buttons
      ; -----------------------------------------
      .elseif uMsg == WM_COMMAND
        .if wParam == 1000      ; convert 1st text

        invoke GetWindowText,hEdit1,ADDR inBuffer,40
      ; ------------------------
      ; text is now in inBuffer,
      ; test if its blank.
      ; ------------------------
        lea esi, inBuffer       ; get 1st byte
        lodsb
        cmp al, 0               ; see if its ascii zero
        jne @F
          invoke SetFocus,hEdit1
          xor eax, eax          ; return zero if blank
          ret
        @@:

        invoke atodw,ADDR inBuffer   ; convert text to DWORD value
        mov TheValue, eax

      ; -------------------------------------------------------------
      ; Do the function call here for the numeric conversion you need
      ; using the DWORD value converted from the text input. When it
      ; is done, use the following conversion of the result back to
      ; text and display it in the second edit control.
      ; -------------------------------------------------------------

        invoke wsprintf,ADDR outBuffer,ADDR fMtStrinG,TheValue

        invoke SetWindowText,hEdit2,ADDR outBuffer

        .elseif wParam == 1001  ; the exit button
          jmp GetOutaHere

        .endif

      .elseif uMsg == WM_CLOSE  ; for system close button
        GetOutaHere:
        invoke EndDialog,hWin,0

      .endif

    xor eax, eax    ; this must be here in NT4
    ret

WndProc endp

; #########################################################################

Edit1Proc proc hCtl   :DWORD,
               uMsg   :DWORD,
               wParam :DWORD,
               lParam :DWORD

    LOCAL tl:DWORD
    LOCAL testBuffer[16]:BYTE

  ; -----------------------------
  ; Process control messages here
  ; -----------------------------

    .if uMsg == WM_CHAR

      .if wParam == 8       ; allow backspace
        jmp @F              ; jump FORWORD to next @@:
      .endif

    invoke GetWindowText,hCtl,ADDR testBuffer,16
    invoke lnstr,ADDR testBuffer

      .if eax >= 10         ; restrict length to 10 digits
        xor eax, eax
        ret
      .endif
    ; ------------------
    ; allow numbers only
    ; ------------------
      .if wParam > 57
          xor eax, eax
          ret
      .elseif wParam < 48
          xor eax, eax
          ret
      .endif

    @@:

    .endif

    invoke CallWindowProc,lpfnEdit1Proc,hCtl,uMsg,wParam,lParam

    ret

Edit1Proc endp

; #########################################################################

end start
