; #########################################################################
;
;     QikPad is a functional text editor written around a normal edit
;     control. It has a size limit of 32k which is dictated by the
;     operating system for a control of this type. It has normal file
;     save confirmation, will load files from the command line and has
;     a working toolbar. It will open long file name files in the normal
;     manner.
;
; #########################################################################

      .386
      .model flat, stdcall  ; 32 bit memory model
      option casemap :none  ; case sensitive

      include qikpad.inc   ; local includes for this file

; #########################################################################

.code

start:
      invoke GetModuleHandle, NULL
      mov hInstance, eax

      invoke GetCommandLine
      mov CommandLine, eax

      invoke InitCommonControls

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

      LOCAL wc           :WNDCLASSEX
      LOCAL msg          :MSG
      LOCAL Wwd          :DWORD
      LOCAL Wht          :DWORD
      LOCAL Wtx          :DWORD
      LOCAL Wty          :DWORD
      LOCAL clBuffer[128]:BYTE

      ;==================================================
      ; Fill WNDCLASSEX structure with required variables
      ;==================================================

      invoke LoadIcon,hInst,500    ; icon ID
      mov hIcon, eax

      szText szClassName,"QikPad_Class"

      mov wc.cbSize,         sizeof WNDCLASSEX
      mov wc.style,          CS_HREDRAW or CS_VREDRAW \
                             or CS_BYTEALIGNWINDOW
      mov wc.lpfnWndProc,    offset WndProc
      mov wc.cbClsExtra,     NULL
      mov wc.cbWndExtra,     NULL
      m2m wc.hInstance,      hInst
        invoke GetStockObject,HOLLOW_BRUSH
      mov wc.hbrBackground,  eax
      mov wc.lpszMenuName,   NULL
      mov wc.lpszClassName,  offset szClassName
      m2m wc.hIcon,          hIcon
        invoke LoadCursor,NULL,IDC_ARROW
      mov wc.hCursor,        eax
      m2m wc.hIconSm,        hIcon

      invoke RegisterClassEx, ADDR wc

      ;================================
      ; Centre window at following size
      ;================================

      mov Wwd, 500
      mov Wht, 350

      invoke GetSystemMetrics,SM_CXSCREEN
      invoke TopXY,Wwd,eax
      mov Wtx, eax

      invoke GetSystemMetrics,SM_CYSCREEN
      invoke TopXY,Wht,eax
      mov Wty, eax

      invoke CreateWindowEx,WS_EX_LEFT,
                            ADDR szClassName,
                            ADDR szUntitled,
                            WS_OVERLAPPEDWINDOW,
                            Wtx,Wty,Wwd,Wht,
                            NULL,NULL,
                            hInst,NULL
      mov   hWnd,eax

      invoke LoadMenu,hInst,600  ; menu ID
      invoke SetMenu,hWnd,eax

      invoke GetAppPath,ADDR PthBuffer

      invoke GetCL,1, ADDR clBuffer
    ; --------------------------------------
    ; return value 1 is successful operation
    ; --------------------------------------
      .if eax == 1
        invoke Read_File_In,ADDR clBuffer,hEdit
      .endif

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

    LOCAL var    :DWORD
    LOCAL caW    :DWORD
    LOCAL caH    :DWORD
    LOCAL tbh    :DWORD
    LOCAL sbh    :DWORD
    LOCAL wWid   :DWORD
    LOCAL wHgt   :DWORD
    LOCAL hDC    :DWORD
    LOCAL Rct    :RECT
    LOCAL tbab   :TBADDBITMAP
    LOCAL tbb    :TBBUTTON
    LOCAL buffer1[128]:BYTE  ; these are two spare buffers
    LOCAL buffer2[128]:BYTE  ; for text manipulation etc..

    .if uMsg == WM_COMMAND
    ;======== toolbar commands ========

        .if wParam == 50
            jmp New_File

        .elseif wParam == 51
            jmp Open_File

        .elseif wParam == 52
            invoke SaveFile

        .elseif wParam == 53
            jmp Edit_Cut

        .elseif wParam == 54
            jmp Edit_Copy

        .elseif wParam == 55
            jmp Edit_Paste

        .elseif wParam == 56
            jmp Edit_Undo

        .endif

    ;======== menu commands ========
        .if wParam == 1000
          New_File:
          invoke SendMessage,hEdit,EM_GETMODIFY,0,0
            .if eax == TRUE
              invoke Confirmation,hWin
                .if eax == IDYES
                  invoke SaveFile
                .elseif eax == IDCANCEL
                  mov eax, 0
                  ret
                .endif
            .endif

            invoke SetWindowText,hEdit,NULL
            invoke SetWindowText,hWin,ADDR szUntitled
            invoke SendMessage,hStatus,SB_SETTEXT,2,NULL

        .elseif wParam == 1001
          Open_File:
          invoke SendMessage,hEdit,EM_GETMODIFY,0,0
            .if eax == TRUE
              invoke Confirmation,hWin
                .if eax == IDYES
                  invoke SaveFile
                .elseif eax == IDCANCEL
                  mov eax, 0
                  ret
                .endif
            .endif

           jmp @F
             szTitleO   db "Open A File",0
             szFilterO  db "All files",0,"*.*",0,
                           "Text files",0,"*.TEXT",0,0
           @@:
    
           invoke FillBuffer,ADDR szFileName,length szFileName,0
           invoke GetFileName,hWin,ADDR szTitleO,ADDR szFilterO
    
           cmp szFileName[0],0   ;<< zero if cancel pressed in dlgbox
           je @F
             invoke Read_File_In,ADDR szFileName,hEdit
             invoke SetWindowText,hWin,ADDR szFileName
           @@:

        .elseif wParam == 1002
            invoke SaveFile

        .elseif wParam == 1003
            invoke SaveFileAs
        .endif

        .if wParam == 1010
            invoke SendMessage,hWin,WM_SYSCOMMAND,SC_CLOSE,NULL
        .elseif wParam == 1900
          invoke About
        .endif

        .if wParam == 1100
          Edit_Undo:
          invoke SendMessage,hEdit,WM_UNDO,0,0
        .elseif wParam == 1101
          Edit_Cut:
          invoke SendMessage,hEdit,WM_CUT,0,0
        .elseif wParam == 1102
          Edit_Copy:
          invoke SendMessage,hEdit,WM_COPY,0,0
        .elseif wParam == 1103
          Edit_Paste:
          invoke SendMessage,hEdit,WM_PASTE,0,0
        .elseif wParam == 1104
          invoke SendMessage,hEdit,WM_CLEAR,0,0
        .elseif wParam == 1105
          invoke WordWrap

        .endif

    ;====== end menu commands ======

    .elseif uMsg == WM_SETFOCUS
        invoke SetFocus,hEdit

    .elseif uMsg == WM_SYSCOLORCHANGE
        invoke Do_ToolBar,hWin

    .elseif uMsg == WM_CREATE
        invoke Do_ToolBar,hWin
        invoke Do_Status,hWin

        mov WrapFlag, 0

        invoke EditML,NULL,0,30,300,200,hWin,700,WrapFlag
        mov hEdit, eax

        invoke SetWindowLong,hEdit,GWL_WNDPROC,EditProc
        mov lpEditProc, eax

        szText OFFWrap," Wrap OFF"
        invoke SendMessage,hStatus,SB_SETTEXT,1,ADDR OFFWrap

    .elseif uMsg == WM_SIZE
        invoke SendMessage,hToolBar,TB_AUTOSIZE,0,0
        invoke MoveWindow,hStatus,0,0,0,0,TRUE

        invoke GetClientRect,hToolBar,ADDR Rct
        push Rct.bottom
        pop tbh     ; toolbar height

        invoke GetClientRect,hStatus,ADDR Rct
        push Rct.bottom
        pop sbh     ; status bar height

        invoke GetClientRect,hWin,ADDR Rct
        push Rct.right
        pop wWid
        push Rct.bottom
        pop wHgt

        mov eax,  tbh
        sub wHgt, eax
        mov eax,  sbh
        sub wHgt, eax

        add tbh, 2
        sub wHgt, 2

        invoke MoveWindow,hEdit,0,tbh,wWid,wHgt,TRUE

    .elseif uMsg == WM_CLOSE
          invoke SendMessage,hEdit,EM_GETMODIFY,0,0
            .if eax == TRUE
              invoke Confirmation,hWin
                .if eax == IDYES
                  invoke SaveFile
                .elseif eax == IDCANCEL
                  mov eax, 0
                  ret
                .endif
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

; ########################################################################

EditML proc szMsg:DWORD,tx:DWORD,ty:DWORD,wd:DWORD,ht:DWORD,
            hParent:DWORD,ID:DWORD,Wrap:DWORD

    LOCAL hCtl   :DWORD
    LOCAL hFnt   :DWORD
    LOCAL eStyle :DWORD

    szText CtlStyle,"EDIT"

    mov eStyle, WS_VISIBLE or WS_CHILDWINDOW or \
                WS_VSCROLL or ES_NOHIDESEL or \
                ES_AUTOVSCROLL or ES_MULTILINE

    .if Wrap == 0
      or eStyle,WS_HSCROLL or ES_AUTOHSCROLL
    .endif

    invoke CreateWindowEx,WS_EX_CLIENTEDGE,ADDR CtlStyle,szMsg,
                          eStyle,tx,ty,wd,ht,hParent,ID,hInstance,NULL
    mov hCtl, eax

    invoke GetStockObject,SYSTEM_FIXED_FONT
    mov hFnt, eax
    invoke SendMessage,hCtl,WM_SETFONT,hFnt,TRUE

    mov eax, hCtl

    ret

EditML endp

; ########################################################################

Read_File_In proc lpszDiskFile:DWORD, hEditControl:DWORD

    LOCAL hFile :DWORD
    LOCAL hMem$ :DWORD
    LOCAL ln    :DWORD
    LOCAL br    :DWORD
    LOCAL txtBuffer[64]:BYTE

    invoke CreateFile,lpszDiskFile,GENERIC_READ,FILE_SHARE_READ,
                       NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
    mov hFile, eax

    invoke GetFileSize,hFile,NULL
    mov ln, eax

    .if ln > 32767
      invoke CloseHandle,hFile
      szText tooBig,"Sorry, file is too large for QIKPAD"
      invoke MessageBox,hWnd,ADDR tooBig,ADDR szDisplayName,MB_OK
      xor eax, eax
      ret
    .endif

    invoke SysAllocStringByteLen,0,ln
    mov hMem$, eax

    invoke ReadFile,hFile,hMem$,ln,ADDR br,NULL
    invoke SetWindowText,hEditControl,hMem$

    invoke SysFreeString,hMem$
    invoke CloseHandle,hFile

    invoke lnstr,ADDR szOpenedAt
    inc eax
    invoke MemCopy,ADDR szOpenedAt,ADDR txtBuffer,eax

    invoke dwtoa,ln,ADDR sizeBuffer
    invoke lstrcat,ADDR txtBuffer,ADDR sizeBuffer
    invoke lstrcat,ADDR txtBuffer,ADDR bytes

    invoke SendMessage,hStatus,SB_SETTEXT,2,ADDR txtBuffer

    ret

Read_File_In endp

; ########################################################################

Confirmation proc hMain:DWORD

    szText ConfirmMsg,"File not saved, save it now ?"
    invoke MessageBox,hMain,ADDR ConfirmMsg,ADDR szDisplayName,
                            MB_YESNOCANCEL or MB_ICONQUESTION

    ret

Confirmation endp

; ######################################################################## 

Write_2_Disk proc lpszFile_Name:DWORD

    LOCAL ln    :DWORD
    LOCAL hMem$ :DWORD
    LOCAL hFile :DWORD
    LOCAL bw    :DWORD
    LOCAL txtBuffer[64]

  ; -----------------------------------------
  ; truncate file to zero length if it exists
  ; -----------------------------------------
    invoke CreateFile,lpszFile_Name,    ; pointer to name of the file
            GENERIC_WRITE,              ; access (read-write) mode
            NULL,                       ; share mode
            NULL,                       ; pointer to security attributes
            CREATE_ALWAYS,              ; how to create
            FILE_ATTRIBUTE_NORMAL,      ; file attributes
            NULL

    mov hFile,eax

    invoke GetWindowTextLength,hEdit
    mov ln, eax
    inc ln

    invoke SysAllocStringByteLen,0,ln
    mov hMem$, eax

    invoke GetWindowText,hEdit,hMem$,ln

    invoke WriteFile,hFile,hMem$,ln,ADDR bw,NULL

    invoke SysFreeString,hMem$
    invoke CloseHandle,hFile

    invoke SendMessage,hEdit,EM_SETMODIFY,FALSE,0

    invoke lnstr,ADDR szSavedAt
    inc eax
    invoke MemCopy,ADDR szSavedAt,ADDR txtBuffer,eax

    invoke dwtoa,ln,ADDR sizeBuffer
    invoke lstrcat,ADDR txtBuffer,ADDR sizeBuffer
    invoke lstrcat,ADDR txtBuffer,ADDR bytes

    invoke SendMessage,hStatus,SB_SETTEXT,2,ADDR txtBuffer

    ret

Write_2_Disk endp

; ########################################################################

SaveFileAs proc

    jmp @F
      szTitleS   db "Save file as",0
      szFilterS  db "All files",0,"*.*",0,
                    "Text files",0,"*.TEXT",0,0
    @@:

    invoke FillBuffer,ADDR szFileName,length szFileName,0
    invoke SaveFileName,hWnd,ADDR szTitleS,ADDR szFilterS

    cmp szFileName[0],0   ;<< zero if cancel pressed in dlgbox
    je @F
       invoke Write_2_Disk,ADDR szFileName
       invoke SetWindowText,hWnd,ADDR szFileName
    @@:

    ret

SaveFileAs endp

; #########################################################################

SaveFile proc

    LOCAL buffer[128]:BYTE

  ; ---------------------------
  ; test if title is "Untitled"
  ; ---------------------------
    invoke GetWindowText,hWnd,ADDR buffer,128

    invoke lstrcmp,ADDR buffer,ADDR szUntitled
      .if eax == 0
        invoke SaveFileAs
        ret
      .endif

    invoke Write_2_Disk,ADDR buffer

    ret

SaveFile endp

; #########################################################################

WordWrap proc

    LOCAL mFlag:DWORD
    LOCAL ln   :DWORD
    LOCAL hMem$:DWORD

    invoke SendMessage,hEdit,EM_GETMODIFY,0,0
    mov mFlag, eax

    invoke GetWindowTextLength,hEdit
    mov ln, eax
    inc ln

    invoke SysAllocStringByteLen,0,ln
    mov hMem$, eax
    invoke GetWindowText,hEdit,hMem$,ln

    invoke DestroyWindow,hEdit

    .if WrapFlag == 0
      mov WrapFlag, 1
        szText WrapON," Wrap ON"
        invoke SendMessage,hStatus,SB_SETTEXT,1,ADDR WrapON
    .elseif WrapFlag == 1
      mov WrapFlag, 0
        szText WrapOFF," Wrap OFF"
        invoke SendMessage,hStatus,SB_SETTEXT,1,ADDR WrapOFF
    .endif

    invoke EditML,NULL,0,30,300,200,hWnd,700,WrapFlag
    mov hEdit, eax

    invoke SetWindowLong,hEdit,GWL_WNDPROC,EditProc
    mov lpEditProc, eax

    invoke SendMessage,hWnd,WM_SIZE,0,0

    invoke SetWindowText,hEdit,hMem$
    invoke SysFreeString,hMem$

    invoke SendMessage,hEdit,EM_SETMODIFY,mFlag,0

    invoke SetFocus,hEdit

    ret

WordWrap endp

; #########################################################################

EditProc proc hCtl   :DWORD,
              uMsg   :DWORD,
              wParam :DWORD,
              lParam :DWORD

    .if uMsg == WM_KEYUP
      .if wParam == VK_F1
        invoke About
      .elseif wParam == VK_F9
        invoke WordWrap
      .elseif wParam == VK_ESCAPE
        invoke SendMessage,hWnd,WM_SYSCOMMAND,SC_CLOSE,NULL
        return 0
      .endif
    .endif

    invoke CallWindowProc,lpEditProc,hCtl,uMsg,wParam,lParam

    ret

EditProc endp

; #########################################################################

About proc

    szText AboutMsg,"QikPad Text Editor",13,10,\
    "Copyright © MASM32 1999"
    invoke ShellAbout,hWnd,ADDR szDisplayName,ADDR AboutMsg,hIcon

    ret

About endp

; #########################################################################

end start
