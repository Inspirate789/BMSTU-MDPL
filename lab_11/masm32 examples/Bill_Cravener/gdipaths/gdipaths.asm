; ####################################################
;       William F. Cravener 8/8/2003
;       GDI Paths Example
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
    
        WinMain PROTO :DWORD,:DWORD,:DWORD,:DWORD
        WndProc PROTO :DWORD,:DWORD,:DWORD,:DWORD
        TopXY PROTO :DWORD,:DWORD

        RoundedPath PROTO :DWORD
        MiteredPath PROTO :DWORD
        BeveledPath PROTO :DWORD

; --------------------------------------------------------
    
.data
        hInstance     dd 0
        hWnd          dd 0
        hPen          dd 0
        oldPen        dd 0

        szClassName   db "GDIPathsClass",0
        szDisplayName db "GDI Paths",0

        PathRound     db "Rounded Path",0
        PathMiter     db "Mitered Path",0
        PathBevel     db "Beveled Path",0

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
        invoke LoadCursor,0,IDC_ARROW
        mov wc.hCursor,eax
        mov wc.hIconSm,0

        invoke RegisterClassEx,ADDR wc

        mov Wwd,500
        mov Wht,350
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
                              0,0,
                              hInst,0
        mov   hWnd,eax

        invoke ShowWindow,hWnd,SW_SHOWNORMAL
        invoke UpdateWindow,hWnd

    StartLoop:
      invoke GetMessage,ADDR msg,0,0,0
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
    LOCAL rct:RECT
    LOCAL ps:PAINTSTRUCT

        .if uMsg == WM_COMMAND

        .elseif uMsg == WM_CREATE

        .elseif uMsg == WM_PAINT
                invoke BeginPaint,hWin,ADDR ps
                mov hDC,eax
                ;-----------------------------------
                invoke SetMapMode,hDC,MM_ANISOTROPIC
                invoke SetWindowExtEx,hDC,100,100,0
                invoke GetClientRect,hWin,ADDR rct
                invoke SetViewportExtEx,hDC,rct.right,rct.bottom,0
                ;-------------------------------------------------
                invoke RoundedPath,hDC 
                invoke MiteredPath,hDC 
                invoke BeveledPath,hDC 
                ;-------------------
                invoke EndPaint,hWin,ADDR ps 
                xor eax,eax
                ret

        .elseif uMsg == WM_CLOSE

        .elseif uMsg == WM_DESTROY
                invoke PostQuitMessage,0
                xor eax,eax
                ret
        .endif

        invoke DefWindowProc,hWin,uMsg,wParam,lParam
        ret

WndProc endp

; ########################################################################

RoundedPath proc hDC:DWORD

    LOCAL lb:LOGBRUSH

        mov lb.lbStyle,BS_SOLID
        mov lb.lbColor,00000FFh
        mov lb.lbHatch,0
        invoke ExtCreatePen,PS_SOLID or PS_GEOMETRIC or PS_ENDCAP_ROUND or PS_JOIN_ROUND,10,ADDR lb,0,0
        mov hPen,eax
        invoke SelectObject,hDC,hPen
        mov oldPen,eax
        ;-------------------
        ; Build the GDI Path
        ;-------------------
        invoke BeginPath,hDC
        invoke MoveToEx,hDC,10,25,0
        invoke LineTo,hDC,20,75
        invoke LineTo,hDC,30,25
        invoke EndPath,hDC
        ;----------------------
        ; Render the built Path
        ;----------------------
        invoke StrokePath,hDC
        invoke DeleteObject,hPen
        ;---------------------------------
        ; Draw black lines inside the Path
        ;---------------------------------
        invoke GetStockObject,BLACK_PEN
        invoke SelectObject,hDC,eax 
        invoke MoveToEx,hDC,10,25,0
        invoke LineTo,hDC,20,75
        invoke LineTo,hDC,30,25
        ;--------------------------
        ; Describe the type of Path
        ;--------------------------
        invoke TextOut,hDC,11,10,ADDR PathRound,12
        invoke SelectObject,hDC,oldPen 
        ret

RoundedPath endp

; ########################################################################

MiteredPath proc hDC:DWORD

    LOCAL lb:LOGBRUSH

        mov lb.lbStyle,BS_SOLID
        mov lb.lbColor,000FF00h
        mov lb.lbHatch,0
        invoke ExtCreatePen,PS_SOLID or PS_GEOMETRIC or PS_ENDCAP_FLAT or PS_JOIN_MITER,10,ADDR lb,0,0
        mov hPen,eax
        invoke SelectObject,hDC,hPen
        mov oldPen,eax
        ;-------------------
        ; Build the GDI Path
        ;-------------------
        invoke BeginPath,hDC
        invoke MoveToEx,hDC,40,25,0
        invoke LineTo,hDC,50,75
        invoke LineTo,hDC,60,25
        invoke EndPath,hDC
        ;----------------------
        ; Render the built path
        ;----------------------
        invoke StrokePath,hDC
        invoke DeleteObject,hPen
        ;---------------------------------
        ; Draw black lines inside the Path
        ;---------------------------------
        invoke GetStockObject,BLACK_PEN
        invoke SelectObject,hDC,eax 
        invoke MoveToEx,hDC,40,25,0
        invoke LineTo,hDC,50,75
        invoke LineTo,hDC,60,25
        ;--------------------------
        ; Describe the type of Path
        ;--------------------------
        invoke TextOut,hDC,41,10,ADDR PathMiter,12
        invoke SelectObject,hDC,oldPen 
        ret

MiteredPath endp

; ########################################################################

BeveledPath proc hDC:DWORD

    LOCAL lb:LOGBRUSH

        mov lb.lbStyle,BS_SOLID
        mov lb.lbColor,0FF0000h
        mov lb.lbHatch,0
        invoke ExtCreatePen,PS_SOLID or PS_GEOMETRIC or PS_ENDCAP_SQUARE or PS_JOIN_BEVEL,10,ADDR lb,0,0
        mov hPen,eax
        invoke SelectObject,hDC,hPen
        mov oldPen,eax
        ;-------------------
        ; Build the GDI Path
        ;-------------------
        invoke BeginPath,hDC
        invoke MoveToEx,hDC,70,25,0
        invoke LineTo,hDC,80,75
        invoke LineTo,hDC,90,25
        invoke EndPath,hDC
        ;----------------------
        ; Render the built Path
        ;----------------------
        invoke StrokePath,hDC
        invoke DeleteObject,hPen
        ;---------------------------------
        ; Draw black lines inside the Path
        ;---------------------------------
        invoke GetStockObject,BLACK_PEN
        invoke SelectObject,hDC,eax 
        invoke MoveToEx,hDC,70,25,0
        invoke LineTo,hDC,80,75
        invoke LineTo,hDC,90,25
        ;--------------------------
        ; Describe the type of Path
        ;--------------------------
        invoke TextOut,hDC,71,10,ADDR PathBevel,12
        invoke SelectObject,hDC,oldPen 
        ret

BeveledPath endp

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

end start
