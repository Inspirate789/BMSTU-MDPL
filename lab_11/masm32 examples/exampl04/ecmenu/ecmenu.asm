; #########################################################################

; "Thomas Vidal" <Thomas-Vidal@wanadoo.fr>

      .386
      .model flat, stdcall
      option casemap :none   ; case sensitive

; #########################################################################

      include \MASM32\include\windows.inc
      include \MASM32\include\user32.inc
      include \MASM32\include\kernel32.inc
      include \MASM32\include\gdi32.inc
      include \MASM32\include\MASM32.inc
      include \MASM32\INCLUDE\advapi32.inc

      includelib \MASM32\lib\user32.lib
      includelib \MASM32\lib\kernel32.lib
      includelib \MASM32\lib\gdi32.lib
      includelib \MASM32\lib\MASM32.lib
      includelib \MASM32\LIB\advapi32.lib

; #########################################################################

        ;=================
        ; Local prototypes
        ;=================
        WinMain   PROTO :DWORD,:DWORD,:DWORD,:DWORD
        WndProc PROTO :DWORD,:DWORD,:DWORD,:DWORD
        TopXY PROTO   :DWORD,:DWORD
        FillBuffer   PROTO :DWORD,:DWORD,:BYTE
        Paint_Proc   PROTO :DWORD,:DWORD
        SetBmpColor PROTO :DWORD
        

        wsprintfA PROTO C :DWORD,:VARARG
        wsprintf equ <wsprintfA>

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

.data
szDisplayName db "An image item (bitmap)",0

        hWnd        dd 0
        hIconImage  dd 0
        hIcon       dd 0

.data?
hMenu	dd ?
hInstance HINSTANCE ?
CommandLine LPSTR ?

hBmp1 dd ?
cxMenu dd ?
cyMenu dd ?

.const
IDBMP_EC equ 750

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

      LOCAL wc   :WNDCLASSEX
      LOCAL msg  :MSG
      LOCAL Wwd  :DWORD
      LOCAL Wht  :DWORD
      LOCAL Wtx  :DWORD
      LOCAL Wty  :DWORD

      ;==================================================
      ; Fill WNDCLASSEX structure with required variables
      ;==================================================

      invoke LoadIcon,hInst,200    ; icon ID
      mov hIcon, eax

      szText szClassName,"Win_Class"

      mov wc.cbSize,         sizeof WNDCLASSEX
      mov wc.style,          CS_HREDRAW or CS_VREDRAW \
                             or CS_BYTEALIGNWINDOW
      mov wc.lpfnWndProc,    offset WndProc
      mov wc.cbClsExtra,     NULL
      mov wc.cbWndExtra,     NULL
      m2m wc.hInstance,      hInst
      mov wc.hbrBackground,  COLOR_WINDOW
      mov wc.lpszMenuName,   NULL
      mov wc.lpszClassName,  offset szClassName
      m2m wc.hIcon,          hIcon
        invoke LoadCursor,NULL,IDC_ARROW
      mov wc.hCursor,        eax
      m2m wc.hIconSm,        hIcon

      invoke RegisterClassEx, ADDR wc

      ;================================
      ; Centre window at following size
      ;================================

      mov Wwd, 350
      mov Wht, 130

      invoke GetSystemMetrics,SM_CXSCREEN
      invoke TopXY,Wwd,eax
      mov Wtx, eax

      invoke GetSystemMetrics,SM_CYSCREEN
      invoke TopXY,Wht,eax
      mov Wty, eax

      invoke LoadMenu,hInst,600  ; menu ID
      mov hMenu, eax

	invoke CreateWindowEx,WS_EX_CLIENTEDGE,ADDR szClassName,ADDR szDisplayName,\
           WS_OVERLAPPED+WS_CAPTION+WS_SYSMENU+WS_MINIMIZEBOX+WS_VISIBLE,Wtx,\  ;+WS_MAXIMIZEBOX+
           Wty,Wwd,Wht,NULL,hMenu,\
           hInst,NULL

      mov   hWnd,eax


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

    LOCAL var    :DWORD
    LOCAL caW    :DWORD
    LOCAL caH    :DWORD
    LOCAL Rct    :RECT
    LOCAL hDC    :DWORD
    LOCAL Ps     :PAINTSTRUCT
    LOCAL buffer1[128]:BYTE  ; these are two spare buffers
    LOCAL buffer2[128]:BYTE  ; for text manipulation etc..
    LOCAL pt:POINT

    .if uMsg == WM_COMMAND
                    mov     eax, wParam

    ;======== menu commands ========
        .if wParam == 2000
            invoke ExitProcess,NULL
        .endif
    ;====== end menu commands ======

    .elseif uMsg == WM_CREATE

      ; ********************************************************************

        invoke LoadBitmap, hInstance, IDBMP_EC
        mov hBmp1, eax
        invoke SetBmpColor,hBmp1
        mov hBmp1,eax
        invoke SetMenuItemBitmaps, hMenu, 2000, MF_BYCOMMAND, hBmp1, hBmp1

      ; ********************************************************************

    .elseif uMsg == WM_PAINT
        invoke BeginPaint,hWin,ADDR Ps
          mov hDC, eax
          invoke Paint_Proc,hWin,hDC
        invoke EndPaint,hWin,ADDR Ps
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

Paint_Proc proc hWin:DWORD, hDC:DWORD

    LOCAL btn_hi   :DWORD
    LOCAL btn_lo   :DWORD
    LOCAL Rct      :RECT

    invoke GetSysColor,COLOR_BTNHIGHLIGHT
    mov btn_hi, eax

    invoke GetSysColor,COLOR_BTNSHADOW
    mov btn_lo, eax

    return 0

Paint_Proc endp

; #########################################################################

SetBmpColor proc hBitmap:DWORD

    LOCAL mDC       :DWORD
    LOCAL hBrush    :DWORD
    LOCAL hOldBmp   :DWORD
    LOCAL hReturn   :DWORD
    LOCAL hOldBrush :DWORD

      invoke CreateCompatibleDC,NULL
      mov mDC,eax

      invoke SelectObject,mDC,hBitmap
      mov hOldBmp,eax

      invoke GetSysColor,COLOR_BTNFACE
      invoke CreateSolidBrush,eax
      mov hBrush,eax

      invoke SelectObject,mDC,hBrush
      mov hOldBrush,eax

      invoke GetPixel,mDC,1,1
      invoke ExtFloodFill,mDC,1,1,eax,FLOODFILLSURFACE

      invoke SelectObject,mDC,hOldBrush
      invoke DeleteObject,hBrush

      invoke SelectObject,mDC,hBitmap
      mov hReturn,eax
      invoke DeleteDC,mDC

      mov eax,hReturn

    ret

SetBmpColor endp

; #########################################################################
end start

