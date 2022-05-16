; #########################################################################

;   A simple useful toy, Shellex takes a command line which is a drive
;   and directory path. Set it as a shortcut on your desktop with the
;   path you require and it will start a window in explorer where you
;   specify.

;   If you set it with a URL, it will open that as well in your default
;   browser so you can have a favourite site parked on your desktop that
;   is only a double click away.

; #########################################################################

      .386
      .model flat, stdcall  ; 32 bit memory model
      option casemap :none  ; case sensitive

      include \MASM32\INCLUDE\windows.inc
      include \MASM32\INCLUDE\kernel32.inc
      include \MASM32\INCLUDE\shell32.inc
      include \MASM32\INCLUDE\masm32.inc

      includelib \MASM32\LIB\kernel32.lib
      includelib \MASM32\LIB\shell32.lib
      includelib \MASM32\LIB\masm32.lib

; #########################################################################

.data
    open db "open",0
    dir  db 128 dup (0) ; buffer for command line

.code

start:

    invoke GetCL,1,ADDR dir

    invoke ShellExecute,0,ADDR open,ADDR dir,NULL,NULL,SW_SHOW
    invoke ExitProcess,eax

end start

; #########################################################################
