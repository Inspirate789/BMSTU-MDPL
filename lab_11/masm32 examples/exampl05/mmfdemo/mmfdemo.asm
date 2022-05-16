; #########################################################################

; This program demonstrates the use of memory mapped files as a medium
; of communication between 2 or more programs and the use of direct
; messaging from one application to another using the handles written
; to specific locations in the memory mapped file that is shared between
; them.

; Between the 2 capacities, it produces an interface between applications
; and DLLs that is not dependent on the stack for parameter passing and is
; capable of handling large amounts of data between applications that are
; not in the same thread.

; #########################################################################

      .486                      ; create 32 bit code
      .model flat, stdcall      ; 32 bit memory model
      option casemap :none      ; case sensitive

      include mmfdemo.inc       ; local includes for this file

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

    STRING szClassName,"Memory_Map_Class"

  ; --------------------------------------------
  ; register class name for CreateWindowEx call
  ; --------------------------------------------
    invoke RegisterWinClass,ADDR WndProc,ADDR szClassName,
                       hIcon,hCursor,COLOR_BTNFACE+1

    invoke CreateWindowEx,WS_EX_LEFT or WS_EX_ACCEPTFILES,
                          ADDR szClassName,
                          ADDR szDisplayName,
                          WS_OVERLAPPEDWINDOW,
                          20,20,300,300,
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

    LOCAL mmfc:WNDCLASSEX

    mov mmfc.cbSize,         sizeof WNDCLASSEX
    mov mmfc.style,          CS_BYTEALIGNCLIENT or \
                             CS_BYTEALIGNWINDOW
    m2m mmfc.lpfnWndProc,    lpWndProc
    mov mmfc.cbClsExtra,     NULL
    mov mmfc.cbWndExtra,     NULL
    m2m mmfc.hInstance,      hInstance
    m2m mmfc.hbrBackground,  bColor
    mov mmfc.lpszMenuName,   NULL
    m2m mmfc.lpszClassName,  lpClassName
    m2m mmfc.hIcon,          Icon
    m2m mmfc.hCursor,        Cursor
    m2m mmfc.hIconSm,        Icon

    invoke RegisterClassEx, ADDR mmfc

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
    LOCAL Rct    :RECT
    LOCAL buffer1[128]:BYTE  ; these are two spare buffers
    LOCAL buffer2[128]:BYTE  ; for text manipulation etc..
    LOCAL szDropFileName[260]:BYTE

    .if uMsg == WM_COMMAND
      ; -------------------------------------------------------
      ; WM_COMMAND messages sent locally from this application
      ; -------------------------------------------------------
        .if wParam == 300
            invoke WinExec,SADD("slave\slave.exe"),1    ; start slave app

        .elseif wParam == 301
            mov eax, lpMemFile  ; get slave app window handle
            add eax, 4          ; from memory mapped file at
            mov eax, [eax]      ; offset 4 in memory mapped file

            invoke SendMessage,eax,WM_COMMAND,1000,1    ; close slave app

        .elseif wParam == 302

            .data
              dllMsg db "This message is sent from the calling app",0
              dllTtl db "MessageBox is displayed from DLL",0
            .code

            push esi
            push edi

          ; ------------------------------------
          ; copy message and title to specified
          ; offsets within memory mapped file.
          ; ------------------------------------

            mov esi, offset dllMsg
            mov edi, lpMemFile
            add edi, 2048           ; offset in MMF for message
            mov ecx, lengthof dllMsg
            rep movsb

            mov esi, offset dllTtl
            mov edi, lpMemFile
            add edi, 4096           ; offset in MF for title
            mov ecx, lengthof dllTtl
            rep movsb

            pop edi
            pop esi

            mov eax, lpMemFile
            add eax, 1024
            mov ecx, hWnd
            mov [eax], ecx                  ; handle at offset        1024
            mov DWORD PTR [eax+4], 2048     ; offset of message at    1024 + 4
            mov DWORD PTR [eax+8], 4096     ; offset of title as      1024 + 8
            mov DWORD PTR [eax+12], MB_OK   ; style of message box at 1024 + 12

            invoke LoadLibrary,SADD("dll\mmfdll.dll")
            invoke GetProcAddress,eax,1 ; SADD("function1")

            call eax        ; call the DLL function with parameters
                            ; already loaded in the MMF.

      ; --------------------------------------------------------
      ; messages sent from test application that use the lParam
      ; to select which preset function should be performed.
      ; --------------------------------------------------------
        .elseif wParam == 1000
          .if lParam == 1
            invoke MessageBox,hWin,SADD("lParam == 1"),ADDR szDisplayName,MB_OK

          .elseif lParam == 2
            invoke MessageBox,hWin,SADD("lParam == 2"),ADDR szDisplayName,MB_OK

          .elseif lParam == 3
            invoke MessageBox,hWin,SADD("lParam == 3"),ADDR szDisplayName,MB_OK

          .elseif lParam == 4
            invoke MessageBox,hWin,SADD("lParam == 4"),ADDR szDisplayName,MB_OK
          .endif

      ; ----------------------------------------------------------
      ; messages reserved for test application to send extra data
      ; using the lParam to vary the value in the called function
      ; ----------------------------------------------------------
        .elseif wParam == 1001


        .elseif wParam == 1002


        .elseif wParam == 1003


        .elseif wParam == 1004

      .endif


    .elseif uMsg == WM_CREATE
        invoke Do_Status,hWin

        invoke PushButton,SADD("Start EXE"),hWin,20,20,100,25,300
        invoke PushButton,SADD("Close EXE"),hWin,20,50,100,25,301
        invoke PushButton,SADD("Run DLL"),hWin,20,80,100,25,302

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

        mov ecx, hWin
        mov [eax], ecx  ; put this window handle at offset zero in memory mapped file

      ; @@@@@@@@@@@@@@@@@@@@@@@@@@@

    .elseif uMsg == WM_CLOSE
      ; @@@@@@@@@@@@@@@@@@@@@@@@@@@
      ; unmap view and close handle
      ; @@@@@@@@@@@@@@@@@@@@@@@@@@@

        invoke UnmapViewOfFile,lpMemFile
        invoke CloseHandle,hMMF

    .elseif uMsg == WM_SYSCOLORCHANGE

    .elseif uMsg == WM_DROPFILES
        invoke DragQueryFile,wParam,0,ADDR szDropFileName,sizeof szDropFileName
        invoke MessageBox,hWin,ADDR szDropFileName,SADD("WM_DROPFILES"),MB_OK

    .elseif uMsg == WM_SIZE
        invoke MoveWindow,hStatus,0,0,0,0,TRUE

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

; ########################################################################

end start
