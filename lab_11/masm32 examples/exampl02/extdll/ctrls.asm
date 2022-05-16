; ########################################################################

    PushButton PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD

    .data
      btnClass  db "BUTTON",0

    .code

; ########################################################################

PushButton proc lpText:DWORD,hParent:DWORD,
                a:DWORD,b:DWORD,wd:DWORD,ht:DWORD,ID:DWORD

; invoke PushButton,ADDR szText,hWnd,20,20,100,25,500

    invoke CreateWindowEx,0,
            ADDR btnClass,lpText,
            WS_CHILD or WS_VISIBLE,
            a,b,wd,ht,hParent,ID,
            hInstance,NULL

    ret

PushButton endp

; #########################################################################
