; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
;                                Build this dialog with MAKEIT.BAT
IF 0  ; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    Note that the resource script for this file is written in UNICODE so that it can display
    character sets that cannot be represented in an ANSI editor. The different character sets
    were translated in GOOGLE then added to the string table in the RSRC.RC file.

ENDIF ; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    __UNICODE__ equ 1                   ; define UNICODE Windows API functions

    include \masm32\include\masm32rt.inc
    .686p
    .MMX
    .XMM

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

    include multi_lingual.inc

  ; --------------------
  ; GLOBAL scope handles
  ; --------------------
    .data?
      hInstance  dd ?
      hWnd       dd ?

      hStat0    dd ?
      hStat1    dd ?
      hStat2    dd ?
      hStat3    dd ?
      hStat4    dd ?
      hStat5    dd ?
      hStat6    dd ?
      hStat7    dd ?
      hStat8    dd ?
      hStat9    dd ?

    .code

start:
    mov hInstance, rv(GetModuleHandle, NULL)

  ; -------------------------------------------
  ; Call the dialog box from the resource file
  ; -------------------------------------------
    invoke DialogBoxParam,hInstance,100,0,ADDR DlgProc,0

    invoke ExitProcess,eax

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

DlgProc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

    LOCAL icce:INITCOMMONCONTROLSEX
    LOCAL dlgtitle  :DWORD
    LOCAL buffer[260]:WORD          ; buffer for UNICODE string
    LOCAL pbuf  :DWORD

    mov dlgtitle, chr$(" Multi Lingual UNICODE Demo")

      switch uMsg
        case WM_INITDIALOG
          m2m hWnd, hWin    ; Copy hWin to GLOBAL variable
          invoke SendMessage,hWin,WM_SETTEXT,0,dlgtitle
          invoke SendMessage,hWin,WM_SETICON,1,FUNC(LoadIcon,hInstance,500)

          mov icce.dwSize, SIZEOF INITCOMMONCONTROLSEX            ; set the structure size
          xor eax, eax                                            ; set EAX to zero
          or eax, ICC_WIN95_CLASSES
          mov icce.dwICC, eax
          invoke InitCommonControlsEx,ADDR icce                   ; initialise the common control library

        ; --------------------------------
        ; Get the handle for each control
        ; --------------------------------
          mov hStat0, rv(GetDlgItem,hWin,1250)
          mov hStat1, rv(GetDlgItem,hWin,1251)
          mov hStat2, rv(GetDlgItem,hWin,1252)
          mov hStat3, rv(GetDlgItem,hWin,1253)
          mov hStat4, rv(GetDlgItem,hWin,1254)
          mov hStat5, rv(GetDlgItem,hWin,1255)
          mov hStat6, rv(GetDlgItem,hWin,1256)
          mov hStat7, rv(GetDlgItem,hWin,1257)
          mov hStat8, rv(GetDlgItem,hWin,1258)
          mov hStat9, rv(GetDlgItem,hWin,1259)

          mov pbuf, ptr$(buffer)

          fn LoadString,hInstance,250,pbuf,260
          fn SetWindowText,hStat0,pbuf

          fn LoadString,hInstance,251,pbuf,260
          fn SetWindowText,hStat1,pbuf

          fn LoadString,hInstance,252,pbuf,260
          fn SetWindowText,hStat2,pbuf

          fn LoadString,hInstance,253,pbuf,260
          fn SetWindowText,hStat3,pbuf

          fn LoadString,hInstance,254,pbuf,260
          fn SetWindowText,hStat4,pbuf

          fn LoadString,hInstance,255,pbuf,260
          fn SetWindowText,hStat5,pbuf

          fn LoadString,hInstance,256,pbuf,260
          fn SetWindowText,hStat6,pbuf

          fn LoadString,hInstance,257,pbuf,260
          fn SetWindowText,hStat7,pbuf

          fn LoadString,hInstance,258,pbuf,260
          fn SetWindowText,hStat8,pbuf

          fn LoadString,hInstance,259,pbuf,260
          fn SetWindowText,hStat9,pbuf

          xor eax, eax
          ret

      case WM_COMMAND
        switch wParam
          case 1
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
    mov mbp.hInstance,          rv(GetModuleHandle,0)
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

