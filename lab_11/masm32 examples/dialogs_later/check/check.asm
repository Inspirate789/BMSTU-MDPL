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
    hCheck1   dd ?
    hCheck2   dd ?
    hCheck3   dd ?
    hCheck4   dd ?

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
    sas [esi+4], " Check Box Demo"                      ; macro to assign a string to a pointer
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
            7, \                            ; number of controls
            50,50,185,120, \                ; x y co-ordinates
            1024                            ; memory buffer size

  ; -----------------------------------------------------------------------
  ; ensure that the number of controls matches the count in the above macro
  ; -----------------------------------------------------------------------
    DlgButton "Check",WS_TABSTOP,120,10,50,13,IDOK
    DlgButton "Cancel",WS_TABSTOP,120,25,50,13,IDCANCEL

    DlgCheck " Check Box 1",0,15,15,80,12,100
    DlgCheck " Check Box 2",0,15,30,80,12,101
    DlgCheck " Check Box 3",0,15,45,80,12,102
    DlgCheck " Check Box 4",0,15,60,80,12,103

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

    LOCAL pbuf  :DWORD
    LOCAL buffer[260]:BYTE

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

        mov hCheck1, rv(GetDlgItem,hWin,100)
        mov hCheck2, rv(GetDlgItem,hWin,101)
        mov hCheck3, rv(GetDlgItem,hWin,102)
        mov hCheck4, rv(GetDlgItem,hWin,103)

        m2m hWnd, hWin
        mov eax, 1
        ret

      Case WM_COMMAND
        Switch wParam
          Case IDOK
          ; -----------------------------------------
          ; construct the strings to show the results
          ; -----------------------------------------
            mov pbuf, ptr$(buffer)
            mov pbuf, cat$(pbuf,"Check Box 1 is ")

            .if rv(SendMessage,hCheck1,BM_GETCHECK,0,0) == BST_CHECKED
              mov pbuf, cat$(pbuf,"checked",chr$(13,10))
            .else
              mov pbuf, cat$(pbuf,"not checked",chr$(13,10))
            .endif

            mov pbuf, cat$(pbuf,"Check Box 2 is ")

            .if rv(SendMessage,hCheck2,BM_GETCHECK,0,0) == BST_CHECKED
              mov pbuf, cat$(pbuf,"checked",chr$(13,10))
            .else
              mov pbuf, cat$(pbuf,"not checked",chr$(13,10))
            .endif

            mov pbuf, cat$(pbuf,"Check Box 3 is ")

            .if rv(SendMessage,hCheck3,BM_GETCHECK,0,0) == BST_CHECKED
              mov pbuf, cat$(pbuf,"checked",chr$(13,10))
            .else
              mov pbuf, cat$(pbuf,"not checked",chr$(13,10))
            .endif

            mov pbuf, cat$(pbuf,"Check Box 4 is ")

            .if rv(SendMessage,hCheck4,BM_GETCHECK,0,0) == BST_CHECKED
              mov pbuf, cat$(pbuf,"checked",chr$(13,10))
            .else
              mov pbuf, cat$(pbuf,"not checked",chr$(13,10))
            .endif

          ; -------------------
          ; display the results
          ; -------------------
            fn MsgBoxi,hInstance,hWnd,pbuf," Howdy",MB_OK,5

          Case IDCANCEL
         invoke EndDialog,hWin,0
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
