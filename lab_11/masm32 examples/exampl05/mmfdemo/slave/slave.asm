; #########################################################################

      .486                      ; create 32 bit code
      .model flat, stdcall      ; 32 bit memory model
      option casemap :none      ; case sensitive

      include slave.inc        ; local includes for this file
      include dbmacros.asm
      include errormac.asm

.code

; #########################################################################

start:

      invoke InitCommonControls

    ; ------------------
    ; set global values
    ; ------------------
      invoke GetModuleHandle, NULL
      mov hInstance, eax

      invoke GetCommandLine
      mov CommandLine, eax

      invoke LoadIcon,hInstance,500    ; icon ID
      mov hIcon, eax

      invoke LoadCursor,NULL,IDC_ARROW
      mov hCursor, eax

      invoke GetSystemMetrics,SM_CXSCREEN
      mov sWid, eax

      invoke GetSystemMetrics,SM_CYSCREEN
      mov sHgt, eax

      call Main

      invoke ExitProcess,eax

; #########################################################################

Main proc

    LOCAL Wwd:DWORD,Wht:DWORD,Wtx:DWORD,Wty:DWORD

    STRING szClassName,"Slave_Class"

    SingleInstanceOnly ADDR szClassName

  ; --------------------------------------------
  ; register class name for CreateWindowEx call
  ; --------------------------------------------
    invoke RegisterWinClass,ADDR WndProc,ADDR szClassName,
                       hIcon,hCursor,COLOR_BTNFACE+1

  ; -------------------------------------------------
  ; macro to autoscale window co-ordinates to screen
  ; percentages and centre window at those sizes.
  ; -------------------------------------------------
    AutoScale 75, 70

    invoke CreateWindowEx,WS_EX_LEFT,
                          ADDR szClassName,
                          ADDR szDisplayName,
                          WS_OVERLAPPEDWINDOW,
                          400,10,200,200,
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

; #########################################################################

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

; ########################################################################

MsgLoop proc

  ; ------------------------------------------
  ; The following 4 equates are available for
  ; processing messages directly in the loop.
  ; m_hWnd - m_Msg - m_wParam - m_lParam
  ; ------------------------------------------

    LOCAL msg:MSG

    StartLoop:
      invoke GetMessage,ADDR msg,NULL,0,0
      cmp eax, 0
      je ExitLoop
      invoke TranslateMessage, ADDR msg
      invoke DispatchMessage,  ADDR msg
      jmp StartLoop
    ExitLoop:

    mov eax, msg.wParam
    ret

MsgLoop endp

; #########################################################################

WndProc proc hWin   :DWORD,
             uMsg   :DWORD,
             wParam :DWORD,
             lParam :DWORD

    LOCAL var    :DWORD
    LOCAL caW    :DWORD
    LOCAL caH    :DWORD
    LOCAL hExt   :DWORD
    LOCAL Rct    :RECT
    LOCAL buffer1[128]:BYTE  ; these are two spare buffers
    LOCAL buffer2[128]:BYTE  ; for text manipulation etc..

    .if uMsg == WM_COMMAND
    ;======== toolbar commands ========
        .if wParam == 50
            mov eax, lpMemFile
            mov eax, [eax]
            mov hExt, eax

            invoke SendMessage,hExt,WM_COMMAND,1000,1

        .elseif wParam == 51
            mov eax, lpMemFile
            mov eax, [eax]
            mov hExt, eax

            invoke SendMessage,hExt,WM_COMMAND,1000,2

        .elseif wParam == 52
            mov eax, lpMemFile
            mov eax, [eax]
            mov hExt, eax

            invoke SendMessage,hExt,WM_COMMAND,1000,3

        .elseif wParam == 1000
          .if lParam == 1
            invoke SendMessage,hWnd,WM_SYSCOMMAND,SC_CLOSE,0
          .endif
        .endif

    .elseif uMsg == WM_CREATE
        invoke Do_ToolBar,hWin
        invoke Do_Status,hWin

      ; @@@@@@@@@@@@@@@@@@@@@@@@@@@
      ; Create the memory mapped file
      ; @@@@@@@@@@@@@@@@@@@@@@@@@@@

        invoke CreateFileMapping,0FFFFFFFFh,        ; nominates the system paging
                                 NULL,
                                 PAGE_READWRITE,    ; read write access to memory
                                 0,
                                 1000000,           ; size in BYTEs
                                 SADD("My_MM_File") ; set file object name here
        mov hMMF, eax

      ; @@@@@@@@@@@@@@@@@@@@@@@@@@@
      ; map a view of that file into
      ; this applications memory
      ; address space.
      ; @@@@@@@@@@@@@@@@@@@@@@@@@@@

        invoke MapViewOfFile,hMMF,FILE_MAP_WRITE,0,0,0
        mov lpMemFile, eax

        add eax, 4
        mov ecx, hWin
        mov [eax], ecx  ; put window handle at offset 4 in the memory mapped file

    .elseif uMsg == WM_SYSCOLORCHANGE
        invoke Do_ToolBar,hWin

    .elseif uMsg == WM_SIZE
        invoke SendMessage,hToolBar,TB_AUTOSIZE,0,0
        invoke MoveWindow,hStatus,0,0,0,0,TRUE

    .elseif uMsg == WM_CLOSE
      ; @@@@@@@@@@@@@@@@@@@@@@@@@@@
      ; unmap view and close handle
      ; @@@@@@@@@@@@@@@@@@@@@@@@@@@

        invoke UnmapViewOfFile,lpMemFile
        invoke CloseHandle,hMMF

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

; ########################################################################

end start
