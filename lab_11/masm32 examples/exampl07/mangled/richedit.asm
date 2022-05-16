; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

        RichEdit2        PROTO :DWORD,:DWORD,:DWORD,:DWORD

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい

RichEdit2 proc iinstance:DWORD,hParent:DWORD,ID:DWORD,WRAP:DWORD

    LOCAL wStyle :DWORD

    mov wStyle, WS_VISIBLE or WS_CHILDWINDOW or WS_CLIPSIBLINGS or ES_MULTILINE or \
                WS_VSCROLL or ES_AUTOVSCROLL or ES_NOHIDESEL or ES_DISABLENOSCROLL

    .if WRAP == 0
      or wStyle, WS_HSCROLL or ES_AUTOHSCROLL
    .endif

    fn CreateWindowEx,WS_EX_STATICEDGE,"RichEdit20a",0,wStyle, \
                      0,0,100,100,hParent,ID,iinstance,NULL

    ret

RichEdit2 endp

; いいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい
