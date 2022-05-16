; #########################################################################

    .486                      ; create 32 bit code
    .model flat, stdcall      ; 32 bit memory model
    option casemap :none      ; case sensitive

    include \masm32\include\windows.inc
    include \masm32\include\gdi32.inc

    .code

; ########################################################################

MakeFont proc hgt:DWORD,wid:DWORD,weight:DWORD,italic:DWORD,lpFontName:DWORD

    invoke CreateFont,hgt,wid,NULL,NULL,weight,italic,NULL,NULL,
                      DEFAULT_CHARSET,OUT_TT_PRECIS,CLIP_DEFAULT_PRECIS,
                      PROOF_QUALITY,DEFAULT_PITCH or FF_DONTCARE,
                      lpFontName
    ret

MakeFont endp

; ########################################################################

   end