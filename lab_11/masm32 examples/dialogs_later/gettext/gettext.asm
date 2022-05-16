; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
;    This example does not use the common control library as it only uses the standard controls
; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    include \masm32\include\masm32rt.inc
    include \masm32\include\dialogs.inc

    dlgproc PROTO :DWORD,:DWORD,:DWORD,:DWORD
    GetTextDialog PROTO :DWORD,:DWORD,:DWORD

    .data?
      hInstance dd ?

    .code

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

start:
    mov hInstance, rv(GetModuleHandle,NULL)
    call main
    invoke ExitProcess,eax

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

main proc

    LOCAL ptxt  :DWORD
    LOCAL hIcon :DWORD

    invoke InitCommonControls

    mov hIcon, rv(LoadIcon,hInstance,10)

    mov ptxt, rv(GetTextDialog," Main Caption Here"," Extra User Text Goes Here ",hIcon)

    .if ptxt != 0
      fn MessageBox,0,ptxt,"Title",MB_OK
    .else
      fn MessageBox,0,"Cancel was pressed","Title",MB_OK
    .endif

    invoke GlobalFree,ptxt

    ret

main endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

GetTextDialog proc dgltxt:DWORD,grptxt:DWORD,iconID:DWORD

    LOCAL arg1[4]:DWORD
    LOCAL parg  :DWORD

    lea eax, arg1
    mov parg, eax

  ; ---------------------------------------
  ; load the array with the stack arguments
  ; ---------------------------------------
    mov ecx, dgltxt
    mov [eax], ecx
    mov ecx, grptxt
    mov [eax+4], ecx
    mov ecx, iconID
    mov [eax+8], ecx

    Dialog "Get User Text", \               ; caption
           "Arial",8, \                     ; font,pointsize
            WS_OVERLAPPED or \              ; styles for
            WS_SYSMENU or DS_CENTER, \      ; dialog window
            5, \                            ; number of controls
            50,50,292,80, \                 ; x y co-ordinates
            4096                            ; memory buffer size

    DlgIcon   0,250,12,299
    DlgGroup  0,8,4,231,31,300
    DlgEdit   ES_LEFT or WS_BORDER or WS_TABSTOP,17,16,212,11,301
    DlgButton "OK",WS_TABSTOP,172,42,50,13,IDOK
    DlgButton "Cancel",WS_TABSTOP,225,42,50,13,IDCANCEL

    CallModalDialog hInstance,0,dlgproc,parg

    ret

GetTextDialog endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

dlgproc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

    LOCAL tlen  :DWORD
    LOCAL hMem  :DWORD
    LOCAL hIcon :DWORD

    switch uMsg
      case WM_INITDIALOG
      ; -------------------------------------------------
      ; get the arguments from the array passed in lParam
      ; -------------------------------------------------
        push esi
        mov esi, lParam
        fn SetWindowText,hWin,[esi]                         ; title text address
        fn SetWindowText,rv(GetDlgItem,hWin,300),[esi+4]    ; groupbox text address
        mov eax, [esi+8]                                    ; icon handle
        .if eax == 0
          mov hIcon, rv(LoadIcon,NULL,IDI_ASTERISK)         ; use default system icon
        .else
          mov hIcon, eax                                    ; load user icon
        .endif
        pop esi

        fn SendMessage,hWin,WM_SETICON,1,hIcon
        invoke SendMessage,rv(GetDlgItem,hWin,299),STM_SETIMAGE,IMAGE_ICON,hIcon
        xor eax, eax
        ret

      case WM_COMMAND
        switch wParam
          case IDOK
            mov tlen, rv(GetWindowTextLength,rv(GetDlgItem,hWin,301))
            .if tlen == 0
              invoke SetFocus,rv(GetDlgItem,hWin,301)
              ret
            .endif
            add tlen, 1
            mov hMem, alloc(tlen)
            fn GetWindowText,rv(GetDlgItem,hWin,301),hMem,tlen
            invoke EndDialog,hWin,hMem
          case IDCANCEL
            invoke EndDialog,hWin,0
        endsw
      case WM_CLOSE
        invoke EndDialog,hWin,0
    endsw

    xor eax, eax
    ret

dlgproc endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

end start
