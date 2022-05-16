; #########################################################################

      .386
      .model flat, stdcall
      option casemap :none   ; case sensitive

; #########################################################################

      include \masm32\include\windows.inc
      include \masm32\include\user32.inc
      include \masm32\include\kernel32.inc

      includelib \masm32\lib\user32.lib
      includelib \masm32\lib\kernel32.lib

; #########################################################################

      ;=============
      ; Local macros
      ;=============

      szText MACRO Name, Text:VARARG
        LOCAL lbl
          jmp lbl
            Name db Text,0
          lbl:
        ENDM

      m2m MACRO M1, M2
        push M2
        pop  M1
      ENDM

      return MACRO arg
        mov eax, arg
        ret
      ENDM

        ;=================
        ; Local prototypes
        ;=================
        WinMain PROTO :DWORD,:DWORD,:DWORD,:DWORD
        WndProc PROTO :DWORD,:DWORD,:DWORD,:DWORD
        TopXY PROTO   :DWORD,:DWORD
        ListBox PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
        ListBoxProc PROTO :DWORD,:DWORD,:DWORD,:DWORD

    .data
        szDisplayName db "List Box Demo",0
        CommandLine   dd 0
        hWnd          dd 0
        hInstance     dd 0
        hList1        dd 0
        hList2        dd 0
        lpLstBox1     dd 0

    .code

start:
        invoke GetModuleHandle, NULL
        mov hInstance, eax

        invoke GetCommandLine
        mov CommandLine, eax

        invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT
        invoke ExitProcess,eax

; #########################################################################

WinMain proc hInst     :DWORD,
             hPrevInst :DWORD,
             CmdLine   :DWORD,
             CmdShow   :DWORD

        ;====================
        ; Put LOCALs on stack
        ;====================

        LOCAL wc   :WNDCLASSEX
        LOCAL msg  :MSG

        LOCAL Wwd  :DWORD
        LOCAL Wht  :DWORD
        LOCAL Wtx  :DWORD
        LOCAL Wty  :DWORD

        ;==================================================
        ; Fill WNDCLASSEX structure with required variables
        ;==================================================

        mov wc.cbSize,         sizeof WNDCLASSEX
        mov wc.style,          CS_HREDRAW or CS_VREDRAW \
                               or CS_BYTEALIGNWINDOW
        mov wc.lpfnWndProc,    offset WndProc
        mov wc.cbClsExtra,     NULL
        mov wc.cbWndExtra,     NULL
        m2m wc.hInstance,      hInst   ;<< NOTE: macro not mnemonic
        mov wc.hbrBackground,  COLOR_BTNFACE+1
        mov wc.lpszMenuName,   NULL
        mov wc.lpszClassName,  offset szClassName
          invoke LoadIcon,hInst,500    ; icon ID
        mov wc.hIcon,          eax
          invoke LoadCursor,NULL,IDC_ARROW
        mov wc.hCursor,        eax
        mov wc.hIconSm,        0

        invoke RegisterClassEx, ADDR wc

        ;================================
        ; Centre window at following size
        ;================================

        mov Wwd, 470
        mov Wht, 285

        invoke GetSystemMetrics,SM_CXSCREEN
        invoke TopXY,Wwd,eax
        mov Wtx, eax

        invoke GetSystemMetrics,SM_CYSCREEN
        invoke TopXY,Wht,eax
        mov Wty, eax

        szText szClassName,"Template_Class"

        invoke CreateWindowEx,WS_EX_OVERLAPPEDWINDOW,
                              ADDR szClassName,
                              ADDR szDisplayName,
                              WS_OVERLAPPEDWINDOW,
                              Wtx,Wty,Wwd,Wht,
                              NULL,NULL,
                              hInst,NULL
        mov   hWnd,eax

        invoke LoadMenu,hInst,600  ; menu ID
        invoke SetMenu,hWnd,eax

        invoke ShowWindow,hWnd,SW_SHOWNORMAL
        invoke UpdateWindow,hWnd

      ;===================================
      ; Loop until PostQuitMessage is sent
      ;===================================

    StartLoop:
      invoke GetMessage,ADDR msg,NULL,0,0
      cmp eax, 0
      je ExitLoop
      invoke TranslateMessage, ADDR msg
      invoke DispatchMessage,  ADDR msg
      jmp StartLoop
    ExitLoop:

      return msg.wParam

WinMain endp

; #########################################################################

WndProc proc hWin   :DWORD,
             uMsg   :DWORD,
             wParam :DWORD,
             lParam :DWORD

    .if uMsg == WM_COMMAND
    ;======== menu commands ========
        .if wParam == 1000
            invoke SendMessage,hWin,WM_SYSCOMMAND,SC_CLOSE,NULL
        .elseif wParam == 1900
            szText TheMsg,"Assembler, Pure & Simple"
            invoke MessageBox,hWin,ADDR TheMsg,ADDR szDisplayName,MB_OK
        .endif
    ;====== end menu commands ======

    .elseif uMsg == WM_CREATE
       invoke ListBox,20,20,200,200,hWin,500
       mov hList1, eax

       szText Patn,"*.*"
       invoke SendMessage,hList1,LB_DIR,DDL_ARCHIVE or DDL_DRIVES or \
                                        DDL_DIRECTORY,ADDR Patn
       invoke SetWindowLong,hList1,GWL_WNDPROC,ListBoxProc
       mov lpLstBox1, eax

       invoke ListBox,240,20,200,200,hWin,501
       mov hList2, eax
       invoke SetWindowLong,hList2,GWL_WNDPROC,ListBoxProc
       mov lpLstBox1, eax

         jmp @@@1
           lItem1 db "Roses are red,",0
           lItem2 db "Violets are blue.",0
           lItem3 db "If sugar is sweet,",0
           lItem4 db "What happened to you ?",0
         @@@1:

       invoke SendMessage,hList2,LB_ADDSTRING,0,ADDR lItem1
       invoke SendMessage,hList2,LB_ADDSTRING,0,ADDR lItem2
       invoke SendMessage,hList2,LB_ADDSTRING,0,ADDR lItem3
       invoke SendMessage,hList2,LB_ADDSTRING,0,ADDR lItem4

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

; ########################################################################

ListBox proc a:DWORD,b:DWORD,wd:DWORD,ht:DWORD,hParent:DWORD,ID:DWORD

    szText lstBox,"LISTBOX"

    invoke CreateWindowEx,WS_EX_CLIENTEDGE,ADDR lstBox,0,
              WS_VSCROLL or WS_VISIBLE or \
              WS_BORDER or WS_CHILD or \
              LBS_HASSTRINGS or LBS_NOINTEGRALHEIGHT or \
              LBS_DISABLENOSCROLL,
              a,b,wd,ht,hParent,ID,hInstance,NULL

    ret

ListBox endp

; #########################################################################

ListBoxProc proc hCtl   :DWORD,
                 uMsg   :DWORD,
                 wParam :DWORD,
                 lParam :DWORD

    LOCAL IndexItem  :DWORD
    LOCAL Buffer[32] :BYTE

    .if uMsg == WM_LBUTTONDBLCLK
      jmp DoIt
    .elseif uMsg == WM_CHAR
      .if wParam == 13
        jmp DoIt
      .endif
    .endif
    jmp EndDo

    DoIt:

        invoke SendMessage,hCtl,LB_GETCURSEL,0,0
          mov IndexItem, eax
        invoke SendMessage,hCtl,LB_GETTEXT,IndexItem,ADDR Buffer

        mov eax, hList1
        .if hCtl == eax
          szText CurSel1,"You selected from hList1"
          invoke MessageBox,hWnd,ADDR Buffer,ADDR CurSel1,MB_OK
        .else
          szText CurSel2,"You selected from hList2"
          invoke MessageBox,hWnd,ADDR Buffer,ADDR CurSel2,MB_OK
        .endif

    EndDo:

    invoke CallWindowProc,lpLstBox1,hCtl,uMsg,wParam,lParam

    ret

ListBoxProc endp

; #########################################################################

end start




