; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

rebar proc instance:DWORD,hParent:DWORD,htrebar:DWORD

    LOCAL hrbar :DWORD

    fn CreateWindowEx,WS_EX_LEFT,"ReBarWindow32",NULL, \
                      WS_VISIBLE or WS_CHILD or \
                      WS_CLIPCHILDREN or WS_CLIPSIBLINGS or \
                      RBS_VARHEIGHT or CCS_NOPARENTALIGN or CCS_NODIVIDER, \
                      0,0,sWid,htrebar,hParent,NULL,instance,NULL
    mov hrbar, eax

    invoke ShowWindow,hrbar,SW_SHOW
    invoke UpdateWindow,hrbar

    mov eax, hrbar

    ret

rebar endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

addband proc instance:DWORD,hrbar:DWORD

    LOCAL tbhandl   :DWORD
    LOCAL rbbi      :REBARBANDINFO

    mov tbhandl, rv(TBcreate,hrbar)

    mov rbbi.cbSize,      sizeof REBARBANDINFO
    mov rbbi.fMask,       RBBIM_ID or RBBIM_STYLE or \
                          RBBIM_BACKGROUND or RBBIM_CHILDSIZE or RBBIM_CHILD
    mov rbbi.wID,         125
    mov rbbi.fStyle,      RBBS_FIXEDBMP
    m2m rbbi.hbmBack,     tbTile
    mov rbbi.cxMinChild,  0
    m2m rbbi.cyMinChild,  rbht
    m2m rbbi.hwndChild,   tbhandl

    invoke SendMessage,hrbar,RB_INSERTBAND,0,ADDR rbbi

    mov eax, tbhandl

    ret

addband endp

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

AboutProc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

    LOCAL hStat     :DWORD
    LOCAL hImage    :DWORD
    LOCAL hbmp      :DWORD
    LOCAL hDC       :DWORD
    LOCAL hOld      :DWORD
    LOCAL hFont     :DWORD
    LOCAL rct       :RECT

      ; ------------------------------------
      ; adjust the text formatting rectangle
      ; here for the banner text below.
      ; ------------------------------------
        aTl equ <10>        ; top left
        aTr equ <10>        ; top right
        aLl equ <400>       ; lower left
        aLr equ <40>        ; lower right
        bHt equ <48>        ; set the bitmap height here

      ; ------------------------
      ; set the banner text here
      ; ------------------------
        .data
          dtext db "MASM32 Application Template",0
          banner dd dtext

      ; -------------------------------------------
      ; modify this text to reflect the information
      ; you wish to display in the about box.
      ; -------------------------------------------
          tdat db "MASM32 Application Template",13,10,13,10
               db "Copyright (c) The MASM32 SDK 1998-2010",0
          text dd tdat

        .code

    switch uMsg
      case WM_INITDIALOG
        mov hImage, rv(GetDlgItem,hWin,999)
        mov hStat,  rv(GetDlgItem,hWin,997)


        invoke SetWindowText,hStat,text

      ; --------------------------------------------------------
      ; set the static control style so it will display a bitmap
      ; --------------------------------------------------------
        invoke SetWindowLong,hImage,GWL_STYLE,WS_VISIBLE or SS_BITMAP

      ; ---------------------------------------------------------
      ; reuse the toolbar bitmap as the display banner background
      ; ---------------------------------------------------------
        mov hbmp, rv(LoadImage,hInstance,800,IMAGE_BITMAP,600,bHt,LR_LOADTRANSPARENT or LR_LOADMAP3DCOLORS)

      ; -------------------------------------
      ; set the image into the static control
      ; -------------------------------------
        invoke SendMessage,hImage,STM_SETIMAGE,IMAGE_BITMAP,hbmp

      ; ---------------------------------------------------------------
      ; post a WM_PAINT message to the window so it updates the display
      ; ---------------------------------------------------------------
        invoke PostMessage,hWin,WM_PAINT,0,0

      case WM_PAINT
        mov hDC, rv(GetDC,hWin)
        invoke SetBkMode,hDC,TRANSPARENT

        fn CreateFont,20,10,0,0,800,FALSE,FALSE,FALSE, \
                      ANSI_CHARSET,0,0,PROOF_QUALITY,DEFAULT_PITCH,"Arial"
        mov hFont, eax

        mov hOld, rv(SelectObject,hDC,hFont)

      ; --------------------
      ; draw the shadow text
      ; --------------------
        mov rct.left, aTl+2
        mov rct.top, aTr+2
        mov rct.right, aLl+2
        mov rct.bottom, aLr+2
        invoke SetTextColor,hDC,00000000h
        invoke DrawText,hDC,banner,-1,ADDR rct,DT_LEFT or DT_VCENTER or DT_SINGLELINE

      ; ----------------------
      ; draw the highlite text
      ; ----------------------
        mov rct.left, aTl
        mov rct.top, aTr
        mov rct.right, aLl
        mov rct.bottom, aLr
        invoke SetTextColor,hDC,00FFFFFFh
        invoke DrawText,hDC,banner,-1,ADDR rct,DT_LEFT or DT_VCENTER or DT_SINGLELINE

        invoke SelectObject,hDC,hOld

        invoke ReleaseDC,hWin,hDC

        xor eax, eax
        ret

      case  WM_COMMAND
        switch wParam
          case IDOK
            invoke EndDialog,hWin,0
        endsw
    endsw

    xor eax, eax
    ret

AboutProc endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

open_file_dialog proc hParent:DWORD,Instance:DWORD,lpTitle:DWORD,lpFilter:DWORD

    LOCAL ofn:OPENFILENAME

    .data?
      openfilebuffer db 260 dup (?)
    .code

    mov eax, OFFSET openfilebuffer
    mov BYTE PTR [eax], 0

  ; --------------------
  ; zero fill structure
  ; --------------------
    push edi
    mov ecx, sizeof OPENFILENAME
    mov al, 0
    lea edi, ofn
    rep stosb
    pop edi

    mov ofn.lpstrInitialDir,    CurDir$()
    mov ofn.lStructSize,        SIZEOF OPENFILENAME
    m2m ofn.hWndOwner,          hParent
    m2m ofn.hInstance,          Instance
    m2m ofn.lpstrFilter,        lpFilter
    m2m ofn.lpstrFile,          OFFSET openfilebuffer
    mov ofn.nMaxFile,           SIZEOF openfilebuffer
    m2m ofn.lpstrTitle,         lpTitle
    mov ofn.Flags,              OFN_EXPLORER or OFN_FILEMUSTEXIST or \
                                OFN_LONGNAMES or OFN_HIDEREADONLY

    invoke GetOpenFileName,ADDR ofn
    mov eax, OFFSET openfilebuffer
    ret

open_file_dialog endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

save_file_dialog proc hParent:DWORD,Instance:DWORD,lpTitle:DWORD,lpFilter:DWORD

    LOCAL ofn:OPENFILENAME

    .data?
      savefilebuffer db 260 dup (?)
    .code

    mov eax, OFFSET savefilebuffer
    mov BYTE PTR [eax], 0

  ; --------------------
  ; zero fill structure
  ; --------------------
    push edi
    mov ecx, sizeof OPENFILENAME
    mov al, 0
    lea edi, ofn
    rep stosb
    pop edi

    mov ofn.lpstrInitialDir,    CurDir$()
    mov ofn.lStructSize,        SIZEOF OPENFILENAME
    m2m ofn.hWndOwner,          hParent
    m2m ofn.hInstance,          Instance
    m2m ofn.lpstrFilter,        lpFilter
    m2m ofn.lpstrFile,          OFFSET savefilebuffer
    mov ofn.nMaxFile,           SIZEOF savefilebuffer
    m2m ofn.lpstrTitle,         lpTitle
    mov ofn.Flags,              OFN_EXPLORER or OFN_LONGNAMES or \
                                OFN_HIDEREADONLY or OFN_OVERWRITEPROMPT
                                
    invoke GetSaveFileName,ADDR ofn
    mov eax, OFFSET savefilebuffer
    ret

save_file_dialog endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
