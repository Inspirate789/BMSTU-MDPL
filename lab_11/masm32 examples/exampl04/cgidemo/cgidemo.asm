;   ----------------------------------------------------------------
;   Program Name: cgidemo.asm
;   Author: Andy Beckman
;   Date:  11/14/01
;   Email: andy981@cafes.net
;   This program,is simple example how to make a cgi program in assembly
;   It should be built with the "Console Assemble & Link" option on
;   the project menu.
;   ----------------------------------------------------------------
      .386
      .model flat, stdcall
      option casemap :none   ; case sensitive



      include \masm32\include\windows.inc

      include \masm32\include\user32.inc
      include \masm32\include\kernel32.inc
      include \masm32\include\masm32.inc

      includelib \masm32\lib\user32.lib
      includelib \masm32\lib\kernel32.lib
      includelib \masm32\lib\masm32.lib

      Main   PROTO



      .data
      lf          db 13,10,0
      content     db "Content-type: text/plain",13,10,13,10,0
      
      top         db "<html>",0
      centertop   db "<center><b><i><font face=""Eras Ultra ITC"" size=""5"">",0
      mytop     db "<head><head><title>Assembly Alphabet CGI</title>",
                     "</head><body bgcolor=""#000000"" text=""#FFFFFF"">",0
      mytitle    db   "<center><b><i><font face=""Eras Ultra ITC"" size=""6"">",
                      "A CGI program made in Assembly<br> That prints ASCII characters 65 to 90",
                      "</font></i></b></center><br><br>",0

      
      num         dd  65
      centerb     db "</font></i></b></center>",0
      bottom      db "</html>",0




    .code

    start:
      invoke Main
      invoke ExitProcess,0



Main proc

    LOCAL cmdBuffer[128]:BYTE
    LOCAL cntBuffer[8]
    LOCAL cnt :DWORD


    mov cnt, 0

    invoke ClearScreen
    invoke StdOut,ADDR content
    invoke StdOut,ADDR top
    invoke StdOut,ADDR mytop
    invoke StdOut,ADDR mytitle
    invoke StdOut,ADDR centertop

  @@:
    invoke GetCL,cnt,ADDR cmdBuffer
   
    invoke StdOut,ADDR num
    add num, 1
    cmp eax, 1
   
    invoke StdOut,ADDR lf  
    inc cnt
    cmp num,91
    jl @B
  @@:
 invoke StdOut,ADDR centerb
 invoke StdOut,ADDR bottom

    ret

Main endp



    end start