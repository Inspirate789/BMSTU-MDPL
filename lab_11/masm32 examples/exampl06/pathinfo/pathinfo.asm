; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
    include \masm32\include\masm32rt.inc
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

comment * -----------------------------------------------------
                        Build this  template with
                       "CONSOLE ASSEMBLE AND LINK"
        ----------------------------------------------------- *

    .code

start:
   
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

    call main
    inkey
    exit

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

main proc

    LOCAL pcmd  :DWORD
    LOCAL clbuffer[260]:BYTE

    mov pcmd, ptr$(clbuffer)

    invoke GetCL,1,pcmd

    .if eax != 1
      call help
      return 0
    .endif

    mov pcmd, trim$(pcmd)

    switch$ pcmd
      case$ "path"
        print "Your current app path is : "
        print pth$(),13,10

      case$ "directory"
        print "Your current directory   : "
        print CurDir$(),13,10

      case$ "system"
        print "Windows SYSTEM directory : "
        print SysDir$(),13,10

      case$ "windows"
        print "Your Windows directory   : "
        print WinDir$(),13,10

      case$ "all"
        print "Your Windows directory   : "
        print WinDir$(),13,10
        print "Windows SYSTEM directory : "
        print SysDir$(),13,10
        print "Your current directory   : "
        print CurDir$(),13,10
        print "Your current app path is : "
        print pth$(),13,10

      else$
        call help

    endsw$

    return 0

main endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

help proc

    print "Pathinfo demonstration",13,10,13,10
    print "SYNTAX : Pathinfo option",13,10
    print "  There are 5 options",13,10
    print "  1. all       : Display all paths",13,10
    print "  2. path      : Display the current path of this application",13,10
    print "  3. windows   : Display the Windows directory",13,10
    print "  4. system    : Display the Windows SYSTEM directory",13,10
    print "  5. directory : Display the current directory",13,10



    ret

help endp

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

end start
