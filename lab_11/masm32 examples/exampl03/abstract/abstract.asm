; #########################################################################
;
;                               abstract.asm
;
;   Abstract demonstrates the MASM macro capacity for simplifying code
;   without performance compromise. The example is restricted to the
;   WinMain to show how much direct code can be reduced while maintaining
;   the full power of pure assembler.
;
; #########################################################################

    include domacros.asm

; @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

    Do_Model .586

    include abstract.inc     ; local includes for this file

; #########################################################################

    Do_Init

; #########################################################################

    Do_WinMain

    invoke LoadIcon,hInst,500    ; icon ID
    Do_RetVal hIcon

    szText szClassName,"Abstract_Class"

    mov wc.cbSize,         sizeof WNDCLASSEX
    mov wc.style,          CS_BYTEALIGNWINDOW
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

    Do_CentreWindow 550,400

    invoke CreateWindowEx,WS_EX_LEFT,
                          ADDR szClassName,
                          ADDR szDisplayName,
                          WS_OVERLAPPEDWINDOW,
                          Wtx,Wty,Wwd,Wht,
                          NULL,NULL,
                          hInst,NULL
    Do_RetVal hWnd

    Do_MenuLoad hInstance,hWnd,600
    Do_WindowDisplay hWnd

    Do_mlStart msg
    Do_mlEnd msg

    Do_EndWinMain

; #########################################################################

WndProc proc hWin   :DWORD,
             uMsg   :DWORD,
             wParam :DWORD,
             lParam :DWORD

    LOCAL var    :DWORD
    LOCAL caW    :DWORD
    LOCAL caH    :DWORD
    LOCAL Rct    :RECT
    LOCAL hDC    :DWORD
    LOCAL Ps     :PAINTSTRUCT
    LOCAL tbab   :TBADDBITMAP
    LOCAL tbb    :TBBUTTON
    LOCAL buffer1[128]:BYTE  ; these are two spare buffers
    LOCAL buffer2[128]:BYTE  ; for text manipulation etc..

    .if uMsg == WM_COMMAND
    ;======== toolbar commands ========

            push lParam
            push wParam
            push uMsg
            push hWin

        .if wParam == 50
            call Butn1

        .elseif wParam == 51
            szText tbMsg1,"WM_COMMAND ID 51"
            invoke MessageBox,hWin,ADDR tbMsg1,
                              ADDR szDisplayName,MB_OK

        .elseif wParam == 52
            szText tbMsg2,"WM_COMMAND ID 52"
            invoke MessageBox,hWin,ADDR tbMsg2,
                              ADDR szDisplayName,MB_OK

        .elseif wParam == 53
            szText tbMsg3,"WM_COMMAND ID 53"
            invoke MessageBox,hWin,ADDR tbMsg3,
                              ADDR szDisplayName,MB_OK

        .elseif wParam == 54
            szText tbMsg4,"WM_COMMAND ID 54"
            invoke MessageBox,hWin,ADDR tbMsg4,
                              ADDR szDisplayName,MB_OK

        .elseif wParam == 55
            szText tbMsg5,"WM_COMMAND ID 55"
            invoke MessageBox,hWin,ADDR tbMsg5,
                              ADDR szDisplayName,MB_OK

        .elseif wParam == 56
            szText tbMsg6,"WM_COMMAND ID 56"
            invoke MessageBox,hWin,ADDR tbMsg6,
                              ADDR szDisplayName,MB_OK

        .elseif wParam == 57
            szText tbMsg7,"WM_COMMAND ID 57"
            invoke MessageBox,hWin,ADDR tbMsg7,
                              ADDR szDisplayName,MB_OK

        .elseif wParam == 58
            szText tbMsg8,"WM_COMMAND ID 58"
            invoke MessageBox,hWin,ADDR tbMsg8,
                              ADDR szDisplayName,MB_OK

        .endif

    ;======== menu commands ========
        .if wParam == 1000
           jmp @F
             szTitleO   db "Open A File",0
             szFilterO  db "All files",0,"*.*",0,
                           "Text files",0,"*.TEXT",0,0
           @@:
    
           invoke FillBuffer,ADDR szFileName,length szFileName,0
           invoke GetFileName,hWin,ADDR szTitleO,ADDR szFilterO
    
           cmp szFileName[0],0   ;<< zero if cancel pressed in dlgbox
           je @F
           ; file name returned in szFileName
           invoke MessageBox,hWin,ADDR szFileName,
                             ADDR szDisplayName,MB_OK
           @@:

        .elseif wParam == 1001
           jmp @F
             szTitleS   db "Save file as",0
             szFilterS  db "All files",0,"*.*",0,
                           "Text files",0,"*.TEXT",0,0
           @@:
    
           invoke FillBuffer,ADDR szFileName,length szFileName,0
           invoke SaveFileName,hWin,ADDR szTitleS,ADDR szFilterS
    
           cmp szFileName[0],0   ;<< zero if cancel pressed in dlgbox
           je @F
           ; file name returned in szFileName
           invoke MessageBox,hWin,ADDR szFileName,
                             ADDR szDisplayName,MB_OK
           @@:

        .endif
        .if wParam == 1010
            invoke SendMessage,hWin,WM_SYSCOMMAND,SC_CLOSE,NULL
        .elseif wParam == 1900
            szText AboutMsg,"Prostart Pure Assembler Template",13,10,\
            "Copyright © Prostart 1999"
            invoke ShellAbout,hWin,ADDR szDisplayName,ADDR AboutMsg,hIcon
        .endif
    ;====== end menu commands ======

    .elseif uMsg == WM_SYSCOLORCHANGE
        invoke Do_ToolBar,hWin

    .elseif uMsg == WM_CREATE
        invoke Do_ToolBar,hWin

        invoke Do_Status,hWin

    .elseif uMsg == WM_SIZE
        invoke SendMessage,hToolBar,TB_AUTOSIZE,0,0
        invoke MoveWindow,hStatus,0,0,0,0,TRUE

    .elseif uMsg == WM_PAINT
        invoke BeginPaint,hWin,ADDR Ps
          mov hDC, eax
          invoke Paint_Proc,hWin,hDC
        invoke EndPaint,hWin,ADDR Ps
        return 0

    .elseif uMsg == WM_CLOSE
        szText TheText,"Please Confirm Exit"
        invoke MessageBox,hWin,ADDR TheText,ADDR szDisplayName,MB_YESNO
          .if eax == IDNO
            return 0
          .endif

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

Paint_Proc proc hWin:DWORD, hDC:DWORD

    LOCAL btn_hi   :DWORD
    LOCAL btn_lo   :DWORD
    LOCAL Rct      :RECT

    invoke GetSysColor,COLOR_BTNHIGHLIGHT
    mov btn_hi, eax

    invoke GetSysColor,COLOR_BTNSHADOW
    mov btn_lo, eax

    return 0

Paint_Proc endp

; ########################################################################

Butn1 proc hWin   :DWORD,
           uMsg   :DWORD,
           wParam :DWORD,
           lParam :DWORD

    szText tbMsg0,"WM_COMMAND ID 50"
    invoke MessageBox,hWin,ADDR tbMsg0,
                      ADDR szDisplayName,MB_OK

    ret

Butn1 endp

; ########################################################################

end start
