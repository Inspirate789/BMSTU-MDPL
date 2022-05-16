         title   TreeDemo
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
            include  \MASM32\include\advapi32.inc

         includelib  \MASM32\lib\user32.lib
         includelib  \MASM32\lib\kernel32.lib
         includelib  \MASM32\lib\gdi32.lib
         includelib  \MASM32\lib\comctl32.lib
         includelib  \MASM32\lib\comdlg32.lib
         includelib  \MASM32\lib\advapi32.lib

;===================================================
; PROTO, MACRO, and Data section
;===================================================
WinMain         PROTO  :DWORD, :DWORD, :DWORD, :DWORD
SplitBarProc    PROTO  :DWORD, :DWORD, :DWORD, :DWORD

.const
IDM_EXIT               equ  2001

TVM_SETBKCOLOR         equ  TV_FIRST + 29
TVM_SETTEXTCOLOR       equ  TV_FIRST + 30
TVM_SETLINECOLOR       equ  TV_FIRST + 40
TVM_SETINSERTMARKCOLOR equ  TV_FIRST + 37

.data
ClassName      db  'TreeDemo',0
AppName        db  'TreeDemo',0
RichEdit       db  'RichEdit20A',0
RichEdDLL      db  'RICHED20.DLL',0
TreeClass      db  'SysTreeView32',0
ListClass      db  'SysListView32',0
StatClass      db  'msctls_statusbar32',0
StaticClass    db  'STATIC',0
MenuName       db  'MainMenu',0
Parent1        db  'Tree',0
Parent2        db  'Does Nothing',0
Child1         db  'Listview',0
Child2         db  'Edit Control',0
Child3         db  'Statusbar',0
Child4         db  'Status 2',0
Child5         db  'Status 3',0
Child6         db  'Clear All',0
Child7         db  'Nothing',0

szColName      db  'Items',0
szItem1        db  'Item 1',0
szItem2        db  'Item 2',0
szDay          db  'Have A Nice Day !!',0

szNull         db  0
First          db  1

Split1         dd  0, 159, 130, 161
Split2         dd  129, 0, 131, 241

.data?
hInst          dd  ?
CommandLine    dd  ?
hREdDll        dd  ?
MainExit       dd  ?
hWnd           dd  ?
MenuCnt        dd  ?

hWndStat       dd  ?
hWndTree       dd  ?
hWndList       dd  ?
hREdit         dd  ?
hImageList     dd  ?
hParent        dd  ?
hChild1        dd  ?
hChild2        dd  ?
hChild3        dd  ?
hChild4        dd  ?
hChild5        dd  ?
hChild6        dd  ?
hSplitBar      dd  ?
BarType        dd  ?
hBR            dd  ?
sbParts        dd  4   dup(?)

;---------- [Structures] ----------
tvis           TV_INSERTSTRUCT      <?>

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

;---------- [Load the Riched20.dll] ----------
      INVOKE     LoadLibrary, addr RichEdDLL
         mov     hREdDll, eax
      .if !eax
;         INVOKE     MessageBox, NULL, addr szError1, addr szAppName, MB_OK or MB_ICONERROR
            jmp     Exit
      .endif

      INVOKE     WinMain, hInst ,NULL, CommandLine, SW_SHOWDEFAULT
         mov     MainExit, eax
      INVOKE     FreeLibrary, hREdDll

Exit:
      INVOKE     ExitProcess, MainExit

;===================================================
; WinMain procedure
;===================================================
WinMain proc  uses ebx  hinst:DWORD, hPrevInst, CmdLine, CmdShow
LOCAL    wc:WNDCLASSEX
LOCAL    msg:MSG

         mov     wc.cbSize, sizeof WNDCLASSEX
         mov     wc.style, CS_BYTEALIGNCLIENT or CS_BYTEALIGNWINDOW
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
         sub     eax, 353
         shr     eax, 1
        push     eax
      INVOKE     GetSystemMetrics, SM_CYSCREEN
         sub     eax, 300
         shr     eax, 1
         pop     ebx

;---------- [Create the Main Window] ----------
      INVOKE     CreateWindowEx, WS_EX_CLIENTEDGE, addr ClassName,\
                 addr AppName, WS_OVERLAPPEDWINDOW,\
                 ebx, eax, 353, 311, NULL, NULL, hInst, NULL
         mov     hWnd, eax

      INVOKE     ShowWindow, hWnd, SW_SHOWNORMAL
      INVOKE     UpdateWindow, hWnd

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
WndProc proc  uses esi edi ebx  hwnd:DWORD, wMsg, wParam, lParam
LOCAL    rect:RECT
LOCAL    lvc:LV_COLUMN
LOCAL    lvi:LV_ITEM
LOCAL    tvi:TV_ITEM
LOCAL    xPos:DWORD, yPos, hBitmap
LOCAL    szWork1[64]:BYTE

;---------- [Create the Control(s) and one time stuff] ----------
      .if wMsg == WM_CREATE

;---------- [Create the status bar window] ----------
         INVOKE     CreateWindowEx, 0, addr StatClass, 0,\
                    WS_CHILD or WS_BORDER or WS_VISIBLE or SBS_SIZEGRIP,\
                    0, 0, 0, 0, hwnd, 0, hInst, 0  
            mov     hWndStat, eax

;---------- [Create the control windows] ----------
         INVOKE     CreateWindowEx, WS_EX_CLIENTEDGE, addr TreeClass, 0,\
                    WS_CHILD or WS_VISIBLE or TVS_HASLINES or TVS_HASBUTTONS or\ 
                    TVS_LINESATROOT or WS_CLIPSIBLINGS,\
                    0, 0, 130, 160, hwnd, 44, hInst, NULL
           test     eax, eax     
             jz     Ret0
            mov     hWndTree, eax 
         INVOKE     SendMessage, hWndTree, TVM_SETBKCOLOR, 0, 00e1f0ffh
;         INVOKE     SendMessage, hWndTree, TVM_SETTEXTCOLOR, 0, 00ffffe0h
;         INVOKE     SendMessage, hWndTree, TVM_SETLINECOLOR, 0, 00ffffe0h
;         INVOKE     SendMessage, hWndTree, TVM_SETINSERTMARKCOLOR, 0, 00ffffe0h

         INVOKE     CreateWindowEx, WS_EX_CLIENTEDGE, addr ListClass, NULL,\
                    WS_CHILD or WS_VISIBLE or LVS_REPORT or LVS_SHAREIMAGELISTS or LVS_SORTASCENDING,\
                    0, 160, 130, 51, hwnd, 45, hInst, NULL
           test     eax, eax     
             jz     Ret0
            mov     hWndList, eax
;         INVOKE     SendMessage, hWndList, LVM_SETTEXTCOLOR, 0, 00000000h
         INVOKE     SendMessage, hWndList, LVM_SETBKCOLOR, 0, 00ffffe0h
         INVOKE     SendMessage, hWndList, LVM_SETTEXTBKCOLOR, 0, 00ffffe0h
   
         INVOKE     CreateWindowEx, WS_EX_CLIENTEDGE, addr RichEdit, NULL,\
                    WS_CHILD or WS_VISIBLE or ES_MULTILINE or\
                    ES_NOHIDESEL or ES_SAVESEL or ES_SELECTIONBAR or\
                    WS_HSCROLL or ES_AUTOHSCROLL or\
                    WS_VSCROLL or ES_AUTOVSCROLL or WS_CLIPSIBLINGS,\
                    131, 0, 211, 241, hwnd, 46, hInst, NULL
           test     eax, eax     
             jz     Ret0
            mov     hREdit, eax
         INVOKE     SendMessage, hREdit, EM_SETBKGNDCOLOR, 0, 00f0fff0h

;---------- [Get the Imagelist] ----------
         INVOKE     ImageList_Create, 16, 16, ILC_COLOR16, 5, 10
            mov     hImageList, eax
         INVOKE     LoadBitmap, hInst, 900
            mov     hBitmap,eax
         INVOKE     ImageList_Add, hImageList, hBitmap, NULL
         INVOKE     DeleteObject, hBitmap

;---------- [Remove the comment if you want images for the Tree] ----------
;         INVOKE     SendMessage, hWndTree, TVM_SETIMAGELIST, 0, hImageList

;---------- [Fill the tree] ----------
         INVOKE     SendMessage, hWndTree, TVM_DELETEITEM, 0, TVI_ROOT
            mov     tvis.hParent, NULL   
            mov     tvis.hInsertAfter, TVI_ROOT
            mov     tvis.item.imask, TVIF_TEXT or TVIF_IMAGE or TVIF_SELECTEDIMAGE
            mov     tvis.item.pszText, offset Parent1
            mov     tvis.item.iImage, 0
            mov     tvis.item.iSelectedImage, 1
         INVOKE     SendMessage, hWndTree, TVM_INSERTITEM, 0, addr tvis
            mov     hParent, eax

            mov     tvis.hParent, eax
            mov     tvis.hInsertAfter, TVI_LAST
            mov     tvis.item.pszText, offset Child1
         INVOKE     SendMessage, hWndTree, TVM_INSERTITEM, 0, addr tvis
            mov     hChild1, eax

            mov     tvis.item.pszText, offset Child2
         INVOKE     SendMessage, hWndTree, TVM_INSERTITEM, 0, addr tvis
            mov     hChild2, eax

            mov     tvis.item.pszText, offset Child3
         INVOKE     SendMessage, hWndTree, TVM_INSERTITEM, 0, addr tvis
            mov     hChild3, eax

            mov     tvis.hParent, eax
            mov     tvis.item.pszText, offset Child4
         INVOKE     SendMessage, hWndTree, TVM_INSERTITEM, 0, addr tvis
            mov     hChild4, eax

            mov     tvis.item.pszText, offset Child5
         INVOKE     SendMessage, hWndTree, TVM_INSERTITEM, 0, addr tvis
            mov     hChild5, eax

            mov     eax, hParent 
            mov     tvis.hParent, eax
            mov     tvis.item.pszText, offset Child6
         INVOKE     SendMessage, hWndTree, TVM_INSERTITEM, 0, addr tvis
            mov     hChild6, eax

            mov     tvis.hParent, NULL   
            mov     tvis.hInsertAfter, TVI_ROOT
            mov     tvis.item.imask, TVIF_TEXT or TVIF_IMAGE or TVIF_SELECTEDIMAGE
            mov     tvis.item.pszText, offset Parent2
         INVOKE     SendMessage, hWndTree, TVM_INSERTITEM, 0, addr tvis
            mov     tvis.hParent, eax
            mov     tvis.item.pszText, offset Child7
         INVOKE     SendMessage, hWndTree, TVM_INSERTITEM, 0, addr tvis

      INVOKE     SendMessage, hWndTree, TVM_EXPAND, TVE_EXPAND, hParent
      INVOKE     SendMessage, hWndTree, TVM_SORTCHILDREN, 0, hParent
      INVOKE     SendMessage, hWndTree, TVM_SELECTITEM, TVGN_CARET, NULL ;hParent

;---------- [Create the column for the Listview] ----------
            mov     lvc.imask, LVCF_TEXT or LVCF_WIDTH
            mov     lvc.pszText, offset szColName
            mov     lvc.lx, 125
         INVOKE     SendMessage, hWndList, LVM_INSERTCOLUMN, 0, addr lvc

;---------- [Move and Size the Control(s)] ----------
      .elseif wMsg == WM_SIZE

;---------- [Size the Statusbar Control] ----------
            mov     eax, lParam       ; Get width
            and     eax, 0ffffh       ; Lowword
            shr     eax, 2            ; /4
            mov     ecx, eax          ; Save factor
            mov     sbParts, eax      ; Make part 1 1/4 the width
            add     eax, ecx
            mov     [sbParts+4], eax  ; and also part2, .. etc
            add     eax, ecx
            mov     [sbParts+8], eax
            mov     [sbParts+12], -1  ; The last part extends to the end
         INVOKE     SendMessage, hWndStat, SB_SETPARTS, 4, addr sbParts
         INVOKE     MoveWindow, hWndStat, 0, 0, 0, 0, TRUE

         INVOKE     GetWindowRect, hWndStat, addr rect ; Rectangle of statusbar
            mov     eax, rect.bottom
            sub     eax, rect.top                      ; eax = height of statusbar
           push     eax
         INVOKE     GetClientRect, hWnd, addr rect
            pop     eax
            dec     eax
            sub     rect.bottom, eax

            mov     ecx, Split2
            mov     edx, Split1[4]
            mov     Split1[8], ecx
         INVOKE     MoveWindow, hWndTree, 1, 1, ecx, edx, TRUE

            mov     edx, rect.bottom
            mov     ecx, Split1[12]
            mov     edi, ecx
            dec     ecx
            sub     edx, ecx
            sub     edx, 2
            mov     ecx, Split2
         INVOKE     MoveWindow, hWndList, 1, edi, ecx, edx, TRUE
            mov     ecx, Split2
            sub     ecx, 4
         INVOKE     SendMessage, hWndList, LVM_SETCOLUMNWIDTH, 0, ecx

            mov     ecx, rect.right
            inc     Split1[8]
            sub     ecx, Split1[8]
            mov     edx, rect.bottom
            mov     Split2[12], edx
            mov     edi, Split2[8]
            dec     ecx
            sub     edx, 2
         INVOKE     MoveWindow, hREdit, edi, 1, ecx, edx, TRUE

      .elseif wMsg == WM_NOTIFY
         .if wParam == 44                ; Treeview
               mov     eax, lParam
               mov     ebx, (NM_TREEVIEW ptr [eax]).hdr.code
               mov     ecx, (NM_TREEVIEW ptr [eax]).itemNew.hItem

            .if ebx == TVN_ITEMEXPANDING
                  mov     edx, (NM_TREEVIEW ptr [eax]).action
               .if edx == TVE_COLLAPSE
;DSPValue hWnd, edx, 1, 't'
                     mov     First, 1
                  INVOKE     SendMessage, hWndTree, TVM_SELECTITEM, TVGN_CARET, NULL
               .endif
                  jmp     Ret0
            .endif

            .if ebx == TVN_SELCHANGED
               .if ecx == hParent && First
                     and     First, 0
                    push     ecx
                    push     eax
                  INVOKE     SendMessage, hWndTree, TVM_SELECTITEM, TVGN_CARET, NULL
                     pop     eax
                     pop     ecx
               .endif
                 test     (NM_TREEVIEW ptr [eax]).action, TVIS_FOCUSED
                   jz     Ret0
                  mov     tvi.hItem, ecx
                  mov     tvi.imask, TVIF_TEXT
                  lea     eax, szWork1
                  mov     tvi.pszText, eax
                  mov     tvi.cchTextMax, 64

               .if ecx == hChild6        ; Clear all
                  INVOKE     SendMessage, hWndList, LVM_DELETEALLITEMS, 0, 0
                  INVOKE     SendMessage, hREdit, WM_SETTEXT, 0, addr szNull
                  INVOKE     SendMessage, hWndStat, SB_SETTEXT, 0, addr szNull
                  INVOKE     SendMessage, hWndStat, SB_SETTEXT, 1, addr szNull
                  INVOKE     SendMessage, hWndStat, SB_SETTEXT, 2, addr szNull
                  INVOKE     SendMessage, hWndStat, SB_SETTEXT, 3, addr szNull
                     jmp     Ret0
               .endif

                    push     ecx
                  INVOKE     SendMessage, hWndTree, TVM_GETITEM, NULL, addr tvi
                  INVOKE     SendMessage, hWndStat, SB_SETTEXT, 0, addr szWork1
                     pop     ecx

               .if ecx == hChild1        ; Listview
                  INVOKE     SendMessage, hWndList, LVM_DELETEALLITEMS, 0, 0

;---------- [Fill the Listview] ----------
                     mov     lvi.imask, LVIF_TEXT or LVIF_PARAM
                     mov     lvi.iItem, 0
                     mov     lvi.lParam, 0
                     mov     lvi.iSubItem, 0
                     lea     eax, szItem1
                     mov     lvi.pszText, eax
                     mov     lvi.iImage, 0
                  INVOKE     SendMessage, hWndList, LVM_INSERTITEM, 0, addr lvi
                     mov     lvi.iItem, 1
                     mov     lvi.lParam, 1
                     mov     lvi.iSubItem, 0
                     lea     eax, szItem2
                     mov     lvi.pszText, eax
                     mov     lvi.iImage, 0
                  INVOKE     SendMessage, hWndList, LVM_INSERTITEM, 0, addr lvi

               .elseif ecx == hChild2    ; Edit control
                  INVOKE     SendMessage, hREdit, WM_SETTEXT, 0, addr szDay

               .elseif ecx == hChild4    ; Stat 2
                  INVOKE     SendMessage, hWndStat, SB_SETTEXT, 2, addr Child4

               .elseif ecx == hChild5    ; Stat 3
                  INVOKE     SendMessage, hWndStat, SB_SETTEXT, 3, addr Child5
               .endif
            .endif

         .elseif wParam == 45            ; Listview
               mov     ebx, lParam       ; Get pointer to NMHDR
            .if [ebx.NMHDR].code == NM_CLICK ;NM_DBLCLK
               INVOKE     SendMessage, hWndList, LVM_GETNEXTITEM, -1, LVNI_FOCUSED
                  mov     lvi.iItem, eax
                  mov     lvi.iSubItem, 0
                  mov     lvi.imask, LVIF_TEXT
                  lea     eax, szWork1
                  mov     lvi.pszText, eax
                  mov     lvi.cchTextMax, 64
               INVOKE     SendMessage, hWndList, LVM_GETITEM, 0, addr lvi
               INVOKE     SendMessage, hWndStat, SB_SETTEXT, 1, addr szWork1
            .endif
         .endif

;---------- [System and user commands] ----------
      .elseif wMsg == WM_COMMAND
            mov     eax, wParam
           cwde                          ; Only low word contains command
         .if eax == IDM_EXIT
            INVOKE     SendMessage, hwnd, WM_CLOSE, 0 ,0

         .endif

;---------- [Move the splitter bars] ----------

      .elseif wMsg == WM_MOUSEMOVE

;---------- [Capture the mouse if within an area] ----------
         INVOKE     GetClientRect, hWnd, addr rect
            mov     eax, lParam
            mov     edx, eax
            and     eax, 0ffffh
            inc     eax
            mov     xPos, eax
            shr     edx, 16
            inc     edx
            mov     yPos, edx

         .if eax > Split1 && eax < Split1[8] && edx >= Split1[4] && edx <= Split1[12] && BarType != 2
            INVOKE     LoadCursor, hInst, 899
            INVOKE     SetCursor, eax
            INVOKE     SetCapture, hwnd
               mov     BarType, 1
         .elseif eax >= Split2 && eax <= Split2[8] && edx > Split2[4] && edx < Split2[12] && BarType != 1
            INVOKE     LoadCursor, hInst, 898
            INVOKE     SetCursor, eax
            INVOKE     SetCapture, hwnd
               mov     BarType, 2
         .else

;---------- [Release the mouse if out of the area] ----------
            .if wParam != MK_LBUTTON
                  xor     esi, esi
               .if BarType == 1
                     lea     esi, Split1
               .elseif BarType == 2
                     lea     esi, Split2
               .endif
               .if esi
                  .if eax < [esi] || eax > [esi+8] || edx < [esi+4] || edx > [esi+12]
                        and     BarType, 0
                     INVOKE     ReleaseCapture
                  .endif
               .endif
            .endif
            INVOKE     LoadCursor, 0, IDC_ARROW
            INVOKE     SetCursor, eax
         .endif

         .if wParam == MK_LBUTTON
            INVOKE     GetClientRect, hWnd, addr rect
               mov     ecx, xPos
               mov     edx, yPos
               sub     rect.bottom, 28
            .if ecx > rect.left && ecx < rect.right && edx > rect.top && edx < rect.bottom
            .else
                  jmp     Ret0
            .endif

;---------- [Create and drag the Splitter bar] ----------
            .if BarType == 1                       ; Horizontal
                  mov     ecx, Split2
               .if xPos < ecx
                  INVOKE     LoadCursor, hInst, 899
                  INVOKE     SetCursor, eax
                  .if !hSplitBar
                     INVOKE     CreateDialogParam, hInst, 4801, hWnd, offset SplitBarProc, 0
                  .endif
                     mov     eax, yPos
                     dec     eax
                     dec     eax
                     mov     Split1[4], eax
                     add     eax, 2
                     mov     Split1[12], eax
                  INVOKE     GetWindowRect, hWnd, addr rect
                     add     rect.left, 6
                     mov     eax, rect.top
                     add     eax, 44
                     add     eax, Split1[4]
                     inc     eax
                     mov     rect.top, eax
                     mov     edx, Split1[8]
                  INVOKE     MoveWindow, hSplitBar, rect.left, rect.top, edx, 2, 1
               .endif
            .endif

            .if BarType == 2                       ; Vertical
               INVOKE     LoadCursor, hInst, 898
               INVOKE     SetCursor, eax
               .if !hSplitBar
                  INVOKE     CreateDialogParam, hInst, 4801, hWnd, offset SplitBarProc, 0
               .endif
                  mov     eax, xPos
                  dec     eax
dec     eax
                  mov     Split2, eax
                  add     eax, 2
                  mov     Split2[8], eax
               INVOKE     GetWindowRect, hWnd, addr rect
                  add     rect.top, 44
                  mov     eax, rect.top
                  add     eax, 28
                  sub     rect.bottom, eax
                  add     rect.left, 6
                  mov     ecx, rect.left
                  add     ecx, Split2
                  inc     ecx
               INVOKE     MoveWindow, hSplitBar, ecx, rect.top, 2, Split2[12], 1
            .endif
         .endif

      .elseif wMsg == WM_LBUTTONUP

;---------- [Restore the cursor and call WM_SIZE] ----------
         INVOKE     LoadCursor, 0, IDC_ARROW
         INVOKE     SetCursor, eax
            and     BarType, 0
         .if hSplitBar
            INVOKE     ReleaseCapture
            INVOKE     SplitBarProc, hSplitBar, WM_COMMAND, IDCANCEL, 0
               and     hSplitBar, 0
            INVOKE     GetClientRect, hWnd, addr rect
               mov     edx, rect.bottom
               shl     edx, 16
               mov     ecx, rect.right
               mov     dx, cx
            INVOKE     SendMessage, hWnd, WM_SIZE, 0, edx
         .endif

      .elseif wMsg == WM_CLOSE
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

;=========================================================================
; Splitter Bar PROCEDURE
;=========================================================================
SplitBarProc PROC    hdlg:DWORD, wmsg, wparam, lparam
LOCAL    hBrush:DWORD

         cmp     wmsg, WM_INITDIALOG   ; If message is INITDIALOG then
         jne     NotInit               ; check wmsg
         mov     eax, hdlg
         mov     hSplitBar, eax
         jmp     DlgDone

NotInit:
         cmp     wmsg, WM_CTLCOLORDLG
         je      ColorDlg
         cmp     wmsg, WM_COMMAND      ; Is message a WM_COMMAND?
         mov     eax, wparam           ; Otherwise, see if it's OK or CANCEL
         cmp     eax, IDCANCEL         ; that was pressed
         je      CancleIt              ; and if not either of these
         jmp     DlgDone

ColorDlg:
      INVOKE     CreateSolidBrush, 0000ff00h
         mov     hBrush, eax
         ret

CancleIt:
      INVOKE     DeleteObject, hBrush
      INVOKE     EndDialog, hdlg, wparam
         mov     eax, TRUE             ; Return
         jmp     DlgRet                ; with TRUE

DlgDone:
         mov     eax, FALSE            ; Return with FALSE

DlgRet:
         ret                           ; Return
SplitBarProc ENDP

end start