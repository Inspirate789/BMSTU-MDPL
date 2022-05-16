; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
    include \masm32\include\masm32rt.inc
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

;   ---------------------------------------------------
;   Demonstrates how to use the "LastError$" macro that
;   displays the system defined error string associated
;   with the GetLastError() API function.
;   ---------------------------------------------------

    .code

start:
   
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    call main
    exit

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

main proc

    LOCAL wc    :WNDCLASSEX

    fclose NULL                         ; close an invalid empty file handle

    fn MessageBox,0,LastError$(), \
                 "System Error String", \
                 MB_OK

    invoke SendMessage,0,0,0,0          ; invalid window handle

    fn MessageBox,0,LastError$(), \
                 "System Error String", \
                 MB_OK

    invoke RegisterClassEx,ADDR wc      ; empty WNDCLASSEX structure

    fn MessageBox,0,LastError$(), \
                 "System Error String", \
                 MB_OK
    ret

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start