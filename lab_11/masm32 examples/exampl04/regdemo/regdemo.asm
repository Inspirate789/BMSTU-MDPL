         title   RegDemo
         comment '*==============================*'
         comment '* Programed by Ewayne Wagner   *'
         comment '* E-MAIL: yooper@kalamazoo.net *'
         comment '*==============================*'

         .586
         .model flat, stdcall
         option casemap:none   ; Case sensitive

            include  \MASM32\include\windows.inc
            include  \MASM32\include\user32.inc
            include  \MASM32\include\GDI32.inc
            include  \MASM32\include\kernel32.inc
            include  \MASM32\include\comdlg32.inc
            include  \MASM32\include\COMCTL32.inc
            include  \MASM32\include\advapi32.inc

         includelib  \MASM32\lib\user32.lib
         includelib  \MASM32\lib\GDI32.lib
         includelib  \MASM32\lib\kernel32.lib
         includelib  \MASM32\lib\comdlg32.lib
         includelib  \MASM32\lib\COMCTL32.lib
         includelib  \MASM32\lib\advapi32.lib

WinMain          PROTO  :DWORD, :DWORD, :DWORD, :DWORD

.const
EditID           equ 1
IDM_EXIT         equ 2

.data
ClassName        db  'RegDemo',0
AppName          db  'RegDemo',0
RichEdit         db  'RichEdit20A',0
RichEdDLL        db  'RICHED20.DLL',0
MenuName         db  'MainMenu',0
ButtClass        db  'button',0
FontNameC        db  'Courier New',0
FontNameS        db  'Tahoma',0

szDay            db  'Have A Nice Day !',0

szAgain          db  'Would you like to go again ?',0
szButt1          db  'Start', 0
szButt2          db  'Next Step', 0
szButt3          db  'Go Back', 0
szError1         db  'The RICHED20.DLL was not found!',0
szREGSZ          db  'REG_SZ',0
szTestKey        db  'Test Key',0
szSubKey         db  'Test Key\Sub Key',0
szHandle         db  '[Win Handle]',0
szDayName        db  '[Day]',0
szBinary         db  '[Binary]',0
szItem           db  '[Item 01]',0

szNULL           db  0
szCRLF           db  0dh,0ah,0dh,0ah,0
fmat2            db  '%02u',0
fmatH2           db  '%02x',0
szSlashB         db  '\',0
szSpace          db  ' ',0
szReg            db  '\Registry.ini',0
szInfo           db  'Info',0
szInfoT          db  'InfoT',0
szFunction       db  'Function',0
szFunctionT      db  'Function ',0
szCode           db  'Code',0
szCodeT          db  'Code ',0
szItemT          db  'Item 01',0
szResults        db  'Results:',0dh,0ah,0
szSuccess        db  'Successful',0dh,0ah,0


.data?
hInst            dd  ?
CommandLine      dd  ?
hREdDll          dd  ?
hDefHeap         dd  ?
pMem             dd  ?
MainExit         dd  ?
hWnd             dd  ? 
hREdit           dd  ?
hFont            dd  ?
hFontB           dd  ?
hButt1           dd  ?
hButt2           dd  ?
Step             dd  ?
Line             dd  ?
DecVal           dd  ?

hKey             dd  ?
hKeyS            dd  ?
lpType           dd  ?
lpcbData         dd  ?
lpdwDisp         dd  ?
lpcValues        dd  ?
lpcbValueName    dd  ?
lpcbMaxValueLen  dd  ?

CurDir           db  256 dup(?)
szBuff           db  256 dup(?)
szBuff1          db  25  dup(?)
szBuff2          db  25  dup(?)
szIndex          db  3   dup(?)
BinVal           db  10  dup(?)

lf               LOGFONT        <?>
charF            CHARFORMAT2    <?>

.code

;________________________________________________________________________________
start:
      INVOKE     GetModuleHandle, NULL
         mov     hInst, eax
      INVOKE     GetCommandLine
         mov     CommandLine, eax

        call     InitCommonControls          ; Initialize the common ctrl lib
      INVOKE     LoadLibrary, addr RichEdDLL ; Load the Riched20.dll
         mov     hREdDll, eax
      .if !eax
         INVOKE     MessageBox, NULL, addr szError1, addr AppName, MB_OK or MB_ICONERROR
            jmp     NoGo
      .endif

      INVOKE     GetProcessHeap
         mov     hDefHeap, eax

      INVOKE     WinMain, hInst ,NULL, CommandLine, SW_SHOWDEFAULT
         mov     MainExit, eax
      INVOKE     FreeLibrary, hREdDll

NoGo:
      INVOKE     ExitProcess, MainExit

;________________________________________________________________________________
WinMain PROC  uses ebx  hinst:DWORD, hPrevInst, CmdLine, CmdShow
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
         sub     eax, 610
         shr     eax, 1
        push     eax
      INVOKE     GetSystemMetrics, SM_CYSCREEN
         sub     eax, 300
         shr     eax, 1
         pop     ebx

      INVOKE     CreateWindowEx, WS_EX_CLIENTEDGE, addr ClassName,\
                 addr AppName, WS_OVERLAPPEDWINDOW,\
                 ebx, eax, 610, 300, NULL, NULL, hInst, NULL
         mov     hWnd, eax

      INVOKE     ShowWindow, hWnd, SW_SHOWNORMAL
      INVOKE     UpdateWindow, hWnd
      .while TRUE
         INVOKE     GetMessage, addr msg, NULL, 0, 0
            .BREAK .IF (!eax)
            INVOKE     TranslateMessage, addr msg
            INVOKE     DispatchMessage, addr msg
      .endw
         mov     eax, msg.wParam
         ret
WinMain ENDP

;________________________________________________________________________________
WndProc PROC  hwnd:DWORD, wMsg, wParam, lParam
LOCAL    Cnt:DWORD

      .if wMsg == WM_CREATE

            mov     charF.cbSize, sizeof charF

;---------- [Allocate memory from the default heap] ----------
         INVOKE     HeapAlloc, hDefHeap, 0, 20000
            mov     pMem, eax

;---------- [Create the Edit font] ----------
         INVOKE     lstrcpy, addr lf.lfFaceName, addr FontNameC
            mov     lf.lfHeight, -9
            mov     lf.lfWidth, 0
            mov     lf.lfWeight, 600
         INVOKE     CreateFontIndirect, addr lf
            mov     hFont, eax

;---------- [Create the Button font] ----------
         INVOKE     lstrcpy, addr lf.lfFaceName, addr FontNameS
            mov     lf.lfHeight, -11
            mov     lf.lfWidth, 0
            mov     lf.lfWeight, 500
         INVOKE     CreateFontIndirect, addr lf
            mov     hFontB, eax

;---------- [Create the buttons] ----------
         INVOKE     CreateWindowEx, 0, addr ButtClass, addr szButt1, WS_CHILD or WS_VISIBLE,
                    3, 3, 75, 22, hwnd, 22, hInst, NULL
            mov     hButt1, eax
         INVOKE     SendMessage, hButt1, WM_SETFONT, hFontB, 1

         INVOKE     CreateWindowEx, 0, addr ButtClass, addr szButt3, WS_CHILD or WS_VISIBLE,
                    81, 3, 75, 22, hwnd, 23, hInst, NULL
            mov     hButt2, eax
         INVOKE     SendMessage, hButt2, WM_SETFONT, hFontB, 1
         INVOKE     ShowWindow, hButt2, SW_HIDE

;---------- [Create the Edit control] ----------
         INVOKE     CreateWindowEx, NULL, addr RichEdit, NULL,\
                    WS_VISIBLE or WS_CHILD or ES_LEFT or ES_MULTILINE or\
                    WS_BORDER or ES_AUTOVSCROLL,\
                    0, 0, 0, 0, hwnd, EditID, hInst, NULL
            mov     hREdit, eax

         INVOKE     SendMessage, hREdit, EM_EXLIMITTEXT, 0, 100000
         INVOKE     SetFocus, hREdit

;---------- [Set back ground and text colors] ----------
         INVOKE     SendMessage, hREdit, WM_SETFONT, hFont, 1
         INVOKE     SendMessage, hREdit, EM_SETBKGNDCOLOR, 0, 00000000h
         INVOKE     lstrcpy, addr charF.szFaceName, addr FontNameC
            mov     charF.crTextColor, 00ffff00h
            mov     charF.crBackColor, 00000000h
            mov     charF.yHeight, 180
            mov     charF.dwEffects, 0 ;CFE_BOLD
            mov     charF.dwMask, CFM_FACE or CFM_SIZE or CFM_COLOR or CFM_BOLD
         INVOKE     SendMessage, hREdit, EM_SETCHARFORMAT, SCF_ALL, addr charF

         INVOKE     GetCurrentDirectory, sizeof CurDir, addr CurDir
         INVOKE     lstrcat, addr CurDir, addr szReg
         INVOKE     GetPrivateProfileString, addr szInfo, addr szInfoT, addr szNULL, addr szBuff, 255, addr CurDir
         INVOKE     SendMessage, hREdit, WM_SETTEXT, 0, addr szBuff

      .elseif wMsg == WM_SIZE
            mov     eax, lParam
            mov     edx, eax
            shr     edx, 16
            and     eax, 0ffffh
            sub     eax, 2
            sub     edx, 27
         INVOKE     MoveWindow, hREdit, 2, 27, eax, edx, TRUE


      .elseif wMsg == WM_DESTROY
         INVOKE     RegCloseKey, hKey
         INVOKE     PostQuitMessage, NULL

      .elseif wMsg == WM_COMMAND
            mov     eax, wParam
           cwde                         ; Only low word contains command

         .if eax == 23
            .if Step > 1
                  sub     Step, 2
               INVOKE     SendMessage, hWnd, WM_COMMAND, 22, 0
            .endif

         .elseif eax == 22
            .if Step == 1
               INVOKE     ShowWindow, hButt2, SW_SHOWNORMAL
            .endif
            INVOKE     SendMessage, hButt1, WM_SETTEXT, 0, addr szButt2
            INVOKE     SetFocus, hREdit
               mov     edx, offset szNULL
            INVOKE     lstrcpy, pMem, edx
            INVOKE     SendMessage, hREdit, WM_SETTEXT, 0, pMem

               mov     charF.crTextColor, 00ffff00h
            INVOKE     SendMessage, hREdit, EM_SETCHARFORMAT, SCF_ALL, addr charF

               inc     Step
            INVOKE     wsprintf, addr szIndex, addr fmat2, Step
            INVOKE     lstrcpy, addr szBuff1, addr szFunction
            INVOKE     lstrcpy, addr szBuff2, addr szFunctionT
            INVOKE     lstrcat, addr szBuff2, addr szIndex
              call     GetCode
               mov     edx, offset szBuff
              Call     BuildEM

               mov     edx, offset szCRLF
              Call     BuildEM

            INVOKE     lstrcpy, addr szBuff1, addr szCode
            INVOKE     lstrcpy, addr szBuff2, addr szCodeT
            INVOKE     lstrcat, addr szBuff2, addr szIndex
              call     GetCode
               mov     edx, offset szBuff
              Call     BuildEM

            INVOKE     SendMessage, hREdit, WM_SETTEXT, 0, pMem
            INVOKE     SendMessage, hREdit, EM_GETLINECOUNT, 0, 0
               mov     Line, eax

               mov     edx, offset szCRLF
              Call     BuildEM

               mov     edx, offset szResults
              Call     BuildEM

            .if Step < 4 || Step == 5 || Step == 7 || Step == 11 || Step == 12 || Step > 13
                  mov     edx, offset szSuccess
                 Call     BuildEM
            .endif

            INVOKE     SendMessage, hREdit, WM_SETTEXT, 0, pMem

            INVOKE     SendMessage, hREdit, EM_HIDESELECTION, 1, 0
            INVOKE     SendMessage, hREdit, EM_LINEINDEX, 2, 0
               dec     eax
            INVOKE     SendMessage, hREdit, EM_SETSEL, 0, eax
               mov     charF.crTextColor, 000000ffh
            INVOKE     SendMessage,  hREdit, EM_SETCHARFORMAT, SCF_SELECTION, addr charF
            INVOKE     SendMessage, hREdit, EM_LINEINDEX, Line, 0
               dec     eax
            INVOKE     SendMessage, hREdit, EM_SETSEL, eax, -1
               mov     charF.crTextColor, 0000ff00h
            INVOKE     SendMessage,  hREdit, EM_SETCHARFORMAT, SCF_SELECTION, addr charF
            INVOKE     SendMessage, hREdit, EM_SETSEL, 0, 0
            INVOKE     SendMessage, hREdit, EM_HIDESELECTION, 0, 0

            .if Step == 1
                  jmp     CreateKey
            .elseif Step == 2
                  jmp     OpenKey
            .elseif Step == 3
                  jmp     SetDword
            .elseif Step == 4
                  jmp     GetDword
            .elseif Step == 5
                  jmp     SetString
            .elseif Step == 6
                  jmp     GetString
            .elseif Step == 7
                  jmp     SetBinary
            .elseif Step == 8
                  jmp     GetBinary
            .elseif Step == 9
                  jmp     GetNumber
            .elseif Step == 10
                  jmp     GetLength
            .elseif Step == 11
                  jmp     CreateSubKey
            .elseif Step == 12
                  jmp     SetStrings
            .elseif Step == 13
                  jmp     Enumerate
            .elseif Step == 14
                  jmp     DeleteSubkey
            .elseif Step == 15
                  jmp     CloseSubkey
            .elseif Step == 16
                  jmp     Deletekey
            .elseif Step == 17
                  jmp     Closekey
            .elseif Step == 18
               INVOKE     SendMessage, hButt1, WM_SETTEXT, 0, addr szButt1
               INVOKE     ShowWindow, hButt2, SW_HIDE
               INVOKE     GetPrivateProfileString, addr szInfo, addr szInfoT, addr szNULL, addr szBuff, 255, addr CurDir
               INVOKE     SendMessage, hREdit, WM_SETTEXT, 0, addr szBuff
               INVOKE     MessageBox, NULL, addr szAgain, addr AppName, MB_YESNO
               .if eax == IDNO
                  INVOKE     SendMessage, hWnd, WM_COMMAND, IDM_EXIT, 0
               .endif
                  and     Step, 0
                  jmp     Ret0
            .endif
         .elseif eax == IDM_EXIT
            INVOKE     DestroyWindow, hwnd
         .endif

      .else

DefWin:
         INVOKE     DefWindowProc, hwnd, wMsg, wParam, lParam
            ret
      .endif
         jmp     Ret0

CreateKey:
;---------- [Open or create a registry key] ---------- 
      INVOKE     RegCreateKeyEx, HKEY_CURRENT_USER, addr szTestKey, 0, addr szREGSZ, 0,\
                 KEY_WRITE or KEY_READ, 0, addr hKey, addr lpdwDisp
      .if eax == ERROR_SUCCESS
            jmp     Closekey
      .else
      .endif
         jmp     Ret0

OpenKey:
;---------- [Open an existing registry key] ---------- 
      INVOKE     RegOpenKeyEx, HKEY_CURRENT_USER, addr szTestKey, 0,\
                 KEY_WRITE or KEY_READ, addr hKey
      .if eax == ERROR_SUCCESS
      .else
      .endif
         jmp     Ret0

SetDword:
;---------- [Set a dword value to the registry key] ---------- 
         mov     lpcbData, 4
      INVOKE     RegSetValueEx, hKey, addr szHandle, 0, REG_DWORD, addr hwnd, lpcbData
      .if eax == ERROR_SUCCESS
      .else
      .endif
         jmp     Ret0

GetDword:
;---------- [Get a dword value from the registry key] ---------- 
         mov     lpcbData, 4
      INVOKE     RegQueryValueEx, hKey, addr szHandle, 0, addr lpType, addr DecVal, addr lpcbData
      .if eax == ERROR_SUCCESS
         INVOKE     wsprintf, addr szBuff1, addr fmat2, DecVal
         INVOKE     SendMessage, hREdit, EM_GETLINECOUNT, 0, 0
            mov     Line, eax
         INVOKE     SendMessage, hREdit, EM_LINEINDEX, Line, 0
            dec     eax
         INVOKE     SendMessage, hREdit, EM_SETSEL, eax, -1
         INVOKE     SendMessage, hREdit, EM_REPLACESEL, FALSE, addr szBuff1
      .else
      .endif
         jmp     Ret0

SetString:
;---------- [Set a string value to the registry key] ---------- 
      INVOKE     lstrlen, addr szDay
         mov     lpcbData, eax
      INVOKE     RegSetValueEx, hKey, addr szDayName, 0, REG_SZ, addr szDay, lpcbData
      .if eax == ERROR_SUCCESS
      .else
      .endif
         jmp     Ret0

GetString:
;---------- [Get a string value from the registry key] ---------- 
         mov     lpcbData, 250
      INVOKE     RegQueryValueEx, hKey, addr szDayName, 0, addr szREGSZ, addr szBuff, addr lpcbData
      .if eax == ERROR_SUCCESS
         INVOKE     SendMessage, hREdit, EM_GETLINECOUNT, 0, 0
            mov     Line, eax
         INVOKE     SendMessage, hREdit, EM_LINEINDEX, Line, 0
            dec     eax
         INVOKE     SendMessage, hREdit, EM_SETSEL, eax, -1
         INVOKE     SendMessage, hREdit, EM_REPLACESEL, FALSE, addr szBuff
      .else
      .endif
         jmp     Ret0

SetBinary:
;---------- [Set a binary value to the registry key] ----------
         mov     eax, hwnd
         mov     dword ptr BinVal, eax
         add     eax, 44
         mov     dword ptr BinVal+3, eax
         add     eax, 999
         mov     word ptr BinVal+7, ax

         mov     lpcbData, 10
      INVOKE     RegSetValueEx, hKey, addr szBinary, 0, REG_BINARY, addr BinVal, lpcbData  ;hwnd
      .if eax == ERROR_SUCCESS

      .else
      .endif
         jmp     Ret0

GetBinary:
;---------- [Get a binary value from the registry key] ---------- 
         mov     lpcbData, 10
      INVOKE     RegQueryValueEx, hKey, addr szBinary, 0, addr lpType, addr szBuff, addr lpcbData
      .if eax == ERROR_SUCCESS
            mov     byte ptr szBuff2, 0
            and     Cnt, 0
         .while (Cnt < 10)
               xor     edx, edx
               mov     eax, Cnt
               mov     dl, byte ptr szBuff[eax]
            INVOKE     wsprintf, addr szBuff1, addr fmatH2, edx
            INVOKE     lstrcat, addr szBuff2, addr szBuff1
            .if Cnt < 9
               INVOKE     lstrcat, addr szBuff2, addr szSpace
            .endif
               inc     Cnt
         .endw
         INVOKE     SendMessage, hREdit, EM_GETLINECOUNT, 0, 0
            mov     Line, eax
         INVOKE     SendMessage, hREdit, EM_LINEINDEX, Line, 0
            dec     eax
         INVOKE     SendMessage, hREdit, EM_SETSEL, eax, -1
         INVOKE     SendMessage, hREdit, EM_REPLACESEL, FALSE, addr szBuff2

      .else
      .endif
         jmp     Ret0

GetNumber:
;---------- [Get the number of value entries in the registry key] ---------- 
      INVOKE     RegQueryInfoKey, hKey, 0, 0, 0, 0, 0, 0, addr lpcValues, 0, 0, 0, 0
      .if eax == ERROR_SUCCESS
         INVOKE     wsprintf, addr szBuff1, addr fmat2, lpcValues
         INVOKE     SendMessage, hREdit, EM_GETLINECOUNT, 0, 0
            mov     Line, eax
         INVOKE     SendMessage, hREdit, EM_LINEINDEX, Line, 0
            dec     eax
         INVOKE     SendMessage, hREdit, EM_SETSEL, eax, -1
         INVOKE     SendMessage, hREdit, EM_REPLACESEL, FALSE, addr szBuff1
      .else
      .endif
         jmp     Ret0

GetLength:
;---------- [Get  the longest value data length in the registry key] ---------- 
      INVOKE     RegQueryInfoKey, hKey, 0, 0, 0, 0, 0, 0, 0, 0, addr lpcbMaxValueLen, 0,0
      .if eax == ERROR_SUCCESS
         INVOKE     wsprintf, addr szBuff1, addr fmat2, lpcbMaxValueLen
         INVOKE     SendMessage, hREdit, EM_GETLINECOUNT, 0, 0
            mov     Line, eax
         INVOKE     SendMessage, hREdit, EM_LINEINDEX, Line, 0
            dec     eax
         INVOKE     SendMessage, hREdit, EM_SETSEL, eax, -1
         INVOKE     SendMessage, hREdit, EM_REPLACESEL, FALSE, addr szBuff1
      .else
      .endif
         jmp     Ret0

CreateSubKey:
;---------- [Open or create a registry Subkey] ---------- 
      INVOKE     RegCreateKeyEx, HKEY_CURRENT_USER, addr szSubKey, 0, addr szREGSZ, 0,\
                 KEY_WRITE or KEY_READ, 0, addr hKeyS, addr lpdwDisp
      .if eax == ERROR_SUCCESS
      .else
      .endif
         jmp     Ret0

SetStrings:
;---------- [Set four string values to the registry Subkey] ----------
         mov     Cnt, 0
      .while (Cnt < 4)
            inc     Cnt
         INVOKE     wsprintf, addr szBuff1, addr fmat2, Cnt
            mov     ax, word ptr szBuff1
            mov     word ptr szItem+6, ax
            mov     word ptr szItemT+5, ax
         INVOKE     lstrlen, addr szItemT
            mov     lpcbData, eax
         INVOKE     RegSetValueEx, hKeyS, addr szItem, 0, REG_SZ, addr szItemT, lpcbData
         .if eax == ERROR_SUCCESS
         .else
         .endif
      .endw
         jmp     Ret0

Enumerate:
;---------- [Enumerate the registry Subkey] ----------
         mov     byte ptr szBuff, 0
         mov     lpcValues, 4
         mov     Cnt, 0
      .while lpcValues   
            dec     lpcValues
            mov     lpcbValueName, 8
            mov     lpcbData, 25
         INVOKE     RegEnumValue, hKeyS, Cnt, addr szBuff1, addr lpcbValueName, 0, addr szREGSZ, addr szBuff2, addr lpcbData
         .if eax == ERROR_NO_MORE_ITEMS
               jmp     NoMore
         .endif
            inc     Cnt
         INVOKE     lstrcat, addr szBuff, addr szBuff2
         INVOKE     lstrcat, addr szBuff, addr szCRLF+2
      .endw

NoMore:
         INVOKE     SendMessage, hREdit, EM_GETLINECOUNT, 0, 0
            mov     Line, eax
         INVOKE     SendMessage, hREdit, EM_LINEINDEX, Line, 0
            dec     eax
         INVOKE     SendMessage, hREdit, EM_SETSEL, eax, -1
         INVOKE     SendMessage, hREdit, EM_REPLACESEL, FALSE, addr szBuff
         jmp     Ret0

DeleteSubkey:
;---------- [Delete the registry Subkey] ---------- 
      INVOKE     RegDeleteKey, HKEY_CURRENT_USER, addr szSubKey
      .if eax == ERROR_SUCCESS
      .else
      .endif

CloseSubkey:
;---------- [Close the registry Subkey] ----------
      INVOKE     RegCloseKey, hKeyS
      .if eax == ERROR_SUCCESS
      .else
      .endif
         jmp     Ret0

Deletekey:
;---------- [Delete the registry key] ---------- 
      INVOKE     RegDeleteKey, HKEY_CURRENT_USER, addr szTestKey
         jmp     Ret0

Closekey:
;---------- [Close the registry key] ---------- 
      INVOKE     RegCloseKey, hKey
         jmp     Ret0

Ret0:
         xor    eax, eax
         ret
WndProc ENDP

;________________________________________________________________________________
GetCode PROC

         INVOKE     GetPrivateProfileString, addr szBuff1, addr szBuff2, addr szNULL, addr szBuff, 255, addr CurDir
         INVOKE     lstrlen, addr szBuff
         .while (eax)
            .if byte ptr szBuff[eax] == '>'
                  mov     byte ptr szBuff[eax], 0ah
            .elseif byte ptr szBuff[eax] == '<'
                  mov     byte ptr szBuff[eax], 0dh
            .endif
               dec     eax
         .endw

Ret0:
         xor    eax, eax
         ret
GetCode ENDP

;________________________________________________________________________________
BuildEM PROC
      INVOKE     lstrcat, pMem, edx
         ret
BuildEM ENDP

end start
;INVOKE     MessageBox, NULL, addr szBuff, addr AppName, MB_OK
