; ########################################################################

    .486                      ; create 32 bit code
    .model flat, stdcall      ; 32 bit memory model
    option casemap :none      ; case sensitive

    include \masm32\include\windows.inc
    include \masm32\include\gdi32.inc
    include \masm32\include\user32.inc
    ; include \masm32\include\kernel32.inc

    dwtoa  PROTO :DWORD,:DWORD
    szMultiCat PROTO C :DWORD,:DWORD,:VARARG

    m2m MACRO M1, M2
      push M2
      pop  M1
    ENDM

    .code

; ########################################################################

colrbutn proc hParent:DWORD,Instance:DWORD,lpText:DWORD,
              upcol:DWORD,dncol:DWORD,
              tx:DWORD,ty:DWORD,bwid:DWORD,bhgt:DWORD,
              alignment:DWORD,ID:DWORD

    LOCAL butc:WNDCLASSEX
    LOCAL hBrush1:DWORD
    LOCAL hBrush2:DWORD
    LOCAL hButn :DWORD
    LOCAL bClass[32]:BYTE
    LOCAL bcCnt[8]:BYTE

  ; -------------------------------------------
  ; create brushes for the UP and DOWN colours
  ; -------------------------------------------
    invoke CreateSolidBrush,upcol
    mov hBrush1, eax
    invoke CreateSolidBrush,dncol
    mov hBrush2, eax

  ; -------------------------------------------
  ; ensure a unique class name for each button
  ; -------------------------------------------
    .data
      cCounter dd 0
      cName db "col_butn_class",0
    .code
    inc cCounter
    mov bClass[0], 0                    ; set buffer to zero
    invoke dwtoa,cCounter,ADDR bcCnt    ; covert counter to string

  ; -------------------------------------------
  ; append "cName" and incremented counter ascii number to buffer
  ; -------------------------------------------
    invoke szMultiCat,2,ADDR bClass,ADDR cName,ADDR bcCnt

    mov butc.cbSize,         sizeof WNDCLASSEX
    mov butc.style,          CS_BYTEALIGNCLIENT or \
                             CS_BYTEALIGNWINDOW
    m2m butc.lpfnWndProc,    offset colrbutnProc
    mov butc.cbClsExtra,     NULL
    mov butc.cbWndExtra,     40         ; allocate extra windows memory
    m2m butc.hInstance,      Instance
    m2m butc.hbrBackground,  hBrush1
    mov butc.lpszMenuName,   NULL
      lea eax, bClass
    mov butc.lpszClassName,  eax
    mov butc.hIcon,          NULL
    invoke LoadCursor,NULL,IDC_ARROW
    mov butc.hCursor,        eax
    mov butc.hIconSm,        NULL

    invoke RegisterClassEx, ADDR butc

    invoke CreateWindowEx,WS_EX_LEFT,
                          ADDR bClass,
                          lpText,
                          WS_VISIBLE or WS_CHILD, ;  or WS_BORDER,
                          tx,ty,bwid,bhgt,
                          hParent,NULL,
                          Instance,NULL
    mov hButn,eax

    invoke SetWindowLong,hButn,0,hBrush1      ; butn up colour
    invoke SetWindowLong,hButn,4,hBrush2      ; butn down colour
    invoke SetWindowLong,hButn,8,ID           ; control ID number
    invoke SetWindowLong,hButn,12,alignment   ; text alignment
    invoke SetWindowLong,hButn,16,0           ; text upcolour
    invoke SetWindowLong,hButn,20,0           ; text dncolour
    invoke SetWindowLong,hButn,24,0           ; offset for font handle
    invoke SetWindowLong,hButn,28,0           ; click state flag

    invoke ShowWindow,hButn,SW_SHOW
    invoke UpdateWindow,hButn

    mov eax, hButn      ; return the button handle
    ret

colrbutn endp

; ########################################################################

colrbutnProc proc hWin   :DWORD,
                 uMsg   :DWORD,
                 wParam :DWORD,
                 lParam :DWORD

    LOCAL hParent    :DWORD
    LOCAL hDC        :DWORD
    LOCAL dtStyle    :DWORD
    LOCAL wOffset    :DWORD
    LOCAL hBrush     :DWORD
    LOCAL hFont      :DWORD
    LOCAL hOld       :DWORD
    LOCAL Rct        :RECT
    LOCAL buffer[128]:BYTE
    LOCAL Ps         :PAINTSTRUCT

    .if uMsg == WM_LBUTTONDOWN
      invoke SetWindowLong,hWin,28,1
      invoke SetCapture,hWin
      invoke GetWindowLong,hWin,4
      invoke SetClassLong,hWin,GCL_HBRBACKGROUND,eax
      invoke GetClientRect,hWin,ADDR Rct
      invoke InvalidateRect,hWin,ADDR Rct,TRUE

    .elseif uMsg == WM_SETTEXT
      invoke GetClientRect,hWin,ADDR Rct
      invoke InvalidateRect,hWin,ADDR Rct,TRUE

    .elseif uMsg == WM_SETFONT
      invoke SetWindowLong,hWin,24,wParam     ; font handle
      invoke GetClientRect,hWin,ADDR Rct
      invoke InvalidateRect,hWin,ADDR Rct,TRUE

    .elseif uMsg == WM_COMMAND
      ; ---------------------------
      ; butn & text colour changes
      ; ---------------------------
      .if wParam == 0
        invoke CreateSolidBrush,lParam
        mov hBrush, eax
        invoke SetWindowLong,hWin,0,hBrush      ; up butn colour
        invoke SetClassLong,hWin,GCL_HBRBACKGROUND,hBrush
      .elseif wParam == 1
        invoke CreateSolidBrush,lParam
        mov hBrush, eax
        invoke SetWindowLong,hWin,4,hBrush      ; down butn colour
      .elseif wParam == 2
        invoke SetWindowLong,hWin,16,lParam     ; up text colour
      .elseif wParam == 3
        invoke SetWindowLong,hWin,20,lParam     ; down text colour
      .elseif wParam == 4
        invoke SetWindowLong,hWin,12,lParam     ; text alignment
      .endif

      invoke GetClientRect,hWin,ADDR Rct
      invoke InvalidateRect,hWin,ADDR Rct,TRUE

    .elseif uMsg == WM_LBUTTONUP
      invoke SetWindowLong,hWin,28,0
      invoke ReleaseCapture
      invoke GetWindowLong,hWin,0
      invoke SetClassLong,hWin,GCL_HBRBACKGROUND,eax
      invoke GetClientRect,hWin,ADDR Rct
      invoke InvalidateRect,hWin,ADDR Rct,TRUE

      movsx eax, WORD PTR [ebp+20]      ; x coordinate
      movsx ecx, WORD PTR [ebp+22]      ; y coordinate

    ; ------------------------------------------------
    ; only send WM_COMMAND message if button release
    ; is within the controls rectangular display area
    ; ------------------------------------------------
      cmp eax, 0
      jl @F                 ; signed
      cmp ecx, 0
      jl @F                 ; signed
      cmp eax, Rct.right
      jg @F                 ; signed
      cmp ecx, Rct.bottom
      jg @F                 ; signed

      invoke GetParent,hWin
      mov hParent, eax
      invoke GetWindowLong,hWin,8
      invoke SendMessage,hParent,WM_COMMAND,eax,0
    @@:
    ; ------------------------------------------------

    .elseif uMsg == WM_PAINT
      invoke BeginPaint,hWin,ADDR Ps
      mov hDC, eax
      invoke GetClientRect,hWin,ADDR Rct
      invoke GetWindowText,hWin,ADDR buffer,128
      invoke SetBkMode,hDC,TRANSPARENT

      invoke GetWindowLong,hWin,12
      .if eax == 2
        mov dtStyle, DT_VCENTER or DT_CENTER or DT_SINGLELINE
      .elseif eax == 3
        mov dtStyle, DT_VCENTER or DT_RIGHT or DT_SINGLELINE
      .else
        mov dtStyle, DT_VCENTER or DT_LEFT or DT_SINGLELINE
      .endif

        invoke SetBkMode,hDC,TRANSPARENT

      ; --------------------------------------------------
      ; use font handle if font handle offset is not zero
      ; --------------------------------------------------
        invoke GetWindowLong,hWin,24
        .if eax != 0
          mov hFont, eax
          invoke SelectObject,hDC,hFont
          mov hOld, eax
        .endif

      invoke GetWindowLong,hWin,28
      .if eax == 0
        invoke DrawEdge,hDC,ADDR Rct,EDGE_RAISED,BF_RECT
        invoke GetWindowLong,hWin,16
        invoke SetTextColor,hDC,eax
        invoke DrawText,hDC,ADDR buffer,-1,ADDR Rct,dtStyle
      .else
        invoke DrawEdge,hDC,ADDR Rct,EDGE_SUNKEN,BF_RECT
          inc Rct.left
          inc Rct.top
          inc Rct.right
          inc Rct.bottom
        invoke GetWindowLong,hWin,20
        invoke SetTextColor,hDC,eax
        invoke DrawText,hDC,ADDR buffer,-1,ADDR Rct,dtStyle
      .endif

        invoke GetWindowLong,hWin,24
        .if eax != 0
          invoke SelectObject,hDC,hOld
        .endif
      invoke EndPaint,hWin,ADDR Ps

    .endif

    invoke DefWindowProc,hWin,uMsg,wParam,lParam

    ret

colrbutnProc endp

; ########################################################################

    end