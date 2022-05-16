; ¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤
;
;                       High speed message dispatcher
;
; ¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤
;
; This example allocates an array in the uninitialised data section, fills
; the array with the default message handling label address in the "WndProc"
; and then writes the addresses of the labels for each message that is
; used in the application into the array.
;
; NOTE : The labels in the WndProc are all GLOBAL labels. IE : label::
;
; This is possible because the normal messages are equates below 1024 so
; storing the offset for each label for the messages being processed can
; be written to an array that is not very large.
;
; In the "WndProc" procedure, the address of the array is a constant known
; at assembly time so to get the address of the correct label to jump to,
; all that has to be done is to use the message passed to the WndProc as
; an index with a multiplier of 4. Each message that is processed in this
; manner must jump to the default handler unless it returns zero.
;
; Any message that is not processed with a jump to a specified label
; automatically jumps to the default label in the WndProc.
;
; The advantage of this architecture is that it will branch to every
; message with the following 2 instructions which is far faster than
; other techniques that read through a list of comparisons.
;
;           mov eax, uMsg
;           jmp DWORD PTR [wMsgs+eax*4]
;
; ¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤

      .486                      ; create 32 bit code
      .model flat, stdcall      ; 32 bit memory model
      option casemap :none      ; case sensitive

    ; -----------------------------
    ; item count for MESSAGE array
    ; -----------------------------
      asize equ 1024

      include arrdisp.inc       ; local includes for this file

      InitMsgArray PROTO

.code

; ¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤

start:

      invoke InitMsgArray

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

; ¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤

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

; ¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤

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

; ¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤

MsgLoop proc

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

; ¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤

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

    cmp uMsg, asize     ; test if message is within the range of the array
    jg @F               ; if its larger, bypass dispatcher and process normally
    DispatchMsg         ; otherwise, dispatch the message
  @@:
    mov eax, uMsg
    .if eax == WM_CUSTOMMESSAGE
      invoke MessageBox,hWnd,SADD("Custom message received"),
                             SADD("WM_CUSTOMMESSAGE"),MB_OK
    .endif

    jmp DEF_MSG_HANDLER

    MSG_WM_COMMAND::
    ;======== toolbar commands ========
        .if wParam == 50
            invoke SendMessage,hWin,WM_CUSTOMMESSAGE,0,0

        .elseif wParam == 51
            invoke MessageBox,hWin,SADD("WM_COMMAND ID 51"),
                              ADDR szDisplayName,MB_OK

        .elseif wParam == 52
            invoke MessageBox,hWin,SADD("WM_COMMAND ID 52"),
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
      jmp DEF_MSG_HANDLER

    ;====== end menu commands ======

    MSG_WM_DROPFILES::
        invoke DragQueryFile,wParam,0,ADDR szDropFileName,sizeof szDropFileName
      ; -------------------------------------------------------
      ; perform the action you want with "szDropFileName" here
      ; -------------------------------------------------------
        invoke MessageBox,hWin,ADDR szDropFileName,SADD("WM_DROPFILES"),MB_OK
      jmp DEF_MSG_HANDLER

    MSG_WM_CREATE::
        invoke Do_ToolBar,hWin
        invoke Do_Status,hWin

        invoke RegisterWindowMessage,SADD("test_custom_message")
        mov WM_CUSTOMMESSAGE, eax

      jmp DEF_MSG_HANDLER

    MSG_WM_SYSCOLORCHANGE::
        invoke Do_ToolBar,hWin
      jmp DEF_MSG_HANDLER

    MSG_WM_SIZE::
        invoke SendMessage,hToolBar,TB_AUTOSIZE,0,0
        invoke MoveWindow,hStatus,0,0,0,0,TRUE
      jmp DEF_MSG_HANDLER

    MSG_WM_PAINT::
        invoke Paint_Proc,hWin
        return 0

    MSG_WM_CLOSE::
      jmp DEF_MSG_HANDLER

    MSG_WM_DESTROY::
        invoke PostQuitMessage,NULL
        return 0

    DEF_MSG_HANDLER::
    invoke DefWindowProc,hWin,uMsg,wParam,lParam

    ret

WndProc endp

; ¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤

TopXY proc wDim:DWORD, sDim:DWORD

    shr sDim, 1      ; divide screen dimension by 2
    shr wDim, 1      ; divide window dimension by 2
    mov eax, wDim    ; copy window dimension into eax
    sub sDim, eax    ; sub half win dimension from half screen dimension

    return sDim

TopXY endp

; ¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤

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

; ¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤

InitMsgArray proc

    ; ---------------------------------------------------------------
    ; fill array with address of default processing label in WndProc
    ; ---------------------------------------------------------------
      push edi
      mov edi, OFFSET wMsgs       ; array address
      mov eax, OFFSET DEF_MSG_HANDLER   ; default processing label in WndProc
      mov ecx, asize              ; array item count
      rep stosd
      pop edi

    ; ----------------------------------------------
    ; write address for each message label to array
    ; ----------------------------------------------
      mov eax, OFFSET wMsgs

      SetMessage WM_COMMAND
      SetMessage WM_DROPFILES
      SetMessage WM_CREATE
      SetMessage WM_SYSCOLORCHANGE
      SetMessage WM_SIZE
      SetMessage WM_PAINT
      SetMessage WM_CLOSE
      SetMessage WM_DESTROY

    ; ----------------------------------------------
    ret

InitMsgArray endp

; ¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤

end start
