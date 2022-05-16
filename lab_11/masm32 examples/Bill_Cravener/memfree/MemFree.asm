; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; GlobalMemoryStatusEx Example - Author: William F Cravener 01 . 17 . 09
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    .486                      ; create 32 bit code
    .model flat,stdcall       ; 32 bit memory model
    option casemap :none      ; case sensitive

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    include \masm32\include\windows.inc
    include \masm32\include\gdi32.inc
    include \masm32\include\user32.inc
    include \masm32\include\kernel32.inc
    include \masm32\include\masm32.inc

    includelib \masm32\lib\gdi32.lib
    includelib \masm32\lib\user32.lib
    includelib \masm32\lib\kernel32.lib
    includelib \masm32\lib\masm32.lib

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    DWORDDWORD STRUCT
       lowDWORD DWORD ?
       highDWORD DWORD ?
    DWORDDWORD ENDS

    MEMORYSTATUSEX STRUCT
       dwLength           DWORD ?
       dwMemoryLoad       DWORD ?
       ullTotalPhys       DWORDDWORD <>
       ullAvailPhys       DWORDDWORD <>
       ullTotalPageFile   DWORDDWORD <>
       ullAvailPageFile   DWORDDWORD <>
       ullTotalVirtual    DWORDDWORD <>
       ullAvailVirtual    DWORDDWORD <>
       ullAvailExtendedVirtual  DWORDDWORD <>
    MEMORYSTATUSEX ENDS

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    WinMain      PROTO :DWORD,:DWORD,:DWORD,:DWORD
    WndProc      PROTO :DWORD,:DWORD,:DWORD,:DWORD
    TopXY        PROTO :DWORD,:DWORD

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.data
    hInstance       dd 0
    hWnd            dd 0

    szClassName     db "MemFree",0
    szDisplayName   db "MemFree",0

    MemString1      db "Total physical memory: ",0
    PhysicalMem1    db 10 dup(0)
    MemString2      db " Free physical memory: ",0
    PhysicalMem2    db 10 dup(0)
    MemString3      db " Total page file size: ",0
    PagingMem3      db 10 dup(0)
    MemString4      db "  Free page file size: ",0
    PagingMem4      db 10 dup(0)
    MemString5      db " Total virtual memory: ",0
    VirtualMem5     db 10 dup(0)
    MemString6      db "  Free virtual memory: ",0
    VirtualMem6     db 10 dup(0)
    MemString7      db "Free extended virtual: ",0
    VirtualMem7     db 10 dup(0)

    paintstruct     PAINTSTRUCT <>
    memStatusEx     MEMORYSTATUSEX <>
    lgfnt           LOGFONT <14,0,0,0,0,0,0,0,0,0,0,0,0,"Lucida Console">

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.code
start:
    invoke FindWindow,ADDR szClassName,0
    cmp eax,0
    je @F
    mov eax,0
    ret
    @@:
    invoke GetModuleHandle,0
    mov hInstance,eax
    invoke WinMain,hInstance,0,0,0
    invoke ExitProcess,eax

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

WinMain proc hInst:DWORD,hPrevInst:DWORD,CmdLine:DWORD,CmdShow:DWORD

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
    invoke LoadIcon,hInstance,500 
    mov wc.hIcon,eax 
    invoke LoadCursor,0,IDC_ARROW
    mov wc.hCursor,eax
    invoke LoadIcon,hInstance,500 
    mov wc.hIconSm,eax

    invoke RegisterClassEx,ADDR wc

    mov Wwd,320
    mov Wht,220

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
 
        .if uMsg == WM_CREATE
            call ShowRAMFreeProc
            
    .elseif uMsg == WM_PAINT
            invoke BeginPaint,hWin,ADDR paintstruct
            mov hDC,eax
            invoke CreateFontIndirect,ADDR lgfnt
            mov hFont,eax
            invoke SelectObject,hDC,hFont
            invoke TextOut,hDC,20,20,ADDR MemString1,24
            invoke lstrlen,ADDR PhysicalMem1
            invoke TextOut,hDC,200,20,ADDR PhysicalMem1,eax
            invoke TextOut,hDC,20,40,ADDR MemString2,24
            invoke lstrlen,ADDR PhysicalMem2
            invoke TextOut,hDC,200,40,ADDR PhysicalMem2,eax
            invoke TextOut,hDC,20,60,ADDR MemString3,24
            invoke lstrlen,ADDR PagingMem3
            invoke TextOut,hDC,200,60,ADDR PagingMem3,eax
            invoke TextOut,hDC,20,80,ADDR MemString4,24
            invoke lstrlen,ADDR PagingMem4
            invoke TextOut,hDC,200,80,ADDR PagingMem4,eax
            invoke TextOut,hDC,20,100,ADDR MemString5,24
            invoke lstrlen,ADDR VirtualMem5
            invoke TextOut,hDC,200,100,ADDR VirtualMem5,eax
            invoke TextOut,hDC,20,120,ADDR MemString6,24
            invoke lstrlen,ADDR VirtualMem6
            invoke TextOut,hDC,200,120,ADDR VirtualMem6,eax
            invoke TextOut,hDC,20,140,ADDR MemString7,24
            invoke lstrlen,ADDR VirtualMem7
            invoke TextOut,hDC,200,140,ADDR VirtualMem7,eax
            invoke DeleteObject,hFont
            invoke EndPaint,hWin,ADDR paintstruct

    .elseif uMsg == WM_DESTROY
            invoke PostQuitMessage,0 
    .else
        invoke DefWindowProc,hWin,uMsg,wParam,lParam 
        ret 
    .endif 

    xor eax,eax 
    ret 

WndProc endp

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ShowRAMFreeProc proc

            push eax
            push ecx
            push edx
            push edi
            push esi

            mov memStatusEx.dwLength,sizeof MEMORYSTATUSEX
            invoke GlobalMemoryStatusEx,ADDR memStatusEx

            mov eax,memStatusEx.ullTotalPhys.lowDWORD
            mov edx,memStatusEx.ullTotalPhys.highDWORD
            mov ecx,1024
            div ecx
            mov esi,eax
            mov edi,OFFSET PhysicalMem1
            invoke dwtoa,esi,edi 

            mov eax,memStatusEx.ullAvailPhys.lowDWORD
            mov edx,memStatusEx.ullAvailPhys.highDWORD
            mov ecx,1024
            div ecx
            mov esi,eax
            mov edi,OFFSET PhysicalMem2
            invoke dwtoa,esi,edi 

            mov eax,memStatusEx.ullTotalPageFile.lowDWORD
            mov edx,memStatusEx.ullTotalPageFile.highDWORD
            mov ecx,1024
            div ecx
            mov esi,eax
            mov edi,OFFSET PagingMem3
            invoke dwtoa,esi,edi 

            mov eax,memStatusEx.ullAvailPageFile.lowDWORD
            mov edx,memStatusEx.ullAvailPageFile.highDWORD
            mov ecx,1024
            div ecx
            mov esi,eax
            mov edi,OFFSET PagingMem4
            invoke dwtoa,esi,edi 

            mov eax,memStatusEx.ullTotalVirtual.lowDWORD
            mov edx,memStatusEx.ullTotalVirtual.highDWORD
            mov ecx,1024
            div ecx
            mov esi,eax
            mov edi,OFFSET VirtualMem5
            invoke dwtoa,esi,edi 

            mov eax,memStatusEx.ullAvailVirtual.lowDWORD
            mov edx,memStatusEx.ullAvailVirtual.highDWORD
            mov ecx,1024
            div ecx
            mov esi,eax
            mov edi,OFFSET VirtualMem6
            invoke dwtoa,esi,edi 

            mov eax,memStatusEx.ullAvailExtendedVirtual.lowDWORD
            mov edx,memStatusEx.ullAvailExtendedVirtual.highDWORD
            mov ecx,1024
            div ecx
            mov esi,eax
            mov edi,OFFSET VirtualMem7
            invoke dwtoa,esi,edi 

            pop esi
            pop edi
            pop edx
            pop ecx
            pop eax
            ret

ShowRAMFreeProc endp

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

TopXY proc wDim:DWORD, sDim:DWORD

    shr sDim,1
    shr wDim,1
    mov eax,wDim
    sub sDim,eax
    mov eax,sDim
    ret

TopXY endp

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

end start 
