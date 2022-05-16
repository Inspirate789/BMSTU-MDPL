; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
    include \masm32\include\masm32rt.inc
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

comment * -------------------------------------------------------

                        Build this  template with
                       "CONSOLE ASSEMBLE AND LINK"

        TOUCH.EXE is a file timestamp utility that supports
        wildcard changes of the timestamp for entire directories.

        ------------------------------------------------------- *

    Find_Files PROTO
    SetDate    PROTO :DWORD

    .data?
      day   dw ?
      month dw ?
      year  dw ?

      fpath db 260 dup (?)

    .data
      ppath dd fpath

    .code

start:
   
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    call main

    exit

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

main proc

    LOCAL pcmd  :DWORD
    LOCAL pbuf  :DWORD
    LOCAL buffer[128]:BYTE

    mov pbuf, ptr$(buffer)
    mov pcmd, rv(GetCommandLine)

  ; ------------------------
  ; test command line length
  ; ------------------------
    cmp len(pcmd),128
    jle @F
    print "Command line too long",13,10,13,10
    ret
  @@:

  ; ----------------------------------------
  ; read optional file path and file pattern
  ; ----------------------------------------
    cmp rv(GetCL,1,ppath), 1
    je @F
    print "Path or file pattern not found",13,10,13,10
    call help
    ret
  @@:

  ; ----------------
  ; get day argument
  ; ----------------
    cmp rv(GetCL,2,pbuf), 1
    je @F
    print "Day argument not found",13,10,13,10
    call help
    ret
  @@:
    invoke atodw,pbuf
    mov day, ax

  ; ------------------
  ; get month argument
  ; ------------------
    cmp rv(GetCL,3,pbuf), 1
    je @F
    print "Month argument not found",13,10,13,10
    call help
    ret
  @@:
    invoke atodw,pbuf
    mov month, ax

  ; -----------------
  ; get year argument
  ; -----------------
    cmp rv(GetCL,4,pbuf), 1
    je @F
    print "Year argument not found",13,10,13,10
    call help
    ret
  @@:
    invoke atodw,pbuf
    mov year, ax

    invoke Find_Files

    ret

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

Find_Files proc

    LOCAL hSrch :DWORD
    LOCAL wfd   :WIN32_FIND_DATA

    mov hSrch, rv(FindFirstFile,ppath,ADDR wfd)

    .if hSrch != INVALID_HANDLE_VALUE
      lea eax, wfd.cFileName
      switch$ eax
        case$ "."                           ; bypass current directory character
          jmp @F
      endsw$
      invoke SetDate,ADDR wfd.cFileName

    @@:
      invoke FindNextFile,hSrch,ADDR wfd
      test eax, eax
      jz close_file
      lea eax, wfd.cFileName
      switch$ eax
        case$ ".."                          ; bypass previous directory characters
          jmp @F
      endsw$
      invoke SetDate,ADDR wfd.cFileName

    @@:
      invoke FindNextFile,hSrch,ADDR wfd    ; loop through the rest
      test eax, eax
      jz close_file
      invoke SetDate,ADDR wfd.cFileName
      jmp @B

    close_file:
      invoke FindClose,hSrch

    .endif

    ret

Find_Files endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

SetDate proc filename:DWORD

    LOCAL hFile     :DWORD
    LOCAL ftime     :FILETIME
    LOCAL stime     :SYSTEMTIME

    mov hFile, fopen(filename)

    m2m stime.wYear, year
    m2m stime.wMonth, month
    mov stime.wDayOfWeek, 0
    m2m stime.wDay, day
    mov stime.wHour, 11
    mov stime.wMinute, 1
    mov stime.wSecond, 1
    mov stime.wMilliseconds, 1

    invoke SystemTimeToFileTime,ADDR stime,ADDR ftime
    invoke SetFileTime,hFile,ADDR ftime,ADDR ftime,ADDR ftime

    ret

SetDate endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

help proc

    print "TOUCH.EXE File time stamp utility",13,10
    print "  (c) 2005 The MASM32 Project",13,10
    print "  SYNTAX: touch [path\]pattern day month year",13,10
    print "    [path\pattern] - optional directory path and file pattern to change",13,10
    print "                     must be quoted if text contains any spaces",13,10
    print "    day            - day from 1 to 7",13,10
    print "    month          - month from 1 to 12",13,10
    print "    year           - 4 digit year 1980 to 2099",13,10

    ret

help endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start
