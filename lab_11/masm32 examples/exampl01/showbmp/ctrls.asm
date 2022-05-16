; ########################################################################

    PushButton  PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
    StaticImage PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
    StaticIcon  PROTO :DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD

    .data
      btnClass  db "BUTTON",0
      statClass db "STATIC",0

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

StaticImage proc lpText:DWORD,hParent:DWORD,
                 a:DWORD,b:DWORD,wd:DWORD,ht:DWORD,ID:DWORD

; invoke StaticImage,NULL,hWnd,20,20,100,25,500

    invoke CreateWindowEx,WS_EX_STATICEDGE,
            ADDR statClass,lpText,
            WS_CHILD or WS_VISIBLE or SS_BITMAP,
            a,b,wd,ht,hParent,ID,
            hInstance,NULL

    ret

StaticImage endp

; ########################################################################

StaticIcon proc lpText:DWORD,hParent:DWORD,
                 a:DWORD,b:DWORD,wd:DWORD,ht:DWORD,ID:DWORD

; invoke StaticIcon,NULL,hWnd,20,20,100,25,500

    invoke CreateWindowEx,WS_EX_LEFT,
            ADDR statClass,lpText,
            WS_CHILD or WS_VISIBLE or SS_ICON,
            a,b,wd,ht,hParent,ID,
            hInstance,NULL

    ; 

    ret

StaticIcon endp

; ########################################################################

