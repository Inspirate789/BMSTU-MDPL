comment * �����������������������������������������������������������������

                         Build this example with

                      >> Console Assemble & Link <<

; ����������������������������������������������������������������������� *

    .486
    .model flat, stdcall
    option casemap :none   ; case sensitive

; �������������������������������������������������������������������������

    include \masm32\include\windows.inc
    include \masm32\include\masm32.inc
    include \masm32\include\kernel32.inc
    include \masm32\macros\macros.asm

    includelib \masm32\lib\masm32.lib
    includelib \masm32\lib\kernel32.lib

    .code

start:

; �������������������������������������������������������������������������

    print "Hello world"

    exit

; �������������������������������������������������������������������������

end start