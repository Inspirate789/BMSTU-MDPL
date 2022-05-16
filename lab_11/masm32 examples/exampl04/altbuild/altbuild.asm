; #########################################################################

; This file demonstrates an alternative set of methods for building
; projects using MASM. The project should be built using MAKEIT.BAT
; It will not build in the MASM32 environment as it uses a different
; technique.

; The method is to set the environment variables of BIN, INCLUDE and
; LIB in the batch file, build response files for both ML.EXE and
; LINK.EXE to handle multiple modules. The resource file is directly
; handled by LINK.EXE which calls CVTRES.EXE to manage the resource
; conversion. The techniques involved are the basis of much larger
; architecture dealing with multimodule projects that are worked on
; by a team of programmers.

; Response files are designed to overcome the command line length limit
; when using a large number of modules by creating a file in the format
; that both ML and LINK are designed to handle.

; In this simple example, parts of the normal file have been made into
; seperate modules that are built using this method. The module format
; is the same as the MASM library format which is another method of
; dealing with very large projects written by a number of programmers
; in a team.

; The methods used are written into the MAKEIT.BAT file and would be
; equivalent to a BUILD ALL command for the project.

; #########################################################################

      .486                      ; create 32 bit code
      .model flat, stdcall      ; 32 bit memory model
      option casemap :none      ; case sensitive

      include altbuild.inc        ; local includes for this file

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

    .if uMsg == WM_COMMAND
    ;======== toolbar commands ========
        .if wParam == 50
            invoke MessageBox,hWin,SADD("WM_COMMAND ID 50"),
                              ADDR szDisplayName,MB_OK

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

; #########################################################################

end start
