; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; About
;
; Author - Bagayev ALEXander ("┴рурхт └ыхъёрэфЁ" - in russian),
; Republic of Uzbekistan, Tashkent city, 2008.
;
; E-mail: ACLOERXE@MAIL.RU
;
; Specially for the MASM32 Project Examples
; 
; This source file - the set of comments slightly "diluted" with a code :-)
;
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл


; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; System

.386                                    ; create 32 bit code i386 CPU
.model flat,stdcall                     ; 32 bit memory model, calling convention
.radix 10
option casemap:none                     ; case sensitive


; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; Includes & Libs

include     \MASM32\include\Windows.inc
include     \MASM32\include\user32.inc
include     \MASM32\include\kernel32.inc
includelib  \MASM32\lib\user32.lib
includelib  \MASM32\lib\kernel32.lib

; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; Data

.data                                   ; initialized data

caption             db      "MemInfo ",0
fmt                 db      "Size of RAM, MB:       ",9,"%d  ",13,10        ; preformatted message
                    db      "Free RAM, MB:          ",9,"%d  ",13,10        ; string for wsprintfA
                    db      "Size of Swap File, MB: ",9,"%d  ",13,10        ; WinAPI function
                    db      "Free Swap File, MB:    ",9,"%d  ",13,10,13,10
                    db      "й ALEX, ACLOERXE@MAIL.RU  ",0

memstat   MEMORYSTATUS <sizeof MEMORYSTATUS,?,?,?,?,?,?,?>                  ; structure for
                                                                            ; GlobalMemoryStatus
                                                                            ; WinAPI function
                                                                            
.data?                                  ; uninitialized data

asciiz1               db      4096 dup(?)                                   ; output buffer for
                                                                            ; wsprintfA WinAPI
                                                                            ; function
                                                                            
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
; Code

.code                                   ; main code

start:

push offset memstat                     ; address of MEMORYSTATUS structure
call GlobalMemoryStatus                 ; call to GlobalMemoryStatus API function

; NOTE: 
; instruction
; shr eax,20
; is a integer division by 1048576 (2^20), for reduction a bytes value to MegaBytes

; pushing the numerical params of the wsprintfA function
mov eax,memstat.dwAvailPageFile         ; last parameter of wsprintfA function - size of available
shr eax,20                              ; pagefile (called "swap file" also)
push eax
mov eax,memstat.dwTotalPageFile         ; total size of pagefile
shr eax,20
push eax
mov eax,memstat.dwAvailPhys             ; size of free RAM (Random-Access Memory)
shr eax,20
push eax
mov eax,memstat.dwTotalPhys             ; first param of wsprintfA function - total size of RAM
shr eax,20
inc eax                                 ; add to total RAM size the "1" - typically Windows report
push eax                                ; about size of the RAM on 1 MB less, than it is actually
                                        ; (1 MB - pseudo-DOS :)

; pushing the addresses of the strings as params of the wsprintfA function
push offset fmt                         ; address of the preformatted message string
push offset asciiz1                     ; address of the output asciiz string-buffer
call wsprintfA                          ; call to wsprintfA API function

; displaying of the program results
push MB_ICONINFORMATION or MB_TOPMOST   ; type of the Message Box
push offset caption                     ; address of the caption for the MessageBoxA function
push offset asciiz1                     ; address of the output buffer                     
push 0                                  ; handle of the Owner Window, "0" - is a Desktop
call MessageBoxA                        ; call to MessageBoxA API function                        

; exit from program
push 0                                  ; normal termination (%ERRORLEVEL% is "0", if program is a
                                        ; console application)
call ExitProcess                        ; call to ExitProcess API function

end start
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл


; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
;
; Calling process of the functions may be replaced to:
;
;   invoke GlobalMemoryStatus,offset memstat
;   for GlobalMemoryStatus info
;
;   invoke wsprintfA,offset asciiz1,offset fmt,dwTotalPhys,dwAvailPhys,dwTotalPageFile,dwAvailPageFile
;   for format the output message. But you should change values of structure to a format in MBYTES!
;
;   invoke MessageBoxA,offset asciiz1,offset caption,MB_ICONINFORMATION or MB_TOPMOST
;   for displaying message dialog box
;
;   invoke ExitProcess,0
;   for exit from program
;
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл


; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл
COMMENT *
Bare program model:

start:

push offset memstat
call GlobalMemoryStatus


mov eax,memstat.dwAvailPageFile
shr eax,20
push eax
mov eax,memstat.dwTotalPageFile
shr eax,20
push eax
mov eax,memstat.dwAvailPhys
shr eax,20
push eax
mov eax,memstat.dwTotalPhys
shr eax,20
add eax,1
push eax

push offset fmt
push offset asciiz1
call wsprintfA


push MB_ICONINFORMATION or MB_TOPMOST
push offset caption
push offset asciiz1
push 0
call MessageBoxA


push 0
call ExitProcess

end start

*
; ллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл

