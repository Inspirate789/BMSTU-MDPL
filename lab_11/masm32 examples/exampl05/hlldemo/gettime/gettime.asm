; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

      .486                      ; create 32 bit code
      .model flat, stdcall      ; 32 bit memory model
      option casemap :none      ; case sensitive
  
;     include files
;     ~~~~~~~~~~~~~
      include \masm32\include\windows.inc
      include \masm32\include\masm32.inc
      include \masm32\include\gdi32.inc
      include \masm32\include\user32.inc
      include \masm32\include\kernel32.inc
      include \masm32\include\Comctl32.inc
      include \masm32\include\comdlg32.inc
      include \masm32\include\shell32.inc
      include \masm32\include\oleaut32.inc
      include \masm32\include\msvcrt.inc
      include \masm32\include\dialogs.inc
      include \masm32\macros\macros.asm

;     libraries
;     ~~~~~~~~~
      includelib \masm32\lib\masm32.lib
      includelib \masm32\lib\gdi32.lib
      includelib \masm32\lib\user32.lib
      includelib \masm32\lib\kernel32.lib
      includelib \masm32\lib\Comctl32.lib
      includelib \masm32\lib\comdlg32.lib
      includelib \masm32\lib\shell32.lib
      includelib \masm32\lib\oleaut32.lib
      includelib \masm32\lib\msvcrt.lib


      DlgProc PROTO :DWORD,:DWORD,:DWORD,:DWORD 

    .data?
      hWnd      dd ?
      hInstance dd ?

    .code

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

start:
  
      mov hInstance, FUNC(GetModuleHandle,NULL)
      call main
      invoke ExitProcess,eax

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

main proc

    Dialog "System Time", \                 ; caption
           "MS Sans Serif",10, \            ; font,pointsize
            WS_OVERLAPPED or \              ; styles for
            WS_SYSMENU or DS_CENTER, \      ; dialog window
            3, \                            ; number of controls
            50,50,155,100, \                ; x y co-ordinates
            1024                            ; memory buffer size

    DlgButton "Time",WS_TABSTOP,106,5,40,13,IDOK
    DlgButton "Cancel",WS_TABSTOP,106,20,40,13,IDCANCEL
    DlgStatic "Parse GetSystemTime API",SS_LEFT,5,5,100,9,100

    CallModalDialog hInstance,0,DlgProc,NULL

    ret

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

DlgProc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD 

    LOCAL str1:DWORD
    LOCAL str2:DWORD
    LOCAL str3:DWORD
    LOCAL str4:DWORD
    LOCAL str5:DWORD
    LOCAL str6:DWORD

    LOCAL hour:DWORD
    LOCAL minute:DWORD
    LOCAL second:DWORD

    LOCAL stm:SYSTEMTIME

    LOCAL buffer1[260]:BYTE
    LOCAL buffer2[260]:BYTE
    LOCAL buffer3[260]:BYTE
    LOCAL buffer4[260]:BYTE

    Switch uMsg
      Case WM_INITDIALOG
        invoke SetWindowText,hWin,SADD("Get Current Time")
        invoke SendMessage,hWin,WM_SETICON,1,
                           FUNC(LoadIcon,NULL,IDI_ASTERISK)
        m2m hWnd, hWin
        return 1
      Case WM_COMMAND
        Switch wParam
          Case IDOK
            mov str1, ptr$(buffer1)
            mov str2, CTXT(" second")
            mov str3, CTXT(" seconds")
            mov str5, CTXT(" AM")
            mov str6, CTXT(" PM")

            invoke GetLocalTime,ADDR stm
            .if stm.wHour > 11
              m2m str5, str6
            .endif

          ; -----------------------------------
          ; zero extend and convert to strings
          ; -----------------------------------
            movzx eax, stm.wHour
            mov hour, ustr$(eax)
            movzx eax, stm.wMinute
            mov minute, ustr$(eax)
            movzx eax, stm.wSecond
            push eax
            .if eax > 1
              m2m str2, str3
            .endif
            pop eax
            mov second, ustr$(eax)

            mov str1, cat$(str1,"The time is ",hour,":",minute," ",str5," and ",second,str2)

            MsgBox hWnd,str1,"Current time",MB_OK

          Case IDCANCEL
            jmp quit_dialog
        EndSw
      Case WM_CLOSE
        quit_dialog:
         invoke EndDialog,hWin,0
    EndSw

    return 0

DlgProc endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start
