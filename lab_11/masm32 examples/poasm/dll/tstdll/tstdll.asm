; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

      .model flat, stdcall  ; 32 bit memory model
      option casemap :none  ; case sensitive
      option cstrings:on    ; enable C string escapes
 
    ; *************
    ; include files
    ; *************
      include \masm32\include\windows.inc
      include \masm32\include\masm32.inc
      include \masm32\include\gdi32.inc
      include \masm32\include\user32.inc
      include \masm32\include\kernel32.inc
      include \masm32\include\Comctl32.inc
      include \masm32\include\comdlg32.inc
      include \masm32\include\shell32.inc
      include \masm32\include\msvcrt.inc
      include \masm32\macros\pomacros.asm

      tstproc PROTO :DWORD

    ; *********
    ; libraries
    ; *********
      includelib \masm32\lib\masm32.lib
      includelib \masm32\lib\gdi32.lib
      includelib \masm32\lib\user32.lib
      includelib \masm32\lib\kernel32.lib
      includelib \masm32\lib\Comctl32.lib
      includelib \masm32\lib\comdlg32.lib
      includelib \masm32\lib\shell32.lib
      includelib \masm32\lib\msvcrt.lib

    .code

comment * ------------------------------------------------------------
        The following LibMain procedure is the DLL entry point and it
        functions as the first label in the .CODE section.
        The DLL is terminated in code with the last line

        end LibMain

        NOTE the name "LibMain" is a placeholder for any name you may
        require.

        The procedure requires 3 DWORD arguments even if they are not
        used otherwise the DLL will start with an unbalanced stack and
        may not run correctly.
        ------------------------------------------------------------ *

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

LibMain proc instance:DWORD,reason:DWORD,reserved:DWORD

comment * -------------------------------------
        If you do not need to set up on entry
        or clean up on exit then you can use
        the simpler form without the .IF block
        mov eax, 1
        ret
        ------------------------------------- *

    .if reason == DLL_PROCESS_ATTACH
      mov eax, 1                        ; must return NON zero to start DLL.

    .elseif reason == DLL_THREAD_ATTACH
      ; unused

    .elseif reason == DLL_THREAD_DETACH
      ; unused

    .elseif reason == DLL_PROCESS_DETACH
      ; unused

    .endif

    ret

LibMain endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

comment * ---------------------------------------------------------------

        For a DLL you write a DEF file that has the following form

        LIBRARY tstdll      << the DLL name
        EXPORTS             << the following list of EXPORTED procedures
        "_tstproc@4"        << quoted decorated name with leading "_"
                            << and trailing byte count after "@" symbol

        The trailing byte count is calculated by the number of parameters
        that the exported procedure has and the data SIZE of each
        parameter. Procedures written in this manner are using the
        STDCALL calling convention.

        EXAMPLE :  FuncName proc arg1:DWORD,arg2:DWORD,arg3:DWORD
        "_FuncName@12"

        --------------------------------------------------------------- *

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

align 4

tstproc proc ptxt:DWORD

    fn MessageBox,0,ptxt,"Text in DLL",MB_OK

    ret

tstproc endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end LibMain