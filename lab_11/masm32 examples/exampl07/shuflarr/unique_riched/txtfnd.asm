; #########################################################################

TextFind proc lpBuffer:DWORD, len:DWORD

    LOCAL tp :DWORD
    LOCAL tl :DWORD
    LOCAL sch:DWORD
    LOCAL ft :FINDTEXT
    LOCAL Cr :CHARRANGE

    invoke SendMessage,hRichEd,WM_GETTEXTLENGTH,0,0
    mov tl, eax

    invoke SendMessage,hRichEd,EM_EXGETSEL,0,ADDR Cr

    inc Cr.cpMin                 ; inc starting pos by 1 so not searching
                                 ; same position repeatedly
    m2m ft.chrg.cpMin, Cr.cpMin  ; start pos
    m2m ft.chrg.cpMax, tl        ; end of text
    m2m ft.lpstrText, lpBuffer   ; string to search for

    ; 0 = case insensitive
    ; 2 = FT_WHOLEWORD
    ; 4 = FT_MATCHCASE
    ; 6 = FT_WHOLEWORD or FT_MATCHCASE

    mov sch, 0
    .if CaseFlag == 1
      or sch, 4
    .endif
    .if WholeWord == 1
      or sch, 2
    .endif

    invoke SendMessage,hRichEd,EM_FINDTEXT,sch,ADDR ft
    mov tp, eax

    .if tp == -1
      invoke MessageBox,hWnd,ADDR nomatch,ADDR szDisplayName,MB_OK
      ret
    .endif

    m2m Cr.cpMin,tp     ; put start pos into structure
    dec len             ; dec length for zero terminator
    mov eax, len
    add tp,eax          ; add length to character pos
    m2m Cr.cpMax,tp     ; put end pos into structure

    ; ------------------------------------
    ; set the selection to the search word
    ; ------------------------------------
    invoke SendMessage,hRichEd,EM_EXSETSEL,0,ADDR Cr

    ret

TextFind endp

; #########################################################################
