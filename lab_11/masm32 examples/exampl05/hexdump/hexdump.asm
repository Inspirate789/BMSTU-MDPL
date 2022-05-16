; #########################################################################

      .486                      ; create 32 bit code
      .model flat, stdcall      ; 32 bit memory model
      option casemap :none      ; case sensitive

      include hexdump.inc        ; local includes for this file
 ;       include dbmacros.asm
 ;       include errormac.asm

      HexDump PROTO :DWORD,:DWORD,:DWORD

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

    STRING szClassName,"hexdump_Class"

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
    DisplayMenu hWnd,600
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
    LOCAL hFile  :DWORD
    LOCAL len    :DWORD
    LOCAL hMem$  :DWORD
    LOCAL hBuf$  :DWORD
    LOCAL bLen   :DWORD
    LOCAL br     :DWORD
    LOCAL Rct    :RECT
    LOCAL buffer1[128]:BYTE  ; these are two spare buffers
    LOCAL buffer2[128]:BYTE  ; for text manipulation etc..
    LOCAL szDropFileName[260]:BYTE

    .if uMsg == WM_COMMAND
    ;======== toolbar commands ========
        .if wParam == 50

        ; --------------------------------------
        ; szFileName is defined in Filedlgs.asm
        ; --------------------------------------
          mov szFileName[0],0     ; set 1st byte to zero
          invoke GetFileName,hWin,SADD("Open A File"),
                                  SADD("All files",0,"*.*",0)
          cmp szFileName[0],0     ; zero if cancel pressed in dlgbox
          jne @F
          ret
        @@:

          invoke CreateFile,ADDR szFileName,
                            GENERIC_READ,
                            FILE_SHARE_READ,
                            NULL,OPEN_EXISTING,
                            FILE_ATTRIBUTE_NORMAL,
                            NULL
          mov hFile, eax

          invoke GetFileSize,hFile,NULL
          mov len, eax

          stralloc len      ; allocate string memory
          mov hMem$, eax

          invoke ReadFile,hFile,hMem$,len,ADDR br,NULL
          invoke CloseHandle,hFile

          mov eax, len
          add eax, eax
          add eax, eax
          mov bLen, eax

          stralloc bLen
          mov hBuf$, eax

          invoke HexDump,hMem$,len,hBuf$

          invoke CreateFile,SADD("testdump.hex"),
                            GENERIC_WRITE,
                            FILE_SHARE_WRITE,
                            NULL,CREATE_ALWAYS,
                            FILE_ATTRIBUTE_NORMAL,
                            NULL
          mov hFile, eax

          invoke StrLen,hBuf$
          mov bLen, eax
          invoke WriteFile,hFile,hBuf$,bLen,ADDR br,NULL

          invoke CloseHandle,hFile

          strfree hBuf$
          strfree hMem$

        ; -----------------------------------------
        ; NOTE This WinExec call will only work on
        ; the logical drive that this EXE is on.
        ; -----------------------------------------
          invoke WinExec,SADD("\masm32\qeditor.exe testdump.hex"),1

        .elseif wParam == 51
            invoke MessageBox,hWin,SADD("WM_COMMAND ID 51"),
                              ADDR szDisplayName,MB_OK

        .elseif wParam == 52
            invoke MessageBox,hWin,SADD("WM_COMMAND ID 52"),
                              ADDR szDisplayName,MB_OK

        .elseif wParam == 53
            invoke MessageBox,hWin,SADD("WM_COMMAND ID 53"),
                              ADDR szDisplayName,MB_OK

        .elseif wParam == 54
            invoke MessageBox,hWin,SADD("WM_COMMAND ID 54"),
                              ADDR szDisplayName,MB_OK

        .elseif wParam == 55
            invoke MessageBox,hWin,SADD("WM_COMMAND ID 55"),
                              ADDR szDisplayName,MB_OK

        .elseif wParam == 56
            invoke MessageBox,hWin,SADD("WM_COMMAND ID 56"),
                              ADDR szDisplayName,MB_OK

        .elseif wParam == 57
            invoke MessageBox,hWin,SADD("WM_COMMAND ID 57"),
                              ADDR szDisplayName,MB_OK

        .elseif wParam == 58
            invoke MessageBox,hWin,SADD("WM_COMMAND ID 58"),
                              ADDR szDisplayName,MB_OK

        .endif

    ;======== menu commands ========

        .if wParam == 1001
          ; --------------------------------------
          ; szFileName is defined in Filedlgs.asm
          ; --------------------------------------
            mov szFileName[0],0     ; set 1st byte to zero
            invoke GetFileName,hWin,SADD("Open A File"),
                                    SADD("All files",0,"*.*",0)
            cmp szFileName[0],0     ; zero if cancel pressed in dlgbox
            je @F
          ; ---------------------------------
          ; perform your file open code here
          ; ---------------------------------
            invoke MessageBox,hWin,ADDR szFileName,ADDR szDisplayName,MB_OK
            @@:

        .elseif wParam == 1002
          ; --------------------------------------
          ; szFileName is defined in Filedlgs.asm
          ; --------------------------------------
            mov szFileName[0],0     ; set 1st byte to zero
            invoke SaveFileName,hWin,SADD("Save File As ..."),
                                     SADD("All files",0,"*.*",0,0)
            cmp szFileName[0],0     ; zero if cancel pressed in dlgbox
            je @F
          ; ---------------------------------
          ; perform your file save code here
          ; ---------------------------------
            invoke MessageBox,hWin,ADDR szFileName,ADDR szDisplayName,MB_OK
            @@:

        .endif

        .if wParam == 1010
            invoke SendMessage,hWin,WM_SYSCOMMAND,SC_CLOSE,NULL

        .elseif wParam == 1900
            ShellAboutBox hWin,hIcon,\
                "About Prostart 3 Template#Windows Application",\
                "Prostart 3 Template",13,10,"Copyright © MASM32 2001"
        .endif
    ;====== end menu commands ======

    .elseif uMsg == WM_DROPFILES
        invoke DragQueryFile,wParam,0,ADDR szDropFileName,sizeof szDropFileName
      ; -------------------------------------------------------
      ; perform the action you want with "szDropFileName" here
      ; -------------------------------------------------------
        invoke MessageBox,hWin,ADDR szDropFileName,SADD("WM_DROPFILES"),MB_OK

    .elseif uMsg == WM_CREATE
        invoke Do_ToolBar,hWin
        invoke Do_Status,hWin

    .elseif uMsg == WM_SYSCOLORCHANGE
        invoke Do_ToolBar,hWin

    .elseif uMsg == WM_SIZE
        invoke SendMessage,hToolBar,TB_AUTOSIZE,0,0
        invoke MoveWindow,hStatus,0,0,0,0,TRUE

    .elseif uMsg == WM_PAINT
        invoke Paint_Proc,hWin
        return 0

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

Paint_Proc proc hWin:DWORD

    LOCAL hDC      :DWORD
    LOCAL btn_hi   :DWORD
    LOCAL btn_lo   :DWORD
    LOCAL Rct      :RECT
    LOCAL Ps       :PAINTSTRUCT

    invoke BeginPaint,hWin,ADDR Ps
    mov hDC, eax

  ; ----------------------------------------

    invoke GetSysColor,COLOR_BTNHIGHLIGHT
    mov btn_hi, eax

    invoke GetSysColor,COLOR_BTNSHADOW
    mov btn_lo, eax

  ; ----------------------------------------

    invoke EndPaint,hWin,ADDR Ps

    ret

Paint_Proc endp

; #########################################################################

HexDump proc lpString:DWORD,lnString:DWORD,lpbuffer:DWORD

    LOCAL lcnt:DWORD

    push ebx
    push esi
    push edi

    jmp over_table
    align 16
  hex_table:
    db "00","01","02","03","04","05","06","07","08","09","0A","0B","0C","0D","0E","0F"
    db "10","11","12","13","14","15","16","17","18","19","1A","1B","1C","1D","1E","1F"
    db "20","21","22","23","24","25","26","27","28","29","2A","2B","2C","2D","2E","2F"
    db "30","31","32","33","34","35","36","37","38","39","3A","3B","3C","3D","3E","3F"
    db "40","41","42","43","44","45","46","47","48","49","4A","4B","4C","4D","4E","4F"
    db "50","51","52","53","54","55","56","57","58","59","5A","5B","5C","5D","5E","5F"
    db "60","61","62","63","64","65","66","67","68","69","6A","6B","6C","6D","6E","6F"
    db "70","71","72","73","74","75","76","77","78","79","7A","7B","7C","7D","7E","7F"
    db "80","81","82","83","84","85","86","87","88","89","8A","8B","8C","8D","8E","8F"
    db "90","91","92","93","94","95","96","97","98","99","9A","9B","9C","9D","9E","9F"
    db "A0","A1","A2","A3","A4","A5","A6","A7","A8","A9","AA","AB","AC","AD","AE","AF"
    db "B0","B1","B2","B3","B4","B5","B6","B7","B8","B9","BA","BB","BC","BD","BE","BF"
    db "C0","C1","C2","C3","C4","C5","C6","C7","C8","C9","CA","CB","CC","CD","CE","CF"
    db "D0","D1","D2","D3","D4","D5","D6","D7","D8","D9","DA","DB","DC","DD","DE","DF"
    db "E0","E1","E2","E3","E4","E5","E6","E7","E8","E9","EA","EB","EC","ED","EE","EF"
    db "F0","F1","F2","F3","F4","F5","F6","F7","F8","F9","FA","FB","FC","FD","FE","FF"
  over_table:

    lea ebx, hex_table        ; get base address of table
    mov esi, lpString         ; address of source string
    mov edi, lpbuffer         ; address of output buffer
    mov eax, esi
    add eax, lnString
    mov ecx, eax              ; exit condition for byte read
    mov lcnt, 0

    xor eax, eax              ; prevent stall

  ; %%%%%%%%%%%%%%%%%%%%%%% loop code %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  hxlp:
    mov al, [esi]             ; get BYTE
    inc esi
    inc lcnt
    mov dx, [ebx+eax*2]       ; put WORD from table into DX
    mov [edi], dx             ; write 2 byte string to buffer
    add edi, 2
    mov BYTE PTR [edi], 32    ; add space
    inc edi
    cmp lcnt, 8               ; test for half to add "-"
    jne @F
    mov WORD PTR [edi], " -"
    add edi, 2
  @@:
    cmp lcnt, 16              ; break line at 16 characters
    jne @F
    dec edi                   ; overwrite last space
    mov WORD PTR [edi], 0A0Dh ; write CRLF to buffer
    add edi, 2
    mov lcnt, 0
  @@:
    cmp esi, ecx              ; test exit condition
    jl hxlp

  ; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    inc edi
    mov BYTE PTR [edi], 0     ; append terminator

    pop edi
    pop esi
    pop ebx

    ret

HexDump endp

; #########################################################################

end start
