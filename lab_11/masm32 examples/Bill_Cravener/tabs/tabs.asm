; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Simple Tab Control without Resource file. Author: William F Cravener 9/14/2011
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    .586                      ; create 32 bit code
    .model flat, stdcall      ; 32 bit memory model
    option casemap :none      ; case sensitive

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    include \masm32\include\windows.inc
    include \masm32\include\gdi32.inc
    include \masm32\include\user32.inc
    include \masm32\include\kernel32.inc
    include \masm32\include\comctl32.inc
    include \masm32\include\masm32.inc

    includelib \masm32\lib\gdi32.lib
    includelib \masm32\lib\user32.lib
    includelib \masm32\lib\kernel32.lib
    includelib \masm32\lib\comctl32.lib
    includelib \masm32\lib\masm32.lib

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    WinMain          PROTO :DWORD,:DWORD,:DWORD,:DWORD
    WndProc          PROTO :DWORD,:DWORD,:DWORD,:DWORD
    TabControls      PROTO :DWORD
    ShowTabIndex     PROTO :DWORD
    TopXY            PROTO :DWORD,:DWORD

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    TABCTRL equ 100

    RADIO1 equ 101
    RADIO2 equ 102
    RADIO3 equ 103
    RADIO4 equ 104

    CHKBOX1 equ 105
    CHKBOX2 equ 106
    CHKBOX3 equ 107
    CHKBOX4 equ 108

    PUSHBTN1 equ 109
    PUSHBTN2 equ 110
    PUSHBTN3 equ 111

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.data
    hInstance       dd 0
    hWnd            dd 0
    hDC             dd 0
    hTab            dd 0
    tabID1          dd 0
    tabID2          dd 0
    tabID3          dd 0
    tabCount        dd 0

    hButton1        dd 0
    hButton2        dd 0
    hButton3        dd 0
    hButton4        dd 0

    hButton5        dd 0
    hButton6        dd 0
    hButton7        dd 0
    hButton8        dd 0

    hButton9        dd 0
    hButton10       dd 0
    hButton11       dd 0

    szButton1       db "Radio Button Setting #1",0
    szButton2       db "Radio Button Setting #2",0
    szButton3       db "Radio Button Setting #3",0
    szButton4       db "Radio Button Setting #4",0

    szButton5       db "Check Box Setting #5",0
    szButton6       db "Check Box Setting #6",0
    szButton7       db "Check Box Setting #7",0
    szButton8       db "Check Box Setting #8",0

    szButton9       db "Push Button Setting #9",0
    szButton10      db "Push Button Setting #10",0
    szButton11      db "Push Button Setting #11",0

    szYouPicked     db "You picked:",0
    szTabTitle1     db "Tab One",0
    szTabTitle2     db "Tab Two",0
    szTabTitle3     db "Tab Three",0

    szClassName     db "TABSEXAMPLE",0
    szDisplayName   db "Tabs Example",0
    szButtonClass   db "BUTTON",0
    szWndClsTab     db "SysTabControl32",0
    szWhichTab      db "Tab Index Number:  ",0

    tie             TC_ITEM <>
    ps              PAINTSTRUCT <>
    icex            INITCOMMONCONTROLSEX <>

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.code

start:
    invoke GetModuleHandle,0
    mov hInstance,eax
    mov icex.dwSize,sizeof INITCOMMONCONTROLSEX
    mov icex.dwICC,ICC_TAB_CLASSES
    invoke InitCommonControlsEx,ADDR icex
    invoke WinMain,hInstance,0,0,0
    invoke ExitProcess,eax

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

WinMain proc hInst:DWORD,hPrevInst:DWORD,CmdLine:DWORD,CmdShow:DWORD

    ; ===============================
    ; Standard window creation stuff
    ; ===============================

    LOCAL wc:WNDCLASSEX
    LOCAL msg:MSG
    LOCAL Wwd:DWORD
    LOCAL Wht:DWORD
    LOCAL Wtx:DWORD
    LOCAL Wty:DWORD

    mov wc.cbSize,sizeof WNDCLASSEX
    mov wc.style,CS_HREDRAW or CS_VREDRAW or CS_BYTEALIGNWINDOW
    mov wc.lpfnWndProc,OFFSET WndProc
    mov wc.cbClsExtra,0
    mov wc.cbWndExtra,0
    mov eax,hInst
    mov wc.hInstance,eax
    mov wc.hbrBackground,COLOR_WINDOW+1
    mov wc.lpszMenuName,0
    mov wc.lpszClassName,OFFSET szClassName
    mov wc.hIcon,0 
    invoke LoadCursor,0,IDC_ARROW
    mov wc.hCursor,eax
    mov wc.hIconSm,0

    invoke RegisterClassEx,ADDR wc

    mov Wwd,357
    mov Wht,300
    invoke GetSystemMetrics,SM_CXSCREEN
    invoke TopXY,Wwd,eax
    mov Wtx,eax
    invoke GetSystemMetrics,SM_CYSCREEN
    invoke TopXY,Wht,eax
    mov Wty,eax

    invoke CreateWindowEx,WS_EX_LEFT,
                          ADDR szClassName,
                          ADDR szDisplayName,
                          WS_OVERLAPPEDWINDOW,
                          Wtx,Wty,Wwd,Wht,
                          0,0,
                          hInstance,0

    mov hWnd,eax
    invoke ShowWindow,hWnd,SW_SHOW

    StartLoop:
      invoke GetMessage,ADDR msg,0,0,0
      cmp eax,0
      je ExitLoop
      invoke TranslateMessage,ADDR msg
      invoke DispatchMessage,ADDR msg
      jmp StartLoop
    ExitLoop:
      
    mov eax,msg.wParam 
    ret

WinMain endp

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

WndProc proc hWin:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD

       .if uMsg == WM_CREATE
           ; ==============================
           ; Create our tab control window 
           ; ==============================
           invoke CreateWindowEx,0,ADDR szWndClsTab,
                                 0,WS_VISIBLE or WS_CHILD or TCS_FIXEDWIDTH or TCS_BOTTOM,
                                 10,10,330,200,
                                 hWin,TABCTRL,
                                 hInstance,0
           mov hTab,eax

           ; ==============================
           ; Create our first tab 
           ; ==============================
           mov tie.imask,TCIF_TEXT
           mov eax,OFFSET szTabTitle1
           mov tie.pszText,eax
           invoke SendMessage,hTab,TCM_GETITEMCOUNT,0,0
           mov tabCount,eax
           invoke SendMessage,hTab,TCM_INSERTITEM,tabCount,ADDR tie
           mov tabID1,eax

           ; ==============================
           ; Create our second tab 
           ; ==============================
           mov tie.imask,TCIF_TEXT
           mov eax,OFFSET szTabTitle2
           mov tie.pszText,eax
           invoke SendMessage,hTab,TCM_GETITEMCOUNT,0,0
           mov tabCount,eax
           invoke SendMessage,hTab,TCM_INSERTITEM,tabCount,ADDR tie
           mov tabID2,eax

           ; ==============================
           ; Create our third tab 
           ; ==============================
           mov tie.imask,TCIF_TEXT
           mov eax,OFFSET szTabTitle3
           mov tie.pszText,eax
           invoke SendMessage,hTab,TCM_GETITEMCOUNT,0,0
           mov tabCount,eax
           invoke SendMessage,hTab,TCM_INSERTITEM,tabCount,ADDR tie
           mov tabID3,eax

           ; =====================================
           ; Create all our tab button controls
           ; =====================================
           invoke TabControls,hWin
           
           ; =====================================
           ; Hide all but the first tabs controls
           ; =====================================
           invoke ShowWindow,hButton1,SW_SHOW
           invoke ShowWindow,hButton2,SW_SHOW
           invoke ShowWindow,hButton3,SW_SHOW
           invoke ShowWindow,hButton4,SW_SHOW
           invoke ShowWindow,hButton5,SW_HIDE
           invoke ShowWindow,hButton6,SW_HIDE
           invoke ShowWindow,hButton7,SW_HIDE
           invoke ShowWindow,hButton8,SW_HIDE
           invoke ShowWindow,hButton9,SW_HIDE
           invoke ShowWindow,hButton10,SW_HIDE
           invoke ShowWindow,hButton11,SW_HIDE

        .elseif uMsg == WM_COMMAND
                ; ===========================================
                ; Deal with all the tab button controls here
                ; ===========================================
                .if wParam == RADIO1
                    invoke MessageBox,hWin,ADDR szButton1,ADDR szYouPicked,MB_OK
                .elseif wParam == RADIO2
                        invoke MessageBox,hWin,ADDR szButton2,ADDR szYouPicked,MB_OK
                .elseif wParam == RADIO3
                        invoke MessageBox,hWin,ADDR szButton3,ADDR szYouPicked,MB_OK
                .elseif wParam == RADIO4
                        invoke MessageBox,hWin,ADDR szButton4,ADDR szYouPicked,MB_OK
                .elseif wParam == CHKBOX1
                        invoke MessageBox,hWin,ADDR szButton5,ADDR szYouPicked,MB_OK
                .elseif wParam == CHKBOX2
                        invoke MessageBox,hWin,ADDR szButton6,ADDR szYouPicked,MB_OK
                .elseif wParam == CHKBOX3
                        invoke MessageBox,hWin,ADDR szButton7,ADDR szYouPicked,MB_OK
                .elseif wParam == CHKBOX4
                        invoke MessageBox,hWin,ADDR szButton8,ADDR szYouPicked,MB_OK
                .elseif wParam == PUSHBTN1
                        invoke MessageBox,hWin,ADDR szButton9,ADDR szYouPicked,MB_OK
                .elseif wParam == PUSHBTN2
                        invoke MessageBox,hWin,ADDR szButton10,ADDR szYouPicked,MB_OK
                .elseif wParam == PUSHBTN3
                        invoke MessageBox,hWin,ADDR szButton11,ADDR szYouPicked,MB_OK
                .endif   

        .elseif uMsg == WM_NOTIFY
                ; ==============================================
                ; WM_NOTIFY is sent if a user clicks on a tab
                ; Show/Hide the appropriate tab button controls
                ; ==============================================
                mov eax,lParam
                mov eax,(NMHDR PTR [eax]).code
                .if eax == TCN_SELCHANGE
                    invoke  SendMessage,hTab,TCM_GETCURSEL,0,0
                    .if eax == tabID1
                        invoke ShowWindow,hButton1,SW_SHOW
                        invoke ShowWindow,hButton2,SW_SHOW
                        invoke ShowWindow,hButton3,SW_SHOW
                        invoke ShowWindow,hButton4,SW_SHOW
                        invoke ShowWindow,hButton5,SW_HIDE
                        invoke ShowWindow,hButton6,SW_HIDE
                        invoke ShowWindow,hButton7,SW_HIDE
                        invoke ShowWindow,hButton8,SW_HIDE
                        invoke ShowWindow,hButton9,SW_HIDE
                        invoke ShowWindow,hButton10,SW_HIDE
                        invoke ShowWindow,hButton11,SW_HIDE
                    .elseif eax == tabID2
                            invoke ShowWindow,hButton1,SW_HIDE
                            invoke ShowWindow,hButton2,SW_HIDE
                            invoke ShowWindow,hButton3,SW_HIDE
                            invoke ShowWindow,hButton4,SW_HIDE
                            invoke ShowWindow,hButton5,SW_SHOW
                            invoke ShowWindow,hButton6,SW_SHOW
                            invoke ShowWindow,hButton7,SW_SHOW
                            invoke ShowWindow,hButton8,SW_SHOW
                            invoke ShowWindow,hButton9,SW_HIDE
                            invoke ShowWindow,hButton10,SW_HIDE
                            invoke ShowWindow,hButton11,SW_HIDE
                    .elseif eax == tabID3
                            invoke ShowWindow,hButton1,SW_HIDE
                            invoke ShowWindow,hButton2,SW_HIDE
                            invoke ShowWindow,hButton3,SW_HIDE
                            invoke ShowWindow,hButton4,SW_HIDE
                            invoke ShowWindow,hButton5,SW_HIDE
                            invoke ShowWindow,hButton6,SW_HIDE
                            invoke ShowWindow,hButton7,SW_HIDE
                            invoke ShowWindow,hButton8,SW_HIDE
                            invoke ShowWindow,hButton9,SW_SHOW
                            invoke ShowWindow,hButton10,SW_SHOW
                            invoke ShowWindow,hButton11,SW_SHOW
                    .endif 
                 invoke ShowTabIndex,hWin
                .endif

        .elseif uMsg==WM_PAINT
                invoke BeginPaint,hWin,ADDR ps
                invoke ShowTabIndex,hWin
                invoke EndPaint,hWin,ADDR ps

        .elseif uMsg == WM_DESTROY
                invoke PostQuitMessage,0

        .endif

    invoke DefWindowProc,hWin,uMsg,wParam,lParam

    ret

WndProc endp

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

TabControls proc hWin:DWORD
        ; ========================================
        ; Create all our tab button controls here
        ; All radio, checkbox and button controls
        ; ========================================
        invoke CreateWindowEx,0,ADDR szButtonClass,ADDR szButton1,
                              WS_CHILD or BS_RADIOBUTTON or WS_TABSTOP,
                              80,50,180,20,
                              hWin,RADIO1,
                              hInstance,0
        mov hButton1,eax        

        invoke CreateWindowEx,0,ADDR szButtonClass,ADDR szButton2,
                               WS_CHILD or BS_RADIOBUTTON or WS_TABSTOP,
                               80,70,180,20,
                               hWin,RADIO2,
                               hInstance,0
        mov hButton2,eax 

        invoke CreateWindowEx,0,ADDR szButtonClass,ADDR szButton3,
                              WS_CHILD or BS_RADIOBUTTON or WS_TABSTOP,
                              80,90,180,20,
                              hWin,RADIO3,
                              hInstance,0
        mov hButton3,eax 

        invoke CreateWindowEx,0,ADDR szButtonClass,ADDR szButton4,
                              WS_CHILD or BS_RADIOBUTTON or WS_TABSTOP,
                              80,110,180,20,
                              hWin,RADIO4,
                              hInstance,0
        mov hButton4,eax 

        invoke CreateWindowEx,0,ADDR szButtonClass,ADDR szButton5,
                              WS_CHILD or BS_CHECKBOX or WS_TABSTOP,
                              80,50,180,20,
                              hWin,CHKBOX1,
                              hInstance,0
        mov hButton5,eax

        invoke CreateWindowEx,0,ADDR szButtonClass,ADDR szButton6,
                              WS_CHILD or BS_CHECKBOX or WS_TABSTOP,
                              80,70,180,20,
                              hWin,CHKBOX2,
                              hInstance,0
        mov hButton6,eax 

        invoke CreateWindowEx,0,ADDR szButtonClass,ADDR szButton7,
                              WS_CHILD or BS_CHECKBOX or WS_TABSTOP,
                              80,90,180,20,
                              hWin,CHKBOX3,
                              hInstance,0
        mov hButton7,eax 

        invoke  CreateWindowEx,0,ADDR szButtonClass,ADDR szButton8,
                               WS_CHILD or BS_CHECKBOX or WS_TABSTOP,
                               80,110,180,20,
                               hWin,CHKBOX4,
                               hInstance,0
        mov hButton8,eax
 
        invoke  CreateWindowEx,0,ADDR szButtonClass,ADDR szButton9,
                               WS_CHILD or BS_PUSHBUTTON or WS_TABSTOP,
                               80,50,180,20,
                               hWin,PUSHBTN1,
                               hInstance,0
        mov hButton9,eax
 
        invoke  CreateWindowEx,0,ADDR szButtonClass,ADDR szButton10,
                               WS_CHILD or BS_PUSHBUTTON or WS_TABSTOP,
                               80,80,180,20,
                               hWin,PUSHBTN2,
                               hInstance,0
        mov hButton10,eax
 
        invoke  CreateWindowEx,0,ADDR szButtonClass,ADDR szButton11,
                               WS_CHILD or BS_PUSHBUTTON or WS_TABSTOP,
                               80,110,180,20,
                               hWin,PUSHBTN3,
                               hInstance,0
        mov hButton11,eax
 
        ret

TabControls endp

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ShowTabIndex proc hWin:DWORD
    ; ============================================
    ; Display which tab index is currently active
    ; ============================================
     invoke GetWindowDC,hWin
     mov hDC,eax
     invoke SendMessage,hTab,TCM_GETCURSEL,0,0
     invoke dwtoa,eax,OFFSET [szWhichTab+18] 
     invoke TextOut,hDC,110,270,ADDR szWhichTab,19
     invoke ReleaseDC,hWin,hDC

     ret

ShowTabIndex endp

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

TopXY proc wDim:DWORD, sDim:DWORD
    ; ==============================================
    ; Centers our tab control window on the desktop
    ; ==============================================
    shr sDim,1
    shr wDim,1
    mov eax,wDim
    sub sDim,eax
    mov eax,sDim

    ret

TopXY endp

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

end start
