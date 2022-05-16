; #########################################################################
;
;                       DEMO Custom colour button
;
;   Characteristics : Button with seperate UP and DOWN colours as started.
;   Adjustments : Dynamic colour change, both TEXT and BUTTON colours.
;   Dynamic alignment control. Default font at startup is SYSTEM and
;   can be changed dynamically by providing a valid font handle. Text
;   can also be changed dynamically.

;   The control uses a WM_COMMAND interface to perform most of the ajustments.

;   invoke SendMessage,hButn,WM_COMMAND,0,000000DDh    ; button up colour
;   invoke SendMessage,hButn,WM_COMMAND,1,00000099h    ; button down colour
;   invoke SendMessage,hButn,WM_COMMAND,2,00000000h    ; text up colour
;   invoke SendMessage,hButn,WM_COMMAND,3,00FFFFFFh    ; text down colour

; --------------------------------------------------
;   text alignment, left = 1, centre = 2 right = 3
; --------------------------------------------------
;   invoke SendMessage,hButn,WM_COMMAND,4,2            ; align button text           

;     Either,
;   invoke SetWindowText,hButn,ADDR YourText
;     or
;   invoke SendMessage,hButn,WM_SETTEXT,0,ADDR YourText
;
;   can be used to change the text dynamically.

;   The font is changed using a WM_SETFONT message.
;   invoke SendMessage,hButn,WM_SETFONT,hFont,0        ; set the font

;   NOTE : When you create a font for the control, it must be removed when
;   it is no longer used to prevent a resource memory leak.

;   It can be created by the procedure provided or a direct call to
;   CreateFont API. The font handle must have GLOBAL scope by putting it
;   in the .DATA section.

;   To destroy the font after it is no longer needed, use the DeleteObject
;   API function and test the return value to make sure the resource is
;   released.

; #########################################################################

      .486                      ; create 32 bit code
      .model flat, stdcall      ; 32 bit memory model
      option casemap :none      ; case sensitive

      include butntest.inc      ; local includes for this file

    ; ----------------------------------------------------
    ; use the library with the font and button procedures
    ; ----------------------------------------------------
      include btest.inc
      includelib btest.lib

.code

; #########################################################################

start:

      invoke InitCommonControls

    ; ------------------
    ; set global values
    ; ------------------
      invoke GetModuleHandle, NULL
      mov hInstance, eax

      invoke GetCommandLine
      mov CommandLine, eax

      invoke LoadIcon,hInstance,500    ; icon ID
      mov hIcon, eax

      invoke LoadCursor,NULL,IDC_ARROW
      mov hCursor, eax

      invoke GetSystemMetrics,SM_CXSCREEN
      mov sWid, eax

      invoke GetSystemMetrics,SM_CYSCREEN
      mov sHgt, eax

      invoke MakeFont,18,8,700,FALSE,SADD("times new roman")
      mov RomanFont, eax    ; <<<<<< DELETE this font on EXIT

      call Main

      invoke DeleteObject,RomanFont     ; delete the font

      invoke ExitProcess,eax

; #########################################################################

Main proc

    LOCAL Wwd:DWORD,Wht:DWORD,Wtx:DWORD,Wty:DWORD

    STRING szClassName,"Prostart_Class"

  ; --------------------------------------------
  ; register class name for CreateWindowEx call
  ; --------------------------------------------
    invoke RegisterWinClass,ADDR WndProc,ADDR szClassName,
                       hIcon,hCursor,COLOR_BTNFACE+1

  ; -------------------------------------------------
  ; macro to autoscale window co-ordinates to screen
  ; percentages and centre window at those sizes.
  ; -------------------------------------------------
    AutoScale 75, 70

    invoke CreateWindowEx,WS_EX_LEFT,
                          ADDR szClassName,
                          ADDR szDisplayName,
                          WS_OVERLAPPEDWINDOW,
                          Wtx,Wty,Wwd,Wht,
                          NULL,NULL,
                          hInstance,NULL
    mov hWnd,eax

  ; ---------------------------
  ; macros for unchanging code
  ; ---------------------------
    DisplayWindow hWnd,SW_SHOWNORMAL

    call MsgLoop
    ret

Main endp

; #########################################################################

RegisterWinClass proc lpWndProc:DWORD, lpClassName:DWORD,
                      Icon:DWORD, Cursor:DWORD, bColor:DWORD

    LOCAL wc:WNDCLASSEX

    mov wc.cbSize,         sizeof WNDCLASSEX
    mov wc.style,          CS_BYTEALIGNCLIENT or \
                           CS_BYTEALIGNWINDOW
    m2m wc.lpfnWndProc,    lpWndProc
    mov wc.cbClsExtra,     NULL
    mov wc.cbWndExtra,     NULL
    m2m wc.hInstance,      hInstance
    invoke CreateSolidBrush,00000044h
    mov wc.hbrBackground,  eax
    mov wc.lpszMenuName,   NULL
    m2m wc.lpszClassName,  lpClassName
    m2m wc.hIcon,          Icon
    m2m wc.hCursor,        Cursor
    m2m wc.hIconSm,        Icon

    invoke RegisterClassEx, ADDR wc

    ret

RegisterWinClass endp

; ########################################################################

MsgLoop proc

  ; ------------------------------------------
  ; The following 4 equates are available for
  ; processing messages directly in the loop.
  ; m_hWnd - m_Msg - m_wParam - m_lParam
  ; ------------------------------------------

    LOCAL msg:MSG

    StartLoop:
      invoke GetMessage,ADDR msg,NULL,0,0
      cmp eax, 0
      je ExitLoop
      invoke TranslateMessage, ADDR msg
      invoke DispatchMessage,  ADDR msg
      jmp StartLoop
    ExitLoop:

    mov eax, msg.wParam
    ret

MsgLoop endp

; #########################################################################

WndProc proc hWin   :DWORD,
             uMsg   :DWORD,
             wParam :DWORD,
             lParam :DWORD

    LOCAL var    :DWORD
    LOCAL caW    :DWORD
    LOCAL caH    :DWORD
    LOCAL Rct    :RECT
    LOCAL buffer1[128]:BYTE  ; these are two spare buffers
    LOCAL buffer2[128]:BYTE  ; for text manipulation etc..

    .if uMsg == WM_COMMAND
    ;======== toolbar commands ========
        .if wParam == 550
            invoke SetWindowText,hWin,SADD("Button One")
            invoke SendMessage,hButn1,WM_COMMAND,4,1
            invoke SendMessage,hButn2,WM_COMMAND,4,1
            invoke SendMessage,hButn3,WM_COMMAND,4,1

            invoke SendMessage,hButn1,WM_COMMAND,0,0000DD00h    ; up colour
            invoke SendMessage,hButn1,WM_COMMAND,1,00009900h    ; down colour
            invoke SendMessage,hButn1,WM_COMMAND,2,00000000h    ; up text colour
            invoke SendMessage,hButn1,WM_COMMAND,3,00FFFFFFh    ; down text colour

        .elseif wParam == 551
            invoke SetWindowText,hWin,SADD("Button Two")
            invoke SendMessage,hButn1,WM_COMMAND,4,2
            invoke SendMessage,hButn2,WM_COMMAND,4,2
            invoke SendMessage,hButn3,WM_COMMAND,4,2
            invoke SendMessage,hButn1,WM_COMMAND,0,000000DDh    ; up colour
            invoke SendMessage,hButn1,WM_COMMAND,1,00000099h    ; down colour
            invoke SendMessage,hButn1,WM_COMMAND,2,00000000h    ; up text colour
            invoke SendMessage,hButn1,WM_COMMAND,3,00FFFFFFh    ; down text colour

        .elseif wParam == 552
            invoke SetWindowText,hWin,SADD("Button Three")
            invoke SendMessage,hButn1,WM_COMMAND,4,3
            invoke SendMessage,hButn2,WM_COMMAND,4,3
            invoke SendMessage,hButn3,WM_COMMAND,4,3

        .endif

    .elseif uMsg == WM_CREATE
        invoke Do_Status,hWin

        invoke colrbutn,hWin,hInstance,SADD(" Button 1 "),
                        000000FFh,000000AAh,
                        50,50,150,25,2,550
        mov hButn1, eax

        invoke SendMessage,hButn1,WM_SETFONT,RomanFont,0

        invoke colrbutn,hWin,hInstance,SADD(" Button 2 "),
                        00FFFFFFh,00AAAAAAh,
                        50,80,150,25,2,551
        mov hButn2, eax

        invoke SendMessage,hButn2,WM_SETFONT,RomanFont,0

        invoke colrbutn,hWin,hInstance,SADD(" Button 3 "),
                        00FF0000h,00AA0000h,
                        50,110,150,25,2,552
        mov hButn3, eax

        invoke SendMessage,hButn3,WM_SETFONT,RomanFont,0

    .elseif uMsg == WM_SYSCOLORCHANGE

    .elseif uMsg == WM_SIZE
        invoke MoveWindow,hStatus,0,0,0,0,TRUE

    .elseif uMsg == WM_PAINT
        invoke Paint_Proc,hWin
        return 0

    .elseif uMsg == WM_CLOSE

    .elseif uMsg == WM_DESTROY
        invoke PostQuitMessage,NULL
        return 0

    .endif

    invoke DefWindowProc,hWin,uMsg,wParam,lParam

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

; #########################################################################

Paint_Proc proc hWin:DWORD

    LOCAL hDC      :DWORD
    LOCAL btn_hi   :DWORD
    LOCAL btn_lo   :DWORD
    LOCAL Font     :DWORD
    LOCAL hOld     :DWORD
    LOCAL Rct      :RECT
    LOCAL Ps       :PAINTSTRUCT

    invoke BeginPaint,hWin,ADDR Ps
    mov hDC, eax

  ; ----------------------------------------

    invoke GetClientRect,hWin,ADDR Rct

    mov Rct.left, 20
    mov Rct.top, 10
    mov Rct.right, 550
    mov Rct.bottom, 30

    invoke MakeFont,24,12,700,FALSE,SADD("times new roman")
    mov Font, eax    ; <<<<<< DELETE this font on EXIT

    invoke SelectObject,hDC,Font
    mov hOld, eax

    invoke SetBkMode,hDC,TRANSPARENT

    invoke SetTextColor,hDC,00888888h   ; shadow
    invoke DrawText,hDC,SADD("Technicolor Custom Button Example"),
                    -1,ADDR Rct,DT_CENTER or DT_VCENTER or DT_SINGLELINE

    sub Rct.left,2
    sub Rct.top,2
    sub Rct.right,2
    sub Rct.bottom,2

    invoke SetTextColor,hDC,000000FFh   ; red
    invoke DrawText,hDC,SADD("Technicolor Custom Button Example"),
                    -1,ADDR Rct,DT_CENTER or DT_VCENTER or DT_SINGLELINE

    invoke SelectObject,hDC,hOld
    invoke DeleteObject,Font     ; delete the font

  ; ----------------------------------------

    invoke EndPaint,hWin,ADDR Ps

    ret

Paint_Proc endp

; ########################################################################

end start
