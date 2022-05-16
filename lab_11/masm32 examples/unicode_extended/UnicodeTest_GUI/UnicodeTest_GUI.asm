;-----------------------------------------------------------------;
; This advanced example shows how to use the Unicode macros       ;
; to display some formulas (MAXWELL).                             ;
; The used font is <Lucida Sans Unicode>.  According to           ;
; Microsoft's Internet site, the equates should be shown correctly;
; for windows Win2K or newer.                                     ;
; Also this example shows the usage of the fnx/rvx macros, which  ;
; adds some new features, like the &-operator.                    ;
;-----------------------------------------------------------------;

__UNICODE__ EQU 1
include \masm32\include\masm32rt.inc

; greek samll/captial letters
include greek.inc

; superscript and subscript
include Super_and_SubScript.inc

; declare some unicode char.
MOP_NABLA                   EQU 2207h
MOP_DOT                     EQU 22c5h
MOP_DIV                     EQU 2215h
MOP_CROSS_PRODUCT           EQU 2a2fh
MOP_DOUBLE_INTEGRAL         EQU 222ch
MOP_TRIPLE_INTEGRAL         EQU 222dh
MOP_CONTOUR_INTEGRAL        EQU 222dh
MOP_SURFACE_INTEGRAL        EQU 222fh
MOP_PARTIAL_DIFFERENTIAL    EQU 2202h

WndProc proto hWnd:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

WND_DATA struct
    hdc         HDC     ?
    hBmp        HBITMAP ?
WND_DATA ends

.data

    ; UC  = UCSTR  = declare unicode string
    ; UCC = UCCSTR = declare unicode string with escape sequences
    ; Create the unicode strings 'wstr'
    UCC wstr,"Some equations \n\n"
    UC ,MOP_NABLA,MOP_DOT,CAP_EPSILON," = ",SML_RHO,MOP_DIV,SML_EPSILON,SUB_ZERO,13,10
    UC ,MOP_NABLA,MOP_DOT,CAP_BETA," = 0",13,10
    UC ,MOP_NABLA,"x",CAP_EPSILON," = -( ",MOP_PARTIAL_DIFFERENTIAL,CAP_BETA,MOP_DIV,MOP_PARTIAL_DIFFERENTIAL,"t )",13,10
    UC ,MOP_NABLA,"x",CAP_BETA," = ",SML_MU,SUB_ZERO,MOP_DOT,"j + ",SML_MU,SUB_ZERO,MOP_DOT,SML_EPSILON,SUB_ZERO,MOP_DOT,"( ",MOP_PARTIAL_DIFFERENTIAL,CAP_EPSILON,MOP_DIV,MOP_PARTIAL_DIFFERENTIAL,"t )",13,10
    UC ,MOP_SURFACE_INTEGRAL,"D",MOP_DOT,"dA = ",MOP_TRIPLE_INTEGRAL,SML_RHO,MOP_DOT,"dV",13,10
    UC ,MOP_SURFACE_INTEGRAL,"B",MOP_DOT,"dA = 0",13,10
    UC ,MOP_CONTOUR_INTEGRAL,CAP_EPSILON,MOP_DOT,"ds + ",MOP_DOUBLE_INTEGRAL,"(",MOP_PARTIAL_DIFFERENTIAL,CAP_BETA,MOP_DIV,MOP_PARTIAL_DIFFERENTIAL,"t )",MOP_DOT,"dA = 0"

    ; add the termination zero
    dw 0
.code
main proc 
LOCAL wcex:WNDCLASSEXW
LOCAL msg:MSG

    mov wcex.hInstance,rv(GetModuleHandle,0)
    mov wcex.cbSize,SIZEOF WNDCLASSEX
    mov wcex.style, CS_HREDRAW or CS_VREDRAW
    mov wcex.lpfnWndProc, OFFSET WndProc
    mov wcex.cbClsExtra,NULL
    mov wcex.cbWndExtra,SIZEOF WND_DATA
    mov wcex.hbrBackground,0
    mov wcex.lpszMenuName,NULL
    mov wcex.lpszClassName,uc$("Win32, unicode")
    mov wcex.hIcon,rv(LoadIcon,NULL,IDI_APPLICATION)
    mov wcex.hIconSm,eax
    mov wcex.hCursor,rv(LoadCursor,NULL,IDC_ARROW)
    fnx RegisterClassEx,&wcex
    fnx esi = CreateWindowEx,0,wcex.lpszClassName,"Maxwell",WS_VISIBLE or WS_SYSMENU,CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,0,0,wcex.hInstance,0
    fnx ShowWindow,esi,SW_SHOWNORMAL
    fnx UpdateWindow,esi

    .while 1
        fnx GetMessage,&msg,NULL,0,0
        .break .if !eax || eax == -1
        fnx TranslateMessage, &msg
        fnx DispatchMessage, &msg
    .endw

    invoke ExitProcess,msg.wParam

main endp

WndProc proc uses ebx esi edi hWnd:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
LOCAL ps:PAINTSTRUCT
LOCAL rect[2]:RECT

    .if uMsg == WM_CLOSE
        invoke PostQuitMessage,NULL
    .elseif uMsg == WM_DESTROY
        ; delete memory DC
        fnx ebx = GetWindowLong,hWnd,WND_DATA.hdc
        invoke DeleteObject,rv(SelectObject,ebx,rv(GetWindowLong,hWnd,WND_DATA.hBmp))
        invoke DeleteDC,ebx
    .elseif uMsg == WM_CREATE
        
        ; resize the client area 512*512
        fnx GetClientRect,hWnd,&rect[16]
        fnx GetWindowRect,hWnd,&rect
        mov eax,rect.right
        mov edx,rect.bottom
        sub eax,rect.left
        sub edx,rect.top
        sub eax,rect[16].right
        sub edx,rect[16].bottom
        lea eax,[eax+512]
        lea edx,[edx+512]
        fn MoveWindow,hWnd,rect.left,rect.top,eax,edx,0
        fnx GetClientRect,hWnd,&rect
        
        ; create memory DC
        fnx esi = GetDC,rv(GetDesktopWindow)
        fnx ebx = CreateCompatibleDC,esi
        fnx edi = CreateCompatibleBitmap,esi,rect.right,rect.bottom
        fn DeleteObject,rv(SelectObject,ebx,edi)
        fn ReleaseDC,rv(GetDesktopWindow),esi
        fn SetWindowLong,hWnd,WND_DATA.hBmp,edi
        fn SetWindowLong,hWnd,WND_DATA.hdc,ebx
        
        ; clear the DC (color=white)
        fn BitBlt,ebx,0,0,rect.right,rect.bottom,ebx,0,0,PATCOPY
        
        ; create font and select it into the DC
        fnx CreateFont,30,10,0,0,FW_NORMAL,0,FALSE,FALSE,DEFAULT_CHARSET,OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,DEFAULT_QUALITY,DEFAULT_PITCH,"Lucida Sans Unicode"
        mov esi,rv(SelectObject,ebx,eax)    
        
        ; draw the text
        add rect.left,10
        add rect.top,10
        fnx DrawTextW,ebx,&wstr,-1,&rect,0
        
        ; delete the font
        pop edx
        invoke DeleteObject,rv(SelectObject,ebx,edx)
        
    .elseif uMsg == WM_PAINT
        fnx BeginPaint,hWnd,&ps
        mov ebx,rv(GetWindowLong,hWnd,WND_DATA.hdc)
        mov edx,ps.rcPaint.right
        sub edx,ps.rcPaint.left
        mov ecx,ps.rcPaint.bottom
        sub ecx,ps.rcPaint.top
        invoke BitBlt,ps.hdc,ps.rcPaint.left,ps.rcPaint.top,edx,ecx,ebx,ps.rcPaint.left,ps.rcPaint.top,SRCCOPY
        fnx EndPaint,hWnd,&ps   
    .else
        invoke DefWindowProc,hWnd,uMsg,wParam,lParam
        ret
    .endif

    xor eax,eax
    ret
WndProc endp
end main