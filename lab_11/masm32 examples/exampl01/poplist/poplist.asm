; #########################################################################
;
;   This demo shows a useful trick to get around an artificial limit that
;   MASM imposes on the length of string data. It loads a long string that
;   is delimited by a single zero and terminated by two zeros, reads each
;   entry and loads each entry into the list box. This allows very large
;   numbers of entries to stored in an EXE file without clumsy multiple
;   addressing for the entries in the data section.
;
;   Use the included QBASIC file to convert a list of text items into the
;   format needed below. There is no practical limit imposed on this
;   technique so you can make large lists in this manner. NOTE that the
;   items in the list must not include quotation marks [ " ] or the backslash
;   character [ \ ] as these have special meaning in the DB format that the
;   text in converted to.
;
; #########################################################################

      .386
      .model flat, stdcall
      option casemap :none   ; case sensitive

; #########################################################################

      include \masm32\include\windows.inc
      include \masm32\include\gdi32.inc
      include \masm32\include\user32.inc
      include \masm32\include\kernel32.inc

      includelib \masm32\lib\gdi32.lib
      includelib \masm32\lib\user32.lib
      includelib \masm32\lib\kernel32.lib

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

      m2m MACRO M1, M2
        push M2
        pop  M1
      ENDM

      return MACRO arg
        mov eax, arg
        ret
      ENDM

        ;=================
        ; Local prototypes
        ;=================
        WinMain PROTO :DWORD,:DWORD,:DWORD,:DWORD
        WndProc PROTO :DWORD,:DWORD,:DWORD,:DWORD
        TopXY PROTO   :DWORD,:DWORD

    .data
        szDisplayName db "Popup List Demo",0
        CommandLine   dd 0
        hWnd          dd 0
        hInstance     dd 0
        lpfnWndProc   dd 0

        ItemBuffer    db 128 dup (?)

      ; ---------------------------------------------------
      ; The following include file is a list converted to
      ; a specific format by the QBASIC program in this
      ; directory. The format is that each item in the list
      ; is delimited by one zero byte and the list is
      ; terminated by two zero bytes. There is an algorithm
      ; in the WinMain procedure that reads this format and
      ; loads the list items individually into the list box.
      ; ---------------------------------------------------

      include list.asm

    .code

start:
        invoke GetModuleHandle, NULL
        mov hInstance, eax

        invoke GetCommandLine
        mov CommandLine, eax

        invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT
        invoke ExitProcess,eax

; #########################################################################

WinMain proc hInst     :DWORD,
             hPrevInst :DWORD,
             CmdLine   :DWORD,
             CmdShow   :DWORD

        ;====================
        ; Put LOCALs on stack
        ;====================

        LOCAL Wwd  :DWORD
        LOCAL Wht  :DWORD
        LOCAL Wtx  :DWORD
        LOCAL Wty  :DWORD
        LOCAL msg  :MSG

        mov Wwd, 200
        mov Wht, 200

        invoke GetSystemMetrics,SM_CXSCREEN
        invoke TopXY,Wwd,eax
        mov Wtx, eax

        invoke GetSystemMetrics,SM_CYSCREEN
        invoke TopXY,Wht,eax
        mov Wty, eax

        szText szClassName,"LISTBOX"

        invoke CreateWindowEx,WS_EX_PALETTEWINDOW or WS_EX_CLIENTEDGE,
                              ADDR szClassName,
                              ADDR szDisplayName,
                              WS_OVERLAPPEDWINDOW or WS_VSCROLL or \
                              LBS_HASSTRINGS or LBS_NOINTEGRALHEIGHT or \
                              LBS_DISABLENOSCROLL, \
                              Wtx,Wty,Wwd,Wht,
                              NULL,NULL,
                              hInst,NULL
        mov   hWnd,eax

        invoke SetWindowLong,hWnd,GWL_WNDPROC,ADDR WndProc
        mov lpfnWndProc, eax

        invoke GetStockObject,ANSI_FIXED_FONT
        invoke SendMessage,hWnd,WM_SETFONT,eax,0

      ; ---------------------------------------------------
      ; This block of code reads a string that is a list of
      ; seperate items delimited by a single zero byte. The
      ; list is terminated by a double zero byte pair.
      ; ---------------------------------------------------
        mov esi, offset item000000
        mov edi, offset ItemBuffer

      @@:
        lodsb
        cmp al, 0   ; get zero
        je SubLp    ; write to list
        stosb
        jmp @B
      SubLp:
        stosb                       ; write terminator
        invoke SendMessage,hWnd,LB_ADDSTRING,0,ADDR ItemBuffer
        lodsb
        cmp al, 0                   ; check for second zero
        je @F                       ; exit if found
        mov edi, offset ItemBuffer  ; reset to start of buffer
        stosb                       ; write test byte to it
        jmp @B
      @@:

      ; --------------------------------------------------------

        invoke ShowWindow,hWnd,SW_SHOWNORMAL
        invoke UpdateWindow,hWnd

      ;===================================
      ; Loop until PostQuitMessage is sent
      ;===================================

    StartLoop:
      invoke GetMessage,ADDR msg,NULL,0,0
      cmp eax, 0
      je ExitLoop
      invoke TranslateMessage, ADDR msg
      invoke DispatchMessage,  ADDR msg
      jmp StartLoop
    ExitLoop:

      return msg.wParam

WinMain endp

; #########################################################################

WndProc proc hWin   :DWORD,
             uMsg   :DWORD,
             wParam :DWORD,
             lParam :DWORD

    .if uMsg == WM_CLOSE

    ; .elseif uMsg == WM_LBUTTONDBLCLK
    ;     szText msgText,"Put your message here if you need it."
    ;     invoke MessageBox,hWin,ADDR msgText,ADDR szDisplayName,MB_OK

    .elseif uMsg == WM_DESTROY
        invoke PostQuitMessage,NULL
        return 0 
    .endif

    invoke CallWindowProc,lpfnWndProc,hWin,uMsg,wParam,lParam

    ret

WndProc endp

; ########################################################################

TopXY proc wDim:DWORD, sDim:DWORD

    shr sDim, 1      ; divide screen dimension by 2
    shr wDim, 1      ; divide window dimension by 2
    mov eax, wDim    ; copy window dimension into eax
    sub sDim, eax    ; sub half win dimension from half screen dimension

    return sDim

TopXY endp

; ########################################################################

end start
