; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

      .486                      ; create 32 bit code
      .model flat, stdcall      ; 32 bit memory model
      option casemap :none      ; case sensitive

      include scroll.inc        ; local includes for this file

    .data?
      hcBmp dd ?

    .data
      scrtxt db "The time has come the walrus said,",13,10,13,10
             db " to speak of many things",13,10,13,10
             db "Of birds and bugs and ceiling wax,",13,10,13,10
             db " of cabbages and kings",13,10,13,10
             db "And if the sea is boiling hot,",13,10,13,10
             db " and whether pigs have wings",0

      ptxt dd scrtxt            ; make a pointer to the text

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
    LOCAL rct   :RECT

    STRING szClassName,"Prostart_Class"

  ; --------------------------------------------
  ; register class name for CreateWindowEx call
  ; --------------------------------------------
    invoke RegisterWinClass,ADDR WndProc,ADDR szClassName,
                       hIcon,hCursor,COLOR_BTNFACE+1

    mov Wwd, 400
    mov Wht, 300
    invoke TopXY,Wwd,sWid
    mov Wtx, eax
    invoke TopXY,Wht,sHgt
    mov Wty, eax

    invoke CreateWindowEx,WS_EX_LEFT or WS_EX_ACCEPTFILES,
                          ADDR szClassName,
                          ADDR szDisplayName,
                          WS_OVERLAPPED or WS_SYSMENU,
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

    LOCAL var    :DWORD
    LOCAL caW    :DWORD
    LOCAL caH    :DWORD
    LOCAL fname  :DWORD
    LOCAL patn   :DWORD
    LOCAL rct    :RECT
    LOCAL bottom :DWORD
    LOCAL hDC    :DWORD
    LOCAL cDC    :DWORD
    LOCAL hOld  :DWORD
    LOCAL buffer1[260]:BYTE  ; these are two spare buffers
    LOCAL buffer2[260]:BYTE  ; for text manipulation etc..

    Switch uMsg
      Case WM_COMMAND

        Switch wParam
        ;======== menu commands ========

          Case 1001
          ; ╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗

            invoke GetClientRect,hWin,ADDR rct
            mrm bottom, rct.bottom
 
            mov hDC, rv(GetDC,hWin)
            mov cDC, rv(CreateCompatibleDC,hDC)
            mov hOld, rv(SelectObject,cDC,hcBmp)
            invoke SetBkMode,cDC,TRANSPARENT
            invoke SetTextColor,cDC,00550000h

            mov eax, rct.bottom
            add eax, eax
            mov rct.bottom, eax

            invoke FillRect,cDC,ADDR rct,rv(CreateSolidBrush,008888FFh)

            invoke DrawText,cDC,ptxt,-1,ADDR rct,DT_EDITCONTROL
            mov eax, bottom
            add rct.top, eax
            invoke DrawText,cDC,ptxt,-1,ADDR rct,DT_EDITCONTROL

            push esi
            xor esi, esi

          @@:
            invoke BitBlt,hDC,0,0,rct.right,rct.bottom,cDC,0,esi,SRCCOPY
            invoke SleepEx,20,0
            add esi, 1
            cmp esi, bottom
            jne @B

            pop esi

            invoke SelectObject,cDC,hOld
            invoke DeleteDC,cDC
            invoke ReleaseDC,hWin,hDC

          ; ╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗╗

          Case 1010
            invoke SendMessage,hWin,WM_SYSCOMMAND,SC_CLOSE,NULL

          Case 1900
            ShellAboutBox hWin,hIcon,\
              "About Prostart 4 Template#Windows Application",\
              "Prostart 4 Template",13,10,"Copyright й MASM32 1998-2005"

          ;====== end menu commands ======
      Endsw

      Case WM_DROPFILES
        mov fname, DropFileName(wParam)
        fn MessageBox,hWin,fname,"WM_DROPFILES",MB_OK

      Case WM_CREATE
        invoke Do_Status,hWin
        invoke GetClientRect,hWin,ADDR rct
        mov hDC, rv(GetDC,hWin)
        mov eax, rct.bottom
        add eax, eax
        mov hcBmp, rv(CreateCompatibleBitmap,hDC,rct.right,eax)
        invoke ReleaseDC,hWin,hDC

      Case WM_SYSCOLORCHANGE

      Case WM_SIZE
        invoke MoveWindow,hStatus,0,0,0,0,TRUE

      Case WM_PAINT
        invoke Paint_Proc,hWin
        return 0

      Case WM_CLOSE
        invoke DeleteObject,hcBmp

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

Paint_Proc proc hWin:DWORD

    LOCAL hDC      :DWORD
    LOCAL btn_hi   :DWORD
    LOCAL btn_lo   :DWORD
    LOCAL Rct      :RECT
    LOCAL Ps       :PAINTSTRUCT

    mov hDC, rv(BeginPaint,hWin,ADDR Ps)

  ; ----------------------------------------

    mov btn_hi, rv(GetSysColor,COLOR_BTNHIGHLIGHT)

    mov btn_lo, rv(GetSysColor,COLOR_BTNSHADOW)

  ; ----------------------------------------

    invoke EndPaint,hWin,ADDR Ps

    ret

Paint_Proc endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start



























