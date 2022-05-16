; #########################################################################

    .486                      ; create 32 bit code
    .model flat, stdcall      ; 32 bit memory model
    option casemap :none      ; case sensitive

    include arrays.inc        ; local includes for this file
    include dbmacros.asm

    stralloc MACRO ln
      invoke SysAllocStringByteLen,0,ln
    ENDM

    strfree MACRO strhandle
      invoke SysFreeString,strhandle
    ENDM

    TestArray    PROTO
    StackArray   PROTO
    PassArray    PROTO
    ProcessArray PROTO :DWORD,:DWORD
    CopyArray    PROTO
    TwoDimArray  PROTO
    SetItem      PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
    GetItem      PROTO :DWORD,:DWORD,:DWORD,:DWORD

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

    szText szClassName,"Prostart_Class"

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
            invoke TestArray

        .elseif wParam == 51
            invoke StackArray

        .elseif wParam == 52
            invoke PassArray

        .elseif wParam == 53
            invoke CopyArray

        .elseif wParam == 54
            invoke TwoDimArray

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

        .if wParam == 1001
            jmp @F
              szTitleO   db "Open A File",0
              szFilterO  db "All files",0,"*.*",0,0
            @@:
          ; --------------------------------------
          ; szFileName is defined in Filedlgs.asm
          ; --------------------------------------
            mov szFileName[0],0     ; set 1st byte to zero
            invoke GetFileName,hWin,ADDR szTitleO,ADDR szFilterO
            cmp szFileName[0],0     ; zero if cancel pressed in dlgbox
            je @F
          ; ---------------------------------
          ; perform your file open code here
          ; ---------------------------------
            invoke MessageBox,hWin,ADDR szFileName,ADDR szDisplayName,MB_OK
            @@:

        .elseif wParam == 1002
            jmp @F
              szTitleS   db "Save File As ...",0
              szFilterS  db "All files",0,"*.*",0,0
            @@:
          ; --------------------------------------
          ; szFileName is defined in Filedlgs.asm
          ; --------------------------------------
            mov szFileName[0],0     ; set 1st byte to zero
            invoke SaveFileName,hWin,ADDR szTitleS,ADDR szFilterS
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
            szText AboutMsg,"Prostart 2 Template",\
            13,10,"Copyright © MASM32 2001"
            invoke ShellAbout,hWin,ADDR szDisplayName,ADDR AboutMsg,hIcon
        .endif
    ;====== end menu commands ======

    .elseif uMsg == WM_DROPFILES
        invoke DragQueryFile,wParam,0,ADDR szDropFileName,sizeof szDropFileName
        szText dfMsg,"WM_DROPFILES"
        invoke MessageBox,hWin,ADDR szDropFileName,ADDR dfMsg,MB_OK

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

; ########################################################################

TestArray proc

  ; @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  ; loading, reading and writing to a dynamic array
  ; @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

    LOCAL hArray:DWORD
    LOCAL cntr:DWORD

    stralloc 2048*4         ; allocate memory for array
    mov hArray, eax

  ; --------------------------------------------------
  ; fill array from 0 to 2047 in DWORD size ascending
  ; array is zero based index.
  ; --------------------------------------------------
    mov eax, 0
    mov ecx, 2048
    mov edi, hArray
  @@:
    mov [edi], eax
    add edi, 4
    inc eax
    cmp eax, ecx
    jne @B

    mov eax, hArray         ; array address in eax
    mov ecx, 1024           ; get this array item

  ; --------------------
  ; get item from array
  ; --------------------
    mov edx, [eax+(ecx*4)]  ; put item at address in eax + ecx*4 in edx

  ; ----------
  ; change it
  ; ----------
    add edx, 10

  ; -----------------------
  ; write it back to array
  ; -----------------------
    mov [eax+(ecx*4)], edx  ; write edx to address in eax + offset ecx*4

    ShowReturn hWnd,[eax+(ecx*4)]

    strfree hArray

    ret

TestArray endp

; ########################################################################

StackArray proc

  ; @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  ; loading, reading and writing to array allocated on the stack
  ; @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

    LOCAL Stack_Array[1024]:DWORD    ; allocate space on the stack

  ; -------------------------------------------------
  ; load array with ascending numbers from 0 to 1023
  ; -------------------------------------------------
    xor eax, eax
    xor ecx, ecx
  @@:
    mov Stack_Array[eax], ecx   ; write ecx to array at offset in eax
    add eax, 4                  ; step address by 4 for DWORD read/write
    inc ecx                     ; increment counter
    cmp ecx, 1024               ; test ecx against count
    jne @B

  ; ----------------------------------------------
  ; loop through array and add 10 to each element
  ; ----------------------------------------------
    xor eax, eax
  @@:
    mov ecx, Stack_Array[eax]   ; get array element
    add ecx, 10                 ; add 10 to it
    mov Stack_Array[eax], ecx   ; write it back to array
    add eax, 4                  ; step address by 4 for DWORD read/write
    cmp eax, 1024*4             ; test eax against count * 4
    jne @B

    ShowReturn hWnd, Stack_Array[1023*4]

    ret

StackArray endp

; ########################################################################

PassArray proc

    LOCAL Test_Array[1024]:DWORD

  ; @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  ; "lengthof" gives the element count in Test_Array
  ; @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    invoke ProcessArray,ADDR Test_Array,lengthof Test_Array

    ShowReturn hWnd, Test_Array[1023*4]

    ret

PassArray endp

; ########################################################################

ProcessArray proc lpArray:DWORD,Elements:DWORD

    mov eax, lpArray    ; array address in EAX
    mov ecx, Elements   ; element count in ECX
    dec ecx             ; correct to get 0 based index

  ; ----------------------------------
  ; fill array with descending values
  ; ----------------------------------
  @@:
    mov [eax], ecx
    add eax, 4
    dec ecx
    jns @B

    ret

ProcessArray endp

; ########################################################################

CopyArray proc

    LOCAL hArray1:DWORD
    LOCAL hArray2:DWORD

  ; -----------------------------------------
  ; allocate 2 blocks of memory for 2 arrays
  ; -----------------------------------------
    stralloc 8192
    mov hArray1, eax

    stralloc 8192
    mov hArray2, eax

  ; -----------------------------------------
  ; fill first array with descending numbers
  ; -----------------------------------------
    mov eax, hArray1
    mov ecx, 2048
  @@:
    mov [eax], ecx
    add eax, 4
    dec ecx
    jnz @B

  ; -------------------------------------
  ; copy complete 1st array to 2nd array
  ; -------------------------------------
    invoke MemCopy,hArray1,hArray2,8192

    mov eax, hArray2

  ; ----------------------------
  ; display item from 2nd array
  ; ----------------------------
    ShowReturn hWnd, [eax+2048*4]

    strfree hArray2
    strfree hArray1

    ret

CopyArray endp

; ########################################################################

TwoDimArray proc

    LOCAL hArray:DWORD
    LOCAL item  :DWORD
    LOCAL string[16]:BYTE

    stralloc 12*12*4    ; a 12 x 12 DWORD array
    mov hArray, eax

    invoke SetItem,6,6,12345678,hArray,12

    invoke GetItem,6,6,12,hArray
    mov item, eax

    invoke dwtoa,item, ADDR string
    invoke MessageBox,hWnd,ADDR string,ADDR string,MB_OK

    strfree hArray

    ret

TwoDimArray endp

; #########################################################################

GetItem proc posX:DWORD,posY:DWORD,dim1:DWORD,lpArray:DWORD

    LOCAL pos1:DWORD

    invoke IntMul,posX,dim1
    add eax, posY
    mov pos1, eax

    mov eax, lpArray
    add eax, pos1
    mov eax, [eax]

    ret

GetItem endp

; #########################################################################

SetItem proc posX:DWORD,posY:DWORD,valu:DWORD,lpArray:DWORD,dim1:DWORD


    LOCAL pos1:DWORD

    invoke IntMul,posX,dim1
    add eax, posY
    mov pos1, eax

    mov eax, lpArray
    add eax, pos1
    mov ecx, valu
    mov [eax], ecx

    ret

SetItem endp

; #########################################################################

end start
