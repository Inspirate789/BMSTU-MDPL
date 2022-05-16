; #########################################################################

hEditProc proc hCtl   :DWORD,
               uMsg   :DWORD,
               wParam :DWORD,
               lParam :DWORD

    LOCAL Pt    :POINT
    LOCAL hSM   :DWORD

    .if uMsg == WM_KEYUP
      ; --------------------------
      ; process the F1 to F3 keys
      ; --------------------------
        .if wParam == VK_F1
          ; -------------------------
          ; impliment help code here
          ; -------------------------
        .elseif wParam == VK_F2
            invoke CallSearchDlg
            return 0
        .elseif wParam == VK_F3
            invoke TextFind,ADDR SearchText, TextLen
        .endif

    .elseif uMsg == WM_RBUTTONDOWN
        invoke GetCursorPos,ADDR Pt
        invoke GetSubMenu,hMnu,menu_popup
        mov hSM, eax
        invoke TrackPopupMenu,hSM,TPM_LEFTALIGN or TPM_LEFTBUTTON,
                              Pt.x,Pt.y,0, hWnd,NULL

    .endif

    invoke CallWindowProc,lpfnhEditProc,hCtl,uMsg,wParam,lParam

    ret

hEditProc endp

; #########################################################################
