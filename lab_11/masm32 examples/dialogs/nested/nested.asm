; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

      .486                      ; create 32 bit code
      .model flat, stdcall      ; 32 bit memory model
      option casemap :none      ; case sensitive

      include \masm32\include\dialogs.inc
      include nested.inc

      dlgproc       PROTO :DWORD,:DWORD,:DWORD,:DWORD
      GetText       PROTO :DWORD,:DWORD,:DWORD
      GetTextProc   PROTO :DWORD,:DWORD,:DWORD,:DWORD

    .code

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

start:

      mov hInstance, FUNC(GetModuleHandle,NULL)
      mov hIcon,     FUNC(LoadIcon,hInstance,500)

      call main

      invoke ExitProcess,eax

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

main proc

    LOCAL lpArgs:DWORD

    invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT, 32
    mov lpArgs, eax

    push hIcon
    pop [eax]

    Dialog "Nested Dialogs","MS Sans Serif",10, \         ; caption,font,pointsize
            WS_OVERLAPPED or WS_SYSMENU or DS_CENTER, \     ; style
            4, \                                            ; control count
            50,50,150,80, \                                 ; x y co-ordinates
            1024                                            ; memory buffer size

    DlgButton "Test",WS_TABSTOP,112,4,30,10,IDOK
    DlgButton "Cancel",WS_TABSTOP,112,15,30,10,IDCANCEL
    DlgStatic 'Click on  "Test"  to run nested dialog',SS_CENTER,3,35,140,9,100
    DlgIcon   500,10,10,101

    CallModalDialog hInstance,0,dlgproc,ADDR lpArgs

    invoke GlobalFree, lpArgs

    ret

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

dlgproc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

    LOCAL buffer:DWORD

    .if uMsg == WM_INITDIALOG
      invoke SetWindowLong,hWin,GWL_USERDATA,lParam
      mov eax, lParam
      mov eax, [eax]
      invoke SendMessage,hWin,WM_SETICON,1,[eax]

    .elseif uMsg == WM_COMMAND
      .if wParam == IDOK
        invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT, 32
        mov buffer, eax
        invoke GetWindowLong,hWin,GWL_USERDATA
        mov ecx, [eax]
        invoke GetText,hWin,[ecx],buffer
        mov ecx, buffer
        cmp BYTE PTR [ecx], 0
        je @F
        invoke MessageBox,hWin,buffer,SADD("You typed ..."),MB_OK
        jmp nxt
      @@:
        invoke MessageBox,hWin,SADD("You did not enter any text"),
                               SADD("No text to display"),MB_OK
      nxt:
        invoke GlobalFree,buffer

      .elseif wParam == IDCANCEL
        jmp quit_dialog
      .endif

    .elseif uMsg == WM_CLOSE
      quit_dialog:
      invoke EndDialog,hWin,0

    .endif

    xor eax, eax
    ret

dlgproc endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

GetText proc hParent:DWORD,lpIcon:DWORD,buffer:DWORD

    Dialog "Enter Text","MS Sans Serif",10, \               ; caption,font,pointsize
            WS_OVERLAPPED or WS_SYSMENU or DS_CENTER, \     ; style
            4, \                                            ; control count
            0,0,200,45, \                                   ; x y co-ordinates
            1024                                            ; memory buffer size

    DlgEdit     WS_TABSTOP or WS_BORDER,28,12,125,10,100
    DlgButton   "OK",WS_TABSTOP,160,4,30,10,IDOK
    DlgButton   "Cancel",WS_TABSTOP,160,15,30,10,IDCANCEL
    DlgIcon     500,5,5,101

  ; --------------------------------------------------------
  ; the use of "ADDR hParent" is to pass the address of the
  ; stack parameters in this proc to the proc being called.
  ; --------------------------------------------------------
    CallModalDialog hInstance,hParent,GetTextProc,ADDR hParent

    ret

GetText endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

GetTextProc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

    LOCAL buffer:DWORD
    LOCAL hEdit :DWORD
    LOCAL tl    :DWORD

    .if uMsg == WM_INITDIALOG
    ; -----------------------------------------
    ; write the parameters passed in "lParam"
    ; to the dialog's GWL_USERDATA address.
    ; -----------------------------------------
      invoke SetWindowLong,hWin,GWL_USERDATA,lParam
      mov eax, lParam
      mov eax, [eax+4]
      invoke SendMessage,hWin,WM_SETICON,1,eax

    .elseif uMsg == WM_COMMAND
      .if wParam == IDOK
        invoke GetDlgItem,hWin,100
        mov hEdit, eax
        invoke GetWindowTextLength,hEdit
        cmp eax, 0
        je @F
        mov tl, eax
        inc tl
        invoke GetWindowLong,hWin,GWL_USERDATA      ; get buffer address
        mov ecx, [eax+8]                            ; put it in ECX
        invoke SendMessage,hEdit,WM_GETTEXT,tl,ecx  ; write edit text to buffer
        jmp Exit_Find_Text

      @@:
        invoke SetFocus,hEdit

      .elseif wParam == IDCANCEL
        jmp Exit_Find_Text
      .endif

    .elseif uMsg == WM_CLOSE
      Exit_Find_Text:
      invoke EndDialog,hWin,0

    .endif

    xor eax, eax
    ret

GetTextProc endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start