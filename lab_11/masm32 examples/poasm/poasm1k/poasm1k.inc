; #########################################################################

;     include files
;     ~~~~~~~~~~~~~
      include \masm32\include\windows.inc

externdef _imp__BeginPaint@8:PTR pr2
BeginPaint equ <_imp__BeginPaint@8>

externdef _imp__DispatchMessageA@4:PTR pr1
DispatchMessage equ <_imp__DispatchMessageA@4>

externdef _imp__DrawTextA@20:PTR pr5
DrawText equ <_imp__DrawTextA@20>

externdef _imp__EndPaint@8:PTR pr2
EndPaint equ <_imp__EndPaint@8>

externdef _imp__GetClientRect@8:PTR pr2
GetClientRect equ <_imp__GetClientRect@8>

externdef _imp__GetMessageA@16:PTR pr4
GetMessage equ <_imp__GetMessageA@16>

externdef _imp__DefWindowProcA@16:PTR pr4
DefWindowProc equ <_imp__DefWindowProcA@16>

externdef _imp__MessageBoxA@16:PTR pr4
MessageBox equ <_imp__MessageBoxA@16>

externdef _imp__PostQuitMessage@4:PTR pr1
PostQuitMessage equ <_imp__PostQuitMessage@4>

externdef _imp__RegisterClassExA@4:PTR pr1
RegisterClassEx equ <_imp__RegisterClassExA@4>

externdef _imp__ShowWindow@8:PTR pr2
ShowWindow equ <_imp__ShowWindow@8>

externdef _imp__UpdateWindow@4:PTR pr1
UpdateWindow equ <_imp__UpdateWindow@4>

externdef _imp__LoadCursorA@8:PTR pr2
LoadCursor equ <_imp__LoadCursorA@8>

externdef _imp__LoadIconA@8:PTR pr2
LoadIcon equ <_imp__LoadIconA@8>

externdef _imp__CreateWindowExA@48:PTR pr12
CreateWindowEx equ <_imp__CreateWindowExA@48>

externdef _imp__ExitProcess@4:PTR pr1
ExitProcess equ <_imp__ExitProcess@4>

externdef _imp__SetBkMode@8:PTR pr2
SetBkMode equ <_imp__SetBkMode@8>

externdef _imp__TranslateMessage@4:PTR pr1
TranslateMessage equ <_imp__TranslateMessage@4>

;     libraries
;     ~~~~~~~~~
      includelib \masm32\lib\user32.lib
      includelib \masm32\lib\kernel32.lib
      includelib \masm32\lib\gdi32.lib

; #########################################################################

        ;=================
        ; Local prototypes
        ;=================
        WinMain          PROTO :DWORD,:DWORD,:DWORD,:DWORD
        WndProc          PROTO :DWORD,:DWORD,:DWORD,:DWORD
        Main             PROTO