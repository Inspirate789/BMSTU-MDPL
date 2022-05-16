; ####################################################
;       William F. Cravener 8/10/2003
;       Grid a 32x32 pixel bitmap example
; ####################################################
    
        .486
        .model flat,stdcall
        option casemap:none   ; case sensitive

; ####################################################
    
        include \masm32\include\windows.inc
        include \masm32\include\user32.inc
        include \masm32\include\kernel32.inc
        include \masm32\include\gdi32.inc

        includelib \masm32\lib\user32.lib
        includelib \masm32\lib\kernel32.lib
        includelib \masm32\lib\gdi32.lib
    
; --------------------------------------------------------

        ID_GRIDON equ 100
        ID_GRIDOFF equ 200
        ID_ZOOMIN equ 300
        ID_ZOOMOUT equ 400

; --------------------------------------------------------
    
        WinMain PROTO :DWORD,:DWORD,:DWORD,:DWORD
        WndProc PROTO :DWORD,:DWORD,:DWORD,:DWORD
        TopXY PROTO :DWORD,:DWORD
        ZoomAdjust PROTO

; --------------------------------------------------------
    
.data
        hInstance     dd 0
        hWnd          dd 0
        hBmp          dd 0
        hMenu         dd 0
        count         dd 0

        memDC1        dd 0
        memDC2        dd 0

        xyZoomFactor  dd 8  

        xWorkSpace    dd 0
        yWorkSpace    dd 0

        xImage        dd 32
        yImage        dd 32

        GridOffOnFlag dd 0

        szClassName   db "GridClass",0
        szDisplayName db "Grid a 32x32 pixel bitmap",0

; ###############################################################
    
.code
    
start:
    invoke GetModuleHandle,0
    mov hInstance,eax
    invoke WinMain,hInstance,0,0,SW_SHOWDEFAULT
    invoke ExitProcess,eax

; #########################################################################

WinMain proc hInst:DWORD, hPrevInst:DWORD, CmdLine:DWORD, CmdShow:DWORD

        LOCAL wc:WNDCLASSEX
        LOCAL msg:MSG
        LOCAL Wwd:DWORD
        LOCAL Wht:DWORD
        LOCAL Wtx:DWORD
        LOCAL Wty:DWORD

        mov wc.cbSize,sizeof WNDCLASSEX
        mov wc.style,CS_HREDRAW or CS_VREDRAW or CS_BYTEALIGNWINDOW
        mov wc.lpfnWndProc,OFFSET WndProc
        mov wc.cbClsExtra,0
        mov wc.cbWndExtra,0
        mov eax,hInst
        mov wc.hInstance,eax
        mov wc.hbrBackground,COLOR_WINDOW+1
        mov wc.lpszMenuName,0
        mov wc.lpszClassName,OFFSET szClassName
        invoke LoadIcon,hInst,500
        mov wc.hIcon,eax
        invoke LoadCursor,NULL,IDC_ARROW
        mov wc.hCursor,eax
        mov wc.hIconSm,0

        invoke RegisterClassEx,ADDR wc

        mov Wwd,450
        mov Wht,450
        invoke GetSystemMetrics,SM_CXSCREEN
        invoke TopXY,Wwd,eax
        mov Wtx,eax
        invoke GetSystemMetrics,SM_CYSCREEN
        invoke TopXY,Wht,eax
        mov Wty,eax

        invoke CreateWindowEx,WS_EX_OVERLAPPEDWINDOW,
                              ADDR szClassName,
                              ADDR szDisplayName,
                              WS_OVERLAPPEDWINDOW, 
                              Wtx,Wty,Wwd,Wht,
                              NULL,NULL,
                              hInst,NULL
        mov   hWnd,eax

        invoke LoadMenu,hInstance,300
        mov hMenu,eax
        invoke SetMenu,hWnd,hMenu

        invoke ShowWindow,hWnd,SW_SHOWNORMAL
        invoke UpdateWindow,hWnd

    StartLoop:
      invoke GetMessage,ADDR msg,NULL,0,0
      cmp eax,0
      je ExitLoop
      invoke TranslateMessage,ADDR msg
      invoke DispatchMessage,ADDR msg
      jmp StartLoop
    ExitLoop:
      
      mov eax,msg.wParam 
      ret

WinMain endp

; #########################################################################

WndProc proc hWin:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD

    LOCAL hDC:DWORD
    LOCAL memBmp:DWORD
    LOCAL OldObj:DWORD
    LOCAL rct:RECT
    LOCAL ps:PAINTSTRUCT

        .if uMsg == WM_COMMAND
            .if wParam == ID_GRIDON
                    mov GridOffOnFlag,0
                    invoke InvalidateRect,hWin,0,FALSE
            .elseif wParam == ID_GRIDOFF
                    mov GridOffOnFlag,1
                    invoke InvalidateRect,hWin,0,FALSE
            .elseif wParam == ID_ZOOMIN
                    .if xyZoomFactor < 12
                        add xyZoomFactor,2
                        invoke ZoomAdjust
                        invoke GetClientRect,hWin,ADDR rct
                        invoke InvalidateRect,hWin,ADDR rct,TRUE
                    .endif
            .elseif wParam == ID_ZOOMOUT
                    .if xyZoomFactor > 4
                        sub xyZoomFactor,2
                        invoke ZoomAdjust
                        invoke GetClientRect,hWin,ADDR rct
                        invoke InvalidateRect,hWin,ADDR rct,TRUE
                    .endif 
            .endif 

        .elseif uMsg == WM_CREATE
                ;--------------------------------------
                ;--------------------------------------
                ; Setup the bitmap resource for testing
                ;--------------------------------------
                invoke LoadBitmap,hInstance,800
                mov hBmp,eax
                invoke GetDC,hWin
                mov hDC,eax
                invoke CreateCompatibleDC,hDC
                mov memDC2,eax
                invoke SelectObject,memDC2,hBmp
                invoke ReleaseDC,hWin,hDC
                invoke ZoomAdjust

        .elseif uMsg == WM_PAINT
                invoke BeginPaint,hWin,ADDR ps
                mov hDC,eax

                .if GridOffOnFlag == 0
                    ;----------------------------------------
                    ;----------------------------------------
                    ; StretchBlt our bitmap to a workspace DC
                    ;----------------------------------------
                    invoke CreateCompatibleDC,hDC
                    mov memDC1,eax
                    invoke CreateCompatibleBitmap,hDC,xWorkSpace,yWorkSpace
                    mov memBmp,eax
                    invoke SelectObject,memDC1,memBmp
                    mov OldObj,eax 
                    invoke StretchBlt,memDC1,0,0,xWorkSpace,yWorkSpace,memDC2,0,0,xImage,yImage,SRCCOPY
                    ;--------------------------------------------
                    ;--------------------------------------------
                    ; Now draw the grid lines on our workspace DC
                    ; Do both vertical and horizontal grid lines
                    ;--------------------------------------------
                    ; We do vertical grid lines first
                    ;--------------------------------
                    mov count,0
               next1:
                    invoke PatBlt,memDC1,count,0,1,yWorkSpace,BLACKNESS
                    mov eax,xyZoomFactor
                    add count,eax
                    mov eax,xWorkSpace
                    cmp count,eax
                    jng next1
                    ;---------------------------------
                    ; Now do the horizontal grid lines
                    ;---------------------------------
                    mov count,0
               next2:
                    invoke PatBlt,memDC1,0,count,xWorkSpace,1,BLACKNESS
                    mov eax,xyZoomFactor
                    add count,eax
                    mov eax,xWorkSpace
                    cmp count,eax
                    jng next2
                    ;----------------------------------
                    ;----------------------------------
                    ; Copy the results to our window DC
                    ;----------------------------------
                    invoke BitBlt,hDC,0,0,xWorkSpace,yWorkSpace,memDC1,0,0,SRCCOPY
                    ;------------------------
                    ;------------------------
                    ; Clean up before leaving
                    ;------------------------ 
                    invoke SelectObject,memDC1,OldObj 
                    invoke DeleteObject,memBmp
                    invoke DeleteDC,memDC1
                .else
                    ;------------------------------------
                    ;------------------------------------
                    ; Show the scaled bitmap without grid
                    ;------------------------------------
                    invoke StretchBlt,hDC,0,0,xWorkSpace,yWorkSpace,memDC2,0,0,xImage,yImage,SRCCOPY
                .endif

                invoke EndPaint,hWin,ADDR ps 
                xor eax,eax
                ret

        .elseif uMsg == WM_CLOSE

        .elseif uMsg == WM_DESTROY
                invoke DeleteDC,memDC2
                invoke PostQuitMessage,NULL
                xor eax,eax
                ret
        .endif

        invoke DefWindowProc,hWin,uMsg,wParam,lParam
        ret

WndProc endp

; ########################################################################

TopXY proc wDim:DWORD, sDim:DWORD

        shr sDim,1
        shr wDim,1
        mov eax,wDim
        sub sDim,eax
        mov eax,sDim
        ret

TopXY endp

; ########################################################################

ZoomAdjust proc

        push eax
        push ecx
        push edx
        mov eax,xImage
        mov ecx,xyZoomFactor
        xor edx,edx
        mul ecx
        inc eax
        mov xWorkSpace,eax
        mov yWorkSpace,eax
        pop edx
        pop ecx
        pop eax
        ret

ZoomAdjust endp

; ########################################################################

end start
