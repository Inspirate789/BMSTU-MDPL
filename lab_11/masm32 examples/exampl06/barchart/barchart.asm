; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; A simple example of how to draw a bar chart using standard GDI functions
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

      .486                      ; create 32 bit code
      .model flat, stdcall      ; 32 bit memory model
      option casemap :none      ; case sensitive

      include barchart.inc      ; local includes for this file

      hbar PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD

.code

start:

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    ; ------------------
    ; set global values
    ; ------------------
      mov hInstance,   FUNC(GetModuleHandle, NULL)
      mov CommandLine, FUNC(GetCommandLine)
      mov hIcon,       FUNC(LoadIcon,hInstance,500)
      mov hCursor,     FUNC(LoadCursor,NULL,IDC_ARROW)
      mov sWid,        FUNC(GetSystemMetrics,SM_CXSCREEN)
      mov sHgt,        FUNC(GetSystemMetrics,SM_CYSCREEN)

      call Main

      invoke ExitProcess,eax

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

Main proc

    LOCAL Wwd:DWORD,Wht:DWORD,Wtx:DWORD,Wty:DWORD

    STRING szClassName,"barchart_class"

  ; --------------------------------------------
  ; register class name for CreateWindowEx call
  ; --------------------------------------------
    invoke RegisterWinClass,ADDR WndProc,ADDR szClassName,
                       hIcon,hCursor,COLOR_BTNFACE+1

    mov Wwd, 600
    mov Wht, 470
    invoke TopXY,Wwd,sWid
    mov Wtx, eax
    invoke TopXY,Wht,sHgt
    mov Wty, eax

    invoke CreateWindowEx,WS_EX_LEFT,
                          ADDR szClassName,
                          ADDR szDisplayName,
                          WS_OVERLAPPED or WS_SYSMENU,
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

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

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
    m2m wc.hbrBackground,  bColor
    mov wc.lpszMenuName,   NULL
    m2m wc.lpszClassName,  lpClassName
    m2m wc.hIcon,          Icon
    m2m wc.hCursor,        Cursor
    m2m wc.hIconSm,        Icon

    invoke RegisterClassEx, ADDR wc

    ret

RegisterWinClass endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

MsgLoop proc

    LOCAL msg:MSG

    push esi
    push edi
    xor edi, edi                        ; clear EDI
    lea esi, msg                        ; Structure address in ESI
    jmp jumpin

    StartLoop:
      invoke TranslateMessage, esi
      invoke DispatchMessage,  esi
    jumpin:
      invoke GetMessage,esi,edi,edi,edi
      test eax, eax
      jnz StartLoop

    mov eax, msg.wParam
    pop edi
    pop esi

    ret

MsgLoop endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

WndProc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

    Switch uMsg
      Case WM_PAINT
        invoke Paint_Proc,hWin
        return 0

      Case WM_DESTROY
        invoke PostQuitMessage,NULL
        return 0

    Endsw

    invoke DefWindowProc,hWin,uMsg,wParam,lParam

    ret

WndProc endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

OPTION PROLOGUE:NONE 
OPTION EPILOGUE:NONE 

TopXY proc wDim:DWORD, sDim:DWORD

    mov eax, [esp+8]
    sub eax, [esp+4]
    shr eax, 1

    ret 8

TopXY endp

OPTION PROLOGUE:PrologueDef 
OPTION EPILOGUE:EpilogueDef 

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

Paint_Proc proc hWin:DWORD

    LOCAL hDC      :DWORD
    LOCAL Rct      :RECT
    LOCAL Ps       :PAINTSTRUCT

    mov hDC, rv(BeginPaint,hWin,ADDR Ps)

  ; ------------------------------------
  ; the last argument in the following
  ; procedure calls is a COLORREF format
  ; hex integer.
  ; ------------------------------------

    invoke hbar,112,hDC,100,20, 00FF0000h
    invoke hbar,363,hDC,100,40, 00FF0000h
    invoke hbar,219,hDC,100,60, 00FF0000h
    invoke hbar,407,hDC,100,80, 00FF0000h
    invoke hbar,175,hDC,100,100,00FF0000h
    invoke hbar,215,hDC,100,120,00FF0000h
    invoke hbar,156,hDC,100,140,00FF0000h
    invoke hbar,97 ,hDC,100,160,00FF0000h
    invoke hbar,332,hDC,100,180,00FF0000h
    invoke hbar,282,hDC,100,200,00FF0000h

    invoke hbar,119,hDC,100,220,00FF0000h
    invoke hbar,318,hDC,100,240,00FF0000h
    invoke hbar,124,hDC,100,260,00FF0000h
    invoke hbar,203,hDC,100,280,00FF0000h
    invoke hbar,412,hDC,100,300,00FF0000h
    invoke hbar,273,hDC,100,320,00FF0000h
    invoke hbar,197,hDC,100,340,00FF0000h
    invoke hbar,87 ,hDC,100,360,00FF0000h
    invoke hbar,222,hDC,100,380,00FF0000h
    invoke hbar,333,hDC,100,400,00FF0000h

    invoke FrameWindow,hWnd,4,1,1
    invoke FrameWindow,hWnd,7,1,0

  ; ----------------------------------------

    invoke EndPaint,hWin,ADDR Ps

    ret

Paint_Proc endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

hbar proc value:DWORD,hDC:DWORD,tx:DWORD,ty:DWORD,bruchcol:DWORD

    LOCAL rct   :RECT

    m2m rct.left, tx                                ; set top X and Y to structure members
    m2m rct.top, ty
    m2m rct.right, tx
    m2m rct.bottom, ty
    mov eax, value                                  ; add the bar value to the right side
    add rct.right, eax                              ; to set the bar width.
    add rct.bottom, 17                              ; add 17 pixels to the bottom

    invoke SetTextColor,hDC,00FFFFFFh               ; white text
    invoke SetBkMode,hDC,TRANSPARENT                ; transparent text background
    invoke FillRect, hDC,ADDR rct,                  ; fill rect with fill colour
                     rv(CreateSolidBrush,bruchcol)
    invoke FrameRect,hDC,ADDR rct,                  ; draw rect border in black
                     rv(CreateSolidBrush,00000000h)

    sub rct.left, 70                                ; shift the text rect back 70 pixels
    m2m rct.right, rct.left
    add rct.right, 50                               ; set its width to 50 pixels

    invoke DrawText,hDC,str$(value),-1,ADDR rct,
                        DT_SINGLELINE or DT_RIGHT   ; right aligned text

    ret

hbar endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start
