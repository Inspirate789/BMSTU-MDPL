;
;		Recursive File Search
;
;	Purpose: Traversal across an entire hard drive
;
;	The SearchForFile function should work in any program provided you include the PROTO
;	below. If it doesn't, email me!
;
;	Special Thanks: Win32ASM.cjb.net message board, bitRAKE!
;	email: kornbizkit536@hotmail.com
;
;	Note: This is a console mode program and builds with Project|Console Assemble & Link
;

.586p
.model flat,stdcall
option casemap :none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib

	; I make these as macros because its easier to understand the code..
	@GetToChar MACRO
		scasb	; check for zero
		jnz $-1 ; loop until zero is found
		
		dec edi		; go back one char
	ENDM
	
	@ClearFN MACRO
		lea edi,WFD.cFileName	; put address of file name in EDI 
		mov ecx,260		; we're gonna do this 260 times
		xor al,al		; clear AL
		rep stosb		; clear all chars in WFD.cFileName
	ENDM


	SearchForFile PROTO :DWORD,:DWORD	; our recursive procedure

.data
usage db "Usage:  w32search <filename>",0Dh,0Ah,0
program db "Win32 Searching Utility v1.00",0Dh,0Ah,0Dh,0Ah,0
stdir db "C:",256 dup (0)	; change this to whatevr drive you'd like
ff db 128 dup (0)		; used to store the filename at the command line

.code
start:
	invoke StdOut,addr program
	
	invoke ArgClC,1,addr ff
	cmp eax,1
	jnz no_arg

	;** ArgClC sometimes messes up so we check for sure that we have a valid file
	cmp byte ptr [ff],00h
	jz no_arg

	invoke SearchForFile,addr stdir,addr ff	; search for the file
	
leave_prog:
	invoke ExitProcess,0	; exit the program

no_arg:
	invoke StdOut,addr usage	; they supplied no file name so we show them how ;)
	jmp leave_prog



SearchForFile PROC StartPath:DWORD,FileToFind:DWORD

	LOCAL	WFD:WIN32_FIND_DATA	; used for file/folder search
	LOCAL	fPath[260]:BYTE		; used to store StartPath locally
	LOCAL   fPath2[260]:BYTE	; we add sub-folders names onto this to form full paths
	LOCAL	hFind:DWORD		; find handle

	; Below is just some little data's that we need in order for function to work
	
	jmp @F
	WildCard db "\*",0		; search ALL files
	CRLF db 13,10,0			; tell me you don't know what this is
	foundat db "Found: ",0		; tell the user we found a file that matches
	@@:
		lea edi,fPath
		push edi	; save EDI in stack
		mov esi,StartPath	; we are copying supplied StartPath to our buffer
		mov ecx,256		; all 256 bytes
		rep movsb		; copy path

		pop edi		; put the path back in EDI

		xor al,al		; clear AL

		@GetToChar		; Find the first zero

		mov al,'\'		; now equals Drive:\Path\*
		stosb			; e.g.: C:\Windows\*
		mov al,'*'
		stosb			
		
		@ClearFN		; clears the cFileName field in Win32_Find_Data
			
		invoke FindFirstFile,addr fPath,addr WFD	; find first file
		
		push eax		; 
		mov hFind,eax		; save FindHandle
		pop ebx			; put handle in EBX
		
		.while ebx > 0		; while a file is found..
			lea esi,WFD.cFileName
			lodsw		; get first two chars

			.if AX!=02E2Eh && AX!=0002Eh	; '..' and '.'		

			  lea edi,WFD
			  mov eax,[edi]	; file attributes
			  .if ax & FILE_ATTRIBUTE_DIRECTORY	; is it a directory?
				sub esi,2		; undo the lodsw
				lea edi,fPath2		; load up the secondary path in EDI
				push edi		; save it on the stack...
			
				xor al,al		; clear secondary path
				mov ecx,260		; ..
				rep stosb
				
				mov edi,[esp]		; restore EDI
				
				lea eax,fPath		; first path
				
				invoke lstrcpy,edi,eax  ; copy first to second
				
				mov al,'*'		; get to the end....
				@GetToChar
				
				mov byte ptr [edi],00h  ; delete the wildcard
				
				invoke lstrcat,edi,esi  ; tack on the new directory name
				pop edi			; restore EDI from stack

				pushad			; must save ALL regs or errors will ocur :)
			    	invoke SearchForFile,edi,FileToFind  ; call function again
			  	popad			; restore all regs
			  	
			  .else
			  
			  	sub esi,2	; undo the lodsw
			  	invoke lstrcmpi,FileToFind,esi	; case insensitive compare
			  	or eax,eax	; are they equal?
			  	jz found_file	; if eax=0 they are equal
			  
			  .endif
			
			.endif
			
			@ClearFN	; Clear the cFileName field again
				
			invoke FindNextFile,hFind,addr WFD
			mov ebx,eax
		
		.endw
__cls_fnd:
			invoke FindClose,hFind	; close it up
		
		ret

found_file:	; we found a file, so we report it to the user
	lea edi,fPath2
	invoke lstrcpy,edi,addr fPath
	
	mov al,'*'
	scasb
	jnz $-1
	
	dec edi
	mov byte ptr [edi],00h
	
	lea edi,WFD.cFileName
	
	invoke lstrcat,addr fPath2,edi
	invoke StdOut,addr foundat
	invoke StdOut,addr fPath2
	invoke StdOut,addr CRLF
	
	jmp __cls_fnd

SearchForFile ENDP

end start