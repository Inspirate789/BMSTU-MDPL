; #########################################################################

CallSearchDlg proc

    invoke DialogBoxParam,hInstance,300,hWnd,ADDR SearchProc,0

    ret

CallSearchDlg endp

; #########################################################################
