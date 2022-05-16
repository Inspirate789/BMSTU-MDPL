; #########################################################################

      .386
      .model flat, stdcall      ; 32 bit memory model
      option casemap :none      ; case sensitive

      include Richedit.inc      ; local includes for this file

    ; ---------------------------------------
    ; Select rich edit version here, leave
    ; uncomment for richedit version 1 or
    ; comment out for richedit version 2
    ; ---------------------------------------
      riched1 equ <anytext>

    ; -----------------------------------
    ; Select right click menu popup here
    ; -----------------------------------
      menu_popup equ 0  ; 0 = File, 1 = Edit etc ....

    ; --------------------------
    ; Select either system font
    ; --------------------------
      edit_font equ <16>
      ; edit_font equ <11>

; #########################################################################

.code

start:
      invoke GetModuleHandle, 0
      mov hInstance, eax

      invoke GetCommandLine
      mov CommandLine, eax

      invoke InitCommonControls

    ; --------------------------
    ; preset GLOBAL scope flags 
    ; --------------------------
      mov CaseFlag, 1
      mov WholeWord, 0
      mov CtrlFlag, 0

      invoke WinMain,hInstance,0,CommandLine,10
      invoke ExitProcess,eax

; #########################################################################

WinMain proc hInst     :DWORD,
             hPrevInst :DWORD,
             CmdLine   :DWORD,
             CmdShow   :DWORD

      ;====================
      ; Put LOCALs on stack
      ;====================

      LOCAL Wwd  :DWORD
      LOCAL Wht  :DWORD
      LOCAL Wtx  :DWORD
      LOCAL Wty  :DWORD
      LOCAL lpArg:DWORD
      LOCAL sWid :DWORD
      LOCAL sHgt :DWORD
      LOCAL wc   :WNDCLASSEX
      LOCAL msg  :MSG

    ; --------------------------------------------------
    ; Fill WNDCLASSEX structure with required variables
    ; --------------------------------------------------
      invoke LoadIcon,hInst,500     ; icon ID
      mov hIcon, eax

      szText szClassName,"Rich_Edit_Class"

      mov wc.cbSize,         sizeof WNDCLASSEX
      mov wc.style,          2000h
      mov wc.lpfnWndProc,    offset WndProc
      mov wc.cbClsExtra,     0
      mov wc.cbWndExtra,     0
      m2m wc.hInstance,      hInst
      mov wc.hbrBackground,  0
      m2m wc.lpszMenuName,   0
      mov wc.lpszClassName,  offset szClassName
      m2m wc.hIcon,          hIcon
        invoke LoadCursor,0,32512
      mov wc.hCursor,        eax
      m2m wc.hIconSm,        hIcon

      invoke RegisterClassEx, ADDR wc

    ; -------------------------------------------------
    ; Size & centre window at 75% x 75% of screen size
    ; -------------------------------------------------
      invoke GetSystemMetrics,0
      mov sWid, eax
      push sWid

      shr eax, 2
      sub sWid, eax
      m2m Wwd, sWid

      invoke GetSystemMetrics,1
      mov sHgt, eax
      push sHgt

      shr eax, 2
      sub sHgt, eax
      m2m Wht, sHgt

      pop sHgt
      invoke TopXY,Wht,sHgt
      mov Wty, eax

      pop sWid
      invoke TopXY,Wwd,sWid
      mov Wtx, eax
    ; ----------------------------------

      invoke CreateWindowEx,000 or 10h,
                            ADDR szClassName,
                            ADDR Untitled,
                            WS_OVERLAPPEDWINDOW,
                            Wtx,Wty,Wwd,Wht,
                            0,0,
                            hInst,0
      mov   hWnd,eax

    ; ------------------------------
    ; get any command line filename
    ; ------------------------------
      invoke PathGetArgs,CommandLine
      mov lpArg, eax

      mov esi, eax
      lodsb
      cmp al, 0
      je noArgs       ; jump if no arg
      cmp al, 34
      jne @F          ; jump if no quote

      invoke PathUnquoteSpaces,lpArg
      mov lpArg, eax

      @@:

      invoke exist,lpArg
      .if eax == 1
        invoke StreamFileIn,hRichEd,lpArg
        invoke SetWindowText,hWnd,lpArg
        invoke SendMessage,hRichEd,0B9h,0,0
      .else
        szText cantfind,"Sorry, cannot find that file."
        invoke MessageBox,hWnd,lpArg,ADDR cantfind,0h
      .endif

      noArgs:
    ; ------------------------------

      invoke LoadMenu,hInst,600     ; menu ID
      mov hMnu, eax
      invoke SetMenu,hWnd,eax

      invoke ShowWindow,hWnd,1
      invoke UpdateWindow,hWnd

  ; -----------------------------------
  ; Loop until PostQuitMessage is sent
  ; -----------------------------------

    StartLoop:
      invoke GetMessage,ADDR msg,0,0,0
      cmp eax, 0
      je ExitLoop

    ; ------------------------------------------------
    ; process keystrokes directly in the message loop
    ; ------------------------------------------------
      .if msg.message == 100h
        .if msg.wParam == 1Bh
          invoke SendMessage,hWnd,112h,0F060h,0
        .elseif msg.wParam == 11h
          mov CtrlFlag, 1                   ; flag set
        .endif
      .endif

      .if msg.message == 101h
        .if msg.wParam == 11h
          mov CtrlFlag, 0                   ; flag clear
        .elseif msg.wParam == 54h           ; Ctrl + T
          .if CtrlFlag == 1
            invoke SendMessage,hWnd,111h,1105,0
          .endif
        .elseif msg.wParam == 4Eh           ; Ctrl + N
          .if CtrlFlag == 1
            invoke SendMessage,hWnd,111h,1000,0
          .endif
        .elseif msg.wParam == 57h           ; Ctrl + W
          .if CtrlFlag == 1
            invoke SendMessage,hWnd,111h,1001,0
            jmp StartLoop
          .endif
        .elseif msg.wParam == 4Fh           ; Ctrl + O
          .if CtrlFlag == 1
            invoke SendMessage,hWnd,111h,1002,0
          .endif
        .elseif msg.wParam == 53h           ; Ctrl + S
          .if CtrlFlag == 1
            invoke SendMessage,hWnd,111h,1003,0
          .endif
        .elseif msg.wParam == 42h           ; Ctrl + B
          .if CtrlFlag == 1
            invoke SendMessage,hWnd,111h,1004,0
          .endif
        .endif
      .endif
    ; ------------------------------------------------

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

    LOCAL var    :DWORD
    LOCAL caW    :DWORD
    LOCAL caH    :DWORD
    LOCAL hTbar  :DWORD
    LOCAL hSbar  :DWORD
    LOCAL tl     :DWORD
    LOCAL hDC    :DWORD
    LOCAL lpTxt  :DWORD
    LOCAL nmh    :NMHDR    
    LOCAL Rct    :RECT
    LOCAL Ps     :PAINTSTRUCT
    LOCAL tbab   :TBADDBITMAP
    LOCAL tbb    :TBBUTTON
    LOCAL buffer1[128]:BYTE
    LOCAL FileBuffer[260]:BYTE

    .if uMsg == 111h
    ;======== toolbar commands ========

        .if wParam == 50
            jmp NewFile

        .elseif wParam == 51
            jmp FileOpen

        .elseif wParam == 52
            jmp FileSave

        .elseif wParam == 53
            jmp mnu_Cut

        .elseif wParam == 54
            jmp mnu_Copy

        .elseif wParam == 55
            jmp mnu_Paste

        .elseif wParam == 56
            jmp mnu_Undo

        .elseif wParam == 57
            jmp mnu_FindText

        .elseif wParam == 58
            jmp new_instance

        .elseif wParam == 59
            jmp QuitApp

    ;======== menu commands ========

        .elseif wParam == 1000  ; **** New ****
            NewFile:
            invoke Confirmation,hRichEd

              .if eax == 6
                  jmp FileSave
              .elseif eax == 7
                  jmp @F
              .elseif eax == 2
                  return 0
              .endif

              @@:
                invoke SendMessage,hWin,0Ch,0,ADDR Untitled
                invoke SendMessage,hRichEd,0Ch,0,0
                invoke SendMessage,hRichEd,0B9h,0,0
              ; -------------------------
              ; Reset status bar message
              ; -------------------------
                szText nStr,0
                invoke SendMessage,hStatus,WM_USER+1,3,ADDR nStr

        .elseif wParam == 1001  ; **** New Instance ****
            new_instance:

            invoke GetModuleFileName,0,ADDR buffer1,128
            invoke WinExec,ADDR buffer1,5

        .elseif wParam == 1002  ; **** Open ****
            FileOpen:

            invoke Confirmation,hRichEd
              .if eax == 6
                  jmp FileSave
              .elseif eax == 2
                  return 0
              .endif

           jmp @F
             szTitleO   db "Open A File",0
             szFilterO  db "All files",0,"*.*",0,
                           "Text files",0,"*.TEXT",0,0
           @@:

           mov szFileName[0],0
           invoke GetFileName,hWin,ADDR szTitleO,ADDR szFilterO
    
           cmp szFileName[0],0  ;<< zero if cancel pressed in dlgbox
           je @F
             invoke StreamFileIn,hRichEd,ADDR szFileName
             invoke SetWindowText,hWin,ADDR szFileName
           @@:

        .elseif wParam == 1003  ; **** Save ****

            FileSave:

            invoke SendMessage,hWin,0Eh,0,0
            mov tl, eax
            inc tl              ; 1 extra for zero terminator

            invoke GetWindowText,hWin,ADDR buffer1,tl
            invoke lstrcmp,ADDR buffer1,ADDR Untitled

            cmp eax, 0          ; eax is zero is strings are equal
              jne @F
              jmp FileSaveAs
            @@:

            invoke StreamFileOut,hRichEd,ADDR buffer1
            invoke SendMessage,hRichEd,0B9h,0,0

        .elseif wParam == 1004  ; **** Save As ****

            FileSaveAs:

           jmp @F
             szTitleS   db "Save file as",0
             szFilterS  db "All files",0,"*.*",0,
                           "Text files",0,"*.TEXT",0,0
           @@:

           mov szFileName[0],0
           invoke SaveFileName,hWin,ADDR szTitleS,ADDR szFilterS
    
           cmp szFileName[0],0  ;<< zero if cancel pressed in dlgbox
           je @F
            invoke StreamFileOut,hRichEd,ADDR szFileName
            invoke SendMessage,hRichEd,0B9h,0,0
            invoke SendMessage,hWin,0Ch,0,ADDR szFileName
           @@:

        .elseif wParam == 1005
            invoke MergeFile,hRichEd

        .elseif wParam == 1010  ; **** Exit ****
            QuitApp:
            invoke SendMessage,hWin,112h,0F060h,0

        ; ----------
        ; Edit Menu 
        ; ----------
        .elseif wParam == 1100
            mnu_Undo:
            invoke SendMessage,hRichEd,0C7h,0,0
        .elseif wParam == 1101
            mnu_Cut:
            invoke SendMessage,hRichEd,300h,0,0
        .elseif wParam == 1102
            mnu_Copy:
            invoke SendMessage,hRichEd,301h,0,0
        .elseif wParam == 1103
            mnu_Paste:
            invoke SendMessage,hRichEd,WM_USER+64,1,0
        .elseif wParam == 1104
            invoke SendMessage,hRichEd,303h,0,0
        .elseif wParam == 1105
            invoke SendMessage,hRichEd,WM_USER+77,0004h,010
        .elseif wParam == 1106
            mnu_FindText:
            invoke CallSearchDlg
        .elseif wParam == 1107
            mnu_FindNext:
            invoke TextFind,ADDR SearchText,TextLen
        .elseif wParam == 1108
            invoke Select_All,hRichEd

        .elseif wParam == 1900  ; **** About ****
            szText RichEd,"MASM RichEdit"
            szText AboutMsg,"Rich Text Editor",13,10,\
            "Copyright © MASM32 2001"
            invoke ShellAbout,hWin,ADDR RichEd,ADDR AboutMsg,hIcon

        .endif

    ;====== end menu commands ======

    .elseif uMsg == 4Eh
      ; ---------------------------------------------------
      ; The toolbar has the 0100h style enabled
      ; so that a 4Eh message is sent when the mouse
      ; is over the toolbar buttons.
      ; ---------------------------------------------------
        mov eax, lParam
        mov eax, [eax]      ; get 1st member of NMHDR structure "hwndFrom"

        .if eax == hToolTips
            .if wParam == 50
                mov lpTxt, offset tbn_new
            .elseif wParam == 51
                mov lpTxt, offset tbn_open
            .elseif wParam == 52
                mov lpTxt, offset tbn_save
            .elseif wParam == 53
                mov lpTxt, offset tbn_cut
            .elseif wParam == 54
                mov lpTxt, offset tbn_copy
            .elseif wParam == 55
                mov lpTxt, offset tbn_paste
            .elseif wParam == 56
                mov lpTxt, offset tbn_undo
            .elseif wParam == 57
                mov lpTxt, offset tbn_find
            .elseif wParam == 58
                mov lpTxt, offset tbn_instance
            .elseif wParam == 59
                mov lpTxt, offset tbn_quit
            .endif
        .else
            mov lpTxt, offset tbn_else
        .endif

        invoke SendMessage,hStatus,WM_USER+1,2,lpTxt

        @@:

    .elseif uMsg == 233h
        invoke DragQueryFile,wParam,0,ADDR FileBuffer,LENGTHOF FileBuffer

        invoke Confirmation,hRichEd
          .if eax == 6
              jmp FileSave
          .elseif eax == 2
              return 0
          .endif

        invoke StreamFileIn,hRichEd,ADDR FileBuffer
        invoke SendMessage,hRichEd,0B9h,0,0
        invoke SendMessage,hWin,0Ch,0,ADDR FileBuffer
        return 0

    .elseif uMsg == 15h
        invoke Do_ToolBar,hWin

    .elseif uMsg == 1h
        invoke Do_ToolBar,hWin
        invoke Do_Status,hWin

      ; --------------------------------
      ; conditional assembly directives
      ; --------------------------------
        IFDEF riched1
          szText ReDLL,"RICHED32.DLL"
        ELSE
          szText ReDLL,"RICHED20.DLL"
        ENDIF
      ; --------------------------------

        invoke LoadLibrary,ADDR ReDLL

        invoke EditControl,hWin,0,40,250,250,800
        mov hRichEd, eax

    .elseif uMsg == 7h
        invoke SetFocus,hRichEd

    .elseif uMsg == 5h
        invoke SendMessage,hToolBar,WM_USER+33,0,0
        invoke MoveWindow,hStatus,0,0,0,0,1

      ; -------------------------------------
      ; get toolbar & statusbar heights, get
      ; window client area size and position
      ; edit window in remaining client area
      ; -------------------------------------
        invoke GetClientRect,hToolBar,ADDR Rct
        mov eax, Rct.bottom
        mov hTbar, eax

        invoke GetClientRect,hStatus,ADDR Rct
        mov eax, Rct.bottom
        mov hSbar, eax

        invoke GetClientRect,hWin,ADDR Rct

        mov eax, Rct.bottom
        sub eax, hTbar
        sub eax, hSbar

      ; -----------------------------
      ; drop edit window by 2 pixels
      ; to display toolbar properly
      ; -----------------------------
        add hTbar, 2
        sub eax, 2

        invoke MoveWindow,hRichEd,0,hTbar,Rct.right,eax,1

    .elseif uMsg == 10h
        invoke Confirmation,hRichEd
        .if eax == 6
            jmp FileSave
        .elseif eax == 2
            return 0
        .endif

    .elseif uMsg == 2h
        invoke PostQuitMessage,0
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

EditControl proc hParent:DWORD, x:DWORD, y:DWORD, wd:DWORD, ht:DWORD, ID:DWORD

    LOCAL hEdit:DWORD
    LOCAL hFont:DWORD

  ; --------------------------------
  ; conditional assembly directives
  ; --------------------------------
    IFDEF riched1
      szText EditMl,"RICHEDIT"
    ELSE
      szText EditMl,"RichEdit20a"
    ENDIF
  ; --------------------------------

    invoke CreateWindowEx,0,ADDR EditMl,0,
                          100 or 00004000h or \
                          400 or 40 or \
                          4h or 200000h or \
                          40h or 100h or \
                          100000h or 80h,
                          x,y,wd,ht,hParent,ID,hInstance,0
    mov hEdit, eax

    invoke SetWindowLong,hEdit,-4,hEditProc
    mov lpfnhEditProc, eax

    invoke GetStockObject,edit_font
    invoke SendMessage,hEdit,30h,eax,0

    invoke SendMessage,hEdit,WM_USER+53,0,100000000
    invoke SendMessage,hEdit,WM_USER+77,0004h,010

    mov eax, hEdit
    ret

EditControl endp

; #########################################################################

hEditProc proc hCtl   :DWORD,
               uMsg   :DWORD,
               wParam :DWORD,
               lParam :DWORD

    LOCAL Pt    :POINT
    LOCAL hSM   :DWORD

    .if uMsg == 101h
      ; --------------------------
      ; process the F1 to F3 keys
      ; --------------------------
        .if wParam == 70h
          ; -------------------------
          ; impliment help code here
          ; -------------------------
        .elseif wParam == 71h
            invoke CallSearchDlg
            return 0
        .elseif wParam == 72h
            invoke TextFind,ADDR SearchText, TextLen
        .endif

    .elseif uMsg == 204h
        invoke GetCursorPos,ADDR Pt
        invoke GetSubMenu,hMnu,menu_popup
        mov hSM, eax
        invoke TrackPopupMenu,hSM,0h or 0h,
                              Pt.x,Pt.y,0, hWnd,0

    .endif

    invoke CallWindowProc,lpfnhEditProc,hCtl,uMsg,wParam,lParam

    ret

hEditProc endp

; #########################################################################

end start
