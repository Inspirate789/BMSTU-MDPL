; ####################################################
;       William F. Cravener Tue . 12/02/08
; ####################################################
    
        .486
        .model flat,stdcall
        option casemap:none   ; case sensitive
    
; ####################################################
    
        include \masm32\include\windows.inc
        include \masm32\include\user32.inc
        include \masm32\include\kernel32.inc

        includelib \masm32\lib\user32.lib
        includelib \masm32\lib\kernel32.lib
    
; ####################################################

; --------------------------------------------------------
    
        AniWindow PROTO :DWORD,:DWORD,:DWORD,:DWORD

; --------------------------------------------------------
    
.data
        hInstance   dd ?
        dlgname     db "MAINSCREEN",0

; ###############################################################
    
.code
    
start:
    
        invoke GetModuleHandle,NULL
        mov hInstance,eax
    
        ; ---------------------------------------------
        ; Call the dialog box stored in resource file
        ; ---------------------------------------------
        invoke DialogBoxParam,hInstance,ADDR dlgname,0,ADDR AniWindow,0
        invoke ExitProcess,eax
    
; ###############################################################
    
AniWindow proc hWin:DWORD,uMsg:DWORD,aParam:DWORD,bParam:DWORD
    
    
        .if uMsg == WM_INITDIALOG
                    invoke AnimateWindow,hWin,500,AW_ACTIVATE or AW_CENTER
                    invoke SetFocus,hWin
    
        .elseif uMsg == WM_COMMAND

        .elseif uMsg == WM_CLOSE
                    invoke AnimateWindow,hWin,500,AW_HIDE or AW_CENTER
                    invoke EndDialog,hWin,NULL
    
        .endif
    
        xor eax,eax
        ret
    
AniWindow endp
    
; ###############################################################

end start
