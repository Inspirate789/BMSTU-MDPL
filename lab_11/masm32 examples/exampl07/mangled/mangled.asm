; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    .686p                       ; create 32 bit code
    .mmx                        ; enable MMX instructions
    .xmm                        ; enable SSE instructions
    .model flat, stdcall        ; 32 bit memory model
    option casemap :none        ; case sensitive

  ; -------------------------------------------------------------
  ; equates for controlling the toolbar button size and placement
  ; -------------------------------------------------------------
    rbht     equ <84>           ; rebar height in pixels
    tbbW     equ <64>           ; toolbar button width in pixels
    tbbH     equ <64>           ; toolbar button height in pixels
    vpad     equ <22>           ; vertical button padding in pixels
    hpad     equ <12>           ; horizontal button padding in pixels
    lind     equ  <5>           ; left side initial indent in pixels

    bColor   equ  <00999999h>   ; client area brush colour

    include mangled.inc         ; local includes for this file

    text_message PROTO

.code

start:

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

  ; ------------------
  ; set global values
  ; ------------------
    mov hInstance,   rv(GetModuleHandle, NULL)
    mov CommandLine, rv(GetCommandLine)
    mov hIcon,       rv(LoadIcon,hInstance,500)
    mov hCursor,     rv(LoadCursor,NULL,IDC_ARROW)
    mov sWid,        rv(GetSystemMetrics,SM_CXSCREEN)
    mov sHgt,        rv(GetSystemMetrics,SM_CYSCREEN)

  ; -------------------------------------------------
  ; load the toolbar button strip at its default size
  ; -------------------------------------------------
    invoke LoadImage,hInstance,700,IMAGE_BITMAP,0,0, \
           LR_DEFAULTSIZE or LR_LOADTRANSPARENT or LR_LOADMAP3DCOLORS
    mov hBitmap, eax

  ; ----------------------------------------------------------------
  ; load the rebar background tile stretching it to the rebar height
  ; ----------------------------------------------------------------
    mov tbTile, rv(LoadImage,hInstance,800,IMAGE_BITMAP,sWid,rbht,LR_DEFAULTCOLOR)

    call Main

    invoke ExitProcess,eax

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

Main proc

    LOCAL Wwd:DWORD,Wht:DWORD,Wtx:DWORD,Wty:DWORD,mWid:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL icce:INITCOMMONCONTROLSEX
    LOCAL pmangled  :DWORD

  ; --------------------------------------
  ; comment out the styles you don't need.
  ; --------------------------------------
    mov icce.dwSize, SIZEOF INITCOMMONCONTROLSEX            ; set the structure size
    xor eax, eax                                            ; set EAX to zero
    or eax, ICC_BAR_CLASSES                                 ; comment out the rest
    or eax, ICC_WIN95_CLASSES
    mov icce.dwICC, eax
    invoke InitCommonControlsEx,ADDR icce                   ; initialise the common control library
  ; --------------------------------------

    STRING szClassName,   "Mqangled_Class"
    STRING szDisplayName, "Mangled Text Demo"

  ; ---------------------------------------------------
  ; set window class attributes in WNDCLASSEX structure
  ; ---------------------------------------------------
    mov wc.cbSize,         sizeof WNDCLASSEX
    mov wc.style,          CS_BYTEALIGNCLIENT or CS_BYTEALIGNWINDOW
    m2m wc.lpfnWndProc,    OFFSET WndProc
    mov wc.cbClsExtra,     NULL
    mov wc.cbWndExtra,     NULL
    m2m wc.hInstance,      hInstance
    m2m wc.hbrBackground,  NULL                             ; client area is covered by the client window
    mov wc.lpszMenuName,   NULL
    mov wc.lpszClassName,  OFFSET szClassName
    m2m wc.hIcon,          hIcon
    m2m wc.hCursor,        hCursor
    m2m wc.hIconSm,        hIcon

  ; ------------------------------------
  ; register class with these attributes
  ; ------------------------------------
    invoke RegisterClassEx, ADDR wc

  ; ---------------------------------------------
  ; set width and height as percentages of screen
  ; ---------------------------------------------
    invoke GetPercent,sWid,70
    mov Wwd, eax
    invoke GetPercent,sHgt,70
    mov Wht, eax

  ; ----------------------
  ; set aspect ratio limit
  ; ----------------------
    FLOAT4 aspect_ratio, 1.4    ; set the maximum startup aspect ratio

    fild Wht                    ; load source
    fld aspect_ratio            ; load multiplier
    fmul                        ; multiply source by multiplier
    fistp mWid                  ; store result in variable

    mov eax, Wwd
    .if eax > mWid              ; if the default window width is > aspect ratio
      m2m Wwd, mWid             ; set the width to the maximum aspect ratio
    .endif

  ; ------------------------------------------------
  ; Top X and Y co-ordinates for the centered window
  ; ------------------------------------------------
    mov eax, sWid
    sub eax, Wwd                ; sub window width from screen width
    shr eax, 1                  ; divide it by 2
    mov Wtx, eax                ; copy it to variable

    mov eax, sHgt
    sub eax, Wht                ; sub window height from screen height
    shr eax, 1                  ; divide it by 2
    mov Wty, eax                ; copy it to variable

  ; -----------------------------------------------------------------
  ; create the main window with the size and attributes defined above
  ; -----------------------------------------------------------------
    invoke CreateWindowEx,WS_EX_LEFT or WS_EX_ACCEPTFILES,
                          ADDR szClassName,
                          ADDR szDisplayName,
                          WS_OVERLAPPEDWINDOW,
                          Wtx,Wty,Wwd,Wht,
                          NULL,NULL,
                          hInstance,NULL
    mov hWnd,eax

    fn LoadLibrary,"RICHED20.DLL"
    mov hEdit, rv(RichEdit2,hInstance,hWnd,999,0)
    invoke SendMessage,hEdit,EM_EXLIMITTEXT,0,1000000000
    invoke SendMessage,hEdit,EM_SETOPTIONS,ECOOP_XOR,ECO_SELECTIONBAR

    invoke SendMessage,hEdit,WM_SETFONT,rv(GetStockObject,SYSTEM_FIXED_FONT),TRUE

  ; ------------------------------------------------------------
  ; The return address from the procedure "text_message" is the
  ; reconstructed text that is displayed in the main edit window
  ; ------------------------------------------------------------
    mov pmangled, rv(text_message)

    fn SetWindowText,hEdit,pmangled         ; load the text into the edit window

    free pmangled                           ; free the memory used by the text

    invoke ShowWindow,hWnd, SW_SHOWNORMAL
    invoke UpdateWindow,hWnd

    call MsgLoop
    ret

Main endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

MsgLoop proc

    LOCAL msg:MSG

    push ebx
    lea ebx, msg
    jmp getmsg

  msgloop:
    invoke TranslateMessage, ebx
    invoke DispatchMessage,  ebx
  getmsg:
    invoke GetMessage,ebx,0,0,0
    test eax, eax
    jnz msgloop

    pop ebx
    ret

MsgLoop endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

WndProc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

    LOCAL var    :DWORD
    LOCAL caW    :DWORD
    LOCAL caH    :DWORD
    LOCAL fname  :DWORD
    LOCAL opatn  :DWORD
    LOCAL spatn  :DWORD
    LOCAL rct    :RECT
    LOCAL buffer1[260]:BYTE  ; these are two spare buffers
    LOCAL buffer2[260]:BYTE  ; for text manipulation etc..

    Switch uMsg
      Case WM_COMMAND
      ; -------------------------------------------------------------------
        Switch wParam
          case 50
            invoke SendMessage,hWin,WM_SYSCOMMAND,SC_CLOSE,NULL

        Endsw
      ; -------------------------------------------------------------------

      case WM_CREATE
        mov hRebar,   rv(rebar,hInstance,hWin,rbht)     ; create the rebar control
        mov hToolBar, rv(addband,hInstance,hRebar)      ; add the toolbar band to it

      case WM_SIZE
        push esi
        invoke GetClientRect,hWin,ADDR rct
        mov esi, rct.bottom
        sub esi, rbht

        invoke MoveWindow,hEdit,0,rbht,rct.right,esi,TRUE

        pop esi

      case WM_SETFOCUS
        invoke SetFocus,hEdit

      case WM_CLOSE
      ; -----------------------------
      ; perform any required cleanups
      ; here before closing.
      ; -----------------------------

      case WM_DESTROY
        invoke PostQuitMessage,NULL
        return 0

    Endsw

    invoke DefWindowProc,hWin,uMsg,wParam,lParam

    ret

WndProc endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

TBcreate proc parent:DWORD

  ; -----------------------------
  ; run to toolbar creation macro
  ; -----------------------------
    ToolbarInit tbbW, tbbH, parent

  ; -----------------------------------
  ; Add toolbar buttons and spaces here
  ; arg1 bmpID (zero based)
  ; arg2 cmdID (1st is 50)
  ; -----------------------------------
    TBbutton  0,  50
  ; -----------------------------------

    mov eax, tbhandl

    ret

TBcreate endp

IF 0  ; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

-----------------------------------------------------------------------------------------------
The text in this comment block has been mangled in the following procedure with the MANGLE tool
-----------------------------------------------------------------------------------------------

MANGLE Demo.

This example demonstrates what the "mangle" utility is used for. When you have
an application that contains sensitive text such as your copyright notice, text
comparisons for passwords and similar, in a normal assembled binary you can open
the executable file in a HEX editor and modify the string data.

The MANGLE tool makes this simple approach to hacking your executable file
unviable as it breaks up the text into assembler instructions that must then
be XORRED against a unique pad stored in the DATA section.

The technique can be defeated by a hacker who takes long enough but it is a
paintakingly slow and complicated task that few would have the skill to
perform.

This means that unskilled hackers cannot simply modify your executable file
using a HEX editor and any who have the skills will have to do a lot of
work to successfully modify your file.

To view the results, open this executable file in a HEX editor and have a look
at the DATA section and you will see that this text message cannot be identified.

ENDIF ; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

text_message proc

    LOCAL pMem  :DWORD

  ; --------------------------------------------------------
  ; Return value in EAX is the memory pointer to the result
  ; The data length is returned in ECX. Deallocate memory in
  ; EAX with the Windows API function GlobalFree() or the
  ; MASM32 macro "free".
  ; --------------------------------------------------------

    push ebx
    push esi
    push edi

    mov pMem, alloc(1058)

    mov esi, pMem

    mov DWORD PTR [esi+344], 2062150179
    mov DWORD PTR [esi+48], 2216185543
    mov DWORD PTR [esi+824], 2760766418
    mov DWORD PTR [esi+524], 2771831554
    mov DWORD PTR [esi+88], 2680928952
    mov DWORD PTR [esi+8], 4774212
    mov DWORD PTR [esi+116], 1968801413
    mov DWORD PTR [esi+20], 2223997875
    mov DWORD PTR [esi+748], 807631430
    mov DWORD PTR [esi+888], 1184031418
    mov DWORD PTR [esi+820], 1213496160
    mov DWORD PTR [esi+552], 1307451445
    mov DWORD PTR [esi+188], 3178144621
    mov DWORD PTR [esi+1032], 2945900498
    mov DWORD PTR [esi+728], 4216076425
    mov DWORD PTR [esi+480], 2326644215
    mov DWORD PTR [esi+772], 3371934374
    mov DWORD PTR [esi+312], 1480888560
    mov DWORD PTR [esi+584], 1048121539
    mov DWORD PTR [esi+620], 2832971946
    mov DWORD PTR [esi+896], 2288464847
    mov DWORD PTR [esi+716], 3409706458
    mov DWORD PTR [esi+732], 2667643623
    mov DWORD PTR [esi+368], 2916680747
    mov DWORD PTR [esi+828], 343857244
    mov DWORD PTR [esi+376], 3601413083
    mov DWORD PTR [esi+32], 976649492
    mov DWORD PTR [esi+836], 2719900587
    mov DWORD PTR [esi+1000], 3235948459
    mov DWORD PTR [esi+152], 76395592
    mov DWORD PTR [esi+680], 2024593431
    mov DWORD PTR [esi+904], 1728548834
    mov DWORD PTR [esi+500], 2014652006
    mov DWORD PTR [esi+640], 2252583115
    mov DWORD PTR [esi+580], 3142335133
    mov DWORD PTR [esi+336], 4095375568
    mov DWORD PTR [esi+308], 3371878942
    mov DWORD PTR [esi+508], 68619648
    mov DWORD PTR [esi+1048], 1517812072
    mov DWORD PTR [esi+604], 2737413103
    mov DWORD PTR [esi+788], 3294650710
    mov DWORD PTR [esi+740], 3886764450
    mov DWORD PTR [esi+848], 3241187161
    mov DWORD PTR [esi+100], 2237846705
    mov DWORD PTR [esi+628], 2178460156
    mov DWORD PTR [esi+364], 1515630587
    mov DWORD PTR [esi+284], 670011673
    mov DWORD PTR [esi+488], 4187979701
    mov DWORD PTR [esi+832], 4246715384
    mov DWORD PTR [esi+232], 2474508925
    mov DWORD PTR [esi+168], 1299565936
    mov DWORD PTR [esi+436], 1479122076
    mov DWORD PTR [esi+408], 2873620950
    mov DWORD PTR [esi+632], 2104449848
    mov DWORD PTR [esi+672], 2972667119
    mov DWORD PTR [esi+868], 2925812078
    mov DWORD PTR [esi+760], 2240679454
    mov DWORD PTR [esi+624], 2055701149
    mov DWORD PTR [esi+108], 2041791481
    mov DWORD PTR [esi+688], 2008329516
    mov DWORD PTR [esi+780], 1422566503
    mov DWORD PTR [esi+528], 2797834213
    mov DWORD PTR [esi+252], 3093007023
    mov DWORD PTR [esi+192], 170010280
    mov DWORD PTR [esi+856], 2028819585
    mov DWORD PTR [esi+72], 1896313721
    mov DWORD PTR [esi+208], 1769512643
    mov DWORD PTR [esi+960], 668005795
    mov DWORD PTR [esi+532], 2632599885
    mov DWORD PTR [esi+1044], 32213403
    mov DWORD PTR [esi+548], 1416930278
    mov DWORD PTR [esi+920], 533918401
    mov DWORD PTR [esi+676], 3945528680
    mov DWORD PTR [esi+572], 2550767916
    mov DWORD PTR [esi+812], 2886395526
    mov DWORD PTR [esi+652], 2941366152
    mov DWORD PTR [esi+196], 815583178
    mov DWORD PTR [esi+700], 505390249
    mov DWORD PTR [esi+504], 1621212274
    mov DWORD PTR [esi+388], 1276255793
    mov DWORD PTR [esi+268], 3793943373
    mov DWORD PTR [esi+356], 19469302
    mov DWORD PTR [esi+256], 2390111497
    mov DWORD PTR [esi+692], 2190605218
    mov DWORD PTR [esi+840], 3159435790
    mov DWORD PTR [esi+492], 3049936577
    mov DWORD PTR [esi+212], 1810491640
    mov DWORD PTR [esi+316], 106184820
    mov DWORD PTR [esi+124], 4276726732
    mov DWORD PTR [esi+288], 3866868525
    mov DWORD PTR [esi+164], 2333435844
    mov DWORD PTR [esi+12], 1808383597
    mov DWORD PTR [esi+708], 4069547646
    mov DWORD PTR [esi+764], 51245119
    mov DWORD PTR [esi+440], 4288022561
    mov DWORD PTR [esi+4], 2186401649
    mov DWORD PTR [esi+940], 2394368860
    mov DWORD PTR [esi+420], 1091692
    mov DWORD PTR [esi+908], 2011570407
    mov DWORD PTR [esi+52], 2667224234
    mov DWORD PTR [esi+392], 1840397996
    mov DWORD PTR [esi+456], 1242411050
    mov DWORD PTR [esi+948], 69564727
    mov DWORD PTR [esi+464], 1634235103
    mov DWORD PTR [esi+1040], 2924802170
    mov DWORD PTR [esi+720], 2861762284
    mov DWORD PTR [esi+520], 3572017053
    mov DWORD PTR [esi+320], 1712978798
    mov DWORD PTR [esi+1016], 59184094
    mov DWORD PTR [esi+404], 4178972121
    mov DWORD PTR [esi+468], 3601736254
    mov DWORD PTR [esi+248], 3461278963
    mov DWORD PTR [esi+44], 1126950482
    mov DWORD PTR [esi+180], 3032057990
    mov DWORD PTR [esi+608], 3820705740
    mov DWORD PTR [esi+372], 1452087473
    mov DWORD PTR [esi+220], 3709426441
    mov DWORD PTR [esi+28], 23737684
    mov DWORD PTR [esi+976], 3780047244
    mov DWORD PTR [esi+24], 2763143126
    mov DWORD PTR [esi+796], 185230548
    mov DWORD PTR [esi+400], 4213659262
    mov DWORD PTR [esi+1024], 4057758869
    mov DWORD PTR [esi+792], 2665803364
    mov DWORD PTR [esi+444], 3751921424
    mov DWORD PTR [esi+980], 3749733568
    mov DWORD PTR [esi+752], 3910533451
    mov DWORD PTR [esi+516], 861826674
    mov DWORD PTR [esi+636], 1106653081
    mov DWORD PTR [esi+564], 1151906999
    mov DWORD PTR [esi+64], 3977265408
    mov DWORD PTR [esi+768], 2755201244
    mov DWORD PTR [esi+1012], 305373939
    mov DWORD PTR [esi+864], 1224576787
    mov DWORD PTR [esi+916], 407050214
    mov DWORD PTR [esi+184], 1308937749
    mov DWORD PTR [esi+148], 4035988673
    mov DWORD PTR [esi+1052], 995217070
    mov DWORD PTR [esi+800], 1740734306
    mov DWORD PTR [esi+0], 3849147294
    mov DWORD PTR [esi+932], 657819994
    mov DWORD PTR [esi+448], 3157127731
    mov DWORD PTR [esi+460], 1381622139
    mov DWORD PTR [esi+776], 2760291203
    mov DWORD PTR [esi+332], 66709784
    mov DWORD PTR [esi+952], 717683251
    mov DWORD PTR [esi+36], 1216227133
    mov DWORD PTR [esi+1004], 329810021
    mov DWORD PTR [esi+756], 717603258
    mov DWORD PTR [esi+816], 213788319
    mov DWORD PTR [esi+68], 1086610410
    mov DWORD PTR [esi+80], 3633428083
    mov DWORD PTR [esi+304], 2905692479
    mov DWORD PTR [esi+472], 2652578157
    mov DWORD PTR [esi+92], 2963757550
    mov DWORD PTR [esi+96], 262437606
    mov DWORD PTR [esi+596], 433356218
    mov DWORD PTR [esi+496], 3529996013
    mov DWORD PTR [esi+384], 3558563280
    mov DWORD PTR [esi+280], 3453256735
    mov DWORD PTR [esi+172], 2311718184
    mov DWORD PTR [esi+808], 4102626560
    mov DWORD PTR [esi+656], 2216693389
    mov DWORD PTR [esi+860], 3543684043
    mov DWORD PTR [esi+120], 3950190190
    mov DWORD PTR [esi+132], 3302342279
    mov BYTE PTR [esi+1056], 71
    mov DWORD PTR [esi+432], 3560496764
    mov DWORD PTR [esi+112], 816199768
    mov DWORD PTR [esi+380], 3260138283
    mov DWORD PTR [esi+292], 3727702296
    mov DWORD PTR [esi+540], 4065956634
    mov DWORD PTR [esi+360], 1792041373
    mov DWORD PTR [esi+156], 2655387630
    mov DWORD PTR [esi+964], 3486023483
    mov DWORD PTR [esi+140], 4290765194
    mov DWORD PTR [esi+592], 270601685
    mov DWORD PTR [esi+936], 3206209631
    mov DWORD PTR [esi+300], 584592058
    mov DWORD PTR [esi+240], 1314942924
    mov DWORD PTR [esi+616], 4055002774
    mov DWORD PTR [esi+1008], 950361442
    mov DWORD PTR [esi+484], 145366590
    mov DWORD PTR [esi+412], 680079332
    mov DWORD PTR [esi+40], 3194132888
    mov DWORD PTR [esi+744], 186590926
    mov DWORD PTR [esi+968], 3157190851
    mov DWORD PTR [esi+340], 4118044993
    mov DWORD PTR [esi+972], 2263431188
    mov DWORD PTR [esi+996], 355012332
    mov DWORD PTR [esi+588], 2737911808
    mov DWORD PTR [esi+912], 652091186
    mov DWORD PTR [esi+900], 3217463451
    mov DWORD PTR [esi+612], 1277704756
    mov DWORD PTR [esi+712], 1599678755
    mov DWORD PTR [esi+576], 2272486532
    mov DWORD PTR [esi+416], 491024920
    mov DWORD PTR [esi+600], 82866090
    mov DWORD PTR [esi+76], 3881131632
    mov DWORD PTR [esi+784], 2183881064
    mov DWORD PTR [esi+928], 1765240764
    mov DWORD PTR [esi+104], 763760267
    mov DWORD PTR [esi+56], 1469745303
    mov DWORD PTR [esi+16], 2991964361
    mov DWORD PTR [esi+136], 525557190
    mov DWORD PTR [esi+276], 817321130
    mov DWORD PTR [esi+724], 1305840112
    mov DWORD PTR [esi+892], 2510584836
    mov DWORD PTR [esi+348], 1733310943
    mov DWORD PTR [esi+644], 3574544377
    mov DWORD PTR [esi+352], 4014245851
    mov DWORD PTR [esi+512], 535087401
    mov DWORD PTR [esi+668], 3883839745
    mov DWORD PTR [esi+876], 74836662
    mov DWORD PTR [esi+872], 2909146377
    mov DWORD PTR [esi+648], 2506756714
    mov DWORD PTR [esi+204], 3022160921
    mov DWORD PTR [esi+260], 295149582
    mov DWORD PTR [esi+244], 1982623225
    mov DWORD PTR [esi+128], 1637281887
    mov DWORD PTR [esi+476], 2068471159
    mov DWORD PTR [esi+944], 3423906953
    mov DWORD PTR [esi+176], 2930553273
    mov DWORD PTR [esi+560], 3956305275
    mov DWORD PTR [esi+144], 3281249144
    mov DWORD PTR [esi+984], 2052414920
    mov DWORD PTR [esi+884], 3919976639
    mov DWORD PTR [esi+736], 4124298509
    mov DWORD PTR [esi+296], 4192582457
    mov DWORD PTR [esi+1028], 3361434749
    mov DWORD PTR [esi+696], 543411864
    mov DWORD PTR [esi+160], 1307400219
    mov DWORD PTR [esi+536], 3916609211
    mov DWORD PTR [esi+544], 1124881364
    mov DWORD PTR [esi+556], 817689674
    mov DWORD PTR [esi+956], 3626295431
    mov DWORD PTR [esi+992], 3382729226
    mov DWORD PTR [esi+396], 2436585958
    mov DWORD PTR [esi+60], 2885792803
    mov DWORD PTR [esi+704], 1755493128
    mov DWORD PTR [esi+272], 3631048326
    mov DWORD PTR [esi+880], 3101432692
    mov DWORD PTR [esi+844], 3990082524
    mov DWORD PTR [esi+852], 546818723
    mov DWORD PTR [esi+804], 627228597
    mov DWORD PTR [esi+1020], 2694314877
    mov DWORD PTR [esi+988], 730292101
    mov DWORD PTR [esi+568], 3502744033
    mov DWORD PTR [esi+428], 137938860
    mov DWORD PTR [esi+224], 1230089937
    mov DWORD PTR [esi+200], 3447186801
    mov DWORD PTR [esi+924], 1684136407
    mov DWORD PTR [esi+664], 1363011083
    mov DWORD PTR [esi+660], 293457895
    mov DWORD PTR [esi+324], 2890968083
    mov DWORD PTR [esi+228], 20687047
    mov DWORD PTR [esi+328], 1885411735
    mov DWORD PTR [esi+236], 2434872579
    mov DWORD PTR [esi+452], 2313880920
    mov DWORD PTR [esi+84], 401119206
    mov DWORD PTR [esi+684], 2783669090
    mov DWORD PTR [esi+1036], 2351104276
    mov DWORD PTR [esi+264], 2981260879
    mov DWORD PTR [esi+424], 3376419102
    mov DWORD PTR [esi+216], 3001759511

    mov edi, 1057
    or ebx, -1

  @@:
    add ebx, 1
    movzx edx, BYTE PTR [mangled_pad+ebx]
    xor [esi+ebx], dl
    sub edi, 1
    jnz @B

  ; -------------------------------------------------
  ; EAX is the memory pointer, ECX is the BYTE length
  ; -------------------------------------------------
    mov eax, pMem
    mov ecx, 1057

    pop edi
    pop esi
    pop ebx

    ret

  .data
  mangled_pad \
    db 211,18,35,162,61,146,113,198,33,180,39,46,96,180,196,97
    db 157,168,60,193,147,230,247,229,187,71,222,193,116,81,15,108
    db 123,19,69,78,79,70,10,45,235,185,21,214,51,146,11,55
    db 175,43,56,166,199,253,148,249,251,237,184,119,86,192,104,192
    db 105,53,105,205,131,40,228,53,10,22,99,81,22,49,39,201
    db 83,225,249,189,136,183,145,120,205,154,163,254,152,60,170,186
    db 135,20,132,110,193,164,14,236,232,111,242,68,150,45,147,13
    db 48,89,210,16,230,233,55,1,15,119,29,152,236,216,140,144
    db 44,153,226,8,241,219,245,176,163,37,39,63,249,148,220,151
    db 88,130,224,227,184,35,229,130,104,215,226,116,151,141,44,249
    db 115,44,205,35,171,19,124,232,21,225,85,57,77,125,190,132
    db 179,210,195,195,246,233,203,221,102,161,106,61,77,197,1,207
    db 136,86,67,121,185,184,243,66,21,150,87,172,119,224,2,199
    db 170,243,17,5,153,154,197,75,126,89,203,211,41,53,118,175
    db 188,207,61,105,166,219,72,100,16,96,18,246,103,21,67,248
    db 162,14,18,55,217,20,67,3,211,143,47,160,143,229,43,221
    db 103,56,124,250,102,197,183,116,55,11,209,196,57,154,64,142
    db 227,70,11,177,198,49,151,89,113,164,181,237,81,212,183,7
    db 72,223,18,146,119,75,16,191,87,223,197,148,213,78,177,68
    db 70,121,69,197,123,234,137,188,130,249,42,63,84,36,53,114
    db 15,213,20,108,30,166,4,196,242,57,44,49,86,174,181,70
    db 240,12,117,155,45,65,25,148,72,143,154,90,171,81,57,20
    db 251,244,45,130,134,127,76,33,252,17,160,24,148,206,53,50
    db 11,112,182,141,217,121,238,61,178,93,206,246,82,172,36,176
    db 240,56,99,177,82,107,102,45,206,82,215,77,128,48,87,244
    db 115,92,82,149,175,100,119,155,186,156,103,202,151,15,224,92
    db 56,16,54,120,13,195,99,32,107,97,96,189,196,162,24,124
    db 25,166,76,244,245,242,93,55,1,105,229,140,117,170,195,179
    db 86,128,13,213,54,118,159,251,95,211,121,35,20,143,42,114
    db 171,26,9,21,30,79,219,165,25,1,111,246,18,51,71,113
    db 149,160,141,210,113,76,248,77,241,95,254,158,160,63,164,198
    db 153,86,6,242,19,72,124,9,7,217,129,16,225,105,55,119
    db 93,166,150,122,22,78,55,93,189,211,128,177,34,143,119,241
    db 164,175,176,195,46,61,131,243,213,152,127,227,23,153,13,154
    db 177,115,120,38,133,203,26,61,68,85,139,109,41,149,210,16
    db 25,8,240,143,210,210,205,37,149,196,163,240,78,216,41,249
    db 164,12,18,228,246,95,62,155,180,120,22,30,116,89,90,198
    db 166,45,77,127,212,26,244,124,196,0,133,99,135,187,75,214
    db 184,119,210,151,20,83,91,108,247,99,184,129,203,209,181,220
    db 252,233,238,20,155,197,161,161,75,55,0,10,185,78,152,37
    db 235,211,44,235,137,91,102,182,11,102,15,241,168,219,48,220
    db 230,46,84,236,134,187,93,119,110,145,29,38,110,196,18,131
    db 207,36,78,199,13,221,95,131,114,248,223,19,11,7,135,133
    db 88,194,185,125,210,158,227,228,247,188,14,14,164,174,18,20
    db 92,219,203,27,94,51,245,147,77,90,121,43,178,156,79,235
    db 153,104,224,193,153,229,185,40,237,24,36,154,132,105,100,237
    db 126,237,176,148,204,63,196,147,238,85,118,102,54,22,90,16
    db 38,110,114,128,220,184,229,83,113,123,252,165,90,136,104,96
    db 169,124,88,198,202,199,219,174,234,223,227,169,109,209,185,61
    db 6,6,11,227,118,41,37,156,68,139,128,247,160,11,120,43
    db 3,17,165,71,212,209,27,5,119,117,230,212,238,135,124,201
    db 191,82,214,105,64,8,63,33,190,159,254,132,43,177,18,120
    db 216,211,126,139,206,67,106,205,46,78,62,156,189,243,191,130
    db 45,183,95,167,174,192,224,79,243,63,205,12,164,115,75,166
    db 112,236,152,59,29,63,17,194,101,116,70,192,217,142,28,98
    db 13,59,165,215,202,106,134,143,211,142,247,104,9,118,169,159
    db 155,92,71,254,242,253,177,159,150,231,98,71,149,69,149,2
    db 94,107,173,10,198,120,51,125,175,210,166,119,190,146,65,1
    db 196,10,84,28,46,232,87,75,58,192,124,214,48,78,151,231
    db 231,140,117,236,127,60,125,36,86,158,175,94,232,146,4,185
    db 205,145,240,79,90,9,173,239,162,200,66,211,123,83,228,140
    db 237,133,110,149,168,1,160,155,137,9,20,90,246,58,228,95
    db 99,53,206,233,141,96,77,53,210,200,149,224,18,233,196,127
    db 66,46,192,93,211,214,91,115,170,51,243,107,20,136,183,212
    db 240,4,168,209,16,9,40,187,179,184,243,143,119,96,77,226
    db 21,132,116,204,254,169,130,101,13,151,3,51,200,167,52,95
    db 105
  .code

text_message endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
















end start
