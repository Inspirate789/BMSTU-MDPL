; #########################################################################

; Splitter Example
; Copyright © 2000 by Brian Burns (aka anon)
;
; This code may be reused for any educational or
; non-commercial application without further licence
; Contact the author at BrianLBurns@att.net for any other use.

; #########################################################################

.386
.model flat, stdcall  ; 32 bit memory model
option casemap :none  ; case sensitive

; #########################################################################

include \MASM32\INCLUDE\windows.inc
include \MASM32\INCLUDE\masm32.inc
include \MASM32\INCLUDE\gdi32.inc
include \MASM32\INCLUDE\user32.inc
include \MASM32\INCLUDE\kernel32.inc
include \MASM32\INCLUDE\Comctl32.inc
include \MASM32\INCLUDE\comdlg32.inc
include \MASM32\INCLUDE\shell32.inc

includelib \MASM32\LIB\masm32.lib
includelib \MASM32\LIB\gdi32.lib
includelib \MASM32\LIB\user32.lib
includelib \MASM32\LIB\kernel32.lib
includelib \MASM32\LIB\Comctl32.lib
includelib \MASM32\LIB\comdlg32.lib
includelib \MASM32\LIB\shell32.lib

; #########################################################################

;Local prototypes
WinMain  PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndProc  PROTO :DWORD,:DWORD,:DWORD,:DWORD
TopXY    PROTO :DWORD,:DWORD
Splitter PROTO :DWORD
Resizer  PROTO :DWORD

;Local macros
szText MACRO Name, Text:VARARG
LOCAL lbl
jmp    lbl
Name   db Text,0
lbl:
ENDM

m2m MACRO M1, M2
push   M2
pop    M1
ENDM

return MACRO arg
mov    eax, arg
ret
ENDM

.data
szDisplayName db "Splitter Example",0
CommandLine   dd 0
hWnd          dd 0
hInstance     dd 0
hIcon         dd 0
StatClass     db "STATIC",0
EditClass     db "EDIT",0
hSplitter     dd 0
hLeftWindow   dd 0
hRightWindow  dd 0
split         dd 0
CurWidth      dd 500

.code
start:
invoke GetModuleHandle,NULL
mov    hInstance,eax
invoke GetCommandLine
mov    CommandLine,eax
invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT
invoke ExitProcess,eax

; #########################################################################

WinMain proc hInst: DWORD,hPrevInst: DWORD,CmdLine: DWORD,CmdShow: DWORD

LOCAL wc   :WNDCLASSEX
LOCAL msg  :MSG
LOCAL Wwd  :DWORD
LOCAL Wht  :DWORD
LOCAL Wtx  :DWORD
LOCAL Wty  :DWORD

invoke LoadIcon,hInst,500
mov    hIcon,eax
szText szClassName,"Project_Class"
mov    wc.cbSize,sizeof WNDCLASSEX
mov    wc.style,CS_HREDRAW or CS_VREDRAW or CS_BYTEALIGNWINDOW
mov    wc.lpfnWndProc,offset WndProc
mov    wc.cbClsExtra,NULL
mov    wc.cbWndExtra,NULL
m2m    wc.hInstance,hInst
mov    wc.hbrBackground,COLOR_BTNFACE+1
mov    wc.lpszMenuName,NULL
mov    wc.lpszClassName,offset szClassName
m2m    wc.hIcon,hIcon
invoke LoadCursor,NULL,IDC_SIZEWE
mov    wc.hCursor,eax
m2m    wc.hIconSm,hIcon
invoke RegisterClassEx,addr wc
;Center window at following size
mov    Wwd,500
mov    Wht,350
invoke GetSystemMetrics,SM_CXSCREEN
invoke TopXY,Wwd,eax
mov    Wtx,eax
invoke GetSystemMetrics,SM_CYSCREEN
invoke TopXY,Wht,eax
mov    Wty,eax
invoke CreateWindowEx,WS_EX_LEFT,addr szClassName,addr szDisplayName,WS_OVERLAPPEDWINDOW,
                      Wtx,Wty,Wwd,Wht,NULL,NULL,hInst,NULL
mov    hWnd,eax
invoke LoadMenu,hInst,600
invoke SetMenu,hWnd,eax
invoke ShowWindow,hWnd,SW_SHOWNORMAL
invoke UpdateWindow,hWnd
;Loop until PostQuitMessage is sent
StartLoop:
invoke GetMessage,addr msg,NULL,0,0
cmp    eax,0
je     ExitLoop
invoke TranslateMessage,addr msg
invoke DispatchMessage,addr msg
jmp    StartLoop
ExitLoop:
return msg.wParam

WinMain endp

; #########################################################################

WndProc proc hWin: DWORD,uMsg: DWORD,wParam: DWORD,lParam: DWORD

LOCAL var    :DWORD
LOCAL caW    :DWORD
LOCAL caH    :DWORD
LOCAL Rct    :RECT
LOCAL hDC    :DWORD
LOCAL Ps     :PAINTSTRUCT
LOCAL buffer1[128]:BYTE  ; these are two spare buffers
LOCAL buffer2[128]:BYTE  ; for text manipulation etc..
LOCAL right  :DWORD

.if uMsg == WM_COMMAND
;======== menu commands ========
   .if wParam == 1010
      invoke SendMessage,hWin,WM_SYSCOMMAND,SC_CLOSE,NULL
   .elseif wParam == 1900
      szText AboutMsg,"Prostart Pure Assembler Template",13,10,\
             "Copyright © Prostart 1999"
      invoke ShellAbout,hWin,ADDR szDisplayName,ADDR AboutMsg,hIcon
   .endif
;====== end menu commands ======
.elseif uMsg == WM_CREATE
   invoke GetClientRect,hWin,Addr Rct
   mov    eax,Rct.right
   shr    eax,1
   mov    right,eax
   invoke CreateWindowEx,WS_EX_CLIENTEDGE,Addr EditClass,NULL,WS_CHILD or WS_VISIBLE,0,0,right,Rct.bottom,hWin,NULL,hInstance,0
   mov    hLeftWindow,eax
   mov    eax,right
   add    eax,4
   mov    right,eax
   invoke CreateWindowEx,WS_EX_CLIENTEDGE,Addr EditClass,NULL,WS_CHILD or WS_VISIBLE,right,0,Rct.right,Rct.bottom,hWin,NULL,hInstance,0
   mov    hRightWindow,eax

.elseif uMsg == WM_SIZE
   invoke Resizer,lParam
   return 0

.elseif uMsg == WM_LBUTTONDOWN
   mov    split,TRUE
   invoke SetCapture,hWnd
   return 0

.elseif uMsg == WM_MOUSEMOVE
   invoke Splitter,lParam
   return 0

.elseif uMsg == WM_LBUTTONUP
   mov    split,FALSE
   invoke ReleaseCapture
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

shr    sDim,1      ; divide screen dimension by 2
shr    wDim,1      ; divide window dimension by 2
mov    eax,wDim    ; copy window dimension into eax
sub    sDim,eax    ; sub half win dimension from half screen dimension
return sDim

TopXY endp

; #########################################################################

Splitter proc lParam:DWORD

LOCAL pPOINT: POINT
LOCAL pRECT: RECT

.if    split == TRUE
   invoke GetCursorPos,addr pPOINT
   invoke ScreenToClient,hWnd,addr pPOINT
   invoke GetClientRect,hWnd,addr pRECT
   sub    pRECT.right,5
   mov    eax,pRECT.right
   .if    pPOINT.x > 3 && pPOINT.x < eax         ;limit travel of 'splitter' to edges of parent window
      and    lParam,0ffffh                       ;mouse X (horiz) position in LoWord
      invoke MoveWindow,hLeftWindow,0,0,lParam,pRECT.bottom,TRUE
      add    lParam,4                            ;save room for 'splitter'
      invoke MoveWindow,hRightWindow,lParam,0,pRECT.right,pRECT.bottom,TRUE
   .endif
.endif
return 0

Splitter endp

; ########################################################################

Resizer proc lParam:DWORD   ;make window split proportional on resize

LOCAL ClientRect: RECT
LOCAL WindowRect: RECT

invoke GetClientRect,hWnd,addr ClientRect
invoke GetClientRect,hLeftWindow,addr WindowRect
finit
fld    WindowRect.right
fld    CurWidth
fdiv
and    lParam,0ffffh        ;new window width in LoWord
fld    lParam
fmul
fstp   WindowRect.right
invoke MoveWindow,hLeftWindow,0,0,WindowRect.right,ClientRect.bottom,TRUE
add    WindowRect.right,4   ;save room for 'splitter'
invoke MoveWindow,hRightWindow,WindowRect.right,0,ClientRect.right,ClientRect.bottom,TRUE
m2m    CurWidth,lParam
return 0

Resizer endp

; ########################################################################

end start
