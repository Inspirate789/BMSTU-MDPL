; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

      .486                      ; create 32 bit code
      .model flat, stdcall      ; 32 bit memory model
      option casemap :none      ; case sensitive

    ; -----------------------------------------
    ; change the equate value to 1 if you want
    ; to use the secret copyright capacity.
    ; -----------------------------------------
      secret_copyright equ 0
    ; -----------------------------------------

      include \masm32\include\dialogs.inc
      include \masm32\include\windows.inc

      include \masm32\include\masm32.inc

      include \masm32\include\user32.inc
      include \masm32\include\kernel32.inc

      FUNC MACRO parameters:VARARG
        invoke parameters
        EXITM <eax>
      ENDM

      literal MACRO quoted_text:VARARG
        LOCAL local_text
        .data
          local_text db quoted_text,0
        .code
        EXITM <local_text>
      ENDM

      SADD MACRO quoted_text:VARARG
        EXITM <ADDR literal(quoted_text)>
      ENDM


      AboutBox     PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
      AboutBoxProc PROTO :DWORD,:DWORD,:DWORD,:DWORD

.code

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

AboutBox proc Parent:DWORD,Instance:DWORD,Icon:DWORD,
              appname:DWORD,description:DWORD,
              copyright:DWORD

    Dialog "About","MS Sans Serif",8, \
           DS_CENTER or WS_OVERLAPPED or WS_SYSMENU, \
           9, \
           0,0,210,154,1024

    DlgButton   "OK",0,160,120,40,15,IDOK
    DlgIcon     NULL,7,7,100

    ;;; DlgButton   "OK",BS_OWNERDRAW,3,3,3,3,150

    DlgStatic   " ",SS_LEFT,35,10,155,9,101
    DlgStatic   " ",SS_LEFT,35,20,155,9,102
    DlgStatic   " ",SS_LEFT,35,32,155,40,103

    DlgStatic   " ",SS_LEFT,35,70,155,9,104
    DlgStatic   " ",SS_LEFT,35,80,155,9,105
    DlgStatic   " ",SS_LEFT,35,90,155,9,106
    DlgStatic   " ",SS_LEFT,35,100,155,9,107

    CallModalDialog Instance,Parent,AboutBoxProc,ADDR Parent

    ret

AboutBox endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

AboutBoxProc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

    LOCAL hDC:DWORD
    LOCAL Icon:DWORD
    LOCAL ps :PAINTSTRUCT
    LOCAL rct:RECT
    LOCAL mst:MEMORYSTATUS
    LOCAL vdrvs[128]:BYTE
    LOCAL opString[128]:BYTE
    LOCAL swid[32]:BYTE
    LOCAL shgt[32]:BYTE

    .if uMsg == WM_INITDIALOG
      push esi
      push edi
      mov esi, lParam
    ; --------------------
    ; set the window icon
    ; --------------------
      cmp DWORD PTR [esi+8], 0
      je noicon
      invoke SendMessage,hWin,WM_SETICON,1,[esi+8]
      jmp @F
    noicon:
      invoke SendMessage,hWin,WM_SETICON,1,FUNC(LoadIcon,0,IDI_ASTERISK)
    @@:

      invoke GetDlgItem,hWin,100
      invoke SendMessage,eax,STM_SETIMAGE,IMAGE_ICON,[esi+8]

      invoke GetDlgItem,hWin,101
      invoke SetWindowText,eax,[esi+12]

      invoke GetDlgItem,hWin,102
      invoke SetWindowText,eax,[esi+16]

      invoke GetDlgItem,hWin,103
      invoke SetWindowText,eax,[esi+20]

      invoke GetLogicalDriveStrings,128,ADDR vdrvs

      lea eax, vdrvs
      dec eax
    @@:
      inc eax
      cmp BYTE PTR [eax], 0
      jne @B
      mov BYTE PTR [eax], 32        ; replace single zero with space
      cmp BYTE PTR [eax+1], 0       ; test if next byte is zero
      jne @B

      lea eax, vdrvs
      dec eax
    @@:
      inc eax
      cmp BYTE PTR [eax], "\"
      jne nxt1
      mov BYTE PTR [eax], 32        ; replace single zero with space
    nxt1:
      cmp BYTE PTR [eax+1], 0       ; test if next byte is zero
      jne @B

      jmp @F
        vds db "Valid Drives  ",0
        scr db "Screen Resolution ",9,0
        tms db " x ",0
        inm db "Installed Memory ",9,0
        byt db " megabytes",0
        avm db "Memory Available ",9,0
     @@:

      lea eax, opString
      mov BYTE PTR [eax], 0         ; set as zero length
      invoke szMultiCat,2,ADDR opString,ADDR vds,ADDR vdrvs
      invoke GetDlgItem,hWin,104
      mov ecx, eax
      invoke SetWindowText,ecx,ADDR opString

      lea eax, opString
      mov BYTE PTR [eax], 0         ; set as zero length
      invoke GetSystemMetrics,SM_CXSCREEN
      mov ecx, eax
      invoke dwtoa,ecx,ADDR swid
      invoke GetSystemMetrics,SM_CYSCREEN
      mov ecx, eax
      invoke dwtoa,ecx,ADDR shgt
      invoke szMultiCat,4,ADDR opString,ADDR scr,ADDR swid,ADDR tms,ADDR shgt
      invoke GetDlgItem,hWin,105
      mov ecx, eax
      invoke SetWindowText,ecx,ADDR opString

      invoke GlobalMemoryStatus,ADDR mst

      lea eax, opString
      mov BYTE PTR [eax], 0         ; set as zero length
      mov ecx, mst.dwTotalPhys
      shr ecx, 20
      invoke dwtoa,ecx,ADDR swid            ; reuse buffer
      invoke szMultiCat,3,ADDR opString,ADDR inm,ADDR swid,ADDR byt
      invoke GetDlgItem,hWin,106
      mov ecx, eax
      invoke SetWindowText,ecx,ADDR opString

      lea eax, opString
      mov BYTE PTR [eax], 0         ; set as zero length
      mov ecx, mst.dwAvailPhys
      shr ecx, 20
      invoke dwtoa,ecx,ADDR swid            ; reuse buffer
      invoke szMultiCat,3,ADDR opString,ADDR avm,ADDR swid,ADDR byt
      invoke GetDlgItem,hWin,107
      mov ecx, eax
      invoke SetWindowText,ecx,ADDR opString

      pop edi
      pop esi

      mov eax, 1    ; return of 1 sets the focus to first control
      ret

    .elseif uMsg == WM_COMMAND

      .if wParam == IDOK

        IF secret_copyright
          invoke GetAsyncKeyState,VK_SHIFT
          rol eax, 16
          cmp ax, 1111111111111111b
          jne abExit

          invoke GetAsyncKeyState,VK_CONTROL
          rol eax, 16
          cmp ax, 1111111111111111b
          jne abExit

          invoke GetAsyncKeyState,VK_BACK
          rol eax, 16
          cmp ax, 1111111111111111b
          jne abExit

          invoke MessageBox,hWin,SADD("AboutBox Copyright й MASM32 1998-2003"),
                                 SADD("About ",34,"AboutBox",34),
                                 MB_OK or MB_ICONINFORMATION
        ELSE
          jmp abExit
        ENDIF

      .endif

    .elseif uMsg == WM_PAINT
      invoke BeginPaint,hWin,ADDR ps
      mov hDC, eax
      invoke GetClientRect,hWin,ADDR rct
      invoke DrawEdge,hDC,ADDR rct,EDGE_ETCHED,BF_RECT
      invoke EndPaint,hWin,ADDR ps

    .elseif uMsg == WM_CLOSE
      abExit:
      invoke EndDialog,hWin, 0

    .endif

    xor eax, eax
    ret

AboutBoxProc endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end