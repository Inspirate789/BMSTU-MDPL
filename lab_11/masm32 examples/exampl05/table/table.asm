; #########################################################################

      .486                      ; create 32 bit code
      .model flat, stdcall      ; 32 bit memory model
      option casemap :none      ; case sensitive

      include table.inc        ; local includes for this file

    AsciiDump PROTO :DWORD,:DWORD,:DWORD

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

            .data
              src db "The time has come, the Walrus said, To talk of many things,",
                     "Of shoes and ships and sealing wax, Of cabbages and kings,",
                     "And why the sea is boiling hot and whether pigs have wings.",0

              dst db 512 dup (0)
            .code

            invoke AsciiDump,ADDR src,ADDR dst,lengthof src


            invoke MessageBox,hWin,ADDR dst,
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

; ########################################################################

AsciiDump proc lpsrc:DWORD,lpbuf:DWORD,lnsrc:DWORD

    LOCAL count  :DWORD

    jmp @F
    align 4
  StringTable:
    db "  0",44,"  1",44,"  2",44,"  3",44,"  4",44,"  5",44,"  6",44,"  7",44
    db "  8",44,"  9",44," 10",44," 11",44," 12",44," 13",44," 14",44," 15",44
    db " 16",44," 17",44," 18",44," 19",44," 20",44," 21",44," 22",44," 23",44
    db " 24",44," 25",44," 26",44," 27",44," 28",44," 29",44," 30",44," 31",44
    db " 32",44," 33",44," 34",44," 35",44," 36",44," 37",44," 38",44," 39",44
    db " 40",44," 41",44," 42",44," 43",44," 44",44," 45",44," 46",44," 47",44
    db " 48",44," 49",44," 50",44," 51",44," 52",44," 53",44," 54",44," 55",44
    db " 56",44," 57",44," 58",44," 59",44," 60",44," 61",44," 62",44," 63",44
    db " 64",44," 65",44," 66",44," 67",44," 68",44," 69",44," 70",44," 71",44
    db " 72",44," 73",44," 74",44," 75",44," 76",44," 77",44," 78",44," 79",44
    db " 80",44," 81",44," 82",44," 83",44," 84",44," 85",44," 86",44," 87",44
    db " 88",44," 89",44," 90",44," 91",44," 92",44," 93",44," 94",44," 95",44
    db " 96",44," 97",44," 98",44," 99",44,"100",44,"101",44,"102",44,"103",44
    db "104",44,"105",44,"106",44,"107",44,"108",44,"109",44,"110",44,"111",44
    db "112",44,"113",44,"114",44,"115",44,"116",44,"117",44,"118",44,"119",44
    db "120",44,"121",44,"122",44,"123",44,"124",44,"125",44,"126",44,"127",44
    db "128",44,"129",44,"130",44,"131",44,"132",44,"133",44,"134",44,"135",44
    db "136",44,"137",44,"138",44,"139",44,"140",44,"141",44,"142",44,"143",44
    db "144",44,"145",44,"146",44,"147",44,"148",44,"149",44,"150",44,"151",44
    db "152",44,"153",44,"154",44,"155",44,"156",44,"157",44,"158",44,"159",44
    db "160",44,"161",44,"162",44,"163",44,"164",44,"165",44,"166",44,"167",44
    db "168",44,"169",44,"170",44,"171",44,"172",44,"173",44,"174",44,"175",44
    db "176",44,"177",44,"178",44,"179",44,"180",44,"181",44,"182",44,"183",44
    db "184",44,"185",44,"186",44,"187",44,"188",44,"189",44,"190",44,"191",44
    db "192",44,"193",44,"194",44,"195",44,"196",44,"197",44,"198",44,"199",44
    db "200",44,"201",44,"202",44,"203",44,"204",44,"205",44,"206",44,"207",44
    db "208",44,"209",44,"210",44,"211",44,"212",44,"213",44,"214",44,"215",44
    db "216",44,"217",44,"218",44,"219",44,"220",44,"221",44,"222",44,"223",44
    db "224",44,"225",44,"226",44,"227",44,"228",44,"229",44,"230",44,"231",44
    db "232",44,"233",44,"234",44,"235",44,"236",44,"237",44,"238",44,"239",44
    db "240",44,"241",44,"242",44,"243",44,"244",44,"245",44,"246",44,"247",44
    db "248",44,"249",44,"250",44,"251",44,"252",44,"253",44,"254",44,"255",44
  @@:

    push ebx
    push esi
    push edi
  ; ============================

    lea edx, StringTable
    xor ebx, ebx                    ; line length counter

    mov eax, lpsrc
    add eax, lnsrc
    mov count, eax                  ; set count as exit condition

    mov esi, lpsrc
    mov edi, lpbuf

    mov [edi], DWORD PTR 0D202020h  ; 3 space padding for alignment + CR
    add edi, 4
    mov [edi], DWORD PTR 2062640Ah  ; LF + "db "
    add edi, 4

    xor eax, eax                    ; avoid stall

  ; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  @@:
    mov al, [esi]
    inc esi
    mov ecx, [edx+eax*4]            ; all table writes are DWORD size
    mov [edi], ecx
    add edi, 4

    cmp ebx, 16                     ; test character count per line
    je nxt1                         ; jump on less common choice
    inc ebx
    cmp esi, count                  ; test exit condition
    jne @B
    jmp The_Exit

  nxt1:
    dec edi
    mov [edi], BYTE PTR 13          ; overwrite comma with CR
    inc edi
    mov [edi], DWORD PTR 2062640Ah  ; write 4 bytes to maintain alignment
    add edi, 4
    xor ebx, ebx                    ; zero character count
    jmp @B

  ; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  The_Exit:

  ; only overwrite last character IF its a comma ","

    cmp [edi-1], BYTE PTR ","
    jne @F
    dec edi
  @@:
    mov [edi], DWORD PTR 00000A0Dh  ; append CRLF * 2 ascii zeros

  ; ============================
    pop edi
    pop esi
    pop ebx

    ret

AsciiDump endp

; #########################################################################

end start
