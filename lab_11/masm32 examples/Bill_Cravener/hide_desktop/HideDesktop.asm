; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;   Hide My Desktop Tray Utility - Author: William F Cravener 08/08/2011
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;   Right click on Hide My Desktop tray icon to access menu options.
;   Once hidden either press ALT + anykey or left double click mouse.
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    .586                      ; create 32 bit code
    .model flat,stdcall       ; 32 bit memory model
    option casemap :none      ; case sensitive

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    include \masm32\include\windows.inc
    include \masm32\include\user32.inc
    include \masm32\include\shell32.inc 
    include \masm32\include\kernel32.inc

    includelib \masm32\lib\user32.lib
    includelib \masm32\lib\shell32.lib
    includelib \masm32\lib\kernel32.lib

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    WM_SHELLNOTIFY equ WM_USER+5
 
    IDI_TRAY equ 1001
    IDM_EXIT equ 1002
    IDM_HIDE equ 1003

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    WinMain          PROTO :DWORD,:DWORD,:DWORD,:DWORD
    WndProc          PROTO :DWORD,:DWORD,:DWORD,:DWORD
    HideDialogProc   PROTO :DWORD,:DWORD,:DWORD,:DWORD

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.data

    hInstance        dd 0
    hWnd             dd 0
    hPopupMenu       dd 0

    scrW             dd 0
    scrH             dd 0
    mainDC           dd 0

    HideDialogClass  db "HideDesktop",0
    HideDialogName   db "Hide My Desktop",0

    HideString       db "H&ide Desktop",0
    ExitString       db "E&xit Program",0

    HideDialog       db "HIDEDIALOG",0

    note             NOTIFYICONDATA <>
    pnt              PAINTSTRUCT <>
    pt               POINT <>


; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.code

start:
    invoke FindWindow,ADDR HideDialogClass,0
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
    ;---------------------------------
    ; Standard window creation stuff
    ;---------------------------------

    LOCAL wc:WNDCLASSEX
    LOCAL msg:MSG

    mov wc.cbSize,sizeof WNDCLASSEX
    mov wc.style,CS_HREDRAW or CS_VREDRAW or CS_BYTEALIGNWINDOW
    mov wc.lpfnWndProc,OFFSET WndProc
    mov wc.cbClsExtra,0
    mov wc.cbWndExtra,0
    mov eax,hInst
    mov wc.hInstance,eax
    mov wc.hbrBackground,COLOR_WINDOW+1
    mov wc.lpszMenuName,0
    mov wc.lpszClassName,OFFSET HideDialogClass
    invoke LoadIcon,hInstance,500 
    mov wc.hIcon,eax 
    invoke LoadCursor,0,IDC_ARROW
    mov wc.hCursor,eax
    invoke LoadIcon,hInstance,500 
    mov wc.hIconSm,eax

    invoke RegisterClassEx,ADDR wc

    invoke CreateWindowEx,WS_EX_LEFT,
                          ADDR HideDialogClass,
                          ADDR HideDialogName,
                          WS_POPUP,
                          0,0,0,0,
                          0,0,
                          hInstance,0
    mov hWnd,eax
    ;--------------------------------------
    ; We do not want to clutter the task-
    ; bar so we do not show the app window
    ;--------------------------------------
    ; invoke ShowWindow,hWnd,SW_SHOW
    ;--------------------------------------

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
 
        .if uMsg == WM_CREATE
            ;--------------------------------------------------------
            ; Create the applications tray icon menu options.
            ; These menu options are accessed when the user right
            ; clicks on the applications tray icon.
            ;--------------------------------------------------------
            invoke CreatePopupMenu 
            mov hPopupMenu,eax 
            invoke AppendMenu,hPopupMenu,MF_STRING,IDM_HIDE,addr HideString 
            invoke AppendMenu,hPopupMenu,MF_STRING,IDM_EXIT,addr ExitString 
            ;--------------------------------------------------------
            ; Send message to minimize application to system tray.
            ;--------------------------------------------------------
            invoke SendMessage,hWin,WM_SIZE,SIZE_MINIMIZED,0
            
    .elseif uMsg == WM_COMMAND 
            ;--------------------------------------------------------
            ; Handles the applications tray icon popup menu options.
            ;--------------------------------------------------------
            .if lParam == 0 
                .if wParam == IDM_EXIT
                    invoke Shell_NotifyIcon,NIM_DELETE,addr note 
                    invoke SendMessage,hWin,WM_DESTROY,0,0
                .elseif wParam == IDM_HIDE 
                    invoke CreateDialogParam,hInstance,ADDR HideDialog,hWin,ADDR HideDialogProc,0
                .endif 
            .endif
 
    .elseif uMsg == WM_DESTROY
            ;--------------------------------------------------------
            ; Shut down the application.
            ;--------------------------------------------------------
            invoke PostQuitMessage,0 

    .elseif uMsg == WM_SIZE 
            ;--------------------------------------------------------
            ; Minimize the application to the system tray.
            ;--------------------------------------------------------
            .if wParam == SIZE_MINIMIZED 
                mov note.cbSize,sizeof NOTIFYICONDATA 
                push hWin 
                pop note.hwnd 
                mov note.uID,IDI_TRAY 
                mov note.uFlags,NIF_ICON+NIF_MESSAGE+NIF_TIP 
                mov note.uCallbackMessage,WM_SHELLNOTIFY  
                invoke LoadIcon,hInstance,500 
                mov note.hIcon,eax 
                invoke lstrcpy,addr note.szTip,addr HideDialogName 
                invoke ShowWindow,hWin,SW_HIDE 
                invoke Shell_NotifyIcon,NIM_ADD,addr note 
            .endif 

    .elseif uMsg == WM_SHELLNOTIFY 
            .if wParam == IDI_TRAY 
                ;--------------------------------------------------------
                ; Display the popup menu at the specified location when
                ; the user right clicks on the applications tray icon.
                ;--------------------------------------------------------
                .if lParam == WM_RBUTTONDOWN or WM_RBUTTONUP 
                    invoke GetCursorPos,addr pt 
                    invoke SetForegroundWindow,hWin 
                    invoke TrackPopupMenu,hPopupMenu,TPM_RIGHTALIGN,pt.x,pt.y,0,hWin,0 
                    invoke PostMessage,hWin,WM_NULL,0,0 
                .endif 
            .endif
    .endif

    invoke DefWindowProc,hWin,uMsg,wParam,lParam 
    ret 

WndProc endp

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

HideDialogProc proc hWin:DWORD,uMsg:DWORD,aParam:DWORD,bParam:DWORD

        .if uMsg == WM_INITDIALOG
            invoke GetSystemMetrics,SM_CXSCREEN
            mov scrW,eax  ; Save screen width
            invoke GetSystemMetrics,SM_CYSCREEN
            mov scrH,eax  ; Save screen height 
            invoke ShowCursor,FALSE ; Hide cursor
            ;-----------------------------------------
            ; Fill the entire screen with the dialog
            ;-----------------------------------------
            invoke SetWindowPos,hWin,HWND_TOPMOST,0,0,scrW,scrH,SWP_SHOWWINDOW

    .elseif uMsg == WM_PAINT
            invoke BeginPaint,hWin,ADDR pnt
            invoke GetWindowDC,hWin
            mov mainDC,eax
            invoke PaintDesktop,mainDC ; Paint dialog with desktop wallpaper
            invoke ReleaseDC,hWin,mainDC
            invoke EndPaint,hWin,ADDR pnt

    .elseif uMsg == WM_COMMAND

    .elseif uMsg == WM_SYSKEYUP        ; ALT + anykey 
            invoke ShowCursor,TRUE     ; Show the cursor
            invoke DestroyWindow,hWin

    .elseif uMsg == WM_LBUTTONDBLCLK   ; Mouse left double click 
            invoke ShowCursor,TRUE     ; Show the cursor
            invoke DestroyWindow,hWin
    .endif

    xor eax,eax
    ret
                    
HideDialogProc endp

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

end start
