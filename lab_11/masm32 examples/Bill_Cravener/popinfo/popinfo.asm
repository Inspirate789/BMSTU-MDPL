; ####################################################
;       William F. Cravener 8/4/2003
; ####################################################
    
        .486
        .model flat,stdcall
        option casemap:none   ; case sensitive
    
; ####################################################
    
        include \masm32\include\windows.inc
        include \masm32\include\user32.inc
        include \masm32\include\kernel32.inc
        include \masm32\include\comctl32.inc

        includelib \masm32\lib\user32.lib
        includelib \masm32\lib\kernel32.lib
        includelib \masm32\lib\comctl32.lib
    
; ####################################################

        IDC_EDIT1   equ 201
        IDC_SLIDER1 equ 301
        IDC_STATIC  equ -1

; --------------------------------------------------------
    
        PopUpHelp PROTO :DWORD,:DWORD,:DWORD,:DWORD

; --------------------------------------------------------
    
.data
        hInstance dd ?

        dlgname   db "POPUPINFO",0

        HelpPath  db ".\Sample.hlp",0

        HelpArray dd IDC_EDIT1    ; Edit control ID
                  dd 1001         ; Help file context ID
                  dd IDC_SLIDER1  ; Slider control ID
                  dd 1002         ; Help file context ID
                  dd 0            ; The array must end 
                  dd 0            ; in a pair of zero's 

.data?
        icex INITCOMMONCONTROLSEX <> ;structure for Controls

   
; ###############################################################
    
.code
    
start:
        invoke GetModuleHandle,NULL
        mov hInstance,eax
        mov icex.dwSize,sizeof INITCOMMONCONTROLSEX
        mov icex.dwICC,ICC_DATE_CLASSES
        invoke InitCommonControlsEx,ADDR icex
    
; ---------------------------------------------
;   Call the dialog box stored in resource file
; ---------------------------------------------
        invoke DialogBoxParam,hInstance,ADDR dlgname,0,ADDR PopUpHelp,0
        invoke ExitProcess,eax
    
; ###############################################################
    
PopUpHelp proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
    
    LOCAL hItem:DWORD	
    
            .if uMsg == WM_INITDIALOG
                invoke SetFocus,hWin
    
        .elseif uMsg == WM_COMMAND

        .elseif uMsg == WM_CLOSE
                invoke EndDialog,hWin,NULL
   
        .elseif uMsg == WM_HELP
                ;-------------------------------------------------------  
                ; The lParam holds the address of the HELPINFO structure
                ;-------------------------------------------------------
                mov eax,lParam
                mov eax,(HELPINFO PTR [eax]).hItemHandle
                mov hItem,eax
                ;-----------------------------------
                ; Get the handle of the edit control
                ;-----------------------------------
                invoke GetDlgItem,hWin,IDC_EDIT1
                .if eax == hItem
                    invoke WinHelp,eax,ADDR HelpPath,HELP_WM_HELP,ADDR HelpArray
                .endif
                ;-------------------------------------
                ; Get the handle of the slider control
                ;-------------------------------------
                invoke GetDlgItem,hWin,IDC_SLIDER1
                .if eax == hItem
                    invoke WinHelp,eax,ADDR HelpPath,HELP_WM_HELP,ADDR HelpArray
                .endif
        .endif
    
        xor eax,eax
        ret
    
PopUpHelp endp
    
; ###############################################################
    
end start
