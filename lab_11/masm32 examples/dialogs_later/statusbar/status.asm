IF 0  ; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

                   Use the MASM32 Dialog Help from the HELP menu as reference
                   when building dialog applications using this type of code

ENDIF ; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    include \masm32\include\masm32rt.inc

    create_dialog PROTO :DWORD,:DWORD
    DlgProc PROTO :DWORD,:DWORD,:DWORD,:DWORD

  .data?
    hWnd      dd ?
    hInstance dd ?
    hStatus   dd ?
    counter   dd ?

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
    mov icce.dwICC, ICC_BAR_CLASSES
    invoke InitCommonControlsEx,ADDR icce               ; initialise the common control library
  ; --------------------------------------

  ; --------------------
  ; set pointer to array
  ; --------------------
    lea eax, arr
    mov parr, eax

    mov counter, 0

  ; -----------------------------------------------------
  ; load array with arguments to pass to dialog procedure
  ; -----------------------------------------------------
    push esi
    mov esi, parr
    mov [esi],   rv(LoadIcon,hInstance,5)
    sas [esi+4], "Dialog With Status Bar"               ; macro to assign a string to a pointer
    sas [esi+8], "Masm32 Dialog"                        ; macro to assign a string to a pointer
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
            50,50,185,120, \                ; x y co-ordinates
            1024                            ; memory buffer size

  ; -----------------------------------------------------------------------
  ; ensure that the number of controls matches the count in the above macro
  ; -----------------------------------------------------------------------
    DlgButton "Test Me",WS_TABSTOP,120,10,50,13,IDOK
    DlgButton "Cancel",WS_TABSTOP,120,25,50,13,IDCANCEL
    DlgStatic "MASM32 Dialog",SS_LEFT,10,10,60,9,100
    DlgIconEx 5,130,40,30,30,101
    DlgStatus 102

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
        invoke SetWindowText,rv(GetDlgItem,hWin,100),[esi+8]
        pop esi

        mov hStatus, rv(GetDlgItem,hWin,102)

        m2m hWnd, hWin
        mov eax, 1
        ret

      Case WM_COMMAND
        Switch wParam
          Case IDOK
            add counter, 1
            mov pbuf, ptr$(buffer)
            mov pbuf, cat$(pbuf,"You have clicked this button ",ustr$(counter)," times")
            invoke SendMessage,hStatus,SB_SETTEXT,0,pbuf

          Case IDCANCEL
         invoke EndDialog,hWin,0
        EndSw
      Case WM_CLOSE
        invoke EndDialog,hWin,0
    EndSw

    return 0

DlgProc endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

end start
