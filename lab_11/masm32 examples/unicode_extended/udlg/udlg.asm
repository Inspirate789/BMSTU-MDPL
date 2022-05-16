; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
;                                Build this dialog with MAKEIT.BAT
; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    __UNICODE__ equ 1   ; enable UNICODE API functions

    include \masm32\include\masm32rt.inc
    .686p
    .MMX
    .XMM

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    include udlg.inc

  ; --------------------
  ; GLOBAL scope handles
  ; --------------------
    .data?
      hInstance  dd ?
      hWnd       dd ?
      hGroup     dd ?
      hButn1     dd ?
      hButn2     dd ?

    .code

start:
    mov hInstance, rvx(GetModuleHandle, NULL)

  ; -------------------------------------------
  ; Call the dialog box from the resource file
  ; -------------------------------------------
    invoke DialogBoxParam,hInstance,100,0,ADDR DlgProc,0

    invoke ExitProcess,eax

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

DlgProc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

    LOCAL icce:INITCOMMONCONTROLSEX
    LOCAL dlgTitle  :DWORD

    mov dlgTitle, uc$(" Unicode Dialog")

      switch uMsg
        case WM_INITDIALOG
          m2m hWnd, hWin    ; Copy hWin to GLOBAL variable
          invoke SendMessage,hWin,WM_SETTEXT,0,dlgTitle
          invoke SendMessage,hWin,WM_SETICON,1,FUNC(LoadIcon,hInstance,500)

          mov icce.dwSize, SIZEOF INITCOMMONCONTROLSEX            ; set the structure size
          xor eax, eax                                            ; set EAX to zero
          or eax, ICC_WIN95_CLASSES
          mov icce.dwICC, eax
          invoke InitCommonControlsEx,ADDR icce                   ; initialise the common control library

        ; --------------------------------
        ; Get the handle for each control
        ; --------------------------------
          mov hGroup, rv(GetDlgItem,hWin,101)
          mov hButn1, rv(GetDlgItem,hWin,102)
          mov hButn2, rv(GetDlgItem,hWin,103)

          xor eax, eax
          ret

      case WM_COMMAND
        switch wParam
          case 102
            fnx MsgboxI,hWnd,"Unicode String In A Message Box   ","Howdy",MB_OK,500
          case 103
            jmp exit_dialog
        endsw

      case WM_CLOSE
        exit_dialog:                ; jump to this label to close program
        invoke EndDialog,hWin,0

      endsw

    xor eax, eax    ; this must be here in NT4 and later
    ret

DlgProc endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

MsgboxI proc hParent:DWORD,pText:DWORD,pTitle:DWORD,mbStyle:DWORD,IconID:DWORD

    LOCAL mbp   :MSGBOXPARAMS

    or mbStyle, MB_USERICON

    mov mbp.cbSize,             SIZEOF mbp
    m2m mbp.hwndOwner,          hParent
    mov mbp.hInstance,          rvx(GetModuleHandle,0)
    m2m mbp.lpszText,           pText
    m2m mbp.lpszCaption,        pTitle
    m2m mbp.dwStyle,            mbStyle
    m2m mbp.lpszIcon,           IconID
    mov mbp.dwContextHelpId,    NULL
    mov mbp.lpfnMsgBoxCallback, NULL
    mov mbp.dwLanguageId,       NULL

    invoke MessageBoxIndirect,ADDR mbp

    ret

MsgboxI endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

end start

