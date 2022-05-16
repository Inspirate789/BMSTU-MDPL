; #########################################################################

Select_All Proc hEdit:DWORD

    LOCAL tl :DWORD
    LOCAL Cr :CHARRANGE

    mov Cr.cpMin,0

    invoke GetWindowTextLength,hEdit
    inc eax
    mov Cr.cpMax, eax

    invoke SendMessage,hEdit,EM_EXSETSEL,0,ADDR Cr

    ret

Select_All endp

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

    szText confirm,"File is not saved, Save it now ?"

    invoke MessageBox,hWnd,ADDR confirm,
                           ADDR szDisplayName,
                           MB_YESNOCANCEL or MB_ICONQUESTION

    ret

Confirmation endp

; #########################################################################
