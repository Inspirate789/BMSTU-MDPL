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
    hEdit     dd ?

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

    fn LoadLibrary,"RICHED32.DLL"

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
    sas [esi+4], "Rich Edit Control"                    ; macro to assign a string to a pointer
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
            4, \                            ; number of controls
            50,50,380,245, \                ; x y co-ordinates
            1024                            ; memory buffer size

  ; -----------------------------------------------------------------------
  ; ensure that the number of controls matches the count in the above macro
  ; -----------------------------------------------------------------------

    editstyle = WS_VISIBLE or WS_CHILDWINDOW or WS_BORDER or \
                ES_MULTILINE or WS_VSCROLL or WS_HSCROLL or \
                ES_AUTOHSCROLL or ES_AUTOVSCROLL or ES_NOHIDESEL or ES_WANTRETURN

    DlgRichEdit editstyle,1,1,300,225,99

    DlgButton "OK",WS_TABSTOP,315,10,50,13,100
    DlgButton "Cancel",WS_TABSTOP,315,25,50,13,IDCANCEL
    DlgIconEx 5,325,40,30,30,101

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

        mov hEdit, rv(GetDlgItem,hWin,99)
        invoke SendMessage,hEdit,EM_EXLIMITTEXT,0,1000000000

        fn SendMessage,hEdit,WM_SETFONT,rv(GetStockObject,ANSI_FIXED_FONT),TRUE

        m2m hWnd, hWin
        mov eax, 1
        ret

      Case WM_COMMAND
        Switch wParam
          Case 100
            fn MsgBoxi,hInstance,hWnd, \
               cfm$("Rich Edit Control in a\nMemory Dialog Template"), \
               " Howdy",MB_OK,5
                       
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
