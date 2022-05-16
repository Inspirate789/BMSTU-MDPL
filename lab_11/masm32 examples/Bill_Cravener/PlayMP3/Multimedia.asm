; ####################################################
;       William F. Cravener 10/15/2008
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
        PlayMp3File PROTO :DWORD,:DWORD

; --------------------------------------------------------
    
.data
        hInstance   dd ?

        Mp3DeviceID dd 0

        PlayFlag    dd 0

        Mp3Files    db "*.mp3",125 dup (0)

        Mp3Device   db "MPEGVideo",0

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
        invoke InitCommonControlsEx,ADDR icex
    
        ; ---------------------------------------------
        ; Call the dialog box stored in resource file
        ; ---------------------------------------------
        invoke DialogBoxParam,hInstance,ADDR dlgname,0,ADDR Multimedia,0
        invoke ExitProcess,eax
    
; ###############################################################
    
Multimedia proc hWin:DWORD,uMsg:DWORD,aParam:DWORD,bParam:DWORD
    
    
        .if uMsg == WM_INITDIALOG
                    invoke DlgDirList,hWin,ADDR Mp3Files,ID_LIST1,ID_SHOWPATH,DDL_DIRECTORY or DDL_DRIVES
                    invoke SendDlgItemMessage,hWin,ID_LIST1,LB_SETCURSEL,0,0
                    invoke SendDlgItemMessage,hWin,ID_LIST1,LB_GETTEXT,eax,ADDR FileName
                    invoke SetFocus,hWin
    
        .elseif uMsg == WM_COMMAND
                        mov eax,aParam
                        .if eax == ID_BUTTON1
                            ;--------------------
                            ; Play button pressed
                            ;--------------------
                            .if PlayFlag == 0
                                mov PlayFlag,1  
                                invoke SendDlgItemMessage,hWin,ID_LIST1,LB_GETCURSEL,0,0
                                invoke SendDlgItemMessage,hWin,ID_LIST1,LB_GETTEXT,eax,ADDR FileName
                                invoke PlayMp3File,hWin,ADDR FileName
                            .endif

                        .elseif eax == ID_BUTTON2
                                ;-------------------------------
                                ; Stop mp3 play and close device
                                ;-------------------------------
                                invoke mciSendCommand,Mp3DeviceID,MCI_CLOSE,0,0
                                mov PlayFlag,0

                        .elseif eax == ID_BUTTON3
                                ;------------------------
                                ; Close player dialog box
                                ;------------------------
                                invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
                        .endif

                        and eax,0FFFFh  
                        .if eax == ID_LIST1
                            mov eax,aParam
                            shr eax,16
                            .if eax == LBN_DBLCLK
                            ;-------------------------------------
                            ; We double clicked on a list box item
                            ;-------------------------------------
                                invoke DlgDirSelectEx,hWin,ADDR Mp3Files,128,ID_LIST1
                                invoke DlgDirList,hWin,ADDR Mp3Files,ID_LIST1,ID_SHOWPATH,DDL_DIRECTORY or DDL_DRIVES
                                invoke SendDlgItemMessage,hWin,ID_LIST1,LB_SETCURSEL,0,0
                            .endif 
                        .endif
   
        .elseif uMsg == WM_CLOSE
                        invoke EndDialog,hWin,NULL
     
        .elseif uMsg == MM_MCINOTIFY
                        ;-----------------------------------------------------
                        ; Sent when media play completes and closes mp3 device
                        ;-----------------------------------------------------
                        invoke mciSendCommand,Mp3DeviceID,MCI_CLOSE,0,0
                        mov PlayFlag,0
    
        .endif
    
        xor eax,eax
        ret
    
Multimedia endp
    
; ###############################################################

PlayMp3File proc hWin:DWORD,NameOfFile:DWORD

      LOCAL mciOpenParms:MCI_OPEN_PARMS,mciPlayParms:MCI_PLAY_PARMS

            mov eax,hWin        
            mov mciPlayParms.dwCallback,eax
            mov eax,OFFSET Mp3Device
            mov mciOpenParms.lpstrDeviceType,eax
            mov eax,NameOfFile
            mov mciOpenParms.lpstrElementName,eax
            invoke mciSendCommand,0,MCI_OPEN,MCI_OPEN_TYPE or MCI_OPEN_ELEMENT,ADDR mciOpenParms
            mov eax,mciOpenParms.wDeviceID
            mov Mp3DeviceID,eax
            invoke mciSendCommand,Mp3DeviceID,MCI_PLAY,MCI_NOTIFY,ADDR mciPlayParms
            ret  

PlayMp3File endp

; ###############################################################

end start
