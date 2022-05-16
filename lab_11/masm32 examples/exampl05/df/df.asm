; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤
    include \masm32\include\masm32rt.inc
; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

comment * ---------------------------------------------------------
                        Build this  template with
                       "CONSOLE ASSEMBLE AND LINK"

        DF.EXE Disk Free utility scans drives from A: to Z:
        displaying the drive type, drive size and available
        drive space.

        Run DF.EXE from the command line

        Another bloated pig wickedly crafted in Microsoft Assembler
        --------------------------------------------------------- *

    include \masm32\include\Shlwapi.inc
    includelib \masm32\lib\Shlwapi.lib

    .code

start:
   
; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

    call main
    inkey                         ; uncoment this line to view from editor
    exit

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

main proc

    LOCAL avl   :QWORD                      ; 64 bit target for available disk space
    LOCAL dsk   :QWORD                      ; 64 bit target for drive size

    LOCAL cnt   :DWORD                      ; loop counter
    LOCAL drv   :DWORD                      ; drive letter variable
    LOCAL pdrv  :DWORD                      ; pointer to drive letter variable

    LOCAL pbuf  :DWORD                      ; text pointer 1
    LOCAL buffer[256]:BYTE                  ; text buffer  1
    LOCAL buf2  :DWORD                      ; text pointer 2
    LOCAL buffer2[256]:BYTE                 ; text buffer  2

    push esi
    push edi

    mov cnt, 0                              ; zero the counter
    mov drv, "A"                            ; start at drive A

    lea eax, drv                            ; get address of variable "drv"
    mov pdrv, eax                           ; copy it to the drive letter pointer

    invoke GetLogicalDrives                 ; returns bitmask in EAX
    mov esi, eax
    mov edi, 00000000000000000000000000000001b  ; start with bit set to drive A:

  ; --------------------
  ; display topic header
  ; --------------------
    print "Media type  Drv",9,"  Size",9,9,"Free",13,10
    print "==========  ===",9,"  ====",9,9,"====",13,10

  ; -----------------------------------------------------------------------

  lp:
    test esi, edi                           ; test if bit set in ESI
    jz @F

    mov pbuf, ptr$(buffer)
    mov pbuf, cat$(pbuf,pdrv,":\  ")        ; append ":\" to the drive letter

    invoke GetDriveType,pbuf

    switch eax
      case 0                                ; The drive type cannot be determined.
        print "Unknown type"
      case 1                                ; The root directory does not exist.
        print "No root dir "
      case DRIVE_REMOVABLE                  ; The drive can be removed from the drive.
        print "Removable   "
      case DRIVE_FIXED                      ; The disk cannot be removed from the drive.
        print "Local disk  "
      case DRIVE_REMOTE                     ; The drive is a remote (network) drive.
        print "Network drv "
      case DRIVE_CDROM                      ; The drive is a CD-ROM drive.
        print "CD/DVD drv  "
      case DRIVE_RAMDISK                    ; The drive is a RAM disk.
        print "Ram drive   "
    endsw

  ; -----------------------------------------------------
  ; so Windows does not display an error on missing media
  ; -----------------------------------------------------
    invoke SetErrorMode,SEM_FAILCRITICALERRORS

    invoke GetDiskFreeSpaceEx,pbuf,ADDR avl,ADDR dsk,NULL

    .if eax != 0
      mov buf2, ptr$(buffer2)
      lea eax, dsk
      invoke StrFormatByteSize64,[eax], [eax+4], buf2, 256  ; format the disk size data
  
      mov pbuf, lcase$(cat$(pbuf," ",buf2," "))             ; construct 1st part of info string
  
      mov buf2, ptr$(buffer2)

      lea eax, avl
      invoke StrFormatByteSize64,[eax], [eax+4], buf2, 256  ; format the available space data
  
      mov pbuf, lcase$(cat$(pbuf,chr$(9),buf2))             ; append 2nd part of string
      print pbuf,13,10                                      ; display the line of information

    .else
      print lcase$(pbuf)," No Media      ------",13,10
    .endif

  @@:
    rol edi, 1                              ; shift bit left to test next drive
    add cnt, 1                              ; increment counter
    add drv, 1                              ; increment drive
    cmp cnt, 26                             ; loop through the 26 possible
    jne lp

  ; -----------------------------------------------------------------------

    pop edi
    pop esi
 
    ret

main endp

; ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤

end start
