; #########################################################################

Confirmation proc hEditor:DWORD

    invoke SendMessage,hEditor,WM_GETTEXTLENGTH,0,0
      cmp eax, 0
      jne @F
      return 0
    @@:
    invoke SendMessage,hEditor,EM_GETMODIFY,0,0
      cmp eax, 0  ; zero = unmodified
      jne @F
      return 0
      @@:

    invoke MessageBox,hWnd,ADDR confirm,
                           ADDR szDisplayName,
                           MB_YESNOCANCEL or MB_ICONQUESTION

    ret

Confirmation endp

; #########################################################################
