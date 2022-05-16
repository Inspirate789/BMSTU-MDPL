comment * ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

        This example creates a normal window as a base application then it
        creates a series of seperate threads each one containing a working
        window that displays a timer on its title bar.

        Each new thread reuses the same code and all of the thread are
        terminated by sending a Windows message with the HWND_BROADCAST
        handle with a custom message registered with the OS.

        ; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл *

    .486                        ; create 32 bit code
    .model flat, stdcall        ; 32 bit memory model
    option casemap :none        ; case sensitive

    include multhrd.inc         ; local includes for this file

  .data?
    WM_CLOSETHREADAPP dd ?      ; name a variable for a custom message
    hButn1 dd ?                 ; handles for the three buttons
    hButn2 dd ?
    hButn3 dd ?

.code

start:

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

      invoke InitCommonControls

    ; ---------------------------
    ; register the custom message
    ; ---------------------------
      mov WM_CLOSETHREADAPP, rv(RegisterWindowMessage,"shutem_down_now")

    ; ------------------
    ; set global values
    ; ------------------
      mov hInstance,   FUNC(GetModuleHandle, NULL)
      mov CommandLine, FUNC(GetCommandLine)
      mov hIcon,       FUNC(LoadIcon,NULL,IDI_APPLICATION)
      mov hCursor,     FUNC(LoadCursor,NULL,IDC_ARROW)
      mov sWid,        FUNC(GetSystemMetrics,SM_CXSCREEN)
      mov sHgt,        FUNC(GetSystemMetrics,SM_CYSCREEN)

      call Main

      invoke ExitProcess,eax

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

Main proc

    LOCAL Wwd:DWORD,Wht:DWORD,Wtx:DWORD,Wty:DWORD

    STRING szClassName,"Multi_Thread_Class"

  ; --------------------------------------------
  ; register class name for CreateWindowEx call
  ; --------------------------------------------
    invoke RegisterWinClass,ADDR WndProc,ADDR szClassName,
                       hIcon,hCursor,COLOR_BTNFACE+1

  ; -------------------------------------------------
  ; macro to autoscale window co-ordinates to screen
  ; percentages and centre window at those sizes.
  ; -------------------------------------------------
    AutoScale 45, 30

    invoke CreateWindowEx,WS_EX_LEFT or WS_EX_ACCEPTFILES,
                          ADDR szClassName,
                          ADDR szDisplayName,
                          WS_OVERLAPPEDWINDOW,
                          Wtx,Wty,Wwd,Wht,
                          NULL,NULL,
                          hInstance,NULL
    mov hWnd,eax

  ; ---------------------------
  ; macros for unchanging code
  ; ---------------------------
    DisplayWindow hWnd,SW_SHOWNORMAL

    call MsgLoop
    ret

Main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

RegisterWinClass proc lpWndProc:DWORD, lpClassName:DWORD,
                      Icon:DWORD, Cursor:DWORD, bColor:DWORD

    LOCAL wc:WNDCLASSEX

    mov wc.cbSize,         sizeof WNDCLASSEX
    mov wc.style,          CS_BYTEALIGNCLIENT or \
                           CS_BYTEALIGNWINDOW
    m2m wc.lpfnWndProc,    lpWndProc
    mov wc.cbClsExtra,     NULL
    mov wc.cbWndExtra,     NULL
    m2m wc.hInstance,      hInstance
    m2m wc.hbrBackground,  bColor
    mov wc.lpszMenuName,   NULL
    m2m wc.lpszClassName,  lpClassName
    m2m wc.hIcon,          Icon
    m2m wc.hCursor,        Cursor
    m2m wc.hIconSm,        Icon

    invoke RegisterClassEx, ADDR wc

    ret

RegisterWinClass endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

MsgLoop proc

    LOCAL msg:MSG

    push esi
    push edi
    xor edi, edi                        ; clear EDI
    lea esi, msg                        ; Structure address in ESI
    jmp jumpin

    StartLoop:
      invoke TranslateMessage, esi
    ; --------------------------------------
    ; perform any required key processing here
    ; --------------------------------------
      invoke DispatchMessage,  esi
    jumpin:
      invoke GetMessage,esi,edi,edi,edi
      test eax, eax
      jnz StartLoop

    mov eax, msg.wParam
    pop edi
    pop esi

    ret

MsgLoop endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

WndProc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

    LOCAL tID    :DWORD

    Switch uMsg
      Case WM_COMMAND
        Switch wParam
          Case 50
          ; ------------------------------------
          ; loop through starting 10 new threads
          ; ------------------------------------
            push esi
            push edi
            xor esi, esi
            xor edi, edi
          @@:
            add esi, 25
            add edi, 1
            fn CreateThread,0,0,ADDR CreateNewThread,esi,0,ADDR tID
            cmp edi, 10
            jl @B
            pop edi
            pop esi

          Case 51
          ; ----------------
          ; close all thread
          ; ----------------
            invoke SendMessage,HWND_BROADCAST,WM_CLOSETHREADAPP,0,0

          Case 52
            invoke SendMessage,hWin,WM_SYSCOMMAND,SC_CLOSE,NULL

        Endsw

      Case WM_CREATE
        mov hButn1, rv(PushButton,"Start Threads",hWin,20,20,130,25,50)
        mov hButn2, rv(PushButton,"Stop Threads",hWin,20,50,130,25,51)
        mov hButn3, rv(PushButton,"Close",hWin,20,80,130,25,52)

        push esi
        mov esi, rv(GetStockObject,SYSTEM_FIXED_FONT)
        invoke SendMessage,hButn1,WM_SETFONT,esi,TRUE
        invoke SendMessage,hButn2,WM_SETFONT,esi,TRUE
        invoke SendMessage,hButn3,WM_SETFONT,esi,TRUE
        pop esi

      Case WM_CLOSE

      Case WM_DESTROY
        invoke PostQuitMessage,NULL
        return 0

    Endsw

    invoke DefWindowProc,hWin,uMsg,wParam,lParam

    ret

WndProc endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

OPTION PROLOGUE:NONE 
OPTION EPILOGUE:NONE 

TopXY proc wDim:DWORD, sDim:DWORD

    mov eax, [esp+8]
    sub eax, [esp+4]
    shr eax, 1

    ret 8

TopXY endp

OPTION PROLOGUE:PrologueDef 
OPTION EPILOGUE:EpilogueDef 

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

PushButton proc lpText:DWORD,hParent:DWORD,
                a:DWORD,b:DWORD,wd:DWORD,ht:DWORD,ID:DWORD

    szText btnClass,"BUTTON"

    invoke CreateWindowEx,0,
            ADDR btnClass,lpText,
            WS_CHILD or WS_VISIBLE,
            a,b,wd,ht,hParent,ID,
            hInstance,NULL

    ret

PushButton endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

CreateNewThread proc argument:DWORD

  ; ----------------------------------------------------------------
  ; each time this procedure is called a new thread has been created.
  ; ----------------------------------------------------------------
    LOCAL Wwd:DWORD,Wht:DWORD,Wtx:DWORD,Wty:DWORD,hWin:DWORD

    LOCAL pbuf      :DWORD
    LOCAL buffer[64]:BYTE
    LOCAL msg       :MSG

    mov pbuf, ptr$(buffer)

    STRING szThreadName,"new_thread_class"

  ; --------------------------------------------
  ; register class name for CreateWindowEx call
  ; --------------------------------------------
    invoke RegisterWinClass,ADDR NewThreadProc,ADDR szThreadName,
                       hIcon,hCursor,COLOR_BTNFACE+1

    AutoScale 18, 10

    invoke CreateWindowEx,WS_EX_LEFT or WS_EX_ACCEPTFILES,
                          ADDR szThreadName,
                          ADDR szDisplayName,
                          WS_OVERLAPPEDWINDOW,
                          Wtx,argument,Wwd,Wht,
                          hWnd,NULL,
                          hInstance,NULL
    mov hWin,eax
    DisplayWindow hWin,SW_SHOWNORMAL

    invoke SetActiveWindow,hWin

  ; ---------------------------------------------
  ; each seperate thread has its own message loop
  ; ---------------------------------------------
    push esi
    push edi
    xor edi, edi                        ; clear EDI
    lea esi, msg                        ; Structure address in ESI
    jmp jumpin

    StartLoop:
      invoke TranslateMessage, esi
      invoke DispatchMessage, esi
    jumpin:
      invoke GetMessage,esi,edi,edi,edi
      test eax, eax
      jnz StartLoop

    mov eax, msg.wParam
    pop edi
    pop esi

    ret

CreateNewThread endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

NewThreadProc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

    Switch uMsg

      case WM_CREATE
        invoke SetTimer,hWin,1234,200,0

      case WM_CLOSETHREADAPP
        invoke SendMessage,hWin,WM_SYSCOMMAND,SC_CLOSE,0

      case WM_COMMAND

      case WM_TIMER
        fn SetWindowText,hWin,str$(rv(GetTickCount))

      case WM_CLOSE
        invoke KillTimer,hWin,1234
        invoke SetActiveWindow,hWnd

      case WM_DESTROY
        invoke PostQuitMessage,NULL
        return 0

    Endsw

    invoke DefWindowProc,hWin,uMsg,wParam,lParam

    ret

NewThreadProc endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start
