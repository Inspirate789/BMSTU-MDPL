; ########################################################################

EditControl proc hParent:DWORD, x:DWORD, y:DWORD, wd:DWORD, ht:DWORD, ID:DWORD

    LOCAL hEdit:DWORD
    LOCAL hFont:DWORD

  ; --------------------------------
  ; conditional assembly directives
  ; --------------------------------
    IFDEF riched1
      szText EditMl,"RICHEDIT"
    ELSE
      szText EditMl,"RichEdit20a"
    ENDIF
  ; --------------------------------

    invoke CreateWindowEx,0,ADDR EditMl,0,
                          WS_VISIBLE or ES_SUNKEN or \
                          WS_CHILDWINDOW or WS_CLIPSIBLINGS or \
                          ES_MULTILINE or WS_VSCROLL or \
                          ES_AUTOVSCROLL or ES_NOHIDESEL or \
                          WS_HSCROLL or ES_AUTOHSCROLL,
                          x,y,wd,ht,hParent,ID,hInstance,NULL
    mov hEdit, eax

    invoke SetWindowLong,hEdit,GWL_WNDPROC,hEditProc
    mov lpfnhEditProc, eax

    invoke GetStockObject,edit_font
    invoke SendMessage,hEdit,WM_SETFONT,eax,0

    invoke SendMessage,hEdit,EM_EXLIMITTEXT,0,100000000
    invoke SendMessage,hEdit,EM_SETOPTIONS,ECOOP_XOR,ECO_SELECTIONBAR

    mov eax, hEdit
    ret

EditControl endp

; #########################################################################
