; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

      .486                      ; create 32 bit code
      .model flat, stdcall      ; 32 bit memory model
      option casemap :none      ; case sensitive

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

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

      DialogProc    PROTO :DWORD,:DWORD,:DWORD,:DWORD
      About         PROTO :DWORD,:DWORD
      AboutProc     PROTO :DWORD,:DWORD,:DWORD,:DWORD
      GetImage      PROTO :DWORD,:DWORD

    .data?
        hWnd      dd ?
        hInstance dd ?
        path      dd ?

    .code

start:

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

      mov path, pth$()
      mov hInstance, FUNC(GetModuleHandle,NULL)
      call main
      invoke ExitProcess,eax

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

main proc

    Dialog "Get PE Image", \                ; caption
           "MS Sans Serif",8, \             ; font,pointsize
            WS_OVERLAPPED or \              ; styles for
            WS_SYSMENU or DS_CENTER, \      ; dialog window
            3, \                            ; number of controls
            50,50,200,120, \                ; x y co-ordinates
            1024                            ; memory buffer size

    DlgButton "Get PE File",WS_TABSTOP,135,10,50,13,IDOK
    DlgButton "Close",WS_TABSTOP,135,25,50,13,IDCANCEL
    DlgStatic "Open PE exe file and save raw memory image to disk", \
              0,15,60,170,25,1000

    CallModalDialog hInstance,0,DialogProc,NULL

    ret

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

DialogProc proc hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

    LOCAL hDC   :DWORD
    LOCAL patn  :DWORD
    LOCAL fname :DWORD
    LOCAL ps    :PAINTSTRUCT
    LOCAL rct   :RECT

    .if uMsg == WM_INITDIALOG
      invoke SendMessage,hWin,WM_SETICON,1,
                         FUNC(LoadIcon,NULL,IDI_ASTERISK)
      m2m hWnd, hWin    ; hWnd is GLOBAL in scope

      mov eax, 1
      ret

    .elseif uMsg == WM_PAINT
      invoke BeginPaint,hWin,ADDR ps
      mov hDC, eax
      invoke GetClientRect,hWin,ADDR rct

      invoke DrawEdge,hDC,ADDR rct,EDGE_ETCHED,BF_RECT
      invoke EndPaint,hWin,ADDR ps

    .elseif uMsg == WM_COMMAND
      .if wParam == IDOK
        mov patn, chr$("EXE Files",0,"*.exe",0,0)
        mov fname, OpenFileDlg(hWin,hInstance,"Get EXE file",patn)
        cmp BYTE PTR [eax], 0
        jne @F
        xor eax, eax
        ret
      @@:
        invoke GetImage,fname,400000h
      .elseif wParam == IDCANCEL
        jmp quit_dialog
      .endif

    .elseif uMsg == WM_CLOSE
      quit_dialog:
      invoke EndDialog,hWin,0

    .endif

    xor eax, eax
    ret

DialogProc endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

GetImage proc lpfname:DWORD, startaddress:DWORD

    LOCAL hFile     :DWORD
    LOCAL fl        :DWORD
    LOCAL bRead     :DWORD
    LOCAL hMem      :DWORD
    LOCAL hProc     :DWORD
    LOCAL bSize     :DWORD
    LOCAL bWritten  :DWORD
    LOCAL str1      :DWORD
    LOCAL patn      :DWORD
    LOCAL fname     :DWORD

    LOCAL pri       :PROCESS_INFORMATION
    LOCAL sui       :STARTUPINFO

    LOCAL buffer[260]:BYTE

  ; ------------------------------
  ; create a handle for file read
  ; ------------------------------
    mov hFile, FUNC(CreateFile,lpfname,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,NULL,NULL)

    cmp hFile, INVALID_HANDLE_VALUE
    jne @F
    fn MessageBox,hWnd,"Access denied","Cannot read file",MB_OK
    ret
  @@:

    mov fl, FUNC(GetFileSize,hFile,NULL)            ; get the file length
    lea eax, [eax+eax*4]                            ; multiply length by 5
    mov bSize, eax
    mov hMem, alloc(eax)                            ; allocate a buffer of that size

  ; ------------------------------------------
  ; fill memory buffer with "xxxx" characters
  ; ------------------------------------------
    push edi
    mov eax, "xxxx"
    mov edi, hMem
    mov ecx, bSize
    shr ecx, 2
    rep stosd
    pop edi

    invoke ReadFile,hFile,hMem,fl,ADDR bRead,NULL   ; read file into buffer
    invoke CloseHandle,hFile                        ; close the handle

  ; --------------------------------------------
  ; scan the first 1024 bytes for a PE signature
  ; --------------------------------------------
    invoke BinSearch,0,hMem,1024,SADD("PE",0,0),4
    cmp eax, -1
    jne @F
    fn MessageBox,hWnd,"Selected file is not a PE file", \
                       "Incorrect EXE file type",MB_OK
    jmp cleanup
  @@:

  ; -----------------------------------------------------------------
  ; specify the ShowWindow() attribute for the process being created
  ; -----------------------------------------------------------------
    mov sui.dwFlags, STARTF_USESHOWWINDOW
    mov sui.wShowWindow, SW_SHOWNOACTIVATE

    invoke CreateProcess,lpfname,NULL,NULL,NULL,FALSE,
                         DETACHED_PROCESS,NULL,NULL,ADDR sui,ADDR pri

    mov hProc, FUNC(OpenProcess,PROCESS_VM_READ,TRUE,pri.dwProcessId)
    invoke ReadProcessMemory,hProc,startaddress,hMem,bSize,ADDR bRead

  ; ---------------------------
  ; find the end of the buffer
  ; ---------------------------
    mov bWritten, FUNC(BinSearch,0,hMem,bSize,chr$("xxxxxxxxxxxx"),12)

    invoke SetCurrentDirectory,path
    invoke SetForegroundWindow,hWnd ; bring this app back to the top

    mov patn, chr$("All Files",0,"*.*",0,0)
    mov fname, SaveFileDlg(hWnd,hInstance,"Save PE Image As ..",patn)
    cmp BYTE PTR [eax], 0
    jne @F
    jmp cleanup
  @@:
  ; ----------------------------------------------------------
  ; write the image to a disk file at the loaded image length
  ; ----------------------------------------------------------
    cmp OutputFile(fname,hMem,bWritten), 0
    jne @F
    jmp cleanup
  @@:

    mov str1, ptr$(buffer)
    mov str1, cat$(str1,"PE Image length is ",ustr$(bWritten)," bytes")
    fn MessageBox,hWnd,str1,"File written to file",MB_OK

  cleanup:
    invoke CloseHandle,hProc
    free hMem

    ret

GetImage endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start
