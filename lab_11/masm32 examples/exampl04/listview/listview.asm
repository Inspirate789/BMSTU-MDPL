         title   Listview
         comment '*==============================*'
         comment '* Programmed by Ewayne Wagner  *'
         comment '* E-MAIL: yooper@kalamazoo.net *'
         comment '*==============================*'

         .586
         .model  flat, STDCALL
            option   casemap: none   ; Case sensitive
            include  \MASM32\include\Windows.inc
            include  \MASM32\include\user32.inc
            include  \Masm32\include\gdi32.inc
            include  \MASM32\include\kernel32.inc
            include  \MASM32\include\comctl32.inc
            include  \MASM32\include\imagehlp.inc
            include  \MASM32\include\shell32.inc
            include  \MASM32\include\ole32.inc

         includelib  \MASM32\lib\user32.lib
         includelib  \Masm32\lib\gdi32.lib
         includelib  \MASM32\lib\kernel32.lib
         includelib  \MASM32\lib\comctl32.lib
         includelib  \MASM32\LIB\imagehlp.LIB
         includelib  \MASM32\lib\shell32.lib
         includelib  \MASM32\lib\ole32.lib

WinMain        PROTO :DWORD, :DWORD, :DWORD, :DWORD
LoadListView   PROTO :DWORD, :DWORD
ListViewSort   PROTO :DWORD, :DWORD, :DWORD
BaseAscii      PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
fmtime         PROTO :SYSTEMTIME

IDM_MAINMENU   equ  10000
IDB_BITMAPS    equ  301
IDB_BITMAPL    equ  302

IDM_OPEN       equ  401
IDM_EXIT       equ  402
IDM_TEST       equ  403

IDM_LARGEICON  equ  500 ;LVS_ICON
IDM_SMALLICON  equ  502 ;LVS_SMALLICON
IDM_LIST       equ  503 ;LVS_LIST
IDM_REPORT     equ  501 ;LVS_REPORT

IDM_ALIGNLEFT  equ  601 ;LVA_ALIGNLEFT    ; 1
IDM_ALIGNTOP   equ  602 ;LVA_ALIGNTOP     ; 2
IDM_DEFAULT    equ  600 ;LVS_DEFAULT      ; 0
IDM_SNAPTOGRID equ  605 ;LVS_SNAPTOGRID   ; 5

MOVmw    MACRO Var1, Var2
               lea     esi, Var2
               lea     edx, Var1
            REPEAT     2
                  mov     al, [esi]
                  mov     [edx], al
                  inc     esi
                  inc     edx
            ENDM
         ENDM

.const
ClassName         db        'ListViewWindow',0
AppName           db        'A ListView Control',0
ListViewClass     db        'SysListView32',0
FontMS            db        'MS Sans Serif',0

szColName         db        'Filename',0
szColSize         db        'Size',0
szColDate         db        'Date           Time',0
szColAttr         db        'Attr',0

szSelect          db        'Select A Folder',0
szAll             db        '*.*',0
template          db        '%lu',0
szRootPath        db        'C:\',0
szSlashB          db        '\',0
szDir             db        '<DIR>',0
szRGB             db        'RGB\',0
szFill            db        '----',0
szFile            db        'GREEN.txt',0

.data?
hInst             dd        ?
hWnd              dd        ?
hList             dd        ?
hTree             dd        ?
hMenu             dd        ?
hFontL            dd        ?
hImageListS       dd        ?
hImageListL       dd        ?
hImageTestS       dd        ?
hImageTestL       dd        ?
hBitmap           dd        ?
HoldT             dd        ?

.data
szArc             db        4   dup(?),0
szRoot            db        256 dup(?)
szPath            db        256 dup(?)

SortN             dd        0
SortS             dd        0
SortD             dd        0
Cnt               dd        0
TestSw            dd        0
SmallBMP          dd        0
LargeBMP          dd        0
DragMode          dd        0
ItemID            dd        0
Diff              dd        0

DATETIME   struct
        dmo       BYTE      2 dup(?)
                  BYTE      '/'
        dda       BYTE      2 dup(?)
                  BYTE      '/'
        dyr       BYTE      4 dup(?)
                  BYTE      ' '
        dhour     BYTE      2 dup(?)
                  BYTE      ':'
        dmin      BYTE      2 dup(?)
                  BYTE      ':'
        dsec      BYTE      2 dup(?)
                  BYTE      0
DATETIME   ends

cdt          DATETIME    <>
lf           LOGFONT     <>
bri          BROWSEINFO  <>
pt           POINT       <?>
rect         RECT        <>

.code

start:
      INVOKE     GetModuleHandle, NULL
         mov     hInst, eax
      INVOKE     InitCommonControls
      INVOKE     WinMain, hInst, NULL, NULL, SW_SHOWDEFAULT
      INVOKE     ExitProcess, eax

;=========================================================================
; WinMain PROCEDURE
;=========================================================================
WinMain proc hinst:DWORD, hPrevInst, CmdLine, CmdShow
LOCAL    wc:WNDCLASSEX
LOCAL    msg:MSG

         mov     wc.cbSize, sizeof WNDCLASSEX
         mov     wc.style,  NULL
         mov     wc.lpfnWndProc,  offset WndProc
         mov     wc.cbClsExtra, NULL
         mov     wc.cbWndExtra, NULL
        push     hInst
         pop     wc.hInstance
         mov     wc.hbrBackground, COLOR_WINDOW+1
         mov     wc.lpszMenuName, IDM_MAINMENU
         mov     wc.lpszClassName, offset ClassName
      INVOKE     LoadIcon, NULL, IDI_APPLICATION
         mov     wc.hIcon, eax
         mov     wc.hIconSm, eax
      INVOKE     LoadCursor, NULL, IDC_ARROW
         mov     wc.hCursor, eax
      INVOKE     RegisterClassEx,  addr wc

;---------- [Center the window] ----------
      INVOKE     GetSystemMetrics, SM_CXSCREEN
         sub     eax, 416
         shr     eax, 1
        push     eax
      INVOKE     GetSystemMetrics, SM_CYSCREEN
         sub     eax, 290
         shr     eax, 1
         pop     ebx

      INVOKE     CreateWindowEx,  NULL,  addr ClassName, addr AppName,\
                 WS_OVERLAPPEDWINDOW,\
                 ebx, eax, 416, 290, NULL, NULL, hInst, NULL
         mov     hWnd, eax

      INVOKE     ShowWindow, hWnd, SW_SHOWNORMAL
      INVOKE     UpdateWindow, hWnd

      .while TRUE
         INVOKE     GetMessage, addr msg, NULL, 0, 0
         .break .if (!eax)
         INVOKE     TranslateMessage, addr msg
         INVOKE     DispatchMessage, addr msg
      .endw
         mov     eax, msg.wParam
         ret
WinMain endp

;=========================================================================
; WndProc PROCEDURE
;=========================================================================
WndProc proc hwnd:DWORD, wmsg, wparam, lparam
LOCAL    lvhit:LV_HITTESTINFO
LOCAL    lvi:LV_ITEM
LOCAL    szBuff[256]:BYTE

      .if wmsg == WM_CREATE
           push     hwnd
            pop     hWnd
           call     InitListView
         INVOKE     SendMessage, hList, LVM_SORTITEMS, 1, addr ListViewSort
           call     Resequence
            mov     SortN, 1

      .elseif wmsg == WM_COMMAND
         .if lparam == 0
               mov     eax, wparam
              cwde
            .if eax == IDM_OPEN
                 call     BrowseForFolder
               INVOKE     SendMessage, hList, LVM_SORTITEMS, 1, addr ListViewSort
                 call     Resequence
                  mov     SortN, 1
                  jmp     Ret0
            .elseif eax == IDM_EXIT
                  jmp     GetOut
            .elseif eax == IDM_TEST
                  mov     TestSw, 1
               INVOKE     lstrcpy, addr szPath, addr szRoot
               INVOKE     lstrcat, addr szPath, addr szRGB
               .if !LargeBMP
                  INVOKE     SendMessage, hList, LVM_SETIMAGELIST, LVSIL_SMALL, hImageTestS
               .else
                  INVOKE     SendMessage, hList, LVM_SETIMAGELIST, LVSIL_NORMAL, hImageTestL
               .endif
               INVOKE     SendMessage, hList, LVM_DELETEALLITEMS, 0, 0
                 call     ReadTheFile
                  jmp     DefWin
            .endif

;---------- [Get the Listview Menu item] ----------
            INVOKE     GetWindowLong, hList, GWL_STYLE
               and     eax, not LVS_TYPEMASK
               mov     edx, wparam
               and     edx, 0FFFFh
               mov     wparam, edx
            .if edx > 499 && edx < 504
                  sub     edx, 500
                   or     eax, edx
                 push     eax
            .elseif edx > 599 && edx < 606
                  sub     edx, 600
            .else
                  jmp     DefWin
            .endif
            .if wparam > 599
               .if LargeBMP || SmallBMP
                  .if SmallBMP
                         or     eax, 2
                  .endif
                  .if wparam == 600          ; Default
;                         or     eax, 100h
                  .elseif wparam == 601      ; Align left
                         or     eax, 800h
                  .elseif wparam == 602      ; Align top
                     .if (eax & LVS_ALIGNLEFT)
                        xor     eax, 800h
                     .endif
                  .endif
                     INVOKE     SetWindowLong, hList, GWL_STYLE, eax
                     jmp     Arrange
               .else
                     jmp     DefWin
               .endif
            .endif
               and     LargeBMP, 0
               and     SmallBMP, 0
            .if edx == LVS_ICON
                   or     LargeBMP, 1
               .if !TestSw
                  INVOKE     SendMessage, hList, LVM_SETIMAGELIST, LVSIL_NORMAL, hImageListL
               .else
                  INVOKE     SendMessage, hList, LVM_SETIMAGELIST, LVSIL_NORMAL, hImageTestL
               .endif
            .else
               .if edx == LVS_SMALLICON
                      or     SmallBMP, 1
               .endif
               .if !TestSw
                  INVOKE     SendMessage, hList, LVM_SETIMAGELIST, LVSIL_SMALL, hImageListS
               .else
                  INVOKE     SendMessage, hList, LVM_SETIMAGELIST, LVSIL_SMALL, hImageTestS
               .endif
            .endif

               pop     eax
            INVOKE     SetWindowLong, hList, GWL_STYLE, eax
            .if edx == LVS_ICON || LVS_SMALLICON
               INVOKE     SendMessage, hList, LVM_ARRANGE, LVA_DEFAULT, 0
            .endif

Arrange:
            .if wparam > 599
                  mov     edx, wparam
                  sub     edx, 600
               INVOKE     SendMessage, hList, LVM_ARRANGE, edx, 0
            .endif

               mov     edx, wparam
            .if edx > 499 && edx < 504
               INVOKE     CheckMenuRadioItem, hMenu, IDM_LARGEICON, IDM_LIST, edx, MF_BYCOMMAND OR MF_CHECKED
            .else
               INVOKE     CheckMenuRadioItem, hMenu, IDM_DEFAULT, IDM_SNAPTOGRID, edx, MF_BYCOMMAND OR MF_CHECKED
            .endif
         .endif

      .elseif wmsg == WM_NOTIFY
           push     edi
            mov     edi, lparam
            mov     eax, [edi.NMHDR].hwndFrom
         .if eax == hList
            .if [edi.NMHDR].code == LVN_COLUMNCLICK
               .if [edi.NM_LISTVIEW].iSubItem == 0
                  .if !SortN
                     INVOKE     SendMessage, hList, LVM_SORTITEMS, 1, addr ListViewSort
                       call     Resequence
                         or     SortN, 1
                  .else
                     INVOKE     SendMessage, hList, LVM_SORTITEMS, 2, addr ListViewSort
                       call     Resequence
                        and     SortN, 0
                  .endif                        
               .elseif [edi.NM_LISTVIEW].iSubItem == 1
                  .if !SortS
                     INVOKE     SendMessage, hList, LVM_SORTITEMS, 3, addr ListViewSort
                       call     Resequence
                         or     SortS, 1
                  .else
                     INVOKE     SendMessage, hList, LVM_SORTITEMS, 4, addr ListViewSort
                       call     Resequence
                        and     SortS, 0
                  .endif
               .elseif [edi.NM_LISTVIEW].iSubItem == 2
                  .if !SortD
                     INVOKE     SendMessage, hList, LVM_SORTITEMS, 5, addr ListViewSort
                       call     Resequence
                         or     SortD, 1
                  .else
                     INVOKE     SendMessage, hList, LVM_SORTITEMS, 6, addr ListViewSort
                       call     Resequence
                        and     SortD, 0
                  .endif
               .endif

            .elseif [edi.NMHDR].code == NM_DBLCLK
               INVOKE     ReleaseCapture
                 call     DisplayFileName

            .elseif [edi.NMHDR].code == LVN_BEGINDRAG
                  mov     eax, [edi.NM_LISTVIEW].iItem
                  mov     ItemID, eax
                  mov     DragMode, 1
                  and     Diff, 0
               INVOKE     SetCapture, hWnd
               INVOKE     GetCursorPos, addr pt
               INVOKE     ScreenToClient, hList, addr pt
                  mov     eax, pt.x
                  mov     lvhit.pt.x, eax
                  mov     eax, pt.y
                  mov     lvhit.pt.y, eax
               INVOKE     SendMessage, hList, LVM_HITTEST, 0, addr lvhit
               .if (lvhit.flags & LVHT_ONITEM)
                  INVOKE     GetWindowRect, hList, addr rect
                     add     rect.top, 2
                  INVOKE     ClipCursor, addr rect
                  INVOKE     SendMessage, hList, LVM_GETVIEWRECT, 0, addr rect
                     mov     eax, rect.top
                  .if eax > 7fffffffh
                        neg     eax
                        add     rect.bottom, eax
                  .endif
                     sub     rect.bottom, 66
                     mov     rect.top, 2
                  INVOKE     SendMessage, hList, LVM_GETITEMPOSITION, ItemID, addr pt
                    push     pt.y
                     pop     Diff
                     mov     eax, lvhit.pt.y
                  .if Diff > eax
                        sub     Diff, eax
                  .else
                        and     Diff, 0
                  .endif
               .endif
            .endif
         .endif
         pop edi

      .elseif wmsg == WM_MOUSEMOVE
         .if DragMode
;            INVOKE     SendMessage, hList, LVM_ENSUREVISIBLE, ItemID, 0
            INVOKE     SendMessage, hList, LVM_GETITEMPOSITION, ItemID, addr pt
            .if pt.x >= 0 && pt.y >= 0
               INVOKE     GetCursorPos, addr pt
               INVOKE     ScreenToClient, hList, addr pt
               .if pt.x < 21 && LargeBMP || pt.x > 9000 && LargeBMP
                     mov     pt.x, 21
               .elseif pt.x > 9000 && !LargeBMP
                     mov     pt.x, 0
               .endif
                 push     pt.y
                  pop     eax
               .if eax < rect.top && LargeBMP
                    push     rect.top
                     pop     pt.y
                     jmp     Pass
               .elseif eax > rect.bottom && LargeBMP
                    push     rect.bottom
                     pop     pt.y
                     jmp     Pass
               .elseif pt.y > 9000 && !LargeBMP
                     mov     pt.y, 0
               .endif
                  mov     eax, Diff
                  add     pt.y, eax
Pass:

               INVOKE     SendMessage, hList, LVM_SETITEMPOSITION32, ItemID, addr pt
                  mov     lvi.imask, LVIF_STATE
                  mov     lvi.state, 0
            .endif
         .endif

      .elseif wmsg == WM_LBUTTONUP
            and     DragMode, 0
         INVOKE     ClipCursor, 0
         INVOKE     ReleaseCapture

      .elseif wmsg == WM_SIZE
            mov     eax, lparam
            mov     edx, eax
            and     eax, 0ffffh
            shr     edx, 16
         INVOKE     MoveWindow, hList, 0, 0, eax, edx, TRUE

      .elseif wmsg == WM_DESTROY

GetOut:
         INVOKE     ImageList_Destroy, hImageTestS
         INVOKE     ImageList_Destroy, hImageTestL
         INVOKE     PostQuitMessage, NULL
      .else

DefWin:
         INVOKE     DefWindowProc, hwnd, wmsg, wparam, lparam       
            ret
      .endif

Ret0:
         xor     eax, eax
         ret
WndProc endp

;=========================================================================
; InitListView PROCEDURE
;=========================================================================
InitListView  proc
LOCAL    sfi:SHFILEINFO
LOCAL    lvc:LV_COLUMN

; or LVS_SORTASCENDING
      INVOKE     CreateWindowEx, WS_EX_CLIENTEDGE, addr ListViewClass, NULL,\
                 WS_CHILD or WS_VISIBLE or LVS_REPORT or LVS_SHAREIMAGELISTS,\
                 0, 0, 0, 0, hWnd, NULL, hInst, NULL
         mov     hList, eax

         mov     eax, LVS_EX_FULLROWSELECT or LVS_EX_HEADERDRAGDROP or\
                      LVS_EX_SUBITEMIMAGES or LVS_EX_GRIDLINES
      INVOKE     SendMessage, hList, LVM_SETEXTENDEDLISTVIEWSTYLE, 0, eax

      INVOKE     ImageList_Create, 16, 16, ILC_COLOR32, 3, 0
         mov     hImageTestS, eax
      INVOKE     LoadBitmap, hInst, IDB_BITMAPS
         mov     hBitmap, eax
      INVOKE     ImageList_Add, hImageTestS, hBitmap, NULL
      INVOKE     DeleteObject, hBitmap
      INVOKE     ImageList_Create, 32, 32, ILC_COLOR32, 3, 0
         mov     hImageTestL, eax
      INVOKE     LoadBitmap, hInst, IDB_BITMAPL
         mov     hBitmap, eax
      INVOKE     ImageList_Add, hImageTestL, hBitmap, NULL
      INVOKE     DeleteObject, hBitmap

      INVOKE     SHGetFileInfo, addr szRootPath, 0, addr sfi, sizeof SHFILEINFO,\
                 SHGFI_SYSICONINDEX or SHGFI_SMALLICON
         mov     hImageListS, eax
      INVOKE     SHGetFileInfo, addr szRootPath, 0, addr sfi, sizeof SHFILEINFO,\
                 SHGFI_SYSICONINDEX or SHGFI_LARGEICON
         mov     hImageListL, eax
      INVOKE     SendMessage, hList, LVM_SETIMAGELIST, LVSIL_SMALL, hImageListS

      INVOKE     GetCurrentDirectory, lengthof szPath, addr szPath
      .if byte ptr szPath+2 != '\' || eax > 3
         INVOKE     lstrcat, addr szPath, addr szSlashB
      .endif
      INVOKE     SearchTreeForFile, addr szPath, addr szFile, addr szRoot
      .if eax
         INVOKE     lstrlen, addr szRoot
            sub     eax, 12
         INVOKE     lstrcpyn, addr szRoot, addr szRoot, eax
      .endif

      INVOKE     lstrcpy, addr lf.lfFaceName, addr FontMS
         mov     lf.lfHeight, -12
         mov     lf.lfWeight, 600
      INVOKE     CreateFontIndirect, addr lf
         mov     hFontL, eax    ; Listview font

      INVOKE     SendMessage, hList, WM_SETFONT, hFontL, 1
      INVOKE     SendMessage, hList, LVM_SETTEXTCOLOR, 0, 00ffff00h
      INVOKE     SendMessage, hList, LVM_SETBKCOLOR, 0, 00000000h
      INVOKE     SendMessage, hList, LVM_SETTEXTBKCOLOR, 0, 00000000h
      INVOKE     GetMenu, hWnd
         mov     hMenu, eax
      INVOKE     CheckMenuRadioItem, hMenu, IDM_LARGEICON, IDM_LIST, IDM_REPORT, MF_BYCOMMAND or MF_CHECKED

         mov     lvc.imask, LVCF_TEXT or LVCF_WIDTH
         mov     lvc.pszText, offset szColName
         mov     lvc.lx, 150
      INVOKE     SendMessage, hList, LVM_INSERTCOLUMN, 0, addr lvc
          or     lvc.imask, LVCF_FMT
         mov     lvc.fmt, LVCFMT_RIGHT
         mov     lvc.pszText, offset szColSize
         mov     lvc.lx, 65
      INVOKE     SendMessage, hList, LVM_INSERTCOLUMN, 1, addr lvc   
         mov     lvc.fmt, LVCFMT_LEFT
         mov     lvc.pszText, offset szColDate
         mov     lvc.lx, 135
      INVOKE     SendMessage, hList, LVM_INSERTCOLUMN, 2, addr lvc   
         mov     lvc.fmt, LVCFMT_LEFT
         mov     lvc.pszText, offset szColAttr
         mov     lvc.lx, 38
      INVOKE     SendMessage, hList, LVM_INSERTCOLUMN, 3, addr lvc   
        call     ReadTheFile
         ret
InitListView  endp

;=========================================================================
; Browse for folder PROCEDURE
;=========================================================================
BrowseForFolder  proc
LOCAL    pidl:DWORD

      pushad
        push     hWnd
         pop     bri.hwndOwner
         mov     bri.pidlRoot, 0
         mov     bri.pszDisplayName, 0
         mov     eax, offset szSelect
         mov     bri.lpszTitle, eax
         mov     bri.ulFlags, BIF_RETURNONLYFSDIRS or BIF_DONTGOBELOWDOMAIN
         mov     bri.lpfn, 0
         mov     bri.lParam, 0
         mov     bri.iImage, 0
      INVOKE     SHBrowseForFolder, addr bri
      .if !eax
            jmp     GetOut
      .endif
         mov     pidl, eax
      INVOKE     SHGetPathFromIDList, pidl, addr szPath
   INVOKE     lstrcat, addr szPath, addr szSlashB
      INVOKE     SendMessage, hList, LVM_DELETEALLITEMS, 0, 0
      INVOKE     CoTaskMemFree, pidl
      .if TestSw
            and     TestSw, 0
         INVOKE     SendMessage, hList, LVM_SETIMAGELIST, LVSIL_SMALL, hImageListS
      .endif
        call     ReadTheFile
      .if LargeBMP
            INVOKE     SendMessage, hWnd, WM_COMMAND, IDM_LARGEICON, 0
      .endif

GetOut:
       popad
         ret
BrowseForFolder  endp

;=========================================================================
; Read the file PROCEDURE
;=========================================================================
ReadTheFile  proc  uses edi
LOCAL    FindData:WIN32_FIND_DATA
LOCAL    Lft:FILETIME
LOCAL    time:SYSTEMTIME
LOCAL    hFind:DWORD
LOCAL    szBuff[256]:BYTE

      INVOKE     lstrcpy, addr szBuff, addr szPath
      INVOKE     lstrcat, addr szBuff, addr szAll
         and     Cnt, 0

      INVOKE     FindFirstFile, addr szBuff, addr FindData
      .if eax != INVALID_HANDLE_VALUE
            mov     hFind, eax
         .while (eax)
               inc     Cnt
            INVOKE     FindNextFile, hFind, addr FindData
         .endw
      .endif

      INVOKE     FindFirstFile, addr szBuff, addr FindData
      .if eax != INVALID_HANDLE_VALUE
            mov     hFind, eax
            xor     edi, edi
         .while eax != 0
            .if byte ptr FindData.cFileName != '.'
;               .if (FindData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)
;               .else

;---------- [Get the time] ----------
                  INVOKE     FileTimeToLocalFileTime, addr FindData.ftLastWriteTime, addr Lft
                  INVOKE     FileTimeToSystemTime, addr Lft, addr time
                  INVOKE     fmtime, time.SYSTEMTIME

;---------- [Get the Attributes] ----------
                  INVOKE     lstrcpy, addr szArc, addr szFill
                     mov     eax, offset szArc
                  .if (FindData.dwFileAttributes & FILE_ATTRIBUTE_READONLY)
                        mov     byte ptr[eax], 'r'
                  .endif
                  .if (FindData.dwFileAttributes & FILE_ATTRIBUTE_ARCHIVE)
                        mov     byte ptr[eax+1], 'a'
                  .endif
                  .if (FindData.dwFileAttributes & FILE_ATTRIBUTE_HIDDEN)
                        mov     byte ptr[eax+2], 'h'
                  .endif
                  .if (FindData.dwFileAttributes & FILE_ATTRIBUTE_SYSTEM)
                        mov     byte ptr[eax+3], 's'
                  .endif
                  INVOKE     LoadListView, edi, addr FindData
                     inc     edi
;               .endif
            .endif
            INVOKE     FindNextFile, hFind, addr FindData
         .endw
         INVOKE     FindClose, hFind
      .endif
         ret
ReadTheFile  endp

;=========================================================================
; Load the ListView with the file data PROCEDURE
;=========================================================================
LoadListView proc  uses ebx edi  row:DWORD, lpFind  ; uses edi
LOCAL    lvi:LV_ITEM
LOCAL    sfi:SHFILEINFO
LOCAL    DirSw:DWORD
LOCAL    szBuff0[20]:BYTE, szBuff1[256]

      INVOKE     lstrcpy, addr szBuff1, addr szPath
         mov     edi, lpFind

;---------- [Load the list items] ----------
         mov     lvi.imask, LVIF_TEXT or LVIF_IMAGE or LVIF_PARAM
        push     row
         pop     lvi.iItem
        push     row
         pop     lvi.lParam
         mov     lvi.iSubItem, 0
         lea     eax, [edi.WIN32_FIND_DATA].cFileName
         mov     lvi.pszText, eax
      INVOKE     lstrcat, addr szBuff1, eax
         mov     lvi.iImage, 0
      .if Cnt < 1000 && !TestSw
         INVOKE     SHGetFileInfo, addr szBuff1, 0, addr sfi, sizeof SHFILEINFO,\
                    SHGFI_SYSICONINDEX or SHGFI_SMALLICON or SHGFI_TYPENAME or SHGFI_ATTRIBUTES
            mov     eax, sfi.iIcon
            mov     lvi.iImage, eax
      .else
         .if byte ptr [edi.WIN32_FIND_DATA].cFileName == 'R'
               mov     lvi.iImage, 0
         .elseif byte ptr [edi.WIN32_FIND_DATA].cFileName == 'G'
               mov     lvi.iImage, 1
         .elseif byte ptr [edi.WIN32_FIND_DATA].cFileName == 'B'
               mov     lvi.iImage, 2
         .endif
      .endif
      INVOKE     SendMessage, hList, LVM_INSERTITEM, 0, addr lvi

;---------- [Load the sub items] ----------
         and     DirSw, 0

;---------- [Check for a Folder] ----------
      .if byte ptr sfi.szTypeName+5 == 'F' && byte ptr sfi.szTypeName+10 == 'r'
             or     DirSw, 1
      .endif
         mov     lvi.imask, LVIF_TEXT
         inc     lvi.iSubItem

;---------- [Get the file size] ----------
      .if !DirSw
            mov     eax, MAXDWORD
            mov     ebx, [edi.WIN32_FIND_DATA].nFileSizeHigh
           imul     ebx
            add     eax, [edi.WIN32_FIND_DATA].nFileSizeLow
            mov     edx, eax
         INVOKE     BaseAscii, edx, addr szBuff0, 0, 10, 0, 0, 1

;---------- [Load the file size] ----------
            lea     eax, szBuff0
      .else
            lea     eax, szDir
      .endif
         mov     lvi.pszText, eax
      INVOKE     SendMessage, hList, LVM_SETITEM, 0, addr lvi
         inc     lvi.iSubItem

;---------- [Load the date] ----------
         lea     eax, cdt.dmo
         mov     lvi.pszText, eax
      INVOKE     SendMessage, hList, LVM_SETITEM, 1, addr lvi
         inc     lvi.iSubItem

;---------- [Load the attributes] ----------
         lea     eax, szArc
         mov     lvi.pszText, eax
      INVOKE     SendMessage, hList, LVM_SETITEM, 2, addr lvi
         ret
LoadListView endp

;=========================================================================
; Resequence the lvi.iItem and copy to lvi.lParam PROCEDURE
;=========================================================================
Resequence proc uses edi
LOCAL    lvi:LV_ITEM

      INVOKE     SendMessage, hList, LVM_GETITEMCOUNT, 0, 0
         mov     edi, eax
         mov     lvi.imask, LVIF_PARAM
         mov     lvi.iSubItem, 0
         mov     lvi.iItem, 0
      .while (edi)
           push     lvi.iItem
            pop     lvi.lParam
         INVOKE     SendMessage, hList, LVM_SETITEM, 0, addr lvi
            inc     lvi.iItem
            dec     edi
      .endw
         ret
Resequence endp

;=========================================================================
; Display the file name PROCEDURE
;=========================================================================
DisplayFileName proc
LOCAL    lvi:LV_ITEM
LOCAL    szBuff[256]:BYTE

      INVOKE     SendMessage, hList, LVM_GETNEXTITEM, -1, LVNI_FOCUSED
         mov     lvi.iItem, eax
         mov     lvi.iSubItem, 0
         mov     lvi.imask, LVIF_TEXT
         lea     eax, szBuff
         mov     lvi.pszText, eax
         mov     lvi.cchTextMax, 256
      INVOKE     SendMessage, hList, LVM_GETITEM, 0, addr lvi
      INVOKE     MessageBox, NULL, addr szBuff, addr AppName, MB_OK
         ret
DisplayFileName endp

;=========================================================================
; Converts an ascii string to a 32 bit num value.
;=========================================================================
AsciiBase proc uses  esi InPut:DWORD
;INVOKE     AsciiBase, addr szBuff0

         xor     eax, eax
         mov     esi, InPut
         xor     ecx, ecx
         xor     edx, edx
         mov     al, [esi]
         inc     esi
      .while al != 0
            sub     al, '0'          ; Convert to bcd
            lea     ecx, [ecx+ecx*4] ; ecx = ecx * 5
            lea     ecx, [eax+ecx*2] ; ecx = eax + old ecx * 10
            mov     al, [esi]
            inc     esi
      .endw
         lea     eax, [ecx+edx]     ; Move to eax
         ret

AsciiBase endp

;=========================================================================
;  Converts a 32 bit num value to a Dec, Hex, Oct or Bin ascii string.
;=========================================================================
;INVOKE     BaseAscii, cnt, addr num, 2, 10, 0, 1, 0
;InPut, OutPut, Length only needed if fill is on, Base, Insert commas, Left fill, Add terminating null
BaseAscii PROC InPut:DWORD, OutPut, Len, Base, Comma, Fill, TermA
LOCAL    LBuff[32]: BYTE

      pushad
         xor     esi, esi
         mov     eax, InPut                ; Input
         mov     ebx, OutPut
         mov     byte ptr [ebx], '0'
      .while (eax)
            xor     edx, edx
            div     Base                   ; Base 10, 16, 8, 2
            add     dl, 30h                ; Convert to dec ASCII
            mov     LBuff[esi], dl
            inc     esi
      .endw
         xor     edi, edi
         mov     ecx, esi
      .if Len > ecx  && Fill == 1          ; Zero fill
            xor     eax, eax
         .while (eax < Len)
               mov     byte ptr [ebx+eax], '0'
               inc     eax
         .endw
            sub     Len, ecx
            add     edi, Len
      .endif
      .while (ecx)
            mov     al, byte ptr LBuff[esi-1]
            mov     byte ptr [ebx+edi], al
            inc     edi
            dec     esi
            dec     ecx
      .endw
      .if TermA                            ; Insert a terminating char
         mov     byte ptr [ebx+edi], 0
      .endif
       popad
          ret
BaseAscii ENDP

;=========================================================================
; Format the time and send it to the ConvDateTime structure
;=========================================================================
fmtime   PROC    time:SYSTEMTIME
       MOVmw     HoldT, time.wDay
      INVOKE     BaseAscii, HoldT, addr cdt.dda, 2, 10, 0, 1, 0
       MOVmw     HoldT, time.wMonth
      INVOKE     BaseAscii, HoldT, addr cdt.dmo, 2, 10, 0, 1, 0
       MOVmw     HoldT, time.wYear
      INVOKE     BaseAscii, HoldT, addr cdt.dyr, 4, 10, 0, 1, 0
       MOVmw     HoldT, time.wHour
      INVOKE     BaseAscii, HoldT, addr cdt.dhour, 2, 10, 0, 1, 0
       MOVmw     HoldT, time.wMinute
      INVOKE     BaseAscii, HoldT, addr cdt.dmin, 2, 10, 0, 1, 0
       MOVmw     HoldT, time.wSecond
      INVOKE     BaseAscii, HoldT, addr cdt.dsec, 2, 10, 0, 1, 0
         lea     eax, cdt.dmo
         RET
fmtime   ENDP

;=========================================================================
; ListViewSort PROCEDURE
;=========================================================================
ListViewSort proc uses edi lParam1:DWORD, lParam2, lParamSort
;INVOKE     SendMessage, hList, LVM_SORTITEMS, 1, addr ListViewSort
LOCAL    lvi:LV_ITEM
LOCAL    Dir1:DWORD, Dir2
LOCAL    szBuff0[256]:BYTE, szBuff1[256], Work[256]

         and     Dir1, 0
         and     Dir2, 0
         mov     lvi.imask, LVIF_TEXT
         lea     eax, szBuff0
         mov     lvi.pszText, eax
         mov     lvi.cchTextMax, 256

         mov     lvi.iSubItem, 1
      INVOKE     SendMessage, hList, LVM_GETITEMTEXT, lParam1, addr lvi
         xor     eax, eax
         mov     al, byte ptr szBuff0
         mov     Dir1, eax
      INVOKE     SendMessage, hList, LVM_GETITEMTEXT, lParam2, addr lvi
         xor     eax, eax
         mov     al, byte ptr szBuff0
         mov     Dir2, eax


      .if lParamSort == 1 || lParamSort == 2
            mov     lvi.iSubItem, 0
         INVOKE     SendMessage, hList, LVM_GETITEMTEXT, lParam1, addr lvi
         INVOKE     lstrcpy, addr szBuff1, addr szBuff0
         INVOKE     SendMessage, hList, LVM_GETITEMTEXT, lParam2, addr lvi
         .if lParamSort == 1
            INVOKE     lstrcmpi, addr szBuff1, addr szBuff0
         .else
            INVOKE     lstrcmpi, addr szBuff0, addr szBuff1
         .endif
      .elseif lParamSort == 3 || lParamSort == 4
            mov     lvi.iSubItem, 1
         INVOKE     SendMessage, hList, LVM_GETITEMTEXT, lParam1, addr lvi
         INVOKE     AsciiBase, addr szBuff0
            mov     edi, eax
         INVOKE     SendMessage, hList, LVM_GETITEMTEXT, lParam2, addr lvi
         INVOKE     AsciiBase, addr szBuff0
         .if lParamSort == 3
               sub     edi, eax
               mov     eax, edi
         .else
               sub     eax, edi
         .endif
      .elseif lParamSort == 5 || lParamSort == 6
            mov     lvi.iSubItem, 2
         INVOKE     SendMessage, hList, LVM_GETITEMTEXT, lParam1, addr lvi

;---------- [Rearrange the date fields] ----------
         INVOKE     lstrcpy, addr Work, addr szBuff0+6
         INVOKE     lstrcpyn, addr Work+4, addr szBuff0, 6
         INVOKE     lstrcpyn, addr Work+9, addr szBuff0+11, 9
         INVOKE     lstrcpy, addr szBuff0, addr Work
         INVOKE     lstrcpy, addr szBuff1, addr szBuff0
         INVOKE     SendMessage, hList, LVM_GETITEMTEXT, lParam2, addr lvi
         INVOKE     lstrcpy, addr Work, addr szBuff0+6
         INVOKE     lstrcpyn, addr Work+4, addr szBuff0, 6
         INVOKE     lstrcpyn, addr Work+9, addr szBuff0+11, 9
         INVOKE     lstrcpy, addr szBuff0, addr Work
         .if lParamSort == 5
            INVOKE     lstrcmpi, addr szBuff1, addr szBuff0
         .else
            INVOKE     lstrcmpi, addr szBuff0, addr szBuff1
         .endif
      .endif

;---------- [Keep the folders on top] ----------
      .if byte ptr Dir1 == '<' && byte ptr Dir2 != '<'
            xor     eax, eax
            dec     eax
            ret
      .elseif byte ptr Dir2 == '<' && byte ptr Dir1 != '<'
            xor     eax, eax
            inc     eax
            ret
      .elseif byte ptr Dir1 == '<' && byte ptr Dir2 == '<'
            xor     eax, eax
            ret
      .endif
         ret
ListViewSort endp

end start
;INVOKE     MessageBox, NULL, addr szPath, addr AppName, MB_OK
