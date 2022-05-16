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

 ;     or eax, 00000001h          ; ICC_LISTVIEW_CLASSES       listview, header
 ;     or eax, 00000002h          ; ICC_TREEVIEW_CLASSES       treeview, tooltips
 ;     or eax, 00000004h          ; ICC_BAR_CLASSES            toolbar, statusbar, trackbar, tooltips
 ;     or eax, 00000008h          ; ICC_TAB_CLASSES            tab, tooltips
 ;     or eax, 00000010h          ; ICC_UPDOWN_CLASS           updown
 ;     or eax, 00000020h          ; ICC_PROGRESS_CLASS         progress
 ;     or eax, 00000040h          ; ICC_HOTKEY_CLASS           hotkey
 ;     or eax, 00000080h          ; ICC_ANIMATE_CLASS          animate
 ;     or eax, 000000FFh          ; ICC_WIN95_CLASSES      
 ;     or eax, 00000100h          ; ICC_DATE_CLASSES           month picker, date picker, time picker, updown
 ;     or eax, 00000200h          ; ICC_USEREX_CLASSES         comboex
 ;     or eax, 00000400h          ; ICC_COOL_CLASSES           rebar (coolbar) control
 ;     or eax, 00000800h          ; ICC_INTERNET_CLASSES   
 ;     or eax, 00001000h          ; ICC_PAGESCROLLER_CLASS     page scroller
 ;     or eax, 00002000h          ; ICC_NATIVEFNTCTL_CLASS     native font control
 ;     or eax, 00004000h          ; ICC_STANDARD_CLASSES   
 ;     or eax, 00008000h          ; ICC_LINK_CLASS         

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
    sas [esi+4], "Dialog Title"                         ; macro to assign a string to a pointer
    sas [esi+8], "Masm32 Dialog"                        ; macro to assign a string to a pointer
    pop esi

    mov rvl, rv(create_dialog,hInstance,parr)

  ; -----------------------------
  ; the return value from DlgProc
  ; -----------------------------
    fn MsgBoxi,hInstance,0,ustr$(rvl),"rvl",MB_OK,5

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
            50,50,185,120, \                ; x y co-ordinates
            1024                            ; memory buffer size

  ; -----------------------------------------------------------------------
  ; ensure that the number of controls matches the count in the above macro
  ; -----------------------------------------------------------------------
    DlgButton "OK",WS_TABSTOP,120,10,50,13,IDOK
    DlgButton "Cancel",WS_TABSTOP,120,25,50,13,IDCANCEL
    DlgStatic "MASM32 Dialog",SS_LEFT,10,10,60,9,100
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
 
    Switch uMsg
      Case WM_INITDIALOG
      ; ----------------------------
      ; read items from passed array
      ; ----------------------------
        push esi
        mov esi, lParam
        invoke SendMessage,hWin,WM_SETICON,1,[esi]
        invoke SetWindowText,hWin,[esi+4]
        invoke SetWindowText,rv(GetDlgItem,hWin,100),[esi+8]
        pop esi

        m2m hWnd, hWin
        mov eax, 1
        ret

      Case WM_COMMAND
        Switch wParam
          Case IDOK
            fn MsgBoxi,hInstance,hWnd,cfm$("Memory Dialog Template\nIn MASM232")," Howdy",MB_OK,5
                       
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
