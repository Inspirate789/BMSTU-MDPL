         title   MenuDemo
         comment '*==============================*'
         comment '* Programed by Ewayne Wagner   *'
         comment '* E-MAIL: yooper@kalamazoo.net *'
         comment '*==============================*'

         .586
         .model flat, stdcall
         option casemap:none   ; Case sensitive

            include  \MASM32\include\Windows.inc
            include  \MASM32\include\user32.inc
            include  \MASM32\include\kernel32.inc
            include  \MASM32\include\gdi32.inc
            include  \MASM32\include\comctl32.inc
            include  \MASM32\include\comdlg32.inc

;       include  \MASM32\include\DSPMACRO.asm

         includelib  \MASM32\lib\user32.lib
         includelib  \MASM32\lib\kernel32.lib
         includelib  \MASM32\lib\gdi32.lib
         includelib  \MASM32\lib\comctl32.lib
         includelib  \MASM32\lib\comdlg32.lib

;===================================================
; PROTO, MACRO, and Data section
;===================================================
WinMain         PROTO  :DWORD, :DWORD, :DWORD, :DWORD

.const
IDM_NEW        equ 1001
IDM_OPEN       equ 1002
IDM_SAVE       equ 1003
IDM_EXIT       equ 2001
IDM_CUT        equ 1005
IDM_COPY       equ 1006
IDM_PASTE      equ 1007
IDM_DEL        equ 1008
IDM_SET1       equ 1101
IDM_SET2       equ 1102
IDM_SET3       equ 1103
IDM_SET4       equ 1104
IDM_SET5       equ 1105
IDM_SET6       equ 1106
IDM_SET7       equ 1107
IDM_SET8       equ 1108
IDM_SET9       equ 1109
IDM_SET10      equ 1110
IDM_SET11      equ 1111

.data
ClassName      db  'MenuDemo',0
AppName        db  'MenuDemo',0
MenuName       db  'MainMenu',0
szNull         db  0

szSaveIt       db  '&Save It',0
szSaveAs       db  'Save &As',0
szNewMenu1     db  'New Menu 1',0
szNewMenu2     db  'New Menu 2',0
szNewSubMenu1  db  'New SubMenu 1',0
szNewSubMenu2  db  'New SubMenu 2',0

szOwner        db  'OwnerDrawn',0
szCut          db  'Cu&t',0
szCopy         db  '&Copy',0
szPaste        db  '&Paste',0
szDelete       db  '&Delete',0
szEdit         db  '&Edit',0

.data?
hInst          dd  ?
CommandLine    dd  ?
MainExit       dd  ?
hWnd           dd  ?
hMenu          dd  ?
hSMenu1        dd  ?
hSMenu2        dd  ?
hSMenu3        dd  ?
hSMenu4        dd  ?
hSMenu5        dd  ?
MenuCnt        dd  ?
Set1           dd  ?
Set2           dd  ?
Set3           dd  ?
Set4           dd  ?
Set5           dd  ?
Set6           dd  ?
Set7           dd  ?
Set8           dd  ?
hMBmp          dd  ?
hMBmp1         dd  ?
hMBmp2         dd  ?
hMBmp3         dd  ?
hMBmp4         dd  ?
hMBmp5         dd  ?
hMBmp6         dd  ?
hMBmp7         dd  ?
hMBmp8         dd  ?

ItemID         dd  ?

;---------- [Structures] ----------
mii            MENUITEMINFO      <?>
mis            MEASUREITEMSTRUCT <?>
dis            DRAWITEMSTRUCT    <?> ; For WM_DRAWITEM

.code

;===================================================
; Program initialization section
;===================================================
start:
      INVOKE     GetModuleHandle, NULL
         mov     hInst, eax
      INVOKE     GetCommandLine
         mov     CommandLine, eax

        call     InitCommonControls

      INVOKE     WinMain, hInst ,NULL, CommandLine, SW_SHOWDEFAULT
         mov     MainExit, eax
      INVOKE     ExitProcess, MainExit

;===================================================
; WinMain procedure
;===================================================
WinMain proc  uses ebx  hinst:DWORD, hPrevInst, CmdLine, CmdShow
LOCAL    wc:WNDCLASSEX
LOCAL    msg:MSG

         mov     wc.cbSize, sizeof WNDCLASSEX
         mov     wc.style, CS_HREDRAW or CS_VREDRAW
         mov     wc.lpfnWndProc, offset WndProc
         mov     wc.cbClsExtra, NULL
         mov     wc.cbWndExtra, NULL
        push     hInst
         pop     wc.hInstance
         mov     wc.hbrBackground, COLOR_BTNFACE+1
         mov     wc.lpszMenuName, offset MenuName
         mov     wc.lpszClassName, offset ClassName
      INVOKE     LoadIcon, NULL, IDI_APPLICATION
         mov     wc.hIcon, eax
         mov     wc.hIconSm, eax
      INVOKE     LoadCursor, NULL, IDC_ARROW
         mov     wc.hCursor, eax
      INVOKE     RegisterClassEx, addr wc

;---------- [Center the window] ----------
      INVOKE     GetSystemMetrics, SM_CXSCREEN
         sub     eax, 350
         shr     eax, 1
        push     eax
      INVOKE     GetSystemMetrics, SM_CYSCREEN
         sub     eax, 300
         shr     eax, 1
         pop     ebx

;---------- [Create the Main Window] ----------
      INVOKE     CreateWindowEx, WS_EX_CLIENTEDGE, addr ClassName,\
                 addr AppName, WS_OVERLAPPEDWINDOW,\
                 ebx, eax, 350, 300, NULL, NULL, hInst, NULL
         mov     hWnd, eax

      INVOKE     ShowWindow, hWnd, SW_SHOWNORMAL
      INVOKE     UpdateWindow, hWnd
      INVOKE     GetMenu, hWnd              ; Get handle to main menu
         mov     hMenu, eax
      INVOKE     GetSubMenu, hMenu, 0       ; Get handle to 1st sub menu
         mov     hSMenu1, eax
      INVOKE     GetSubMenu, hMenu, 1       ; Get handle to 2nd sub menu
         mov     hSMenu2, eax

;---------- [Message loop] ----------
      .while TRUE
         INVOKE     GetMessage, addr msg, NULL, 0, 0
            .break .if (!eax)
            INVOKE     TranslateMessage, addr msg
            INVOKE     DispatchMessage, addr msg
      .endw
         mov     eax, msg.wParam
         ret
WinMain endp

;===================================================
; WinProc procedure
;===================================================
WndProc proc  uses ebx  hwnd:DWORD, wMsg, wParam, lParam
LOCAL    pt:POINT
LOCAL    rect:RECT
LOCAL    szBuff[25]:BYTE
LOCAL    hBR:DWORD, hMemDC, ID, Cnt, Disable, dwRob

;---------- [Create the Control(s) and one time stuff] ----------
      .if wMsg == WM_CREATE
         INVOKE     LoadMenu, hInst, 700   
         INVOKE     GetSubMenu, eax, 0
            mov     hSMenu5, eax

;---------- [Load The Bitmaps] ----------
            mov     ID, 701           ; Bitmap ID
            mov     Cnt, 8
         .while (Cnt)
            INVOKE     LoadBitmap, hInst, ID
               mov     ecx, ID
               sub     ecx, 701
               mov     hMBmp1[ecx*4], eax
               inc     ID
               dec     Cnt
         .endw

            mov     mii.cbSize, sizeof mii
            mov     mii.fMask, MIIM_DATA or MIIM_ID or MIIM_STATE or MIIM_SUBMENU or MIIM_TYPE or MIIM_CHECKMARKS

;---------- [Move and Size the Control(s)] ----------
      .elseif wMsg == WM_SIZE

      .elseif wMsg == WM_NOTIFY

;---------- [System and user commands] ----------
      .elseif wMsg == WM_COMMAND
            mov     eax, wParam
           cwde                          ; Only low word contains command
         .if eax == IDM_NEW

         .elseif eax == IDM_OPEN

         .elseif eax == IDM_SAVE

         .elseif eax == IDM_EXIT
            INVOKE     SendMessage, hwnd, WM_CLOSE, 0 ,0

         .elseif eax == IDM_CUT

         .elseif eax == IDM_COPY

         .elseif eax == IDM_PASTE

         .elseif eax == IDM_DEL

;---------- [Change the name of Save in the File Menu & adds Check bullet] ----------
         .elseif eax == IDM_SET1
               cmp     Set1, 1
                je     Ret0
               mov     Set1, 1
               mov     mii.fType, MFT_STRING or MFT_RADIOCHECK
               mov     mii.fState, MFS_CHECKED	
               mov     mii.wID, IDM_SAVE
               mov     eax, offset szSaveIt
               mov     mii.dwTypeData, eax
            INVOKE     SetMenuItemInfo, hSMenu1, IDM_SAVE, FALSE, addr mii

;---------- [Insert a Save As Menu Item in the File Menu] ----------
         .elseif eax == IDM_SET2
               cmp     Set2, 1
                je     Ret0
               mov     Set2, 1
               mov     mii.fType, MFT_STRING
               mov     mii.fState, 0
               mov     mii.wID, 1019              ; New ID
               mov     eax, offset szSaveAs
               mov     mii.dwTypeData, eax
            INVOKE     InsertMenuItem, hSMenu1, 3, TRUE, addr mii   ; Adds after Save

;---------- [Insert a New Menu to the Menu bar] ----------
         .elseif eax == IDM_SET3
               cmp     Set3, 1
                je     Ret0
               mov     Set3, 1
            INVOKE     CreatePopupMenu
               mov     hSMenu3, eax
               mov     mii.fType, MFT_STRING
              push     hSMenu3
               pop     mii.hSubMenu
               mov     eax, offset szNewMenu1
               mov     mii.dwTypeData, eax
            INVOKE     InsertMenuItem, hMenu, 2, TRUE, addr mii   ; Adds new menu
            INVOKE     DrawMenuBar, hwnd

;---------- [Insert a Menu Item to the New Menu] ----------
         .elseif eax == IDM_SET4
               cmp     Set4, 1
                je     Ret0
               mov     Set4, 1
               mov     mii.fType, MFT_STRING
               mov     mii.wID, 1020
               mov     mii.hSubMenu, 0
               mov     eax, offset szNewSubMenu1
               mov     mii.dwTypeData, eax
            INVOKE     InsertMenuItem, hSMenu3, 0, TRUE, addr mii   ; Adds to the end
            INVOKE     DrawMenuBar, hwnd

;---------- [Insert a Seperator and Menu Item to the New Menu] ----------
         .elseif eax == IDM_SET5
               cmp     Set5, 1
                je     Ret0
               mov     Set5, 1
            INVOKE     GetMenuItemCount, hSMenu3  ; Get count of items in the sub menu
               mov     edx, eax
               mov     mii.fType, MFT_SEPARATOR
               mov     mii.dwTypeData, eax
            INVOKE     InsertMenuItem, hSMenu3, edx, TRUE, addr mii   ; Adds to the end
               mov     mii.fType, MFT_STRING
               mov     mii.wID, 1021
               mov     mii.hSubMenu, 0
               mov     eax, offset szNewSubMenu2
               mov     mii.dwTypeData, eax
            INVOKE     InsertMenuItem, hSMenu3, 99, TRUE, addr mii   ; Adds to the end
            INVOKE     DrawMenuBar, hwnd

;---------- [Add Bitmaps to the Edit Menu (Ugly)] ----------
         .elseif eax == IDM_SET6
               cmp     Set6, 1
                je     Ret0
               mov     Set6, 1
            INVOKE     SetMenuItemBitmaps, hSMenu2, IDM_CUT, MF_BYCOMMAND, hMBmp1, hMBmp1
            INVOKE     SetMenuItemBitmaps, hSMenu2, IDM_COPY, MF_BYCOMMAND, hMBmp2, hMBmp2
            INVOKE     SetMenuItemBitmaps, hSMenu2, IDM_PASTE, MF_BYCOMMAND, hMBmp3, hMBmp3
            INVOKE     SetMenuItemBitmaps, hSMenu2, IDM_DEL, MF_BYCOMMAND, hMBmp4, hMBmp4

;---------- [Insert a New Menu and Submenu to the Menu bar] ----------
         .elseif eax == IDM_SET7
               cmp     Set7, 1
                je     Ret0
               mov     Set7, 1
            INVOKE     CreatePopupMenu
               mov     hSMenu4, eax
            INVOKE     GetMenuItemCount, hMenu  ; Get count of items in the Menu bar
               dec     eax
               mov     edx, eax
               mov     mii.fType, MFT_STRING
               mov     mii.fState, MFS_ENABLED
              push     hSMenu4
               pop     mii.hSubMenu
               mov     mii.hbmpChecked, 0
               mov     mii.hbmpUnchecked, 0
               mov     eax, offset szNewMenu2
               mov     mii.dwTypeData, eax
            INVOKE     InsertMenuItem, hMenu, edx, TRUE, addr mii   ; Adds new menu
               mov     mii.fType, MFT_STRING
              push     hSMenu5
               pop     mii.hSubMenu             ; New Edit Submenu
               mov     eax, offset szEdit
               mov     mii.dwTypeData, eax
            INVOKE     InsertMenuItem, hSMenu4, 0, TRUE, addr mii   ; Adds to the top
            INVOKE     DrawMenuBar, hwnd

;---------- [Change the new Submenu to OwnerDrawn] ----------
         .elseif eax == IDM_SET8
               cmp     Set8, 1
                je     Ret0
               mov     Set8, 1
               mov     mii.fType, MFT_STRING
               mov     mii.fState, MFS_ENABLED
               mov     eax, offset szOwner
               mov     mii.dwTypeData, eax
            INVOKE     SetMenuItemInfo, hSMenu4, 0, TRUE, addr mii   ; Adds to the top

               mov     mii.fType, MFT_OWNERDRAW
               mov     mii.fState, MFS_ENABLED
               mov     mii.hSubMenu, 0
               mov     mii.wID, 1005
               mov     mii.dwItemData, IDM_CUT
               mov     mii.dwTypeData, 0
            INVOKE     SetMenuItemInfo, hSMenu5, IDM_CUT, FALSE, addr mii
               mov     mii.wID, 1006
               mov     mii.dwItemData, IDM_COPY
            INVOKE     SetMenuItemInfo, hSMenu5, IDM_COPY, FALSE, addr mii
               mov     mii.wID, 1007
               mov     mii.dwItemData, IDM_PASTE
            INVOKE     SetMenuItemInfo, hSMenu5, IDM_PASTE, FALSE, addr mii
               mov     mii.wID, 1008
               mov     mii.dwItemData, IDM_DEL
            INVOKE     SetMenuItemInfo, hSMenu5, IDM_DEL, FALSE, addr mii
            INVOKE     DrawMenuBar, hwnd

;---------- [Gray or Enable Copy in the Edit Menu] ----------
         .elseif eax == IDM_SET9
            INVOKE     GetMenuItemInfo, hSMenu2, IDM_COPY, FALSE, addr mii
            .if mii.fState == MF_GRAYED
               INVOKE     EnableMenuItem, hMenu, IDM_COPY, MF_ENABLED
            .else
               INVOKE     EnableMenuItem, hMenu, IDM_COPY, MF_GRAYED
            .endif

;---------- [Gray or Enable Copy in the OwnerDrawn Edit Menu] ----------
         .elseif eax == IDM_SET10
              push     mii.fMask
               mov     mii.fMask, MIIM_STATE
            INVOKE     GetMenuItemInfo, hSMenu5, IDM_COPY, FALSE, addr mii
            .if mii.fState == MFS_GRAYED
                  mov     mii.fState, MFS_ENABLED
            .else
                  mov     mii.fState, MFS_GRAYED
            .endif
            .if Set8
                  mov     mii.fType, MFT_OWNERDRAW
            .endif
            INVOKE     SetMenuItemInfo, hSMenu5, IDM_COPY, FALSE, addr mii
               pop     mii.fMask

;---------- Restore the Menu bar] ----------
         .elseif eax == IDM_SET11
            INVOKE     DestroyMenu, hMenu
            INVOKE     LoadMenu, hInst, addr MenuName
               mov     hMenu, eax
            INVOKE     SetMenu, hWnd, hMenu
            INVOKE     GetSubMenu, hMenu, 0       ; Get handle to 1st sub menu
               mov     hSMenu1, eax
            INVOKE     GetSubMenu, hMenu, 1       ; Get handle to 2nd sub menu
               mov     hSMenu2, eax
            INVOKE     LoadMenu, hInst, 700   
            INVOKE     GetSubMenu, eax, 0
               mov     hSMenu5, eax
               xor     eax, eax
            .while (eax < 9)
                  and     Set1[eax*4], 0
                  inc     eax
            .endw
         .endif

      .elseif wMsg == WM_MEASUREITEM
         .if wParam == 0               ; 0 = Menu
               mov     edx, lParam     ; Get pointer to MEASUREITEMSTRUCT
               mov     (MEASUREITEMSTRUCT ptr [edx]).itemWidth, 80
               mov     (MEASUREITEMSTRUCT ptr [edx]).itemHeight, 16
         .endif

      .elseif wMsg == WM_DRAWITEM
         .if wParam == 0               ; 0 = Menu
               mov     esi, lParam
               lea     edi, dis
               mov     ecx, sizeof dis
               rep     movsb
            .if dis.itemID != -1
                  mov     dis.rcItem.left, 17
                  mov     dis.rcItem.top, 0
                  mov     dis.rcItem.right, 100
                  mov     dis.rcItem.bottom, 16

                  mov     eax, dis.itemData
                  sub     eax, 1005
                  mov     edx, hMBmp5[eax*4]
                  mov     hMBmp, edx

               .if dis.itemData == 1005
                  INVOKE     lstrcpy, addr szBuff, addr szCut
               .elseif dis.itemData == 1006
                     mov     dis.rcItem.top, 16
                     mov     dis.rcItem.bottom, 32
                  INVOKE     lstrcpy, addr szBuff, addr szCopy
               .elseif dis.itemData == 1007
                     mov     dis.rcItem.top, 32
                     mov     dis.rcItem.bottom, 48
                  INVOKE     lstrcpy, addr szBuff, addr szPaste
               .elseif dis.itemData == 1008
                     mov     dis.rcItem.top, 48
                     mov     dis.rcItem.bottom, 64
                  INVOKE     lstrcpy, addr szBuff, addr szDelete
               .endif
   
                  and     Disable, 0
                  mov     dwRob, SRCCOPY
               .if dis.itemState == 2 || dis.itemState == 4 || dis.itemState == 6 || dis.itemState == 7
                     inc     Disable
                     mov     dwRob, SRCAND ;NOTSRCCOPY
               .endif
               INVOKE     CreateCompatibleDC, dis.hdc ; Create a compatible dc in memory
                  mov     hMemDC, eax
               INVOKE     SelectObject, hMemDC, hMBmp ; Select the opened bitmap into the dc
               INVOKE     BitBlt, dis.hdc, 0, dis.rcItem.top, 16, 16, hMemDC, 0, 0, dwRob ;Copy the bitmap
               INVOKE     DeleteDC, hMemDC            ; Delete the memory dc

               .if dis.itemState == ODS_SELECTED
                  INVOKE     CreateSolidBrush, 00000000h
                     mov     hBR, eax
                  INVOKE     FillRect, dis.hdc, addr dis.rcItem, eax
                  INVOKE     SetTextColor, dis.hdc, 00ffff00h
                  INVOKE     SetBkColor, dis.hdc, 00000000h

                     mov     rect.left, 0
                    push     dis.rcItem.top 
                     pop     rect.top
                     mov     rect.right, 16
                    push     dis.rcItem.bottom
                     pop     rect.bottom
                  INVOKE     DrawEdge, dis.hdc, addr rect, BDR_RAISEDINNER, BF_TOPLEFT
                  INVOKE     DrawEdge, dis.hdc, addr rect, BDR_RAISEDOUTER, BF_BOTTOMRIGHT

               .elseif Disable
                  INVOKE     GetSysColor, COLOR_GRAYTEXT
                  INVOKE     SetTextColor, dis.hdc, eax
                  INVOKE     SetBkMode, dis.hdc, TRANSPARENT

               .else
                  INVOKE     GetBkColor, dis.hdc
                  INVOKE     CreateSolidBrush, eax
                     mov     hBR, eax
                  INVOKE     FillRect, dis.hdc, addr dis.rcItem, eax
                  INVOKE     SetTextColor, dis.hdc, 00ff0000h
                  INVOKE     SetBkMode, dis.hdc, TRANSPARENT
               .endif
                  add     dis.rcItem.left, 4
               INVOKE     DrawText, dis.hdc, addr szBuff, -1, addr dis.rcItem, DT_LEFT or DT_VCENTER or DT_SINGLELINE
               INVOKE     DeleteObject, hBR
            .endif
               mov     dis.itemState, ODS_DEFAULT
               mov     dis.hdc, 0
         .endif


      .elseif wMsg == WM_CLOSE
         INVOKE     DeleteObject, hMBmp1
         INVOKE     DeleteObject, hMBmp2
         INVOKE     DeleteObject, hMBmp3
         INVOKE     DeleteObject, hMBmp4
         INVOKE     DeleteObject, hMBmp5
         INVOKE     DeleteObject, hMBmp6
         INVOKE     DeleteObject, hMBmp7
         INVOKE     DeleteObject, hMBmp8
         INVOKE     DestroyWindow, hwnd

      .elseif wMsg == WM_DESTROY
         INVOKE     PostQuitMessage, NULL

      .else

DefWin:
         INVOKE     DefWindowProc, hwnd, wMsg, wParam, lParam
            ret
      .endif

Ret0:
         xor    eax, eax
         ret
WndProc endp

end start