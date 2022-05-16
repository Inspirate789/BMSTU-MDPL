
comment * ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

        This example uses function from the PSAPI DLL to list
        device drivers running within the operating system.

        ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл *

      .486                      ; create 32 bit code
      .model flat, stdcall      ; 32 bit memory model
      option casemap :none      ; case sensitive

      include enumdd.inc        ; local includes for this file

.code

start:

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

      invoke InitCommonControls

    ; ------------------
    ; set global values
    ; ------------------
      mov hInstance,   FUNC(GetModuleHandle, NULL)
      mov CommandLine, FUNC(GetCommandLine)
      mov hIcon,       FUNC(LoadIcon,hInstance,500)
      mov hCursor,     FUNC(LoadCursor,NULL,IDC_ARROW)
      mov sWid,        FUNC(GetSystemMetrics,SM_CXSCREEN)
      mov sHgt,        FUNC(GetSystemMetrics,SM_CYSCREEN)

      call Main

      invoke ExitProcess,eax

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

Main proc

    LOCAL Wwd:DWORD,Wht:DWORD,Wtx:DWORD,Wty:DWORD

    STRING szClassName,"Prostart_Class"

  ; --------------------------------------------
  ; register class name for CreateWindowEx call
  ; --------------------------------------------
    invoke RegisterWinClass,ADDR WndProc,ADDR szClassName,
                       hIcon,hCursor,COLOR_BTNFACE+1

  ; -------------------------------------------------
  ; macro to autoscale window co-ordinates to screen
  ; percentages and centre window at those sizes.
  ; -------------------------------------------------
    AutoScale 60, 45

    fn CreateWindowEx,WS_EX_LEFT,ADDR szClassName, \
                          "Enumerate Running Device Drivers", \
                          WS_OVERLAPPEDWINDOW or WS_CLIPCHILDREN, \
                          Wtx,Wty,Wwd,Wht, \
                          NULL,NULL, \
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

    LOCAL var    :DWORD
    LOCAL caW    :DWORD
    LOCAL caH    :DWORD
    LOCAL sbh   :DWORD
    LOCAL Rct    :RECT
    LOCAL buffer1[260]:BYTE  ; these are two spare buffers
    LOCAL buffer2[260]:BYTE  ; for text manipulation etc..

    switch uMsg
      case WM_COMMAND

      case WM_CREATE
        invoke Do_Status,hWin
        mov hList, rv(ListBox,0,30,150,200,hWin,600)
        invoke SendMessage,hList,WM_SETFONT,rv(GetStockObject,SYSTEM_FIXED_FONT),TRUE

        call enumproc

      case WM_SYSCOLORCHANGE

      case WM_SIZE
        invoke MoveWindow,hStatus,0,0,0,0,TRUE
        invoke GetClientRect,hStatus,ADDR Rct
        mov eax, Rct.bottom
        mov sbh, eax
        invoke GetClientRect,hWin,ADDR Rct
        mov eax, sbh
        sub Rct.bottom, eax
        invoke MoveWindow,hList,0,0,Rct.right,Rct.bottom,TRUE

      case WM_CLOSE

      case WM_DESTROY
        invoke PostQuitMessage,NULL
        return 0

    endsw

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

ListBox proc a:DWORD,b:DWORD,wd:DWORD,ht:DWORD,hParent:DWORD,ID:DWORD

    fn CreateWindowEx,WS_EX_STATICEDGE,"LISTBOX",0, \
              WS_VSCROLL or WS_VISIBLE or \
              WS_CHILD or LBS_HASSTRINGS or \
              LBS_NOINTEGRALHEIGHT or LBS_DISABLENOSCROLL, \
              a,b,wd,ht,hParent,ID,hInstance,NULL
    ret

ListBox endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

enumproc proc

    LOCAL parr  :DWORD
    LOCAL breq  :DWORD
    LOCAL pbuf  :DWORD
    LOCAL ptxt  :DWORD
    LOCAL buffer[512]:BYTE
    LOCAL txt[64]:BYTE

    push esi
    push edi

    mov pbuf, ptr$(buffer)
    mov ptxt, ptr$(txt)

    invoke EnumDeviceDrivers,NULL,NULL,ADDR breq    ; get array size in bytes
    mov parr, alloc(breq)                           ; allocate required memory
    invoke EnumDeviceDrivers,parr,breq,ADDR breq    ; enumerate device drivers
    shr breq, 2                                     ; divide result by 4 for driver count

    mov esi, parr                                   ; array address in ESI
    mov edi, breq                                   ; driver count in EDI
  @@:
    invoke GetDeviceDriverFileName,[esi],pbuf,512
    invoke SendMessage,hList,LB_ADDSTRING,0,pbuf
    add esi, 4
    sub edi, 1
    jnz @B

    free parr                                       ; deallocate memory

  ; ----------------------------------
  ; display device count on status bar.
  ; ----------------------------------
    mov ptxt, cat$(ptxt," Device Count = ",str$(breq))
    fn SendMessage,hStatus,SB_SETTEXT,3,ptxt

    pop edi
    pop esi

    ret

enumproc endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start
