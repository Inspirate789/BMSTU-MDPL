; #########################################################################
;
;          Build this DLL from the batch file called makeit.bat
;
; #########################################################################

    .486
    .model flat, stdcall
    option casemap :none   ; case sensitive

; #########################################################################

    include \masm32\include\windows.inc
    include \masm32\include\user32.inc
    include \masm32\include\kernel32.inc

    includelib \masm32\lib\user32.lib
    includelib \masm32\lib\kernel32.lib

; #########################################################################

    ; ---------------------
    ; literal string MACRO
    ; ---------------------
      literal MACRO quoted_text:VARARG
        LOCAL local_text
        .data
          local_text db quoted_text,0
        .code
        EXITM <local_text>
      ENDM
    ; --------------------------------
    ; string address in INVOKE format
    ; --------------------------------
      SADD MACRO quoted_text:VARARG
        EXITM <ADDR literal(quoted_text)>
      ENDM
    ; --------------------------------
    ; string OFFSET for manual coding
    ; --------------------------------
      CTXT MACRO quoted_text:VARARG
        EXITM <offset literal(quoted_text)>
      ENDM

.data?
    hMMF      dd ?
    lpMemFile dd ?

.code

; ##########################################################################

LibMain proc hInstDLL:DWORD, reason:DWORD, unused:DWORD

        .if reason == DLL_PROCESS_ATTACH

          ; @@@@@@@@@@@@@@@@@@@@@@@@@@@
          ; Create the memory mapped file
          ; @@@@@@@@@@@@@@@@@@@@@@@@@@@
    
            invoke CreateFileMapping,0FFFFFFFFh,        ; nominates the system paging
                                     NULL,
                                     PAGE_READWRITE,    ; read write access to memory
                                     0,
                                     1000000,           ; size in BYTEs
                                     SADD("My_MM_File") ; set file object name here
            mov hMMF, eax

          ; @@@@@@@@@@@@@@@@@@@@@@@@@@@
          ; map a view of that file into
          ; this applications memory
          ; address space.
          ; @@@@@@@@@@@@@@@@@@@@@@@@@@@

            invoke MapViewOfFile,hMMF,FILE_MAP_WRITE,0,0,0
            mov lpMemFile, eax

            mov eax, 1
            ret

        .elseif reason == DLL_PROCESS_DETACH

        ; @@@@@@@@@@@@@@@@@@@@@@@@@@@
        ; unmap view and close handle
        ; @@@@@@@@@@@@@@@@@@@@@@@@@@@

          invoke UnmapViewOfFile,lpMemFile
          invoke CloseHandle,hMMF

 ;         .elseif reason == DLL_THREAD_ATTACH
 ; 
 ;         .elseif reason == DLL_THREAD_DETACH
            
        .endif

        ret

LibMain Endp

; ##########################################################################

function1 proc

  ; parameters are placed in the MM file in the order,

  ; 1. window handle in MMF at offset  1024
  ; 2. offset of message in MMF at     1024 + 4
  ; 3. offset of title in MMF at       1024 + 8
  ; 4. message box style at            1024 + 12

    mov eax, lpMemFile
    add eax, 1024
    mov ecx, [eax+4]  ; message
    add ecx, lpMemFile
    mov edx, [eax+8]    ; title
    add edx, lpMemFile

    invoke MessageBox,[eax],ecx,edx,[eax+12]

    ret

function1 endp

; ##########################################################################

End LibMain
