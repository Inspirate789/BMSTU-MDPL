IF 0  ; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

                   Use the MASM32 Dialog Help from the HELP menu as reference
                   when building dialog applications using this type of code

ENDIF ; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    include \masm32\include\masm32rt.inc

    create_dialog PROTO :DWORD,:DWORD
    DlgProc PROTO :DWORD,:DWORD,:DWORD,:DWORD
    MsgBoxi PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD

  .data?
    hWnd      dd ?
    hInstance dd ?
    hRadio1   dd ?
    hRadio2   dd ?
    hRadio3   dd ?
    hRadio4   dd ?

  .code

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

start:
    call main
    invoke ExitProcess,eax

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

main proc

    LOCAL rvl   :DWORD
    LOCAL arr[4]:DWORD          ; DWORD array
    LOCAL parr  :DWORD          ; array pointer

    LOCAL icce:INITCOMMONCONTROLSEX

    mov hInstance, rv(GetModuleHandle,NULL)

  ; ------------------------------
  ; uncomment the styles you need.
  ; ------------------------------
    mov icce.dwSize, SIZEOF INITCOMMONCONTROLSEX        ; set the structure size
    xor eax, eax                                        ; set EAX to zero
    mov icce.dwICC, eax
    invoke InitCommonControlsEx,ADDR icce               ; initialise the common control library
  ; --------------------------------------

  ; --------------------
  ; set pointer to array
  ; --------------------
    lea eax, arr
    mov parr, eax

  ; -----------------------------------------------------
  ; load array with arguments to pass to dialog procedure
  ; -----------------------------------------------------
    push esi
    mov esi, parr
    mov [esi],   rv(LoadIcon,hInstance,5)
    sas [esi+4], " Radio Buttons"                         ; macro to assign a string to a pointer
    pop esi

    mov rvl, rv(create_dialog,hInstance,parr)

    ret

main endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

create_dialog proc iinstance:DWORD,extra:DWORD

  ; -----------------------------------------------------------------------
  ; scale the dialog size up or down by changing the point size of the font
  ; -----------------------------------------------------------------------
    Dialog " Dialog Template", \            ; caption
           "MS Sans Serif",8, \             ; font,pointsize
            WS_OVERLAPPED or \              ; styles for
            WS_SYSMENU or DS_CENTER, \      ; dialog window
            8, \                            ; number of controls
            50,50,185,108, \                ; x y co-ordinates
            1024                            ; memory buffer size

  ; -----------------------------------------------------------------------
  ; ensure that the number of controls matches the count in the above macro
  ; -----------------------------------------------------------------------
    DlgButton "OK",WS_TABSTOP,120,10,50,13,IDOK
    DlgButton "Cancel",WS_TABSTOP,120,25,50,13,IDCANCEL

    DlgGroup " Group Box ",10,5,100,75,100

    DlgRadio " Radio Button 1",BS_LEFT or WS_TABSTOP,20,15,60,12,101
    DlgRadio " Radio Button 2",BS_LEFT or WS_TABSTOP,20,30,60,12,102
    DlgRadio " Radio Button 3",BS_LEFT or WS_TABSTOP,20,45,60,12,103
    DlgRadio " Radio Button 4",BS_LEFT or WS_TABSTOP,20,60,60,12,104

    DlgIconEx 5,130,40,30,30,101

  ; ------------------------------------------------------------------------
  ; the argument "extra" is available in the DlgProc WM_INITDIALOG as lParam
  ; ------------------------------------------------------------------------
    CallModalDialog iinstance,0,DlgProc,extra

  ; -------------------------------------------------------------------------
  ; the value in EAX is that set by the EndDialog() API called in the DlgProc
  ; -------------------------------------------------------------------------
    ret

create_dialog endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

DlgProc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD 

    LOCAL flag  :DWORD
    LOCAL pbuf  :DWORD
    LOCAL buffer[128]:BYTE

    Switch uMsg
      Case WM_INITDIALOG
      ; ----------------------------
      ; read items from passed array
      ; ----------------------------
        push esi
        mov esi, lParam
        invoke SendMessage,hWin,WM_SETICON,1,[esi]
        invoke SetWindowText,hWin,[esi+4]
        pop esi

        mov hRadio1, rv(GetDlgItem,hWin,101)
        mov hRadio2, rv(GetDlgItem,hWin,102)
        mov hRadio3, rv(GetDlgItem,hWin,103)
        mov hRadio4, rv(GetDlgItem,hWin,104)

      ; -------------------------------------------
      ; set the selection to the first radio button
      ; -------------------------------------------
        fn SendMessage,hRadio1,BM_SETCHECK,BST_CHECKED,0

        m2m hWnd, hWin
        mov eax, 1
        ret

      Case WM_COMMAND
        Switch wParam
          Case IDOK
            .if rv(SendMessage,hRadio1,BM_GETCHECK,0,0) == BST_CHECKED
              mov flag, 1
              jmp showit
            .endif

            .if rv(SendMessage,hRadio2,BM_GETCHECK,0,0) == BST_CHECKED
              mov flag, 2
              jmp showit
            .endif

            .if rv(SendMessage,hRadio3,BM_GETCHECK,0,0) == BST_CHECKED
              mov flag, 3
              jmp showit
            .endif

            .if rv(SendMessage,hRadio4,BM_GETCHECK,0,0) == BST_CHECKED
              mov flag, 4
              jmp showit
            .endif

          showit:
          ; ------------------------------------------
          ; construct the string to display the choice
          ; ------------------------------------------
            mov pbuf, ptr$(buffer)
            mov pbuf, cat$(pbuf,"Radio button ",str$(flag)," is selected")

            fn MsgBoxi,hInstance,hWnd,pbuf," Howdy",MB_OK,5
                       
          Case IDCANCEL
         invoke EndDialog,hWin,1
        EndSw
      Case WM_CLOSE
        invoke EndDialog,hWin,0
    EndSw

    return 0

DlgProc endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

MsgBoxi proc iinstance:DWORD,hParent:DWORD,msgtxt:DWORD,caption:DWORD,mbstyle:DWORD,iconID:DWORD

    LOCAL mbp :MSGBOXPARAMS

    or mbstyle, MB_USERICON

    mov mbp.cbSize,             SIZEOF mbp
    m2m mbp.hwndOwner,          hParent
    m2m mbp.hInstance,          iinstance
    m2m mbp.lpszText,           msgtxt
    m2m mbp.lpszCaption,        caption
    m2m mbp.dwStyle,            mbstyle
    m2m mbp.lpszIcon,           iconID
    mov mbp.dwContextHelpId,    NULL
    mov mbp.lpfnMsgBoxCallback, NULL
    mov mbp.dwLanguageId,       NULL

    invoke MessageBoxIndirect,ADDR mbp

    ret

MsgBoxi endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

end start
