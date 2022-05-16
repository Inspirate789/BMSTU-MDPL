; ##########################################################################
;
;  This macro calls a DLL that displays the corresponding error string for
;  the return value of GetLastError(). This MACRO file and the DLL called
;  DBERROR.DLL must be placed in the SAME directory as the file and the
;  line,
;
;  include errormac.asm
;
;  must be included at the beginning of the file after the system includes
;  & libraries.
;
;  Usage : ShowLastError
;
;  It is to be used directly after the function that produces the error.
;
; ##########################################################################

ShowLastError MACRO

    LOCAL lbl
    LOCAL LibName
    LOCAL ProcName

    pushad

    invoke GetLastError

    jmp lbl
      LibName       db "dberror.dll",0
      ProcName      db "ShowLastError",0
    lbl:

    push eax
    invoke LoadLibrary,ADDR LibName
    invoke GetProcAddress,eax,ADDR ProcName
    call eax

    popad

ENDM

; ##########################################################################
