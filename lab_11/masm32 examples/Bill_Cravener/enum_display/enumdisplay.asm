; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;       William F. Cravener Sun . Feb . 22 . 09
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
        .486
        .model flat,stdcall
        option casemap:none   ; case sensitive
    
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
        include \masm32\include\windows.inc
        include \masm32\include\user32.inc
        include \masm32\include\gdi32.inc
        include \masm32\include\kernel32.inc
        include \masm32\include\masm32.inc

        includelib \masm32\lib\user32.lib
        includelib \masm32\lib\gdi32.lib
        includelib \masm32\lib\kernel32.lib
        includelib \masm32\lib\masm32.lib
   
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        WinMain      PROTO :DWORD,:DWORD,:DWORD,:DWORD
        WndProc      PROTO :DWORD,:DWORD,:DWORD,:DWORD
        TopXY        PROTO :DWORD,:DWORD

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.data
        hInstance           dd 0
        vidModeNum          dd 0
        nomoreflag          dd 0
        szClassName         db "EnumDisplaySettings",0
        szDisplayName       db "EnumDisplaySettings",0
        colorbits           db "   Color Bit Setting: ",0 
        pixelwidth          db "  Screen Pixel Width: ",0
        pixelheight         db " Screen Pixel Height: ",0
        displayfreq         db "Monitor Display Freq: ",0
        modeindex           db " Graphics Mode Index: ",0
        ThatsAll            db "Thats All Supported Graphic Modes!",0 
        HowToUse            db "Left click mouse bottom to increment graphics mode index.",0
        tempbuffer          db 128 dup(0)
        deviceInfo          DISPLAY_DEVICE <>
        vidModeInfo         DEVMODE <>
        lgfnt               LOGFONT <14,0,0,0,FW_NORMAL,0,0,0,0,0,0,0,0,"Lucida Console">
   
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~    
.code
start:
    invoke GetModuleHandle,0
    mov hInstance,eax
    invoke WinMain,hInstance,0,0,0
    invoke ExitProcess,eax

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

WinMain proc hInst:DWORD,hPrevInst:DWORD,CmdLine:DWORD,CmdShow:DWORD

    LOCAL wc:WNDCLASSEX
    LOCAL msg:MSG
    LOCAL hWnd:DWORD
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
    invoke LoadIcon,hInstance,500 
    mov wc.hIcon,eax 
    invoke LoadCursor,0,IDC_ARROW
    mov wc.hCursor,eax
    invoke LoadIcon,hInstance,500 
    mov wc.hIconSm,eax
    invoke RegisterClassEx,ADDR wc
    mov Wwd,550
    mov Wht,250
    invoke GetSystemMetrics,SM_CXSCREEN ; get screen width in pixels
    invoke TopXY,Wwd,eax
    mov Wtx,eax
    invoke GetSystemMetrics,SM_CYSCREEN ; get screen height in pixels
    invoke TopXY,Wht,eax
    mov Wty,eax
    invoke CreateWindowEx,WS_EX_OVERLAPPEDWINDOW,
                          ADDR szClassName,
                          ADDR szDisplayName,
                          WS_OVERLAPPEDWINDOW,
                          Wtx,Wty,Wwd,Wht,
                          NULL,NULL,
                          hInstance,NULL
    mov hWnd,eax
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

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

WndProc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
    
    LOCAL hDC:DWORD
    LOCAL hFont:DWORD
    LOCAL ps:PAINTSTRUCT
    
        .if uMsg == WM_CREATE
            mov deviceInfo.cb,SIZEOF deviceInfo
            invoke EnumDisplayDevices,0,0,ADDR deviceInfo,0
            mov vidModeInfo.dmSize,SIZEOF vidModeInfo
            mov eax,OFFSET [deviceInfo.DeviceName]
            invoke EnumDisplaySettings,eax,vidModeNum,ADDR vidModeInfo

        .elseif uMsg == WM_LBUTTONDOWN
                .if nomoreflag == 0
                    inc vidModeNum
                    mov eax,OFFSET [deviceInfo.DeviceName]
                    invoke EnumDisplaySettings,eax,vidModeNum,ADDR vidModeInfo
                    .if eax == 0
                        mov nomoreflag,1
                        dec vidModeNum
                        invoke MessageBox,hWin,ADDR ThatsAll,ADDR ThatsAll,MB_OK
                    .endif
                 .endif
                 invoke InvalidateRect,hWin,0,TRUE
    
        .elseif uMsg == WM_PAINT
                invoke BeginPaint,hWin,ADDR ps
                mov hDC,eax
                invoke CreateFontIndirect,ADDR lgfnt
                mov hFont,eax
                invoke SelectObject,hDC,hFont
                invoke lstrlen,ADDR [deviceInfo.DeviceString]
                invoke TextOut,hDC,20,20,ADDR [deviceInfo.DeviceString],eax
                push esi
                push edi
                invoke TextOut,hDC,20,50,ADDR colorbits,22
                mov esi,vidModeInfo.dmBitsPerPel 
                mov edi,OFFSET tempbuffer
                invoke dwtoa,esi,edi 
                invoke lstrlen,ADDR tempbuffer
                invoke TextOut,hDC,200,50,ADDR tempbuffer,eax
                invoke TextOut,hDC,20,70,ADDR pixelwidth,22
                mov esi,vidModeInfo.dmPelsWidth  
                mov edi,OFFSET tempbuffer
                invoke dwtoa,esi,edi
                invoke lstrlen,ADDR tempbuffer
                invoke TextOut,hDC,200,70,ADDR tempbuffer,eax
                invoke TextOut,hDC,20,90,ADDR pixelheight,22
                mov esi,vidModeInfo.dmPelsHeight  
                mov edi,OFFSET tempbuffer
                invoke dwtoa,esi,edi
                invoke lstrlen,ADDR tempbuffer
                invoke TextOut,hDC,200,90,ADDR tempbuffer,eax
                invoke TextOut,hDC,20,110,ADDR displayfreq,22
                mov esi,vidModeInfo.dmDisplayFrequency 
                mov edi,OFFSET tempbuffer
                invoke dwtoa,esi,edi
                invoke lstrlen,ADDR tempbuffer
                invoke TextOut,hDC,200,110,ADDR tempbuffer,eax
                invoke TextOut,hDC,20,130,ADDR modeindex,22
                mov esi,vidModeNum 
                mov edi,OFFSET tempbuffer
                invoke dwtoa,esi,edi
                invoke lstrlen,ADDR tempbuffer
                invoke TextOut,hDC,200,130,ADDR tempbuffer,eax
                pop edi
                pop esi
                invoke lstrlen,ADDR HowToUse
                invoke TextOut,hDC,20,180,ADDR HowToUse,eax
                invoke DeleteObject,hFont
                invoke EndPaint,hWin,ADDR ps

        .elseif uMsg == WM_COMMAND
 
        .elseif uMsg == WM_DESTROY
                invoke PostQuitMessage,0 
        .else
            invoke DefWindowProc,hWin,uMsg,wParam,lParam 
            ret 
        .endif 

        xor eax,eax 
        ret 

WndProc endp

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
TopXY proc wDim:DWORD, sDim:DWORD

    shr sDim,1
    shr wDim,1
    mov eax,wDim
    sub sDim,eax
    mov eax,sDim
    ret

TopXY endp

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

end start
