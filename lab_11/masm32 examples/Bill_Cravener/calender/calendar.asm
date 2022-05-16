; ####################################################
;       William F. Cravener 5/15/2003
; ####################################################

        .486
        .model flat,stdcall
        option casemap:none   ; case sensitive

; ####################################################

        include \masm32\include\windows.inc
        include \masm32\include\user32.inc
        include \masm32\include\kernel32.inc
        include \masm32\include\gdi32.inc
        include \masm32\include\comctl32.inc

        includelib \masm32\lib\user32.lib
        includelib \masm32\lib\kernel32.lib
        includelib \masm32\lib\gdi32.lib
        includelib \masm32\lib\comctl32.lib

; ####################################################

        DTN_CLOSEUP equ DTN_FIRST + 7
        ID_DATETIMEPICKER equ 100
        ID_BUTTON equ 300
        ID_TIMER equ 400

        MAX_XYSTEPS equ 5
        DELAY_VALUE equ 15   ; Increase/decrease value to slow down speed up effect.
        X_STEP_SIZE equ 100
        Y_STEP_SIZE equ 90
        X_START_SIZE equ 20
        Y_START_SIZE equ 10

        LMA_ALPHA equ 2
        LMA_COLORKEY equ 1
        WS_EX_LAYERED equ 80000h

; ----------------------------------------------------

        MonthCalendar PROTO :DWORD,:DWORD,:DWORD,:DWORD
        AnimateOpen PROTO :DWORD
        AnimateClose PROTO :DWORD
        FadeInOpen PROTO :DWORD
        FadeOutClose PROTO :DWORD
        Paint_Goofy_Eyes PROTO :DWORD
        Paint_Goofy_Title PROTO :DWORD
        TopXY PROTO :DWORD,:DWORD

; ----------------------------------------------------

    .data
        hInstance dd ?
        libhandle dd ?
        vardelay dd 0
        counts dd 0
        Xplace dd 0
        Yplace dd 0
        Xsize dd 0
        Ysize dd 0
        Value dd 0
        sWth dd 0
        sHth dd 0
        pSLWA dd ?
        bitmapflag dd 0
        DatePicker db "The date you picked is:",0
        DateString db 20 dup (0)
        dlgname db "Calendar",0
        User32 db "User32.dll",0
        SLWA db "SetLayeredWindowAttributes",0
        lib_name db "\comctl32.dll",0
        d_buffer db MAX_PATH + 1 dup (?)

; --------------------------------------------------------------------------

    .data?
        VerInfo OSVERSIONINFO <> ;structure for OS version info 
        icex INITCOMMONCONTROLSEX <> ;structure for Calender and Date Picker

; --------------------------------------------------------------------------

    .code

start:

; ###############################################################

        invoke GetModuleHandle,NULL
        mov hInstance,eax

; ------------------------------------------------------
; The Month Calendar control and Date Picker control are
; implemented in version 4.70 and later of Comctl32.dll.
; ------------------------------------------------------ 
        mov icex.dwSize,sizeof INITCOMMONCONTROLSEX
        mov icex.dwICC,ICC_DATE_CLASSES
        invoke InitCommonControlsEx,ADDR icex

; -------------------------------------------
; Call the dialog box stored in resource file
; -------------------------------------------
        invoke DialogBoxParam,hInstance,ADDR dlgname,0,ADDR MonthCalendar,0
        invoke ExitProcess,0

; ###############################################################

MonthCalendar proc hWin:DWORD,uMsg:DWORD,aParam:DWORD,bParam:DWORD

    LOCAL Ps:PAINTSTRUCT

        .if uMsg == WM_INITDIALOG
                    mov VerInfo.dwOSVersionInfoSize,sizeof OSVERSIONINFO
                    invoke GetVersionEx,ADDR VerInfo
                    .if VerInfo.dwMajorVersion >= 5   ; Win2000 or XP ?
                        invoke FadeInOpen,hWin
                    .else
                        invoke AnimateOpen,hWin
                    .endif
                    invoke SetTimer,hWin,ID_TIMER,5000,0
                    invoke SetFocus,hWin

        .elseif uMsg == WM_COMMAND
                        mov eax,aParam
                        .if eax == ID_BUTTON
                            invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
                        .endif

        .elseif uMsg == WM_NOTIFY
                        mov eax,bParam
                        mov eax,(NMHDR PTR [eax]).code
                        .if eax == DTN_CLOSEUP
                            mov eax,aParam
                            .if eax == ID_DATETIMEPICKER
                                invoke GetDlgItemText,hWin,ID_DATETIMEPICKER,ADDR DateString,20 
                                invoke MessageBox,hWin,ADDR DateString,ADDR DatePicker,MB_OK
                            .endif 
                        .endif

        .elseif uMsg == WM_PAINT
                        invoke BeginPaint,hWin,ADDR Ps
                        invoke Paint_Goofy_Eyes,hWin
                        invoke Paint_Goofy_Title,hWin 
                        invoke EndPaint,hWin,ADDR Ps

        .elseif uMsg == WM_CLOSE
                        .if VerInfo.dwMajorVersion >= 5   ; Win2000 or XP ?
                            invoke FadeOutClose,hWin
                        .else
                            invoke AnimateClose,hWin
                        .endif
                        invoke KillTimer,hWin,ID_TIMER
                        invoke EndDialog,hWin,NULL

        .elseif uMsg == WM_TIMER
                        mov bitmapflag,1
                        invoke Paint_Goofy_Eyes,hWin
                        invoke Sleep,200
                        mov bitmapflag,0
                        invoke Paint_Goofy_Eyes,hWin

        .endif

        xor eax,eax
        ret
                    
MonthCalendar endp

; ###############################################################

AnimateOpen proc hWin:DWORD

    LOCAL Rct:RECT

;-----------------------------------------------------------
; This is a simple method to animate the opening of a dialog
; box by making the dialog appear to be expanding outward.
;-----------------------------------------------------------
                    invoke GetWindowRect,hWin,ADDR Rct
                    mov Xsize,X_START_SIZE
                    mov Ysize,Y_START_SIZE
                    invoke GetSystemMetrics,SM_CXSCREEN
                    mov sWth,eax
                    invoke TopXY,Xsize,eax
                    mov Xplace,eax
                    invoke GetSystemMetrics,SM_CYSCREEN
                    mov sHth,eax
                    invoke TopXY,Ysize,eax
                    mov Yplace,eax
                    mov counts,MAX_XYSTEPS
                    aniloop:
                    invoke MoveWindow,hWin,Xplace,Yplace,Xsize,Ysize,FALSE
                    invoke ShowWindow,hWin,SW_SHOWNA
                    invoke Sleep,DELAY_VALUE
                    invoke ShowWindow,hWin,SW_HIDE
                    add Xsize,X_STEP_SIZE
                    add Ysize,Y_STEP_SIZE
                    invoke TopXY,Xsize,sWth
                    mov Xplace,eax
                    invoke TopXY,Ysize,sHth
                    mov Yplace,eax
                    dec counts
                    jnz aniloop
                    mov eax,Rct.left
                    mov ecx,Rct.right
                    sub ecx,eax
                    mov Xsize,ecx
                    mov eax,Rct.top
                    mov ecx,Rct.bottom
                    sub ecx,eax
                    mov Ysize,ecx
                    invoke TopXY,Xsize,sWth
                    mov Xplace,eax
                    invoke TopXY,Ysize,sHth
                    mov Yplace,eax
                    invoke MoveWindow,hWin,Xplace,Yplace,Xsize,Ysize,TRUE 
                    ret 

AnimateOpen endp

; ###############################################################

AnimateClose proc hWin:DWORD

    LOCAL Rct:RECT

;-----------------------------------------------------------
; This is a simple method to animate the closing of a dialog
; box by making the dialog appear to shrink away to nothing.
;-----------------------------------------------------------
                    invoke ShowWindow,hWin,SW_HIDE
                    invoke GetWindowRect,hWin,ADDR Rct
                    mov eax,Rct.left
                    mov ecx,Rct.right
                    sub ecx,eax
                    mov Xsize,ecx
                    mov eax,Rct.top
                    mov ecx,Rct.bottom
                    sub ecx,eax
                    mov Ysize,ecx
                    invoke GetSystemMetrics,SM_CXSCREEN
                    mov sWth,eax
                    invoke TopXY,Xsize,eax
                    mov Xplace,eax
                    invoke GetSystemMetrics,SM_CYSCREEN
                    mov sHth,eax
                    invoke TopXY,Ysize,eax
                    mov Yplace,eax
                    mov counts,MAX_XYSTEPS
                    aniloop:
                    invoke MoveWindow,hWin,Xplace,Yplace,Xsize,Ysize,FALSE 
                    invoke ShowWindow,hWin,SW_SHOWNA
                    invoke Sleep,DELAY_VALUE
                    invoke ShowWindow,hWin,SW_HIDE
                    sub Xsize,X_STEP_SIZE
                    sub Ysize,Y_STEP_SIZE
                    invoke TopXY,Xsize,sWth
                    mov Xplace,eax
                    invoke TopXY,Ysize,sHth
                    mov Yplace,eax
                    dec counts
                    jnz aniloop
                    ret 

AnimateClose endp

; ###############################################################

FadeInOpen proc hWin:DWORD

; ------------------------------------------------------------------------------------
; This function enables changing the opacity and transparency color keys of a layered
; window. To do this to a dialog we first need to set the dialog extended window style
; to a layered window style. This only works with Windows 2000 or Windows XP OS's.
; ------------------------------------------------------------------------------------
                    invoke GetWindowLongA,hWin,GWL_EXSTYLE
                    or eax,WS_EX_LAYERED
                    invoke SetWindowLongA,hWin,GWL_EXSTYLE,eax
                    invoke GetModuleHandleA,ADDR User32
                    invoke GetProcAddress,eax,ADDR SLWA
                    mov pSLWA,eax
                    push LMA_ALPHA
                    push 0 
                    push 0
                    push hWin
                    call pSLWA
                    mov Value,90
                    invoke ShowWindow,hWin,SW_SHOWNA
                    doloop:
                    push LMA_COLORKEY + LMA_ALPHA
                    push Value
                    push Value
                    push hWin
                    call pSLWA
                    invoke Sleep,DELAY_VALUE
                    add Value,15
                    cmp Value,255
                    jne doloop
                    push LMA_ALPHA
                    push 255
                    push 0
                    push hWin
                    call pSLWA
                    ret 

FadeInOpen endp

; ###############################################################

FadeOutClose proc hWin:DWORD

; ------------------------------------------------------------------------------------
; This function enables changing the opacity and transparency color keys of a layered
; window. To do this to a dialog we first need to set the dialog extended window style
; to a layered window style. This only works with Windows 2000 or Windows XP OS's.
; ------------------------------------------------------------------------------------
                    invoke GetWindowLongA,hWin,GWL_EXSTYLE
                    or eax,WS_EX_LAYERED
                    invoke SetWindowLongA,hWin,GWL_EXSTYLE,eax
                    invoke GetModuleHandleA,ADDR User32
                    invoke GetProcAddress,eax,ADDR SLWA
                    mov pSLWA,eax
                    push LMA_ALPHA
                    push 255
                    push 0
                    push hWin
                    call pSLWA
                    mov Value,255
                    doloop:
                    push LMA_COLORKEY + LMA_ALPHA
                    push Value
                    push Value
                    push hWin
                    call pSLWA
                    invoke Sleep,DELAY_VALUE
                    sub Value,15
                    cmp Value,0
                    jne doloop
                    ret

FadeOutClose endp

; ###############################################################

Paint_Goofy_Eyes proc hWin:DWORD

    LOCAL hDC:DWORD
    LOCAL hBmp:DWORD
    LOCAL memDC:DWORD

; -----------------------------------------------------------------
; You could instead of GetDC us GetWindowDC which retrieves the DC
; for the entire window including titlebar, menus, and scroll bars.
; -----------------------------------------------------------------
                    invoke GetDC,hWin
                    mov hDC,eax
                    invoke CreateCompatibleDC,hDC
                    mov memDC,eax
                    .if bitmapflag == 0
                        invoke LoadImage,hInstance,600,IMAGE_BITMAP,0,0,
                                         LR_LOADTRANSPARENT or LR_LOADMAP3DCOLORS
                    .else
                        invoke LoadImage,hInstance,700,IMAGE_BITMAP,0,0,
                                         LR_LOADTRANSPARENT or LR_LOADMAP3DCOLORS
                    .endif
                    mov hBmp,eax
                    invoke SelectObject,memDC,hBmp
                    invoke BitBlt,hDC,20,13,44,21,memDC,0,0,SRCCOPY
                    invoke DeleteObject,hBmp
                    invoke DeleteDC,memDC
                    invoke ReleaseDC,hWin,hDC
                    ret

Paint_Goofy_Eyes endp

; ###############################################################

Paint_Goofy_Title proc hWin:DWORD

    LOCAL hDC:DWORD
    LOCAL hBmp:DWORD
    LOCAL memDC:DWORD

; -----------------------------------------------------------------
; You could instead of GetDC us GetWindowDC which retrieves the DC
; for the entire window including titlebar, menus, and scroll bars.
; -----------------------------------------------------------------
                    invoke GetDC,hWin
                    mov hDC,eax
                    invoke CreateCompatibleDC,hDC
                    mov memDC,eax
                    invoke LoadImage,hInstance,800,IMAGE_BITMAP,0,0,
                                     LR_LOADTRANSPARENT or LR_LOADMAP3DCOLORS
                    mov hBmp,eax
                    invoke SelectObject,memDC,hBmp
                    invoke BitBlt,hDC,65,18,142,13,memDC,0,0,SRCCOPY
                    invoke DeleteObject,hBmp
                    invoke DeleteDC,memDC
                    invoke ReleaseDC,hWin,hDC
                    ret

Paint_Goofy_Title endp

; ###############################################################

TopXY proc wDim:DWORD,sDim:DWORD

                    shr sDim,1 
                    shr wDim,1
                    mov eax,wDim
                    sub sDim,eax
                    mov eax,sDim
                    ret

TopXY endp

; ###############################################################

end start
