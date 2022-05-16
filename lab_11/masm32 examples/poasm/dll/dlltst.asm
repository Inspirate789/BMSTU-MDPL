; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

      .model flat, stdcall  ; 32 bit memory model
      option casemap :none  ; case sensitive 
      option cstrings:on    ; enable C string escapes

    ; *************
    ; include files
    ; *************
      include \masm32\include\windows.inc
      include \masm32\include\gdi32.inc
      include \masm32\include\user32.inc
      include \masm32\include\kernel32.inc
      include \masm32\include\Comctl32.inc
      include \masm32\include\comdlg32.inc
      include \masm32\include\shell32.inc
      include \masm32\include\msvcrt.inc
      include \masm32\macros\pomacros.asm

      tstproc PROTO :DWORD

    ; *********
    ; libraries
    ; *********
      includelib \masm32\lib\gdi32.lib
      includelib \masm32\lib\user32.lib
      includelib \masm32\lib\kernel32.lib
      includelib \masm32\lib\Comctl32.lib
      includelib \masm32\lib\comdlg32.lib
      includelib \masm32\lib\shell32.lib
      includelib \masm32\lib\msvcrt.lib
      includelib tstdll.lib

    ; ****************
    ; Local prototypes
    ; ****************
      main PROTO
      WndProc PROTO :DWORD,:DWORD,:DWORD,:DWORD

    .data
      szDisplayName db "POASM Template",0
      szClassName   db "Poasm_Class",0

    .data?
      CommandLine   dd ?
      hWnd          dd ?
      hInstance     dd ?
      hIcon         dd ?
      hCursor       dd ?

    .code

start:

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

      mov hInstance,   FUNC(GetModuleHandle, NULL)
      mov CommandLine, FUNC(GetCommandLine)
      mov hIcon,       FUNC(LoadIcon,hInstance,5)
      mov hCursor,     FUNC(LoadCursor,NULL,IDC_ARROW)

      invoke main
      invoke ExitProcess,eax

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

main proc

      LOCAL Wwd  :DWORD
      LOCAL Wht  :DWORD
      LOCAL Wtx  :DWORD
      LOCAL Wty  :DWORD
      LOCAL msg  :MSG
      LOCAL wc   :WNDCLASSEX

      mov wc.cbSize,         sizeof WNDCLASSEX
      mov wc.style,          CS_BYTEALIGNWINDOW
      mov wc.lpfnWndProc,    offset WndProc
      mov wc.cbClsExtra,     NULL
      mov wc.cbWndExtra,     NULL
      m2m wc.hInstance,      hInstance
      mov wc.hbrBackground,  COLOR_BTNFACE+1
      mov wc.lpszMenuName,   NULL
      mov wc.lpszClassName,  offset szClassName
      m2m wc.hIcon,          hIcon
      m2m wc.hCursor,        hCursor
      m2m wc.hIconSm,        hIcon

      invoke RegisterClassEx, ADDR wc

      mov Wwd, 600
      mov Wht, 400

      invoke GetSystemMetrics,SM_CXSCREEN
      mov Wtx, SetXY(Wwd,eax)

      invoke GetSystemMetrics,SM_CYSCREEN
      mov Wty, SetXY(Wht,eax)

      invoke CreateWindowEx,WS_EX_LEFT,
                            ADDR szClassName,
                            ADDR szDisplayName,
                            WS_OVERLAPPEDWINDOW,
                            Wtx,Wty,Wwd,Wht,
                            NULL,NULL,
                            hInstance,NULL
      mov   hWnd,eax

      invoke LoadMenu,hInstance,600  ; menu ID
      invoke SetMenu,hWnd,eax

      invoke ShowWindow,hWnd,SW_SHOWNORMAL
      invoke UpdateWindow,hWnd

    StartLoop:
      invoke TranslateMessage, ADDR msg
      invoke DispatchMessage,  ADDR msg
      invoke GetMessage,ADDR msg,NULL,0,0
      test al, al
      jnz StartLoop

      mov eax, msg.wParam
      ret

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

WndProc proc hWin:DWORD,uMsg:DWORD,wParam :DWORD,lParam :DWORD

    LOCAL hDC    :DWORD
    LOCAL Ps     :PAINTSTRUCT

    .if uMsg == WM_COMMAND
      .if wParam == 1000
        invoke SendMessage,hWin,WM_SYSCOMMAND,SC_CLOSE,NULL

      .elseif wParam == 2000
        szText AboutMsg,"POASM Pure Assembler Template\r\nCopyright й The POASM Project 2006"
        invoke ShellAbout,hWin,ADDR szDisplayName,ADDR AboutMsg,hIcon
      .endif

    .elseif uMsg == WM_CREATE
      fn tstproc,"Text for the DLL Test"

    .elseif uMsg == WM_SIZE

    .elseif uMsg == WM_PAINT
      invoke BeginPaint,hWin,ADDR Ps
      mov hDC, eax
      
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

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start
