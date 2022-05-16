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
    hList     dd ?
    hCombo    dd ?

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

    mov icce.dwSize, SIZEOF INITCOMMONCONTROLSEX        ; set the structure size
    xor eax, eax                                        ; set EAX to zero
    mov icce.dwICC, eax
    invoke InitCommonControlsEx,ADDR icce               ; initialise the common control library

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
    sas [esi+4], "Combo and List boxes"                 ; macro to assign a string to a pointer
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
            5, \                            ; number of controls
            50,50,250,120, \                ; x y co-ordinates
            1024                            ; memory buffer size

  ; -----------------------------------------------------------------------
  ; ensure that the number of controls matches the count in the above macro
  ; -----------------------------------------------------------------------
    DlgCombo CBS_DROPDOWNLIST,10,10,150,150,99
    DlgList  LBS_STANDARD or LBS_NOINTEGRALHEIGHT,10,25,150,68,100

    DlgButton "OK",WS_TABSTOP,180,10,50,13,IDOK
    DlgButton "Cancel",WS_TABSTOP,180,25,50,13,IDCANCEL
    DlgIconEx 5,190,40,30,30,101

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

        mov hCombo, rv(GetDlgItem,hWin,99)
        mov hList, rv(GetDlgItem,hWin,100)

        fn SendMessage,hCombo,WM_SETFONT,rv(GetStockObject,ANSI_FIXED_FONT),TRUE
        fn SendMessage,hList, WM_SETFONT,rv(GetStockObject,ANSI_FIXED_FONT),TRUE

      ; ----------------------------------
      ; populate the combo box with drives
      ; ----------------------------------
        fn DlgDirListComboBox,hWin,"c:\",99,0,DDL_DRIVES

      ; ----------------------------
      ; search for and set drive c:\
      ; ----------------------------
        fn SendMessage,hCombo,CB_SETCURSEL,rv(SendMessage,hCombo,CB_FINDSTRING,0,"[-c-]"),0

      ; ------------------------------------------------
      ; populate the list box with directories and files
      ; ------------------------------------------------
        fn DlgDirList,hWin,"c:\",100,0,DDL_DIRECTORY or \
                      DDL_ARCHIVE or DDL_HIDDEN or DDL_READONLY or DDL_SYSTEM

        m2m hWnd, hWin
        mov eax, 1
        ret

      Case WM_COMMAND
        Switch wParam
          Case IDOK
            fn MsgBoxi,hInstance,hWnd,"Combo and List box demo."," Howdy",MB_OK,5
                       
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
