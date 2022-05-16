; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;   Popup Calendar Tray Utility - Author: William F Cravener 12/15/08
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    .486                      ; create 32 bit code
    .model flat,stdcall       ; 32 bit memory model
    option casemap :none      ; case sensitive

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    include \masm32\include\windows.inc
    include \masm32\include\gdi32.inc
    include \masm32\include\user32.inc
    include \masm32\include\shell32.inc 
    include \masm32\include\kernel32.inc

    includelib \masm32\lib\gdi32.lib
    includelib \masm32\lib\user32.lib
    includelib \masm32\lib\shell32.lib
    includelib \masm32\lib\kernel32.lib

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    m2m MACRO M1,M2
      push M2
      pop  M1
    ENDM

    WM_SHELLNOTIFY equ WM_USER+5
 
    IDI_TRAY equ 1001
 
    IDC_TIME equ 1002

    IDM_EXIT equ 1003
    IDM_SHOW equ 1004

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    WinMain                    PROTO :DWORD,:DWORD,:DWORD,:DWORD
    WndProc                    PROTO :DWORD,:DWORD,:DWORD,:DWORD
    CalendarClassDialogProc    PROTO :DWORD,:DWORD,:DWORD,:DWORD

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.data

    hInstance       dd 0
    hWnd            dd 0
    hDialog         dd 0
    hPopupMenu      dd 0

    CalendarClassName     db "CalendarClass",0
    CalendarDisplayName   db "Popup Calendar",0
    CalendarClassDialog   db "CALENDARDIALOG",0

    TimeFormat      db "hh':'mm':'ss",0
    TimeString      db 10 dup(0)

    ShowString      db "S&how Calendar",0 
    ExitString      db "E&xit Program",0
 
    note            NOTIFYICONDATA <>

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.code
start:
    invoke FindWindow,ADDR CalendarClassName,0
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

    mov wc.cbSize,sizeof WNDCLASSEX
    mov wc.style,CS_HREDRAW or CS_VREDRAW or CS_BYTEALIGNWINDOW
    mov wc.lpfnWndProc,OFFSET WndProc
    mov wc.cbClsExtra,0
    mov wc.cbWndExtra,0
    mov eax,hInst
    mov wc.hInstance,eax
    mov wc.hbrBackground,COLOR_WINDOW+1
    mov wc.lpszMenuName,0
    mov wc.lpszClassName,OFFSET CalendarClassName
    invoke LoadIcon,hInstance,500 
    mov wc.hIcon,eax 
    invoke LoadCursor,0,IDC_ARROW
    mov wc.hCursor,eax
    invoke LoadIcon,hInstance,500 
    mov wc.hIconSm,eax

    invoke RegisterClassEx,ADDR wc

    invoke CreateWindowEx,WS_EX_LEFT,
                          ADDR CalendarClassName,
                          ADDR CalendarDisplayName,
                          WS_POPUP,
                          0,0,0,0,
                          0,0,
                          hInstance,0
    mov hWnd,eax

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

    LOCAL pt:POINT
 
        .if uMsg == WM_CREATE
            ;--------------------------------------------------------
            ; Create the applications tray icon menu options.
            ; These menu options are accessed when the user right
            ; clicks on the applications tray icon.
            ;--------------------------------------------------------
            invoke CreatePopupMenu 
            mov hPopupMenu,eax 
            invoke AppendMenu,hPopupMenu,MF_STRING,IDM_SHOW,addr ShowString 
            invoke AppendMenu,hPopupMenu,MF_SEPARATOR,0,0 
            invoke AppendMenu,hPopupMenu,MF_STRING,IDM_EXIT,addr ExitString 

            ;--------------------------------------------------------
            ; Create dialog for the calendar and save dialog handle.
            ;--------------------------------------------------------
            invoke CreateDialogParam,hInstance,ADDR CalendarClassDialog,\
                                     hWin,ADDR CalendarClassDialogProc,0
            mov hDialog,eax

            ;--------------------------------------------------------
            ; Send message to minimize application to system tray.
            ;--------------------------------------------------------
            invoke SendMessage,hWin,WM_SIZE,SIZE_MINIMIZED,0
            
    .elseif uMsg == WM_DESTROY
            ;--------------------------------------------------------
            ; Shut down the Calendar.exe application.
            ;--------------------------------------------------------
            invoke PostQuitMessage,0 

    .elseif uMsg == WM_COMMAND 
            ;--------------------------------------------------------
            ; Handles the applications tray icon popup menu options.
            ;--------------------------------------------------------
            .if lParam == 0 
                .if wParam == IDM_EXIT
                    invoke Shell_NotifyIcon,NIM_DELETE,addr note 
                    invoke SendMessage,hWin,WM_DESTROY,0,0

                .elseif wParam == IDM_SHOW
                    ;------------------------------------------------
                    ; Shows popup calendar if its been hidden.
                    ;------------------------------------------------
                    invoke ShowWindow,hDialog,SW_SHOW

                .endif 
            .endif
 
    .elseif uMsg == WM_SIZE 
            ;--------------------------------------------------------
            ; Minimize the Calendar application to the system tray.
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
                invoke lstrcpy,addr note.szTip,addr CalendarDisplayName 
                invoke ShowWindow,hWin,SW_HIDE 
                invoke Shell_NotifyIcon,NIM_ADD,addr note 
            .endif 

    .elseif uMsg == WM_SHELLNOTIFY 
            ;--------------------------------------------------------
            ; Display the popup menu at the specified location when
            ; the user right clicks on the applications tray icon.
            ;--------------------------------------------------------
            .if wParam == IDI_TRAY 
                .if lParam==WM_RBUTTONDOWN 
                    invoke GetCursorPos,addr pt 
                    invoke SetForegroundWindow,hWin 
                    invoke TrackPopupMenu,hPopupMenu,TPM_RIGHTALIGN,pt.x,pt.y,0,hWin,0 
                    invoke PostMessage,hWin,WM_NULL,0,0 
                .endif 
            .endif
 
    .else
        invoke DefWindowProc,hWin,uMsg,wParam,lParam 
        ret 
    .endif 

    xor eax,eax 
    ret 

WndProc endp

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

CalendarClassDialogProc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

        .if uMsg == WM_INITDIALOG
            invoke LoadIcon,hInstance,500
            invoke SetClassLong,hWin,GCL_HICON,eax
            ;--------------------------------------------------------
            ; Retrieve and format the system time to a string.
            ;--------------------------------------------------------
            invoke GetTimeFormat,0,0,0,ADDR TimeFormat,ADDR TimeString,8

            ;--------------------------------------------------------
            ; Place the formatted time string in the static control.
            ;--------------------------------------------------------
            invoke SetDlgItemText,hWin,IDC_TIME,ADDR TimeString

            ;--------------------------------------------------------
            ; Start our timer to display time string once a second.
            ;--------------------------------------------------------
            invoke SetTimer,hWin,1,1000,0

    .elseif uMsg == WM_TIMER
            ;--------------------------------------------------------
            ; Retrieve/format and show the time string once a second.
            ;--------------------------------------------------------
            invoke GetTimeFormat,0,0,0,ADDR TimeFormat,ADDR TimeString,8
            invoke SetDlgItemText,hWin,IDC_TIME,ADDR TimeString

    .elseif uMsg == WM_CLOSE
            ;--------------------------------------------------------
            ; Hide popup calendar when the close [X] button clicked.
            ;--------------------------------------------------------
            invoke ShowWindow,hWin,SW_HIDE

    .elseif uMsg==WM_CTLCOLORSTATIC
            ;--------------------------------------------------------
            ; Set static control IDC_TIME background to white.
            ;--------------------------------------------------------
            invoke GetStockObject,WHITE_BRUSH
            ret

    .endif 
            xor eax,eax 
            ret 

CalendarClassDialogProc endp

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

end start
