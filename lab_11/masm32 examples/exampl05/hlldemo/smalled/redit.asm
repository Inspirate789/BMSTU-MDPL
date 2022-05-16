comment * ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    This example demonstrates two seperate things, a miniature working
    application that uses no resources and can therefore be placed in
    a library for inclusion in another larger application.

    It shows how to creat a menu using API functions only and it shows
    how to manually code hot keys for menus directly in the message loop.

    If you placed this test piece in a library, you would include the
    library in your own application and write a PROTOTYPE for the
    entry point procedure "ReEntryPoint".

    ReEntryPoint PROTO STDCALL

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл *

      .486                      ; create 32 bit code
      .model flat, stdcall      ; 32 bit memory model
      option casemap :none      ; case sensitive

;     include files
;     ~~~~~~~~~~~~~
      include \masm32\include\windows.inc
      include \masm32\include\masm32.inc
      include \masm32\include\gdi32.inc
      include \masm32\include\user32.inc
      include \masm32\include\kernel32.inc
      include \masm32\include\Comctl32.inc
      include \masm32\include\comdlg32.inc
      include \masm32\include\shell32.inc
      include \masm32\include\oleaut32.inc
      include \masm32\include\msvcrt.inc
      include \masm32\macros\macros.asm

;     libraries
;     ~~~~~~~~~
      includelib \masm32\lib\masm32.lib
      includelib \masm32\lib\gdi32.lib
      includelib \masm32\lib\user32.lib
      includelib \masm32\lib\kernel32.lib
      includelib \masm32\lib\Comctl32.lib
      includelib \masm32\lib\comdlg32.lib
      includelib \masm32\lib\shell32.lib
      includelib \masm32\lib\oleaut32.lib
      includelib \masm32\lib\msvcrt.lib

      WndProc          PROTO :DWORD,:DWORD,:DWORD,:DWORD
      TopXY            PROTO :DWORD,:DWORD
      RegisterWinClass PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD
      MsgLoop          PROTO
      Main             PROTO
      Select_All       PROTO :DWORD
      ReEntryPoint     PROTO

      AutoScale MACRO swidth, sheight
        invoke GetPercent,sWid,swidth
        mov Wwd, eax
        invoke GetPercent,sHgt,sheight
        mov Wht, eax

        invoke TopXY,Wwd,sWid
        mov Wtx, eax

        invoke TopXY,Wht,sHgt
        mov Wty, eax
      ENDM

      DisplayWindow MACRO handl, ShowStyle
        invoke ShowWindow,handl, ShowStyle
        invoke UpdateWindow,handl
      ENDM

    .data?
      hInstance dd ?
      CommandLine dd ?
      hIcon dd ?
      hCursor dd ?
      sWid dd ?
      sHgt dd ?
      hWnd dd ?
      hEdit dd ?
      hMenu dd ?
      hfMnu dd ?
      heMnu dd ?

.code

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

ReEntryPoint proc    ;; <<<< This is the entry point

    ; ------------------
    ; set global values
    ; ------------------
      mov hInstance,   FUNC(GetModuleHandle, NULL)
      mov CommandLine, FUNC(GetCommandLine)
      mov hIcon,       FUNC(LoadIcon,NULL,IDI_APPLICATION)
      mov hCursor,     FUNC(LoadCursor,NULL,IDC_ARROW)
      mov sWid,        FUNC(GetSystemMetrics,SM_CXSCREEN)
      mov sHgt,        FUNC(GetSystemMetrics,SM_CYSCREEN)

      call Main

      invoke ExitProcess,eax

ReEntryPoint endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

Main proc

    LOCAL Wwd:DWORD,Wht:DWORD,Wtx:DWORD,Wty:DWORD

    STRING szClassName,"riched_Class"
    invoke RegisterWinClass,ADDR WndProc,ADDR szClassName,
                       hIcon,hCursor,NULL

    AutoScale 75, 70

    invoke CreateWindowEx,WS_EX_LEFT or WS_EX_ACCEPTFILES,
                          ADDR szClassName,
                          chr$("Untitled"),
                          WS_OVERLAPPEDWINDOW,
                          Wtx,Wty,Wwd,Wht,
                          NULL,NULL,
                          hInstance,NULL
    mov hWnd,eax

    mov hMenu, FUNC(CreateMenu)     ; main menu
    mov hfMnu, FUNC(CreateMenu)     ; file menu
    mov heMnu, FUNC(CreateMenu)     ; edit menu

  ; file menu

    invoke AppendMenu,hMenu,MF_POPUP,hfMnu,chr$("&File")
    invoke AppendMenu,hfMnu,MF_STRING,1000,chr$("&New",9,"Ctrl+N")
    invoke AppendMenu,hfMnu,MF_SEPARATOR,0,0
    invoke AppendMenu,hfMnu,MF_STRING,1001,chr$("&Open",9,"Ctrl+O")
    invoke AppendMenu,hfMnu,MF_SEPARATOR,0,0
    invoke AppendMenu,hfMnu,MF_STRING,1002,chr$("&Save",9,"Ctrl+S")
    invoke AppendMenu,hfMnu,MF_STRING,1003,chr$("Save &As")
    invoke AppendMenu,hfMnu,MF_SEPARATOR,0,0
    invoke AppendMenu,hfMnu,MF_STRING,1010,chr$("&Exit",9,"Alt+F4")

  ; edit menu

    invoke AppendMenu,hMenu,MF_POPUP,heMnu,chr$("&Edit")
    invoke AppendMenu,heMnu,MF_STRING,1100,chr$("&Undo",9,"Ctrl+Z")
    invoke AppendMenu,heMnu,MF_SEPARATOR,0,0
    invoke AppendMenu,heMnu,MF_STRING,1101,chr$("&Cut",9,"Ctrl+X")
    invoke AppendMenu,heMnu,MF_STRING,1102,chr$("C&opy",9,"Ctrl+C")
    invoke AppendMenu,heMnu,MF_STRING,1103,chr$("&Paste",9,"Ctrl+V")
    invoke AppendMenu,heMnu,MF_SEPARATOR,0,0
    invoke AppendMenu,heMnu,MF_STRING,1104,chr$("&Clear",9,"Del")
    invoke AppendMenu,heMnu,MF_SEPARATOR,0,0
    invoke AppendMenu,heMnu,MF_STRING,1105,chr$("&Copy All",9,"Ctrl+A")

    invoke SetMenu,hWnd,hMenu
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

    LOCAL rval  :DWORD
    LOCAL msg   :MSG

    StartLoop:
      invoke GetMessage,ADDR msg,NULL,0,0
      cmp eax, 0
      je ExitLoop

      Switch msg.message
      ; ------------------------------------
      ; menu hot key processing CTRL+Hotkey
      ; ------------------------------------
        Case WM_KEYDOWN
          mov rval, FUNC(GetAsyncKeyState,VK_CONTROL)
          cmp WORD PTR rval[2], 1111111111111111b
          jne @F
            Switch msg.wParam
              Case VK_A
                invoke Select_All,hEdit
                invoke SendMessage,hEdit,WM_COPY,0,0
                jmp StartLoop
              Case VK_C
                invoke SendMessage,hEdit,WM_COPY,0,0
                jmp StartLoop
              Case VK_N
                invoke SendMessage,hWnd,WM_COMMAND,1000,0
                jmp StartLoop
              Case VK_O
                invoke SendMessage,hWnd,WM_COMMAND,1001,0
                jmp StartLoop
              Case VK_S
                invoke SendMessage,hWnd,WM_COMMAND,1002,0
                jmp StartLoop
              Case VK_V
                invoke SendMessage,hEdit,EM_PASTESPECIAL,CF_TEXT,0
                jmp StartLoop
              Case VK_X
                invoke SendMessage,hEdit,WM_CUT,0,0
                jmp StartLoop
              Case VK_Z
                invoke SendMessage,hEdit,EM_UNDO,0,0
                jmp StartLoop
            Endsw
          @@:
      Endsw
      invoke TranslateMessage, ADDR msg
      invoke DispatchMessage,  ADDR msg
      jmp StartLoop
    ExitLoop:

    mov eax, msg.wParam
    ret

MsgLoop endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

WndProc proc hWin   :DWORD,
             uMsg   :DWORD,
             wParam :DWORD,
             lParam :DWORD

    LOCAL fname  :DWORD
    LOCAL patn   :DWORD
    LOCAL Rct    :RECT
    LOCAL buffer[MAX_PATH]:BYTE

    Switch uMsg
      Case WM_COMMAND
      ;======== menu commands ========
        Switch wParam
          Case 1000
            invoke SetWindowText,hEdit,0
            fn SetWindowText,hWin,"Untitled"

          Case 1001
            sas patn, "All files",0,"*.*",0
            mov fname, OpenFileDlg(hWin,hInstance,"Open File",patn)
            cmp BYTE PTR [eax], 0
            jne @F
            return 0
            @@:
            invoke Read_File_In,hEdit,fname
            invoke SetWindowText,hWin,fname

          Case 1002
            invoke GetWindowText,hWin,ADDR buffer,MAX_PATH
            fn szCmp,ADDR buffer,"Untitled"
            test eax, eax
            jnz Save_As
            invoke Write_To_Disk,hEdit,ADDR buffer

          Case 1003
            Save_As:
            sas patn, "All files",0,"*.*",0
            mov fname, SaveFileDlg(hWin,hInstance,"Save File As ...",patn)
            cmp BYTE PTR [eax], 0
            jne @F
            return 0
            @@:
            invoke Write_To_Disk,hEdit,fname
            invoke SetWindowText,hWin,fname

          Case 1010
            invoke SendMessage,hWin,WM_SYSCOMMAND,SC_CLOSE,NULL

        ;====== edit menu commands ======
          Case 1100
            invoke SendMessage,hEdit,EM_UNDO,0,0
          Case 1101
            invoke SendMessage,hEdit,WM_CUT,0,0
          Case 1102
            invoke SendMessage,hEdit,WM_COPY,0,0
          Case 1103
            invoke SendMessage,hEdit,EM_PASTESPECIAL,CF_TEXT,0
          Case 1104
            invoke SendMessage,hEdit,WM_CLEAR,0,0
          Case 1105
            invoke Select_All,hEdit
            invoke SendMessage,hEdit,WM_COPY,0,0

        Endsw
    ;====== end menu commands ======

      Case WM_SETFOCUS
        invoke SetFocus,hEdit

      Case WM_DROPFILES
        invoke Read_File_In,hEdit,DropFileName(wParam)

      Case WM_CREATE
        fn LoadLibrary,"RICHED32.DLL"
        mov hEdit, FUNC(RichEd1,0,0,100,100,hWin,hInstance,555,0)
        invoke SendMessage,hEdit,WM_SETFONT,FUNC(GetStockObject,ANSI_FIXED_FONT),0
        invoke SendMessage,hEdit,EM_EXLIMITTEXT,0,500000000
        invoke SendMessage,hEdit,EM_SETOPTIONS,ECOOP_XOR,ECO_SELECTIONBAR

      Case WM_SIZE
        invoke GetClientRect,hWin,ADDR Rct
        invoke MoveWindow,hEdit,0,0,Rct.right,Rct.bottom,TRUE

      Case WM_CLOSE

      Case WM_DESTROY
        invoke PostQuitMessage,NULL
        return 0

    Endsw

    invoke DefWindowProc,hWin,uMsg,wParam,lParam

    ret

WndProc endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

TopXY proc wDim:DWORD, sDim:DWORD

    shr sDim, 1      ; divide screen dimension by 2
    shr wDim, 1      ; divide window dimension by 2
    mov eax, wDim    ; copy window dimension into eax
    sub sDim, eax    ; sub half win dimension from half screen dimension

    return sDim

TopXY endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

Select_All Proc Edit:DWORD

    LOCAL tl :DWORD
    LOCAL Cr :CHARRANGE

    mov Cr.cpMin,0
    invoke GetWindowTextLength,Edit
    inc eax
    mov Cr.cpMax, eax
    invoke SendMessage,Edit,EM_EXSETSEL,0,ADDR Cr

    ret

Select_All endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end ReEntryPoint
