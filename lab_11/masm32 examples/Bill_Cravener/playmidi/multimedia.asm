; ####################################################
;       William F. Cravener 5/27/2003
; ####################################################
    
        .486
        .model flat,stdcall
        option casemap:none   ; case sensitive
    
; ####################################################
    
        include \masm32\include\windows.inc
        include \masm32\include\user32.inc
        include \masm32\include\kernel32.inc
        include \masm32\include\comctl32.inc
        include \masm32\include\winmm.inc

        includelib \masm32\lib\user32.lib
        includelib \masm32\lib\kernel32.lib
        includelib \masm32\lib\comctl32.lib
        includelib \masm32\lib\winmm.lib
    
; ####################################################

        ID_LIST1 equ 101

        ID_BUTTON1 equ 201
        ID_BUTTON2 equ 202
        ID_BUTTON3 equ 203

        ID_SHOWPATH equ 1000

; --------------------------------------------------------
    
        Multimedia PROTO :DWORD,:DWORD,:DWORD,:DWORD
        PlayMidiFile PROTO :DWORD,:DWORD

; --------------------------------------------------------
    
.data
        hInstance   dd ?

        MidDeviceID dd 0

        PlayFlag    dd 0

        AllFiles    db "*.*",125 dup (0)

        szMIDISeqr  db "Sequencer",0

        FileName    db 128 dup (0)

        dlgname     db "MAINSCREEN",0

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
        invoke DialogBoxParam,hInstance,ADDR dlgname,0,ADDR Multimedia,0
        invoke ExitProcess,eax
    
; ###############################################################
    
Multimedia proc hWin:DWORD,uMsg:DWORD,aParam:DWORD,bParam:DWORD
    
    
        .if uMsg == WM_INITDIALOG
                    invoke DlgDirList,hWin,ADDR AllFiles,ID_LIST1,ID_SHOWPATH,DDL_DIRECTORY or DDL_DRIVES
                    invoke SendDlgItemMessage,hWin,ID_LIST1,LB_SETCURSEL,0,0
                    invoke SendDlgItemMessage,hWin,ID_LIST1,LB_GETTEXT,eax,ADDR FileName
                    invoke SetFocus,hWin
    
        .elseif uMsg == WM_COMMAND
                        mov eax,aParam
                        .if eax == ID_BUTTON1
                            .if PlayFlag == 0
                                mov PlayFlag,1  
                                invoke SendDlgItemMessage,hWin,ID_LIST1,LB_GETCURSEL,0,0
                                invoke SendDlgItemMessage,hWin,ID_LIST1,LB_GETTEXT,eax,ADDR FileName
                                invoke PlayMidiFile,hWin,ADDR FileName
                            .endif

                        .elseif eax == ID_BUTTON2
                                ; Stop midi play and close device
                                invoke mciSendCommand,MidDeviceID,MCI_CLOSE,0,0
                                mov PlayFlag,0

                        .elseif eax == ID_BUTTON3
                                invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
                        .endif

                        and eax,0FFFFh  
                        .if eax == ID_LIST1
                            mov eax,aParam
                            shr eax,16
                            ;  Did we double click list box
                            .if eax == LBN_DBLCLK
                                invoke DlgDirSelectEx,hWin,ADDR AllFiles,128,ID_LIST1
                                invoke DlgDirList,hWin,ADDR AllFiles,ID_LIST1,ID_SHOWPATH,DDL_DIRECTORY or DDL_DRIVES
                                invoke SendDlgItemMessage,hWin,ID_LIST1,LB_SETCURSEL,0,0
                            .endif 
                        .endif
   
        .elseif uMsg == WM_CLOSE
                        invoke EndDialog,hWin,NULL
     
        .elseif uMsg == MM_MCINOTIFY
                        ; sent when media play completes and closes midi device
                        invoke mciSendCommand,MidDeviceID,MCI_CLOSE,0,0
                        mov PlayFlag,0
    
        .endif
    
        xor eax,eax
        ret
    
Multimedia endp
    
; ###############################################################

PlayMidiFile proc hWin:DWORD,NameOfFile:DWORD

      LOCAL mciOpenParms:MCI_OPEN_PARMS,mciPlayParms:MCI_PLAY_PARMS

            mov eax,hWin        
            mov mciPlayParms.dwCallback,eax
            mov eax,OFFSET szMIDISeqr
            mov mciOpenParms.lpstrDeviceType,eax
            mov eax,NameOfFile
            mov mciOpenParms.lpstrElementName,eax
            invoke mciSendCommand,0,MCI_OPEN,MCI_OPEN_TYPE or MCI_OPEN_ELEMENT,ADDR mciOpenParms
            mov eax,mciOpenParms.wDeviceID
            mov MidDeviceID,eax
            invoke mciSendCommand,MidDeviceID,MCI_PLAY,MCI_NOTIFY,ADDR mciPlayParms
            ret  

PlayMidiFile endp

; ###############################################################

end start
