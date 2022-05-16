    Do_Model MACRO psize
      psize
      .model flat, stdcall  ; 32 bit memory model
      option casemap :none  ; case sensitive
    ENDM

    Do_Init MACRO
    .code
    start:
      invoke GetModuleHandle, NULL
      mov hInstance, eax

      invoke GetCommandLine
      mov CommandLine, eax

      invoke InitCommonControls

      invoke WinMain,hInstance,NULL,CommandLine,SW_SHOWDEFAULT
      invoke ExitProcess,eax
    ENDM

    Do_WinMain MACRO
      WinMain proc hInst     :DWORD,
                   hPrevInst :DWORD,
                   CmdLine   :DWORD,
                   CmdShow   :DWORD
      LOCAL wc   :WNDCLASSEX
      LOCAL msg  :MSG
      LOCAL Wwd  :DWORD
      LOCAL Wht  :DWORD
      LOCAL Wtx  :DWORD
      LOCAL Wty  :DWORD
    ENDM

    Do_EndWinMain MACRO
      mov eax, msg.wParam
      ret
      WinMain endp
    ENDM

    Do_RetVal MACRO var
      mov var,eax
    ENDM

    Do_WindowDisplay MACRO whandle
      invoke ShowWindow,whandle,SW_SHOWNORMAL
      invoke UpdateWindow,whandle
    ENDM

    Do_MenuLoad MACRO instance,handle,IDnum
      invoke LoadMenu,instance,IDnum
      invoke SetMenu,handle,eax
    ENDM

    Do_mlStart MACRO msgSt
      mLoopStart:
      invoke GetMessage,ADDR msgSt,NULL,0,0
      cmp eax, 0
      je mLoopEnd
    ENDM

    Do_mlEnd MACRO msgSt
      invoke TranslateMessage, ADDR msgSt
      invoke DispatchMessage,  ADDR msgSt
      jmp mLoopStart
      mLoopEnd:
    ENDM

    Do_CentreWindow MACRO wWidth,wHeight
      mov Wwd, wWidth
      mov Wht, wHeight

      invoke GetSystemMetrics,SM_CXSCREEN
      invoke TopXY,Wwd,eax
      mov Wtx, eax

      invoke GetSystemMetrics,SM_CYSCREEN
      invoke TopXY,Wht,eax
      mov Wty, eax
    ENDM
