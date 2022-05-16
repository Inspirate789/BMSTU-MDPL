; #########################################################################

;         This demo shows how to use Greg Falen's SWITCH macro

; #########################################################################

      .486                      ; create 32 bit code
      .model flat, stdcall      ; 32 bit memory model
      option casemap :none      ; case sensitive

      include switch.inc        ; local includes for this file

.code

; #########################################################################

start:

      invoke InitCommonControls

    ; ------------------
    ; set global values
    ; ------------------
      mov hInstance, FUNC(GetModuleHandle, NULL)
      mov CommandLine, FUNC(GetCommandLine)
      mov hIcon, FUNC(LoadIcon,hInstance,500)       ; icon ID
      mov hCursor, FUNC(LoadCursor,NULL,IDC_ARROW)
      mov sWid, FUNC(GetSystemMetrics,SM_CXSCREEN)
      mov sHgt, FUNC(GetSystemMetrics,SM_CYSCREEN)

      call Main

      invoke ExitProcess,eax

; #########################################################################

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
    LOCAL Rct    :RECT
    LOCAL buffer1[128]:BYTE  ; these are two spare buffers
    LOCAL buffer2[128]:BYTE  ; for text manipulation etc..
    LOCAL szDropFileName[260]:BYTE

    Switch uMsg

      Case WM_COMMAND
    ;======== toolbar commands ========
        Switch wParam
          Case 50
            invoke MessageBox,hWin,SADD("WM_COMMAND ID 50"),
                              ADDR szDisplayName,MB_OK
          Case 51
            invoke MessageBox,hWin,SADD("WM_COMMAND ID 51"),
                              ADDR szDisplayName,MB_OK
          Case 52
            invoke MessageBox,hWin,SADD("WM_COMMAND ID 52"),
                              ADDR szDisplayName,MB_OK
          Case 53
            invoke MessageBox,hWin,SADD("WM_COMMAND ID 53"),
                              ADDR szDisplayName,MB_OK
          Case 54
            invoke MessageBox,hWin,SADD("WM_COMMAND ID 54"),
                              ADDR szDisplayName,MB_OK
          Case 55
            invoke MessageBox,hWin,SADD("WM_COMMAND ID 55"),
                              ADDR szDisplayName,MB_OK
          Case 56
            invoke MessageBox,hWin,SADD("WM_COMMAND ID 56"),
                              ADDR szDisplayName,MB_OK
          Case 57
            invoke MessageBox,hWin,SADD("WM_COMMAND ID 57"),
                              ADDR szDisplayName,MB_OK
          Case 58
            invoke MessageBox,hWin,SADD("WM_COMMAND ID 58"),
                              ADDR szDisplayName,MB_OK

    ;======== menu commands ========
          Case 1001
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

          Case 1002
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

          Case 1010
            invoke SendMessage,hWin,WM_SYSCOMMAND,SC_CLOSE,NULL

          Case 1900
            ShellAboutBox hWin,hIcon,\
                "About Prostart 3 Template#Windows Application",\
                "Prostart 3 Template",13,10,"Copyright © MASM32 2001"
        EndSw
    ;====== end menu commands ======

      Case WM_DROPFILES
        invoke DragQueryFile,wParam,0,ADDR szDropFileName,sizeof szDropFileName
      ; -------------------------------------------------------
      ; perform the action you want with "szDropFileName" here
      ; -------------------------------------------------------
        invoke MessageBox,hWin,ADDR szDropFileName,SADD("WM_DROPFILES"),MB_OK

      Case WM_CREATE
        invoke Do_ToolBar,hWin
        invoke Do_Status,hWin

      Case WM_SYSCOLORCHANGE
        invoke Do_ToolBar,hWin

      Case WM_SIZE
        invoke SendMessage,hToolBar,TB_AUTOSIZE,0,0
        invoke MoveWindow,hStatus,0,0,0,0,TRUE

      Case WM_PAINT
        invoke Paint_Proc,hWin
        return 0

      Case WM_CLOSE

      Case WM_DESTROY
        invoke PostQuitMessage,NULL
        return 0

    EndSw

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

    mov hDC, FUNC(BeginPaint,hWin,ADDR Ps)

  ; ----------------------------------------

    invoke GetSysColor,COLOR_BTNHIGHLIGHT
    mov btn_hi, eax

    invoke GetSysColor,COLOR_BTNSHADOW
    mov btn_lo, eax

  ; ----------------------------------------

    invoke EndPaint,hWin,ADDR Ps

    ret

Paint_Proc endp

; ########################################################################

end start
