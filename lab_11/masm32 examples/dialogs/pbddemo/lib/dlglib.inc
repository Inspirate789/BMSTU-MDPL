; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

;         prototypes for dialogs contained in the DLGLIB library

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    GetTextInput PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
    AboutBox     PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
    GetFile      PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
    LoadList     PROTO :DWORD,:DWORD
    IPtoString   PROTO :DWORD,:DWORD
    GetIP        PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD

  ; --------------------
  ; IP control messages
  ; --------------------
    IPM_CLEARADDRESS  equ WM_USER + 100
    IPM_SETADDRESS    equ WM_USER + 101
    IPM_GETADDRESS    equ WM_USER + 102
    IPM_SETRANGE      equ WM_USER + 103
    IPM_SETFOCUS      equ WM_USER + 104
    IPM_ISBLANK       equ WM_USER + 105
