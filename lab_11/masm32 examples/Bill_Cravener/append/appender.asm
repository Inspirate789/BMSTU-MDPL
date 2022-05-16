; ####################################################
;       William F. Cravener 5/12/2003
; ####################################################

        .486
        .model flat, stdcall
        option casemap:none   ; case sensitive

; ####################################################

        include \masm32\include\windows.inc
        include \masm32\include\user32.inc
        include \masm32\include\kernel32.inc
        include \masm32\include\advapi32.inc ; needed for Registry functions
 
        includelib \masm32\lib\user32.lib
        includelib \masm32\lib\kernel32.lib
        includelib \masm32\lib\advapi32.lib  ; needed for Registry functions

; ####################################################

        ID_EDIT1 equ 101
        ID_EDIT2 equ 102

        ID_BUTTON1 equ 201
        ID_BUTTON2 equ 202
        ID_BUTTON3 equ 203

        MAXLENGTH equ 256

; #######################################################

        MenuOptionMaker PROTO :DWORD,:DWORD,:DWORD,:DWORD

; #######################################################

    .data

        hInstance dd ?

        RegKeyHandle dd 0
        KeyStringLngth dd 0

        dBuffer db MAXLENGTH dup (0)

        ZeroKeyString db 0

        Success db "Success!",0
        Appending db "New menu option created.",0
        Removing db "New menu option removed.",0

        RegKeyFolder1 db "Folder\shell\NewMenuOption",0
        RegKeyFolder2 db "Folder\shell\NewMenuOption\command",0

        dialogname db "APPENDER",0

; #########################################################################

    .code

start:
      invoke GetModuleHandle, 0
      mov hInstance,eax

      ; -------------------------------------------
      ; Call the dialog box stored in resource file
      ; -------------------------------------------
      invoke DialogBoxParam,hInstance,ADDR dialogname,0,ADDR MenuOptionMaker,0
      invoke ExitProcess,eax

; #########################################################################

MenuOptionMaker proc hWin:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD


        .if uMsg == WM_INITDIALOG

                    ;-----------------------------------------------------
                    ; First we see if we already created a new menu option
                    ; If so we will retrieve the menu name and place it in
                    ; our first edit box.
                    ;-----------------------------------------------------
                    invoke RegOpenKeyEx,HKEY_CLASSES_ROOT,ADDR RegKeyFolder1,
                                        0,KEY_QUERY_VALUE,ADDR RegKeyHandle
                    .if eax == ERROR_SUCCESS

                        mov KeyStringLngth,MAXLENGTH
                        invoke RegQueryValueEx,RegKeyHandle,0,0,0,ADDR dBuffer,ADDR KeyStringLngth

                        invoke RegCloseKey,RegKeyHandle

                        invoke GetDlgItem,hWin,ID_EDIT1
                        invoke SetWindowText,eax,ADDR dBuffer

                    .endif

                    ;-------------------------------------------------
                    ; Next we retrieve the command string and place it
                    ; in our second edit box
                    ;-------------------------------------------------
                    invoke RegOpenKeyEx,HKEY_CLASSES_ROOT,ADDR RegKeyFolder2,
                                        0,KEY_QUERY_VALUE,ADDR RegKeyHandle
                    .if eax == ERROR_SUCCESS

                        mov KeyStringLngth,MAXLENGTH
                        invoke RegQueryValueEx,RegKeyHandle,0,0,0,ADDR dBuffer,ADDR KeyStringLngth
   
                        invoke RegCloseKey,RegKeyHandle

                        invoke GetDlgItem,hWin,ID_EDIT2
                        invoke SetWindowText,eax,ADDR dBuffer

                    .endif

              
        .elseif uMsg == WM_COMMAND
                        mov eax,wParam

                        .if eax == ID_BUTTON1

                            ;-----------------------------------------------------
                            ; Create our new subkey and write our menu name to it
                            ;-----------------------------------------------------
                            invoke GetDlgItem,hWin,ID_EDIT1
                            invoke GetWindowText,eax,ADDR dBuffer,MAXLENGTH

                            invoke RegCreateKeyEx,HKEY_CLASSES_ROOT,ADDR RegKeyFolder1,
                                                  0,ADDR ZeroKeyString,REG_OPTION_NON_VOLATILE,
                                                  KEY_SET_VALUE,0,ADDR RegKeyHandle,0

                            invoke RegSetValue,RegKeyHandle,0,REG_SZ,ADDR dBuffer,sizeof dBuffer

                            invoke RegCloseKey,RegKeyHandle

                            ;---------------------------------------------------------
                            ; Create our new subkey and write our command string to it
                            ;---------------------------------------------------------
                            invoke GetDlgItem,hWin,ID_EDIT2
                            invoke GetWindowText,eax,ADDR dBuffer,MAXLENGTH

                            invoke RegCreateKeyEx,HKEY_CLASSES_ROOT,ADDR RegKeyFolder2,
                                                  0,ADDR ZeroKeyString,REG_OPTION_NON_VOLATILE,
                                                  KEY_SET_VALUE,0,ADDR RegKeyHandle,0

                            invoke RegSetValue,RegKeyHandle,0,REG_SZ,ADDR dBuffer,sizeof dBuffer

                            .if eax == ERROR_SUCCESS
                                invoke MessageBox,hWin,ADDR Appending,ADDR Success,MB_OK
                            .endif 
                                    
                            invoke RegCloseKey,RegKeyHandle
                    

                    .elseif eax == ID_BUTTON2

                            ;----------------------------------------
                            ; Remove the menu name and command string
                            ;----------------------------------------
                            invoke RegOpenKeyEx,HKEY_CLASSES_ROOT,ADDR RegKeyFolder2,
                                                0,KEY_ALL_ACCESS,ADDR RegKeyHandle
                            .if eax == ERROR_SUCCESS

                                invoke RegDeleteKey,HKEY_CLASSES_ROOT,ADDR RegKeyFolder2

                                invoke RegDeleteKey,HKEY_CLASSES_ROOT,ADDR RegKeyFolder1

                                .if eax == ERROR_SUCCESS
                                    invoke MessageBox,hWin,ADDR Removing,ADDR Success,MB_OK
                                .endif 

                                invoke RegCloseKey,RegKeyHandle

                                ;--------------------
                                ; Clear the edit boxs
                                ;--------------------
                                mov dBuffer,0

                                invoke GetDlgItem,hWin,ID_EDIT1
                                invoke SetWindowText,eax,ADDR dBuffer

                                invoke GetDlgItem,hWin,ID_EDIT2
                                invoke SetWindowText,eax,ADDR dBuffer

                          .endif


                  .elseif eax == ID_BUTTON3

                          invoke SendMessage,hWin,WM_CLOSE,0,0

                  .endif


        .elseif uMsg == WM_CLOSE

                        invoke EndDialog,hWin,0

        .endif

    
        xor eax,eax 
        ret

MenuOptionMaker endp

; ########################################################################

end start
