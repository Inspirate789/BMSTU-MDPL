; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
    include \masm32\include\masm32rt.inc
; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

comment * ------------------------------------------------------------------------------------------
                   Use the MASM32 Dialog Help from the HELP menu as reference
                   when building dialog applications using this type of code
        ------------------------------------------------------------------------------------------ *

      DlgProc PROTO :DWORD,:DWORD,:DWORD,:DWORD
      enable_common_controls PROTO
 
    .data?
      hWnd      dd ?
      hInstance dd ?

    .code

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

start:
    invoke enable_common_controls
    mov hInstance, rv(GetModuleHandle,NULL)
    call main
    invoke ExitProcess,eax

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

main proc

    Dialog "SHCreateDirectoryEx Test", \                ; caption
           "MS Sans Serif",10, \            ; font,pointsize
            WS_OVERLAPPED or \              ; styles for
            WS_SYSMENU or DS_CENTER, \      ; dialog window
            3, \                            ; number of controls
            50,50,155,100, \                ; x y co-ordinates
            1024                            ; memory buffer size

    DlgButton "Build Tree",WS_TABSTOP,106,5,40,13,IDOK
    DlgButton "Cancel",WS_TABSTOP,106,20,40,13,IDCANCEL
    DlgStatic "Cick the Build Tree Button",SS_LEFT,5,5,90,9,100

    CallModalDialog hInstance,0,DlgProc,NULL

    ret

main endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

DlgProc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

    LOCAL pbuf  :DWORD
    LOCAL buffer[260]:BYTE

    Switch uMsg
      Case WM_INITDIALOG
        invoke SendMessage,hWin,WM_SETICON,1,rv(LoadIcon,NULL,IDI_ASTERISK)
        m2m hWnd, hWin
        return 1

      Case WM_COMMAND
        Switch wParam
          Case IDOK
            mov pbuf, ptr$(buffer)
            invoke GetCurrentDirectory,260,pbuf
            mov pbuf, cat$(pbuf,"\test1\test2\test3\test4")
            invoke SHCreateDirectoryEx,hWin,pbuf,NULL

            mov pbuf, ptr$(buffer)
            invoke GetCurrentDirectory,260,pbuf
            mov pbuf, cat$(pbuf,"\test1\test2\test3\test44")
            invoke SHCreateDirectoryEx,hWin,pbuf,NULL

            mov pbuf, ptr$(buffer)
            invoke GetCurrentDirectory,260,pbuf
            mov pbuf, cat$(pbuf,"\test1\test2\test3\test444")
            invoke SHCreateDirectoryEx,hWin,pbuf,NULL

            fn MessageBox,hWin,"The game is done, I've won I've won quote she and whistled thrice.","Coleridge",MB_OK

          Case IDCANCEL
            jmp quit_dialog
        EndSw
      Case WM_CLOSE
        quit_dialog:
         invoke EndDialog,hWin,0
    EndSw

    return 0

DlgProc endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

enable_common_controls proc

    LOCAL icce:INITCOMMONCONTROLSEX

  ; --------------------------------------
  ; comment out the styles you don't need.
  ; --------------------------------------
    mov icce.dwSize, SIZEOF INITCOMMONCONTROLSEX            ; set the structure size
    xor eax, eax                                            ; set EAX to zero
 ;     or eax, ICC_ANIMATE_CLASS                               ; OR as many styles as you need to it
 ;     or eax, ICC_BAR_CLASSES                                 ; comment out the rest
 ;     or eax, ICC_COOL_CLASSES
 ;     or eax, ICC_DATE_CLASSES
 ;     or eax, ICC_HOTKEY_CLASS
 ;     or eax, ICC_INTERNET_CLASSES
 ;     or eax, ICC_LISTVIEW_CLASSES
 ;     or eax, ICC_PAGESCROLLER_CLASS
 ;     or eax, ICC_PROGRESS_CLASS
 ;     or eax, ICC_TAB_CLASSES
 ;     or eax, ICC_TREEVIEW_CLASSES
 ;     or eax, ICC_UPDOWN_CLASS
 ;     or eax, ICC_USEREX_CLASSES
 ;     or eax, ICC_WIN95_CLASSES
    mov icce.dwICC, eax
    invoke InitCommonControlsEx,ADDR icce                   ; initialise the common control library
  ; --------------------------------------

    ret

enable_common_controls endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

end start
