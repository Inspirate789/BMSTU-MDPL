; ####################################################
;       William F. Cravener 5/14/2003
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

        ID_SPIN1 equ 101
        ID_SPIN2 equ 102

        ID_SLIDER1 equ 201
        ID_SLIDER2 equ 202

        ID_SCROLLBAR1 equ 301
        ID_SCROLLBAR2 equ 302

        ID_PROGRESS1 equ 401
        ID_PROGRESS2 equ 402

        ID_EDIT1 equ 501
        ID_EDIT2 equ 502

; --------------------------------------------------------
    
        ControlsMadness PROTO :DWORD,:DWORD,:DWORD,:DWORD
        SetControlsPosition PROTO :DWORD
    
; --------------------------------------------------------
    
.data
        hInstance dd ?

        NewPosition dd 0
    
        dlgname db "CONTROLS",0

.data?
        icex INITCOMMONCONTROLSEX <> ;structure for Controls
    
; ###############################################################
    
.code
    
start:
    
; ###############################################################
    
        invoke GetModuleHandle,NULL
        mov hInstance,eax
        mov icex.dwSize,sizeof INITCOMMONCONTROLSEX
        mov icex.dwICC,0FFFFh
        invoke InitCommonControlsEx,ADDR icex
    
; ---------------------------------------------
;   Call the dialog box stored in resource file
; ---------------------------------------------
        invoke DialogBoxParam,hInstance,ADDR dlgname,0,ADDR ControlsMadness,0
        invoke ExitProcess,eax
    
; ###############################################################
    
ControlsMadness proc hWin:DWORD,uMsg:DWORD,aParam:DWORD,bParam:DWORD
    
    LOCAL Ps:PAINTSTRUCT
    
        .if uMsg == WM_INITDIALOG
                    invoke SendDlgItemMessage,hWin,ID_SPIN1,UDM_SETRANGE32,0,100
                    invoke SendDlgItemMessage,hWin,ID_SPIN2,UDM_SETRANGE32,0,100
                    invoke SendDlgItemMessage,hWin,ID_SLIDER1,TBM_SETRANGEMIN,FALSE,0
                    invoke SendDlgItemMessage,hWin,ID_SLIDER1,TBM_SETRANGEMAX,FALSE,100
                    invoke SendDlgItemMessage,hWin,ID_SLIDER2,TBM_SETRANGEMIN,FALSE,0
                    invoke SendDlgItemMessage,hWin,ID_SLIDER2,TBM_SETRANGEMAX,FALSE,100
                    invoke SendDlgItemMessage,hWin,ID_SCROLLBAR1,SBM_SETRANGE,0,100
                    invoke SendDlgItemMessage,hWin,ID_SCROLLBAR2,SBM_SETRANGE,0,100
                    invoke SendDlgItemMessage,hWin,ID_PROGRESS1,PBM_SETRANGE32,0,100
                    invoke SendDlgItemMessage,hWin,ID_PROGRESS2,PBM_SETRANGE32,0,100
                    invoke SetFocus,hWin
    
        .elseif uMsg == WM_COMMAND
    
        .elseif uMsg == WM_PAINT
    
        .elseif uMsg == WM_CLOSE
                        invoke EndDialog,hWin,NULL
   
        .elseif uMsg == WM_HSCROLL
                        mov eax,aParam
                        and eax,0FFFFh  
                        .if eax == TB_THUMBPOSITION ; Same as SB_THUMBPOSITION
                            mov eax,aParam
                            shr eax,16
                            mov NewPosition,eax
                            invoke SetControlsPosition,hWin
                        .elseif eax == TB_THUMBTRACK ; Same as SB_THUMBTRACK
                            mov eax,aParam
                            shr eax,16
                            mov NewPosition,eax
                            invoke SetControlsPosition,hWin
                        .elseif eax == SB_LINEUP
                            .if NewPosition != 0
                                dec NewPosition
                            .endif
                            invoke SetControlsPosition,hWin
                        .elseif eax == SB_LINEDOWN
                            .if NewPosition != 100
                                inc NewPosition
                            .endif 
                            invoke SetControlsPosition,hWin
                        .endif
    
        .elseif uMsg == WM_VSCROLL
                        mov eax,aParam
                        and eax,0FFFFh  
                        .if eax == TB_THUMBPOSITION
                            mov eax,aParam
                            shr eax,16
                            mov NewPosition,eax
                            invoke SetControlsPosition,hWin
                        .elseif eax == TB_THUMBTRACK
                            mov eax,aParam
                            shr eax,16
                            mov NewPosition,eax
                            invoke SetControlsPosition,hWin
                        .elseif eax == SB_LINEUP
                            .if NewPosition != 0
                                dec NewPosition
                            .endif
                            invoke SetControlsPosition,hWin
                        .elseif eax == SB_LINEDOWN
                            .if NewPosition != 100
                                inc NewPosition
                            .endif 
                            invoke SetControlsPosition,hWin
                        .endif
    
        .endif
    
        xor eax,eax
        ret
    
ControlsMadness endp
    
; ###############################################################
    
SetControlsPosition proc hWin:DWORD

        invoke SendDlgItemMessage,hWin,ID_SPIN1,UDM_SETPOS32,0,NewPosition
        invoke SendDlgItemMessage,hWin,ID_SPIN2,UDM_SETPOS32,0,NewPosition
        invoke SendDlgItemMessage,hWin,ID_SLIDER1,TBM_SETPOS,TRUE,NewPosition
        invoke SendDlgItemMessage,hWin,ID_SLIDER2,TBM_SETPOS,TRUE,NewPosition
        invoke SendDlgItemMessage,hWin,ID_SCROLLBAR1,SBM_SETPOS,NewPosition,TRUE
        invoke SendDlgItemMessage,hWin,ID_SCROLLBAR2,SBM_SETPOS,NewPosition,TRUE
        invoke SendDlgItemMessage,hWin,ID_PROGRESS1,PBM_SETPOS,NewPosition,0
        invoke SendDlgItemMessage,hWin,ID_PROGRESS2,PBM_SETPOS,NewPosition,0
        ret

SetControlsPosition endp
    
; ###############################################################
    
end start
