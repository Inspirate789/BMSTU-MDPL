; #########################################################################
;
;   This demo show how to use an external DLL when you have no IMPORT
;   library to use for its functions. It uses LoadLibrary() and
;   GetProcAddress() to get the addresses of the functions. It shows 2
;   ways of calling the functions, a seperate procedure for each function
;   call so that the invoke syntax can be used and a direct call to the
;   function where stack overhead interferes with speed critical code.
;
;   The code to use the DLL functions is in the WndProc procedure and is
;   processed in the WM_COMMAND message. The seperate procedures for each
;   function call are at the end of the file.
;
; #########################################################################

      .386
      .model flat, stdcall  ; 32 bit memory model
      option casemap :none  ; case sensitive

      include ExDLL.inc     ; local includes for this file

    ; -----------------------------------
    ; Normal prototypes for DLL functions
    ; -----------------------------------
      Sqrt      PROTO:DWORD
      ShowValue PROTO:DWORD
      Add_1     PROTO:DWORD
      Minus_1   PROTO:DWORD

; #########################################################################

.code

start:
      invoke LoadLibrary,ADDR DLLname   ; Load the DLL and get its handle
      mov hDLL, eax

      invoke LoadProcs,hDLL             ; Get the addresses of the procedures

      invoke GetModuleHandle, NULL
      mov hInstance, eax

      invoke GetCommandLine
      mov CommandLine, eax

      invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT

      invoke FreeLibrary,hDLL           ; Free the DLL after use

      invoke ExitProcess,eax

; #########################################################################

LoadProcs proc hLibrary:DWORD

  ; --------------------------------------------------------------
  ; This gets the address of each procedure so it can be used with
  ; the "call" mnemonic in either the seperate procedures for each
  ; function or for direct manual function usage.
  ; --------------------------------------------------------------

    invoke GetProcAddress,hLibrary,ADDR p1name
    mov lpSqrt, eax

    invoke GetProcAddress,hLibrary,ADDR p2name
    mov lpShowValue, eax

    invoke GetProcAddress,hLibrary,ADDR p3name
    mov lpAdd_1, eax

    invoke GetProcAddress,hLibrary,ADDR p4name
    mov lpMinus_1, eax

    ret

LoadProcs endp

; #########################################################################

WinMain proc hInst     :DWORD,
             hPrevInst :DWORD,
             CmdLine   :DWORD,
             CmdShow   :DWORD

      ;====================
      ; Put LOCALs on stack
      ;====================

      LOCAL wc   :WNDCLASSEX
      LOCAL msg  :MSG
      LOCAL Wwd  :DWORD
      LOCAL Wht  :DWORD
      LOCAL Wtx  :DWORD
      LOCAL Wty  :DWORD
      LOCAL ref  :DWORD

      ;==================================================
      ; Fill WNDCLASSEX structure with required variables
      ;==================================================

      invoke LoadIcon,hInst,500    ; icon ID
      mov hIcon, eax

      szText szClassName,"ExDLL_Class"

      mov wc.cbSize,         sizeof WNDCLASSEX
      mov wc.style,          CS_HREDRAW or CS_VREDRAW \
                             or CS_BYTEALIGNWINDOW
      mov wc.lpfnWndProc,    offset WndProc
      mov wc.cbClsExtra,     NULL
      mov wc.cbWndExtra,     NULL
      m2m wc.hInstance,      hInst
      mov wc.hbrBackground,  COLOR_BTNFACE+1
      mov wc.lpszMenuName,   NULL
      mov wc.lpszClassName,  offset szClassName
      m2m wc.hIcon,          hIcon
        invoke LoadCursor,NULL,IDC_ARROW
      mov wc.hCursor,        eax
      m2m wc.hIconSm,        hIcon

      invoke RegisterClassEx, ADDR wc

      ;================================
      ; Centre window at following size
      ;================================

      mov Wwd, 500
      mov Wht, 350

      invoke GetSystemMetrics,SM_CXSCREEN
      invoke TopXY,Wwd,eax
      mov Wtx, eax

      invoke GetSystemMetrics,SM_CYSCREEN
      invoke TopXY,Wht,eax
      mov Wty, eax

      invoke CreateWindowEx,WS_EX_LEFT,
                            ADDR szClassName,
                            ADDR szDisplayName,
                            WS_OVERLAPPED or WS_SYSMENU,
                            Wtx,Wty,Wwd,Wht,
                            NULL,NULL,
                            hInst,NULL
      mov   hWnd,eax

      invoke ShowWindow,hWnd,SW_SHOWNORMAL
      invoke UpdateWindow,hWnd

      ;===================================
      ; Loop until PostQuitMessage is sent
      ;===================================

    StartLoop:
      invoke GetMessage,ADDR msg,NULL,0,0
      cmp eax, 0
      je ExitLoop
      invoke TranslateMessage, ADDR msg
      invoke DispatchMessage,  ADDR msg
      jmp StartLoop
    ExitLoop:

      return msg.wParam

WinMain endp

; #########################################################################

WndProc proc hWin   :DWORD,
             uMsg   :DWORD,
             wParam :DWORD,
             lParam :DWORD

    LOCAL ref    :DWORD

    .if uMsg == WM_COMMAND

        .if wParam == 500
        ; ----------------------------------
        ; Use the DLL functions with the
        ; protection of the "invoke" syntax.
        ; ----------------------------------
          mov eax, 16           ; put a number in eax
          invoke Sqrt,eax       ; get its square root
          invoke Minus_1,eax    ; subtract 1 from it
          invoke Add_1,eax      ; add 1 to it
          mov ref, eax

          invoke ShowValue,ref  ; display 1st result

        .elseif wParam == 501
        ; ----------------------------------
        ; Call the "Add_1" function manually
        ; to avoid the extra stack overhead.
        ; ----------------------------------
          mov ref, 0
        @@:
          push ref
          call lpAdd_1          ; call "Add_1" DLL function 1 million times
          mov ref, eax
          cmp ref, 1000000
          jne @B
    
          invoke ShowValue,ref  ; display 2nd result

        .endif

    .elseif uMsg == WM_CREATE

        .data
          butn1 db "Test Invoked functions",0
          butn2 db "Manually call function",0
        .code

        invoke PushButton,ADDR butn1,hWin,20,20,200,25,500
        invoke PushButton,ADDR butn2,hWin,20,60,200,25,501

    .elseif uMsg == WM_CLOSE

    .elseif uMsg == WM_DESTROY
        invoke PostQuitMessage,NULL
        return 0 
    .endif

    invoke DefWindowProc,hWin,uMsg,wParam,lParam

    ret

WndProc endp

; ########################################################################

TopXY proc wDim:DWORD, sDim:DWORD

    shr sDim, 1      ; divide screen dimension by 2
    shr wDim, 1      ; divide window dimension by 2
    mov eax, wDim    ; copy window dimension into eax
    sub sDim, eax    ; sub half win dimension from half screen dimension

    return sDim

TopXY endp

; #########################################################################

Sqrt proc value:DWORD

    push value
    call lpSqrt     ; return value is in eax

    ret

Sqrt endp

; ########################################################################

ShowValue proc value:DWORD

    push value
    call lpShowValue

    ret

ShowValue endp

; ########################################################################

Add_1 proc value:DWORD

    push value
    call lpAdd_1    ; return value is in eax

    ret

Add_1 endp

; ########################################################################

Minus_1 proc value:DWORD

    push value
    call lpMinus_1  ; return value is in eax

    ret

Minus_1 endp

; ########################################################################

end start

