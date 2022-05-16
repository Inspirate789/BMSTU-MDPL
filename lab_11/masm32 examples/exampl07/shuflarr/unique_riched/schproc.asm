; #########################################################################

SearchProc proc hWin   :DWORD,
                uMsg   :DWORD,
                wParam :DWORD,
                lParam :DWORD

    LOCAL hEdit      :DWORD

      .if uMsg == WM_INITDIALOG
        invoke SendMessage,hWin,WM_SETTEXT,0,ADDR dlgTitle

        invoke GetDlgItem,hWin,3093
        mov hCheck1, eax
        invoke GetDlgItem,hWin,3094
        mov hCheck2, eax

        .if CaseFlag == 1
          invoke SendMessage,hCheck1,BM_SETCHECK,BST_CHECKED,0
        .endif

        .if WholeWord == 1
          invoke SendMessage,hCheck2,BM_SETCHECK,BST_CHECKED,0
        .endif

      .elseif uMsg == WM_COMMAND
      
        .if wParam == 3091                ; cancel button
          jmp OutaHere

        .elseif wParam == IDOK            ; default enter key
          jmp FindMe

        .elseif wParam == 3090            ; find button
          FindMe:
          invoke GetDlgItem,hWin,3092
            mov hEdit, eax
            invoke SendMessage,hEdit,WM_GETTEXTLENGTH,0,0
            mov TextLen, eax
            .if TextLen == 0
              return 0
            .else

            invoke SendMessage,hCheck1,BM_GETCHECK,0,0
              .if eax == BST_CHECKED
                mov CaseFlag, 1
              .else
                mov CaseFlag, 0
              .endif

            invoke SendMessage,hCheck2,BM_GETCHECK,0,0
              .if eax == BST_CHECKED
                mov WholeWord, 1
              .else
                mov WholeWord, 0
              .endif

              inc TextLen
              invoke SendMessage,hEdit,WM_GETTEXT,TextLen,ADDR SearchText
              invoke TextFind,ADDR SearchText,TextLen
              jmp OutaHere
            .endif

        .elseif wParam == IDCANCEL  ; default escape button
          jmp OutaHere

        .endif

      .elseif uMsg == WM_CLOSE
        OutaHere:
        invoke EndDialog,hWin,0

      .endif

    mov eax, 0

    ret

SearchProc endp

; #########################################################################
