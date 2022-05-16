; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Common Dialogs Example - Author: William F Cravener 10/08/2011
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
        .586
        .model flat,stdcall
        option casemap:none   ; case sensitive
    
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
        include \masm32\include\windows.inc
        include \masm32\include\user32.inc
        include \masm32\include\kernel32.inc
        include \masm32\include\comdlg32.inc

        includelib \masm32\lib\user32.lib
        includelib \masm32\lib\kernel32.lib
        includelib \masm32\lib\comdlg32.lib    

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

        IDC_EXIT equ 100
        IDC_BUTTON1 equ 101
        IDC_BUTTON2 equ 102
        IDC_BUTTON3 equ 103
        IDC_BUTTON4 equ 104
        IDC_BUTTON5 equ 105
        IDC_BUTTON6 equ 106
        IDC_BUTTON7 equ 107
        IDC_BUTTON8 equ 108

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
        CommonDialogs     PROTO :DWORD,:DWORD,:DWORD,:DWORD
        ColorDialog       PROTO :DWORD
        FontDialog        PROTO :DWORD
        FileOpenDialog    PROTO :DWORD
        FileSaveDialog    PROTO :DWORD
        PrintDialog       PROTO :DWORD
        PageSetupDialog   PROTO :DWORD
        FindTextDialog    PROTO :DWORD
        FindReplaceDialog PROTO :DWORD

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
.data
        hInstance     dd 0
        dlgname       db "COMMONDIALOGS",0

        ; -----------------------------------
        ; Used by choose color dialog
        ; -----------------------------------
        aryCustClr    dd 16 dup(0)
        rgbCurrent    dd 00000FFh ;<-- Red

        ; -----------------------------------
        ; Used by choose font dialog
        ; -----------------------------------
        rgbCurrnt     dd 0FF0000h ;<-- Blue

        ; -----------------------------------
        ; Used by open & save file dialogs
        ; -----------------------------------
        szFile        db "*.*",256 dup (0)     
        strFilter     db "All Files",0

        ; -----------------------------------
        ; Used by find & replace text dialogs
        ; -----------------------------------
        szFindWhat    db "Masm is",73 dup (0)
        szReplaceWith db "Great !",73 dup (0)

        ; -----------------------------------
        ; Required structures used by dialogs
        ; -----------------------------------
        cc  CHOOSECOLOR <>
        lf  LOGFONT <24,0,0,0,FW_BOLD,0,0,0,DEFAULT_CHARSET,0,0,0,0,"Arial">
        cf  CHOOSEFONT <>
        ofn OPENFILENAME <>
        pd  PRINTDLG <>
        psd PAGESETUPDLG <>
        fr  FINDREPLACE <>

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
.code
    
start:
        invoke GetModuleHandle,0
        mov hInstance,eax
        ; --------------------------------------------
        ; Call the dialog box stored in resource file.
        ; --------------------------------------------
        invoke DialogBoxParam,hInstance,ADDR dlgname,0,ADDR CommonDialogs,0
        invoke ExitProcess,eax
    
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
CommonDialogs proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
    
        .if uMsg == WM_INITDIALOG

        .elseif uMsg == WM_COMMAND
                mov eax,wParam
                .if eax == IDC_BUTTON1
                    invoke ColorDialog,hWin
                .elseif eax == IDC_BUTTON2
                        invoke FontDialog,hWin
                .elseif eax == IDC_BUTTON3
                        invoke FileOpenDialog,hWin
                .elseif eax == IDC_BUTTON4
                        invoke FileSaveDialog,hWin
                .elseif eax == IDC_BUTTON5
                        invoke PrintDialog,hWin
                .elseif eax == IDC_BUTTON6
                        invoke PageSetupDialog,hWin
                .elseif eax == IDC_BUTTON7
                        invoke FindTextDialog,hWin
                .elseif eax == IDC_BUTTON8
                        invoke FindReplaceDialog,hWin 
                .elseif eax == IDC_EXIT
                        invoke SendMessage,hWin,WM_CLOSE,0,0
                .endif
    
        .elseif uMsg == WM_CLOSE
                invoke EndDialog,hWin,0
   
        .endif
        xor eax,eax
        ret
    
CommonDialogs endp
    
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
ColorDialog proc hwnd:DWORD

          ; -------------------------------------
          ; Initialize the CHOOSECOLOR structure.
          ; -------------------------------------
          invoke RtlZeroMemory,ADDR cc,SIZEOF cc 
          mov cc.lStructSize,SIZEOF cc
          mov eax,hwnd
          mov cc.hwndOwner,eax
          mov eax,OFFSET aryCustClr
          mov cc.lpCustColors,eax
          mov eax,rgbCurrent
          mov cc.rgbResult,eax
          mov cc.Flags,CC_FULLOPEN or CC_RGBINIT
          ; -------------------------------------
          ; Call the Color Common Control dialog.
          ; -------------------------------------
          invoke ChooseColor,ADDR cc
          ; -------------------------------------------------------
          ; If OK button is clicked the return value is NONZERO and
          ; the rgbResult member of the CHOOSECOLOR struct contains
          ; RGB color value. If Cancel or [X] clicked in the Color
          ; dialog box or an error occurs the return value is ZERO. 
          ; -------------------------------------------------------
          ret

ColorDialog endp

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

FontDialog proc hwnd:DWORD

          ; ------------------------------------
          ; Initialize the CHOOSEFONT structure.
          ; ------------------------------------
          invoke RtlZeroMemory,ADDR cf,SIZEOF cf 
          mov cf.lStructSize,SIZEOF cf
          mov eax,hwnd
          mov cf.hwndOwner,eax
          mov eax,OFFSET lf 
          mov cf.lpLogFont,eax
          mov eax,rgbCurrnt
          mov cf.rgbColors,eax
          mov cf.Flags,CF_SCREENFONTS or CF_EFFECTS or CF_INITTOLOGFONTSTRUCT
          ; -------------------------------------
          ; Call the Font Common Control dialog.
          ; -------------------------------------
          invoke ChooseFont,ADDR cf
          ; -------------------------------------------------------
          ; If OK button is clicked return value is TRUE and the
          ; members of the CHOOSEFONT structure contains the users
          ; selections. If Cancel or [X] clicked in the Font dialog
          ; box or an error occurs the return value is FALSE.
          ; -------------------------------------------------------
          ret

FontDialog endp

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

FileOpenDialog proc hwnd:DWORD

          ; --------------------------------------
          ; Initialize the OPENFILENAME structure.
          ; --------------------------------------
          invoke RtlZeroMemory,ADDR ofn,SIZEOF ofn
          mov ofn.lStructSize,SIZEOF ofn
          mov eax,hwnd
          mov ofn.hwndOwner,eax
          mov eax,OFFSET szFile
          mov ofn.lpstrFile,eax
          mov ofn.nMaxFile,SIZEOF szFile
          mov eax,OFFSET strFilter
          mov ofn.lpstrFilter,eax
          mov ofn.nFilterIndex,1
          mov ofn.lpstrFileTitle,0
          mov ofn.nMaxFileTitle,0
          mov ofn.lpstrInitialDir,0
          mov ofn.Flags,OFN_PATHMUSTEXIST
          ; -----------------------------------------
          ; Call the File Open Common Control dialog.
          ; -----------------------------------------
          invoke GetOpenFileName,ADDR ofn 
          ; -------------------------------------------------------
          ; If user picks a file name and clicks the OK button the
          ; return value is NONZERO. The buffer pointed to by the
          ; lpstrFile member contains the full path and file name
          ; choosen. If Cancel or [X] is clicked or an error occurs
          ; the return value is ZERO.
          ; -------------------------------------------------------
          ret

FileOpenDialog endp
    
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FileSaveDialog proc hwnd:DWORD

          ; --------------------------------------
          ; Initialize the OPENFILENAME structure.
          ; --------------------------------------
          invoke RtlZeroMemory,ADDR ofn,SIZEOF ofn
          mov ofn.lStructSize,SIZEOF ofn
          mov eax,hwnd
          mov ofn.hwndOwner,eax
          mov eax,OFFSET szFile
          mov ofn.lpstrFile,eax
          mov ofn.nMaxFile,SIZEOF szFile
          mov eax,OFFSET strFilter
          mov ofn.lpstrFilter,eax
          mov ofn.nFilterIndex,1
          mov ofn.lpstrFileTitle,0
          mov ofn.nMaxFileTitle,0
          mov ofn.lpstrInitialDir,0
          mov ofn.Flags,OFN_PATHMUSTEXIST
          ; -----------------------------------------
          ; Call the File Save Common Control dialog.
          ; -----------------------------------------
          invoke GetSaveFileName,ADDR ofn 
          ; -----------------------------------------------------------
          ; If the user specifies a file name and clicks the OK button
          ; and the function is successful the return value is NONZERO.
          ; The buffer pointed to by the lpstrFile member contains the
          ; full path and file name specified by the user. If Cancel or
          ; [X] is clicked or an error occurs the return value is ZERO.
          ; -----------------------------------------------------------
          ret

FileSaveDialog endp
    
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

PrintDialog proc hwnd:DWORD

          ; ----------------------------------
          ; Initialize the PRINTDLG structure.
          ; ----------------------------------
          invoke RtlZeroMemory,ADDR pd,SIZEOF pd
          mov pd.lStructSize,SIZEOF pd
          mov eax,hwnd
          mov pd.hwndOwner,eax
          mov pd.hDevMode,0
          mov pd.hDevNames,0
          mov pd.Flags,PD_ALLPAGES
          mov pd.nCopies,1
          mov pd.nFromPage,1 
          mov pd.nToPage,1 
          mov pd.nMinPage,1 
          mov pd.nMaxPage,2 
          ; ---------------------------------------
          ; Call the Printer Common Control dialog.
          ; ---------------------------------------
          invoke PrintDlg,ADDR pd 
          ; -----------------------------------------------------
          ; If user clicks OK button the return value is NONZERO.
          ; The members of the PRINTDLG struct indicates the users
          ; selections. If Cancel or [X] is clicked or an error
          ; occurs the return value is ZERO.
          ; -----------------------------------------------------
          ret

PrintDialog endp

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

PageSetupDialog proc hwnd:DWORD

          ; --------------------------------------
          ; Initialize the PAGESETUPDLG structure.
          ; --------------------------------------
          invoke RtlZeroMemory,ADDR psd,SIZEOF psd
          mov psd.lStructSize,SIZEOF psd
          mov eax,hwnd
          mov psd.hwndOwner,eax
          mov psd.hDevMode,0
          mov psd.hDevNames,0
          mov psd.Flags,PSD_INTHOUSANDTHSOFINCHES or PSD_MARGINS
;          mov psd.Flags,PSD_INHUNDREDTHSOFMILLIMETERS or PSD_MARGINS
          mov psd.rtMargin.top,0
          mov psd.rtMargin.left,0
          mov psd.rtMargin.right,0
          mov psd.rtMargin.bottom,0
          mov psd.lpfnPagePaintHook,0
          ; -----------------------------------------
          ; Call the PageSetup Common Control dialog.
          ; -----------------------------------------
          invoke PageSetupDlg,ADDR psd
          ; -----------------------------------------------------
          ; If user clicks OK button the return value is NONZERO.
          ; The members of the PAGESETUPDLG struct indicates the
          ; users selections. If Cancel or [X] is clicked or an
          ; error occurs the return value is ZERO.
          ; -----------------------------------------------------
          ret 

PageSetupDialog endp

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

FindTextDialog proc hwnd:DWORD

          ; -------------------------------------
          ; Initialize the FINDREPLACE structure.
          ; -------------------------------------
          invoke RtlZeroMemory,ADDR fr,SIZEOF fr
          mov fr.lStructSize,SIZEOF fr
          mov eax,hwnd
          mov fr.hwndOwner,eax
          mov eax,OFFSET szFindWhat
          mov fr.lpstrFindWhat,eax
          mov fr.wFindWhatLen,80
          mov fr.Flags,FR_DOWN or FR_WHOLEWORD
          ; ----------------------------------------
          ; Call the FindText Common Control dialog.
          ; ----------------------------------------
          invoke FindText,ADDR fr
          ; -------------------------------------------------------
          ; If the function succeeds the return value is the window
          ; handle to the dialog box. You can use the window handle
          ; to communicate with or to close the dialog box. If the
          ; function fails the return value is ZERO.
          ; -------------------------------------------------------
          ret

FindTextDialog endp

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

FindReplaceDialog proc hwnd:DWORD

          ; -------------------------------------
          ; Initialize the FINDREPLACE structure.
          ; -------------------------------------
          invoke RtlZeroMemory,ADDR fr,SIZEOF fr
          mov fr.lStructSize,SIZEOF fr
          mov eax,hwnd
          mov fr.hwndOwner,eax
          mov eax,OFFSET szFindWhat
          mov fr.lpstrFindWhat,eax
          mov fr.wFindWhatLen,80
          mov eax,OFFSET szReplaceWith
          mov fr.lpstrReplaceWith,eax
          mov fr.wReplaceWithLen,80
          mov fr.Flags,FR_WHOLEWORD
          ; -------------------------------------------
          ; Call the ReplaceText Common Control dialog.
          ; -------------------------------------------
          invoke ReplaceText,ADDR fr
          ; -------------------------------------------------------
          ; If the function succeeds the return value is the window
          ; handle to the dialog box. You can use the window handle
          ; to communicate with or to close the dialog box. If the
          ; function fails the return value is ZERO.
          ; -------------------------------------------------------
          ret

FindReplaceDialog endp

; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

end start






