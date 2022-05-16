; ¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤
;
;                 High speed event driven message dispatcher
;              with individual encapsulated message processing
;
; ¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤

      .486                      ; create 32 bit code
      .model flat, stdcall      ; 32 bit memory model
      option casemap :none      ; case sensitive

      include arrdisp2.inc      ; local includes for this file

      SetAddress MACRO wm_message
        mOFFSET CATSTR <OFFSET >,<wm_message>,<_EVENT>
        mov [eax+wm_message*4], mOFFSET
      ENDM

      CallMsgProc MACRO
        mov eax, uMsg
        call DWORD PTR [wMsgs+eax*4]
      ENDM

      InitMsgArray PROTO

      WM_COMMAND_EVENT         PROTO :DWORD,:DWORD,:DWORD,:DWORD
      WM_DROPFILES_EVENT       PROTO :DWORD,:DWORD,:DWORD,:DWORD
      WM_CREATE_EVENT          PROTO :DWORD,:DWORD,:DWORD,:DWORD
      WM_SYSCOLORCHANGE_EVENT  PROTO :DWORD,:DWORD,:DWORD,:DWORD
      WM_SIZE_EVENT            PROTO :DWORD,:DWORD,:DWORD,:DWORD
      WM_PAINT_EVENT           PROTO :DWORD,:DWORD,:DWORD,:DWORD
      WM_CLOSE_EVENT           PROTO :DWORD,:DWORD,:DWORD,:DWORD
      WM_DESTROY_EVENT         PROTO :DWORD,:DWORD,:DWORD,:DWORD
      DEF_MSG_HANDLER          PROTO :DWORD,:DWORD,:DWORD,:DWORD

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

    push esi
    push edi

    xor esi, esi
    lea edi, msg

    jmp @F

  StartLoop:
    invoke DispatchMessage,edi
  @@:
    invoke GetMessage,edi,esi,esi,esi
    cmp eax, esi
    jne StartLoop

    mov eax, msg.wParam

    pop edi
    pop esi

    ret

MsgLoop endp

; «««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««

WndProc proc hWin   :DWORD,
             uMsg   :DWORD,
             wParam :DWORD,
             lParam :DWORD

    cmp uMsg, 1023      ; don't process messages about 1023
    jg @F

    push lParam
    push wParam
    push uMsg
    push hWin
    CallMsgProc         ; this is a MACRO

  @@:

    ret

WndProc endp

; «««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««««

TopXY proc wDim:DWORD, sDim:DWORD

    shr sDim, 1      ; divide screen dimension by 2
    shr wDim, 1      ; divide window dimension by 2
    mov eax, wDim    ; copy window dimension into eax
    sub sDim, eax    ; sub half win dimension from half screen dimension

    return sDim

TopXY endp

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
    ; write address of each procedure
    ; associated with a message to process
    ; ----------------------------------------------
      mov eax, OFFSET wMsgs

      SetAddress WM_COMMAND
      SetAddress WM_DROPFILES
      SetAddress WM_CREATE
      SetAddress WM_SYSCOLORCHANGE
      SetAddress WM_SIZE
      SetAddress WM_PAINT
      SetAddress WM_CLOSE
      SetAddress WM_DESTROY

    ; ----------------------------------------------

    ret

InitMsgArray endp

; ¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤

WM_DESTROY_EVENT proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD


    invoke PostQuitMessage,NULL
    xor eax, eax

    invoke DefWindowProc,hWin,uMsg,wParam,lParam

    ret

WM_DESTROY_EVENT endp

; ¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤

WM_CLOSE_EVENT proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

    invoke DefWindowProc,hWin,uMsg,wParam,lParam

    ret

WM_CLOSE_EVENT endp

; ¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤

WM_PAINT_EVENT proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

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
    invoke DefWindowProc,hWin,uMsg,wParam,lParam

    xor eax, eax
    ret

WM_PAINT_EVENT endp

; ¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤

WM_SIZE_EVENT proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

    invoke SendMessage,hToolBar,TB_AUTOSIZE,0,0
    invoke MoveWindow,hStatus,0,0,0,0,TRUE

    invoke DefWindowProc,hWin,uMsg,wParam,lParam

    ret

WM_SIZE_EVENT endp

; ¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤

WM_SYSCOLORCHANGE_EVENT proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

    invoke DefWindowProc,hWin,uMsg,wParam,lParam

    ret

WM_SYSCOLORCHANGE_EVENT endp

; ¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤

WM_CREATE_EVENT proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

    invoke Do_ToolBar,hWin
    invoke Do_Status, hWin

    invoke DefWindowProc,hWin,uMsg,wParam,lParam

    ret

WM_CREATE_EVENT endp

; ¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤

WM_DROPFILES_EVENT proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

    invoke DefWindowProc,hWin,uMsg,wParam,lParam

    ret

WM_DROPFILES_EVENT endp

; ¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤

WM_COMMAND_EVENT proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

    .if wParam == 50
      invoke MessageBox,hWin,SADD("Button1"),SADD("50"),MB_OK
    .elseif wParam == 51
      invoke MessageBox,hWin,SADD("Button2"),SADD("51"),MB_OK
    .elseif wParam == 52
      invoke MessageBox,hWin,SADD("Button3"),SADD("52"),MB_OK


    .elseif wParam == 1001
    .elseif wParam == 1002
    .elseif wParam == 1010
    .elseif wParam == 1900





    .endif

    invoke DefWindowProc,hWin,uMsg,wParam,lParam

    ret

WM_COMMAND_EVENT endp

; ¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤

DEF_MSG_HANDLER proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

    invoke DefWindowProc,hWin,uMsg,wParam,lParam

    ret

DEF_MSG_HANDLER endp

; ¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤=÷=¤

end start
