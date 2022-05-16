; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

      .486                      ; create 32 bit code
      .model flat, stdcall      ; 32 bit memory model
      option casemap :none      ; case sensitive

      include    pbddemo.inc
      include    \masm32\include\dialogs.inc

      FUNC MACRO parameters:VARARG
        invoke parameters
        EXITM <eax>
      ENDM

      MakeIP MACRO arg1,arg2,arg3,arg4
          mov ah, arg1
          mov al, arg2
          rol eax, 16
          mov ah, arg3
          mov al, arg4
        EXITM <eax>
      ENDM

      dlgproc   PROTO :DWORD,:DWORD,:DWORD,:DWORD
      Butn1Proc PROTO :DWORD,:DWORD,:DWORD,:DWORD

    .data?
        hInstance dd ?
        hIcon  dd ?
        hButn1 dd ?
        hButn2 dd ?
        hButn3 dd ?
        hButn4 dd ?
        hButn5 dd ?
        hStat1 dd ?
        lpButn1Proc dd ?

    .code

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

start:

      mov hInstance, FUNC(GetModuleHandle,NULL)
      mov hIcon,     FUNC(LoadIcon,hInstance,500)

      call main

      invoke ExitProcess,eax

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

main proc

    LOCAL icce:INITCOMMONCONTROLSEX
    
    mov icce.dwSize, SIZEOF INITCOMMONCONTROLSEX
    mov icce.dwICC,  ICC_WIN95_CLASSES
    invoke InitCommonControlsEx,ADDR icce

    Dialog "Prebuilt Library Dialog Demo", \; caption
           "MS Sans Serif",8, \             ; font,pointsize
            WS_OVERLAPPED or \              ; styles for
            WS_SYSMENU or DS_CENTER, \      ; dialog window
            6, \                            ; number of controls
            50,50,180,105, \                ; x y co-ordinates
            1024                            ; memory buffer size

    DlgButton "Cancel"  ,WS_TABSTOP,126,10,40,13,IDCANCEL
    DlgButton "GetText" ,WS_TABSTOP,10,10,50,13,100
    DlgButton "AboutBox",WS_TABSTOP,10,25,50,13,101
    DlgButton "GetFile" ,WS_TABSTOP,10,40,50,13,102
    DlgButton "GetIP"   ,WS_TABSTOP,10,55,50,13,103
    DlgStatic 0         ,SS_LEFT or WS_TABSTOP,10,75,160,9,104

    CallModalDialog hInstance,0,dlgproc,NULL

    ret

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

dlgproc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

    LOCAL hDC   :DWORD
    LOCAL hMem$ :DWORD
    LOCAL var   :DWORD
    LOCAL ps    :PAINTSTRUCT
    LOCAL rct   :RECT
    LOCAL buffer[32]:BYTE

    .if uMsg == WM_INITDIALOG
      invoke SendMessage,hWin,WM_SETICON,1,hIcon

      ; -----------------------
      ; get the button handles
      ; -----------------------
        invoke GetDlgItem,hWin,100
        mov hButn1, eax
        invoke GetDlgItem,hWin,101
        mov hButn2, eax
        invoke GetDlgItem,hWin,102
        mov hButn3, eax
        invoke GetDlgItem,hWin,103
        mov hButn4, eax
        invoke GetDlgItem,hWin,IDCANCEL
        mov hButn5, eax
        invoke GetDlgItem,hWin,104
        mov hStat1, eax

      ; ------------------------------------------------------
      ; set all of the buttons to the same subclass procedure
      ; ------------------------------------------------------
        invoke SetWindowLong,hButn1,GWL_WNDPROC,Butn1Proc
        invoke SetWindowLong,hButn2,GWL_WNDPROC,Butn1Proc
        invoke SetWindowLong,hButn3,GWL_WNDPROC,Butn1Proc
        invoke SetWindowLong,hButn4,GWL_WNDPROC,Butn1Proc
        invoke SetWindowLong,hButn5,GWL_WNDPROC,Butn1Proc
        mov lpButn1Proc, eax

    .elseif uMsg == WM_COMMAND
      .if wParam == IDCANCEL
        jmp quit_dialog
      .elseif wParam == 100
          stralloc 256
          mov hMem$, eax
          invoke GetTextInput,hWin,hInstance,hIcon,
                              SADD("Find Text"),SADD("Press F3 for next"),hMem$
          mov eax, hMem$
          cmp BYTE PTR [eax], 0
          je @F
          invoke MessageBox,hWin,hMem$,
                            SADD("You typed ...."),MB_OK
        @@:

      .elseif wParam == 101
          invoke AboutBox,hWin,hInstance,hIcon,
                 SADD("Prebuilt Library Dialog Demo"),
                 SADD("MASM32 Dialogs With No Dialog Editor"),
                 SADD("Copyright й 1998-2003",13,10,"MASM32",13,10,"All Right Reserved")

      .elseif wParam == 102
          stralloc 260
          mov hMem$, eax
          invoke GetFile,hWin,hInstance,hIcon,SADD("Please Select File"),
                         SADD("c:\windows\system"),SADD("*.*"),hMem$
          mov eax, hMem$
          cmp BYTE PTR [eax], 0
          je @F
          invoke MessageBox,hWin,hMem$,
                            SADD("Selected File"),MB_OK
        @@:
          strfree hMem$

      .elseif wParam == 103
          invoke GetIP,hWin,hInstance,hIcon,
                       SADD("Internet Connection"),
                       SADD("Change IP if required"),
                       MakeIP(121,32,254,201)
          .if eax != -1
            mov var, eax
            invoke IPtoString,var,ADDR buffer
            invoke MessageBox,hWin,ADDR buffer,
                              SADD("Returned IP"),MB_OK
          .else
            invoke MessageBox,hWin,SADD("Cancel was pressed"),SADD("Message"),MB_OK
          .endif

      .endif

    .elseif uMsg == WM_PAINT
      invoke BeginPaint,hWin,ADDR ps
      mov hDC, eax
      invoke GetClientRect,hWin,ADDR rct
      invoke DrawEdge,hDC,ADDR rct,EDGE_ETCHED,BF_RECT
      invoke EndPaint,hWin,ADDR ps

    .elseif uMsg == WM_MOUSEMOVE
      invoke SendMessage,hStat1,WM_SETTEXT,0,SADD(0)

    .elseif uMsg == WM_CLOSE
      quit_dialog:
      invoke EndDialog,hWin,0

    .endif

    xor eax, eax
    ret

dlgproc endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

Butn1Proc proc hCtl   :DWORD,
               uMsg   :DWORD,
               wParam :DWORD,
               lParam :DWORD

    .if uMsg == WM_MOUSEMOVE
        invoke SetFocus,hCtl
        mov eax, hCtl
        .if eax == hButn1
          invoke SendMessage,hStat1,WM_SETTEXT,0,SADD("Dialog To Get Text Fom The User")
        .elseif eax == hButn2
          invoke SendMessage,hStat1,WM_SETTEXT,0,SADD("Dialog For Copyright And Other Information")
        .elseif eax == hButn3
          invoke SendMessage,hStat1,WM_SETTEXT,0,SADD("Dialog To Get A File Name From A Directory")
        .elseif eax == hButn4
          invoke SendMessage,hStat1,WM_SETTEXT,0,SADD("Dialog To Get Or Set An IP Address")
        .elseif eax == hButn5
          invoke SendMessage,hStat1,WM_SETTEXT,0,SADD("Close This Dialog")
        .endif
    .endif

    invoke CallWindowProc,lpButn1Proc,hCtl,uMsg,wParam,lParam

    ret

Butn1Proc endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start
