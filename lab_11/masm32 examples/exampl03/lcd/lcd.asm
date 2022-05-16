;===============================================================================
; LCD CD Player - (C) 2000 by Thomas Bleeker [exagone]. http://exagone.cjb.net
;===============================================================================
;
; This program is a basic CD-Player with a nice LCD interface. I didn't finish
; it but the basic functions work and it shows some GDI and MCI stuff. Not all 
; functions visible in the main window may work.
; 
; Build with MAKE.BAT
;
; Close this program with Alt + F4
;
; Best viewed with tabstop=4 and a good editor with syntax highlighting.
;
; Thomas.
; ska-pig@gmx.net
; http://exagone.cjb.net
;
.486
.model flat,stdcall
option	casemap:none

;-----------------------------------------------------------------------------
; Libraries & Include files
;-----------------------------------------------------------------------------

includelib 	\masm32\lib\kernel32.lib
includelib 	\masm32\lib\user32.lib
includelib 	\masm32\lib\gdi32.lib
includelib 	\masm32\lib\winmm.lib

include 	\masm32\include\windows.inc
include 	\masm32\include\kernel32.inc
include 	\masm32\include\winmm.inc
include 	\masm32\include\user32.inc
include 	\masm32\include\gdi32.inc
include		prog.inc

;-----------------------------------------------------------------------------
; Prototypes
;-----------------------------------------------------------------------------
WinMain 				PROTO 	STDCALL :DWORD, :DWORD, :DWORD, :DWORD
WndProc 				PROTO 	STDCALL :DWORD, :DWORD, :DWORD, :DWORD
CreateLCDColors			PROTO 	STDCALL
CreateLCD				PROTO	STDCALL	:DWORD
PseudoRandom			PROTO	STDCALL
DrawLCD					PROTO	STDCALL

DrawChar				PROTO	STDCALL :DWORD, :DWORD, :DWORD
DrawSmallChar			PROTO	STDCALL :DWORD, :DWORD, :DWORD
DrawLCDText				PROTO	STDCALL :DWORD, :DWORD, :DWORD, :DWORD
CheckForButton			PROTO	STDCALL :DWORD, :DWORD
GetPositionFromString 	PROTO	STDCALL :DWORD, :DWORD
GetNextNumberFromTime 	PROTO	STDCALL

;-----------------------------------------------------------------------------
; Initialized data
;-----------------------------------------------------------------------------
.data
AppName		db	"LCD",0
ClassName	db	"LCD32",0


; The bitmapinfoheader structure used for the DC the lcd is drawn on
; before it is blitted onto the backbuffer.
; Note that the height property is set to the negated WINDOW_HEIGHT. This 
; will cause the bitmap data bits being arranged in top-down order instead
; of the usual down-top order.
; The bitmap used is a 256 color bitmap. A 16-bit bitmap would be enough, but
; then 4 bits per pixel are used which are harder to work with than 8 bits 
; per pixel.
LCDBITMAPINFO	BITMAPINFOHEADER <SIZEOF BITMAPINFOHEADER,\
								  ALIGNED_WIDTH, -WINDOW_HEIGHT,\
								  1, 8, BI_RGB, 0, 100, 100, 16, 16>
	
	
								  
; This is the pallette used. The first 7 colors are the colors that are used
; to paint the green background color of the LCD. The 7 colors after that are
; the same colors as the first 7 ones, but darker for use in shadows. The
; colors are not initialized here, but in the code (CreateLCDColors). This way
; the darkness can be changed. Finally, the last two colors are simply black
; and white. The other 240 colors of the 256 color bitmap are not used (see 
; also the note above LCDBITMAPINFO).
LCDBaseColors	db	140, 165, 148, 0    ; --+
				db	148, 165, 140, 0	;   |
				db	140, 156, 156, 0	;   |
				db	145, 165, 138, 0	;   +- 7 LCD background
				db	148, 156, 140, 0	;	|  colors
				db	142, 156, 140, 0	;   |
				db	140, 168, 148, 0	; --+
				db	4 * 7 dup (0)		; ---- Reserved for shadow colors
				db	0,0,0,0				; ---- Black
				db  255,255,255,0		; ---- White




;LCD Characters consist of a 6x7 bit pattern like this:
; Character 'A':
;
; 011110  .oooo.  
; 100001  o....o
; 100001  o....o
; 111111  oooooo
; 100001  o....o
; 100001  o....o
; 100001  o....o
;
; This pattern is stored row by row, each row of 6 bits gets two extra 0-bits on the
; right, making it a full byte. 

; The following table (LCDChars) contains the most used characters. The comment after
; the lines indicate which char is described. (A=10 means that it is the character A,
; at index 10 (0-based) in list)

LCDChars	db		01111000b,10000100b,10001100b,10010100b,10100100b,11000100b,01111000b	;0
			db		00010000b,00110000b,00010000b,00010000b,00010000b,00010000b,00010000b	;1
			db		01111000b,10000100b,00000100b,01111000b,10000000b,10000000b,11111100b	;2
			db		11111000b,00000100b,00000100b,11111000b,00000100b,00000100b,11111000b	;3
			db		10000100b,10000100b,10000100b,11111100b,00000100b,00000100b,00000100b	;4
			db		11111100b,10000000b,10000000b,11111000b,00000100b,10000100b,01111000b	;5
			db		01111000b,10000100b,10000000b,11111000b,10000100b,10000100b,01111000b	;6
			db		01111100b,00001000b,00001000b,00010000b,00010000b,00100000b,00100000b	;7
			db		01111000b,10000100b,10000100b,01111000b,10000100b,10000100b,01111000b	;8
			db		01111000b,10000100b,10000100b,01111100b,00000100b,10000100b,01111000b	;9
			
			db		01111000b,10000100b,10000100b,11111100b,10000100b,10000100b,10000100b	;A = 10
			db		11111000b,10000100b,10000100b,11111000b,10000100b,10000100b,11111000b   ;B
			db		01111100b,10000000b,10000000b,10000000b,10000000b,10000000b,01111100b   ;C
			db		11111000b,10000100b,10000100b,10000100b,10000100b,10000100b,11111000b   ;D
			db		11111100b,10000000b,10000000b,11111100b,10000000b,10000000b,11111100b   ;E
			db		11111100b,10000000b,10000000b,11111100b,10000000b,10000000b,10000000b   ;F
			db		01111100b,10000000b,10000000b,10111000b,10000100b,10000100b,01111000b   ;G
			db		10000100b,10000100b,10000100b,11111100b,10000100b,10000100b,10000100b   ;H
			db		00100000b,00100000b,00100000b,00100000b,00100000b,00100000b,00100000b   ;I
			db		00010000b,00010000b,00010000b,00010000b,00010000b,10010000b,01100000b   ;J
			db		10001000b,10010000b,10100000b,11000000b,10100000b,10010000b,10001000b   ;K
			db		10000000b,10000000b,10000000b,10000000b,10000000b,10000000b,11111100b   ;L
			db		11011000b,10101000b,10101000b,10101000b,10101000b,10101000b,10101000b   ;M
			
			db		11000100b,10100100b,10100100b,10010100b,10010100b,10010100b,10001100b   ;N
			db		01111000b,10000100b,10000100b,10000100b,10000100b,10000100b,01111000b	;O
			db		11111000b,10000100b,10000100b,11111000b,10000000b,10000000b,10000000b	;P
			db		01111000b,10000100b,10000100b,10000100b,10010100b,10001100b,01111100b	;Q
			db		11111000b,10000100b,10000100b,11111000b,11000000b,10110000b,10001100b	;R
			db		01111000b,10000100b,10000000b,01111000b,00000100b,10000100b,01111000b	;S
			db		11111000b,00100000b,00100000b,00100000b,00100000b,00100000b,00100000b	;T
			db		10000100b,10000100b,10000100b,10000100b,10000100b,10000100b,01111000b	;U
			db		10001000b,10001000b,10001000b,10001000b,01010000b,01010000b,00100000b	;V
			db		10101000b,10101000b,10101000b,10101000b,10101000b,10101000b,01010000b	;W
			db		10001000b,10001000b,01010000b,00100000b,01010000b,10001000b,10001000b	;X
			db		10001000b,10001000b,10001000b,01010000b,00100000b,00100000b,00100000b	;Y
			db		11111100b,00001000b,00010000b,00100000b,01000000b,10000000b,11111100b	;Z
			
			db		00000000b,00000000b,00000000b,00000000b,00000000b,00110000b,00110000b	;. = 36
			db		00000000b,00000000b,00000000b,00000000b,00110000b,00010000b,00100000b	;, = 37
			db		00000000b,00110000b,00110000b,00000000b,00110000b,00110000b,00000000b	;: = 38
			db		00010000b,00100000b,00100000b,00100000b,00100000b,00100000b,00010000b	;( = 39
			db		00100000b,00010000b,00010000b,00010000b,00010000b,00010000b,00100000b	;) = 40
			db		00000000b,00000000b,11111100b,00000000b,11111100b,00000000b,00000000b   ;= = 41
			db		00000000b,00000000b,00000000b,11111100b,00000000b,00000000b,00000000b   ;- = 42
			db		01111000b,10000100b,10110100b,11000100b,10110100b,10000100b,01111000b	;© = 43


tCollon		db		":",0

;Introductiontexts
tSmallText1	db		"-== CD PLAYER ==-",0 
tSmallText2	db		"© 2000 by Exagone",0

;wsprintf format for a 2 digit, 0 padded number
Format2Digits 	db		"%02lu",0

;wsprintf format for a TMSF time
FormatTMSF		db		"%lu:%lu:%lu:%lu",0

;wsprintf format for a TMSF time mci seek command
FormatSeekTMSF	db		"seek cdaudio to %lu:%lu:%lu:%lu wait",0 

; open cdaudio mci command
tOpenCD		db	"open cdaudio wait",0

;tSeekCD		db	"seek cdaudio to 1:00:10:00",0

; play cdaudio mci command
tPlayCD		db	"play cdaudio",0

; stop cdaudio mci command
tStopCD		db	"stop cdaudio wait",0

; set timeformat mci command
tSetTimeF	db	"set cdaudio time format tmsf wait",0

; get current cdaudio position mci command
tGetPos		db	"status cdaudio position",0


; Special color indexes in the color palette:
COLORINDEX_BLACK		equ		14
COLORINDEX_WHITE		equ		15
COLORBASE_BACKGROUND	equ		0	;base for background colors (colors 0-6)
COLORBASE_SHADOW		equ		7   ;base for shadow colors (colors 7-13)
BASECOLORCOUNT			equ		7	;7 lcd colors for background & shadow

; The higher this value, the darker the shadow:
SHADOWDARKNESS			equ		40	;color -40 for shadow

; Random seed value to paint the background:
RANDOMSEED				equ		19172991h

; Positions of the various buttons:
ButtonVolPlus	RECT	<194,13,204,24>
ButtonVolMin	RECT	<181,13,192,24>
ButtonPrevTrack	RECT	<182,37,194,48>
ButtonNextTrack	RECT	<195,37,208,48>
ButtonPlay		RECT	<220,12,254,23>
ButtonStop		RECT	<220,24,254,34>

;-----------------------------------------------------------------------------
; Uninitialized data
;-----------------------------------------------------------------------------
.data?

hInstance	dd	?

; Handles of the bitmap & DC for the LCD Display
hLCDBitmap	dd	?
hLCDDC		dd	?

; Dword that will hold a pointer to the bitmap data in the backbuffer
lpLCDBmp	dd	?

; Random seed variable used in the PseudoRandom procedure.
RandSeed	dd	?

; Handles of DC and bitmap for the backbuffer
hBackDC		dd	?
hBackBmp	dd	?

; Handles of DC and bitmap for the monochrom overlay
; (the bitmap in the resource file)
hLabelBmp	dd	?
hLabelDC	dd	?


; LCD text buffers
tMinuteText		db	5 dup (?)
tSecondsText	db	5 dup (?)
tTrackText		db	5 dup (?)


;-----------------------------------------------------------------------------
; Code
;-----------------------------------------------------------------------------
.code
start:
	invoke	GetModuleHandle, NULL
	mov		hInstance, eax
	invoke  WinMain, hInstance, NULL, NULL, SW_SHOWNORMAL
    invoke	ExitProcess, NULL
    
WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL hwnd:DWORD
    LOCAL msg:MSG
    mov     wc.cbSize,SIZEOF WNDCLASSEX
    mov     wc.style,   CS_HREDRAW or CS_VREDRAW
    mov     wc.lpfnWndProc, OFFSET WndProc
    mov     wc.cbClsExtra,NULL
    mov     wc.cbWndExtra,NULL
    push    hInst
    pop     wc.hInstance
    mov     wc.hbrBackground,COLOR_WINDOW
    mov     wc.lpszMenuName,NULL
    mov     wc.lpszClassName,OFFSET ClassName
    invoke  LoadIcon,NULL,IDI_APPLICATION
    mov     wc.hIcon,   eax
    mov     wc.hIconSm, eax
    invoke  LoadCursor,NULL,IDC_ARROW
    mov     wc.hCursor,eax
    invoke  RegisterClassEx,    addr wc
    
    ; WINDOW_HEIGHT and WINDOW_WIDTH are the dimensions of the display, but the
    ; actual window has borders too. The size of these borders is retrieved with
    ; GetSystemMetrics (multiplied by 2 because there are borders on each side),
    ; and added to the width & height to get the correct size.
    invoke	GetSystemMetrics, SM_CYEDGE
    shl		eax, 1
    add		eax, WINDOW_HEIGHT
    push	eax
    invoke	GetSystemMetrics, SM_CXEDGE
    shl		eax, 1
    add		eax, WINDOW_WIDTH
    mov		ecx, eax
    pop		edx
    
    INVOKE CreateWindowEx,WS_EX_CLIENTEDGE, ADDR ClassName,ADDR AppName,\
           WS_POPUP,\
            400,300,ecx,edx,NULL,NULL,\
           hInst,NULL
    mov   hwnd,eax
    invoke ShowWindow, hwnd,SW_SHOWNORMAL
    invoke UpdateWindow, hwnd
    .WHILE TRUE
        invoke GetMessage, ADDR msg,NULL,0,0
        .BREAK .IF (!eax)
                invoke TranslateMessage, ADDR msg
                invoke DispatchMessage, ADDR msg
    .ENDW
    mov     eax,msg.wParam
    ret
WinMain endp

WndProc proc uses ebx hWnd:DWORD, uMsg:DWORD, wParam:DWORD, lParam:DWORD
LOCAL	hDC:DWORD
LOCAL	ps:PAINTSTRUCT
LOCAL	Buffer[128]:BYTE
LOCAL	TempPos:CDPOSITION
LOCAL	MousePos:POINT
mov eax, uMsg
.IF eax==WM_CREATE
	; On startup, open the CD device and set the time format
	; to TMSF (tt:mm:ss:ff, track:minute:second:frame)
	invoke	mciSendString, ADDR tOpenCD, 0, 0, 0
	invoke	mciSendString, ADDR tSetTimeF, 0, 0, 0

	;invoke	mciSendString, ADDR tSeekCD, 0, 0, 0
	;invoke	mciSendString, ADDR tPlayCD, 0,0,0
	
	; --- Create LCD colors ---
	invoke	CreateLCDColors
	
	; --- Create LCD ---
	invoke	CreateLCD, hWnd
	
	; --- Create timer to update the display every 500 ms ---
	invoke	SetTimer, hWnd, MAINTIMERID, 500, NULL
	
.ELSEIF	eax==WM_TIMER
	; --- display update timer ---
	.IF		wParam==MAINTIMERID
		
		; Get current position in TMSF format in Buffer:
		invoke	mciSendString, ADDR tGetPos, ADDR Buffer,127 ,0
	
		; Parse TMSF string to CDPOSITION (see prog.inc)
		invoke	GetPositionFromString, ADDR Buffer, ADDR TempPos
		
		; Format Second, minute and track into seperate buffers
		xor		ebx, ebx
		mov		bl, TempPos.Second
		invoke	wsprintf, ADDR tSecondsText, ADDR Format2Digits, ebx
		xor		ebx, ebx
		mov		bl, TempPos.Minute
		invoke	wsprintf, ADDR tMinuteText, ADDR Format2Digits, ebx
		xor		ebx, ebx
		mov		bl, TempPos.Track
		invoke	wsprintf, ADDR tTrackText, ADDR Format2Digits, ebx

		; Invalidate the window to force a repaint
		invoke	InvalidateRect, hWnd, NULL, FALSE
	
	.ENDIF
.ELSEIF	eax==WM_LBUTTONDOWN

	; On mousepress, extract X and Y coordinates from lParam:
	mov		eax, lParam
	mov		ecx, eax
	shr		ecx, 16		; ecx = Y
	and		eax, 0ffffh	; eax = X

	; Use CheckForButton to see if a button is present at (X,Y)
	invoke	CheckForButton, eax, ecx
	
	; The return value is a LCDBUTTON_?? constant:
	
	.IF		eax==LCDBUTTON_NEXTTRACK
		
		; Next track button. Get position in TMSF format:
		invoke	mciSendString, ADDR tGetPos, ADDR Buffer,127 ,0
		
		; Convert TMSF string to CDPOSITION struct:
		invoke	GetPositionFromString, ADDR Buffer, ADDR TempPos
		
		; Set next track number:
		inc		TempPos.Track
		
		; Setup command to seek to a position:
		invoke	wsprintf, ADDR Buffer, ADDR FormatSeekTMSF, TempPos.Track,0,0,0
		
		; Send the mci command:
		invoke	mciSendString, ADDR Buffer, 0, 0, 0
		
		; Play track:
		invoke	mciSendString, ADDR tPlayCD,0,0,0
		
	.ELSEIF	eax==LCDBUTTON_PREVTRACK
		
		; Previous track button. Get current position in TMSF format:
		invoke	mciSendString, ADDR tGetPos, ADDR Buffer,127 ,0
		
		; Convert TMSF format into CDPOSITION struct:
		invoke	GetPositionFromString, ADDR Buffer, ADDR TempPos
		
		; If current track is not the first track, decrease track number:
		xor		ecx, ecx
		mov		cl, TempPos.Track
		.IF		ecx!=1
			dec		ecx
			
			; Setup seek command for new track position:
			invoke	wsprintf, ADDR Buffer, ADDR FormatSeekTMSF, ecx,0,0,0
			
			; Send mci command:
			invoke	mciSendString, ADDR Buffer, 0, 0, 0
			
			; Play track:
			invoke	mciSendString, ADDR tPlayCD,0,0,0
		.ENDIF
		
	.ELSEIF	eax==LCDBUTTON_PLAY
		
		; Send mci play command:
		invoke	mciSendString, ADDR tPlayCD,0,0,0
		
	.ELSEIF	eax==LCDBUTTON_STOP
	
		; Send mci stop command:
		invoke	mciSendString, ADDR tStopCD,0,0,0
		
	.ENDIF
	xor		eax, eax
.ELSEIF eax==WM_DESTROY
	; Kill timer:
	invoke	KillTimer, hWnd, MAINTIMERID
	
	; Delete all DCs and buffers:
	invoke	DeleteDC, hBackDC
	invoke	DeleteObject, hBackBmp
	invoke	DeleteDC, hLabelDC
	invoke	DeleteObject, hLabelBmp
	invoke	DeleteDC, hLCDDC
	invoke	DeleteObject, hLCDBitmap
	
	; Post quit message:
	invoke 	PostQuitMessage, NULL

.ELSEIF eax==WM_NCHITTEST  
	; This handler is a little trick to make moving the window easy.
	
	; First get mouse position in client coordinates:
	mov		eax, lParam
	mov		ecx, eax
	shr		ecx, 16		; ecx = Y
	and		eax, 0ffffh	; eax = X
	mov		MousePos.x, eax
	mov		MousePos.y, ecx
	invoke	ScreenToClient, hWnd, ADDR MousePos
	
	; Check if mouse is on a button:
	invoke	CheckForButton, MousePos.x, MousePos.y
	
	; If not, return HTCAPTION, which will make windows think you are clicking on
	; the window caption (and thus moving the window)
	.IF		eax==0
		mov		eax, HTCAPTION	
	.ELSE
	; Else, do not process the message (so that the button handler is called):
		invoke DefWindowProc, hWnd, uMsg, wParam, lParam
	.ENDIF
.ELSEIF eax==WM_PAINT
	; Start painting:
	invoke	BeginPaint, hWnd, ADDR ps
	mov		hDC, eax
	
	; Draw the LCD on the backbuffer:
	invoke	DrawLCD
	
	; Draw the backbuffer onto the main window:
	invoke	BitBlt, hDC,0,0,WINDOW_WIDTH, WINDOW_HEIGHT, hBackDC, 0,0, SRCCOPY
	
	; Stop painting:
	invoke	EndPaint, hWnd, ADDR ps
.ELSE
	invoke DefWindowProc, hWnd, uMsg, wParam, lParam
.ENDIF
ret 
WndProc endp

CreateLCD		proc	uses edi esi ebx hWnd:DWORD
LOCAL	hDC:DWORD

	; Get DC of main window to create compatible DCs:
	invoke	GetDC, hWnd
	mov		hDC, eax
	
	; Create DC for LCD (background & text):
	invoke	CreateCompatibleDC, hDC
	mov		hLCDDC, eax
	
	; Create a bitmap for the LCD. lpLCDBmp is a dword that will hold a pointer
	; to the raw bitmap data (8-bit per pixel). This pointer is used to draw the
	; LCD.
	invoke	CreateDIBSection, hDC, ADDR LCDBITMAPINFO, DIB_RGB_COLORS, ADDR lpLCDBmp,\
				NULL, NULL
	mov		hLCDBitmap, eax
	
	; Select bitmap into DC
	invoke	SelectObject, hLCDDC, hLCDBitmap
	
	; Create overlay label DC & Bitmap (for the bitmap in the resource file)
	invoke	CreateCompatibleDC, hDC
	mov		hLabelDC, eax
	invoke	LoadBitmap, hInstance, PRINTED_TEXT_BITMAP
	mov		hLabelBmp, eax
	invoke	SelectObject, hLabelDC, hLabelBmp
	
	; Create backbuffer:
	invoke	CreateCompatibleDC, hDC
	mov		hBackDC, eax
	invoke	CreateCompatibleBitmap, hDC, ALIGNED_WIDTH, WINDOW_HEIGHT
	mov		hBackBmp, eax
	invoke	SelectObject, hBackDC, hBackBmp
	
	; Release main window DC
	invoke	ReleaseDC, hWnd, hDC
	
	; Draw LCD for the first time
	invoke	DrawLCD
ret
CreateLCD		endp

DrawLCD	proc uses edi esi ebx
	; --- draw background ---
	; The background is drawn by randomly drawing pixels with color
	; indexes 0-6. Note that this is done every time the LCD is drawn.
	; But because of the fixed randomseed used, the (pseudo)random 
	; function will always draw the same pixels and thus always keeping 
	; the background the same. 
	mov		RandSeed, RANDOMSEED
	xor		ebx, ebx
	
	mov		ecx, lpLCDBmp 	;ecx points to raw bitmap data
	xor		edi, edi
	.WHILE	edi<WINDOW_HEIGHT
		xor		esi, esi
		.WHILE	esi<ALIGNED_WIDTH
			invoke	PseudoRandom
			mov		[ecx+ebx], al		;add random pixel
		inc	ebx
		inc	esi
		.ENDW
	inc		edi
	.ENDW
	
	; --- Draw the different LCD texts ---
	invoke	DrawLCDText, 10,10,LCDTEXTSIZE_BIG, ADDR tTrackText
	invoke	DrawLCDText, 65,10,LCDTEXTSIZE_BIG, ADDR tMinuteText
	invoke	DrawLCDText, 65+40,10,LCDTEXTSIZE_BIG, ADDR tCollon
	invoke	DrawLCDText, 65+60,10,LCDTEXTSIZE_BIG, ADDR tSecondsText
	
	invoke	DrawLCDText, 6,38, LCDTEXTSIZE_SMALL, ADDR tSmallText1
	invoke	DrawLCDText, 6,48, LCDTEXTSIZE_SMALL, ADDR tSmallText2
	
	; --- Blit the drawn LCD onto the back buffer ---
	invoke	BitBlt, hBackDC,0,0,ALIGNED_WIDTH, WINDOW_HEIGHT, hLCDDC, 0,0, SRCCOPY
	
	; --- Blit the monochrome label onto the back buffer ---
	invoke	BitBlt, hBackDC,0,0,ALIGNED_WIDTH, WINDOW_HEIGHT, hLabelDC, 0, 0, SRCAND	
ret
DrawLCD endp

CreateLCDColors	proc uses ebx
	; This function simply copies the darker version of the colors 0-6 in 
	; the palette to colors 7-13. SHADOWDARKNESS determines the darkness
	; of the shadow.
	
	xor		ecx, ecx
	mov		edx, offset LCDBaseColors
	mov		ebx, edx						;ebx points to first background color
	add		edx, COLORBASE_SHADOW*4			;edx points to first shadow color
	; loop for every color index
	.WHILE	ecx<BASECOLORCOUNT*4
		; read color:
		mov		al, [ebx+ecx]
		
		; darken color:
		.IF		al<SHADOWDARKNESS
			xor		al, al
		.ELSE
			sub		al, SHADOWDARKNESS
		.ENDIF
		
		; put darkened color:
		mov		[edx+ecx], al
	inc	ecx
	.ENDW
ret
CreateLCDColors	endp


PseudoRandom	proc uses ecx
	  mov 	eax, 7
	  push 	edx
	  imul 	edx,RandSeed,08088405H
	  inc 	edx
	  mov 	RandSeed, edx
	  mul 	edx
	  mov 	eax, edx
	  pop 	edx
	  ret
ret
PseudoRandom	endp

DrawLCDText	proc	uses esi edi ebx dwX:DWORD, dwY:DWORD, dwSize:DWORD, lpText:DWORD
	; This procedure reads a null-terminated string character for character and
	; looks each char up in the LCDChars table. When found, it displays the character
	; and proceeds to the next. dwX and dwY are the start coordinates (left-top).
	; dwSize can be LCDTEXTSIZE_SMALL or LCDTEXTSIZE_BIG (small or big characters).
	; lpText is the pointer to the string.
	
	mov		esi, lpText
	xor		edi, edi
	.WHILE	TRUE
		; get one char:
		xor		eax, eax
		mov		al, [esi]
		inc		esi
		
		; stop if 0 terminator found:
		.BREAK .IF al==0
		
		; --- Map character into LCDChars (ascii -> LCDChars index) ---
		.IF		al>="0" && al<="9"
			sub		al, "0"
		.ELSEIF	al>="A" && al<="Z"
			sub		al, ("A"-10)
		.ELSEIF	al>="a" && al<="z"
			sub		al, ("a"-10)
		.ELSEIF	al=="."
			mov		al, 36
		.ELSEIF	al==","
			mov		al, 37
		.ELSEIF	al==":"
			mov		al, 38
		.ELSEIF	al=="("
			mov		al, 39
		.ELSEIF	al==")"
			mov		al, 40
		.ELSEIF	al=="="
			mov		al, 41
		.ELSEIF	al=="-"
			mov		al, 42
		.ELSEIF al=="©"
			mov		al, 43
		.ELSEIF	al==" "
			jmp	@nextchar
		.ELSE
			jmp	@nextchar
		.ENDIF
		
		; --- draw char ---
		mov		edx, dwX
		add		edx, edi
		.IF		dwSize==LCDTEXTSIZE_SMALL
			invoke	DrawSmallChar, edx, dwY, eax 	;draw one small char
		.ELSEIF	dwSize==LCDTEXTSIZE_BIG
			invoke	DrawChar, edx, dwY, eax 		;draw one big char
		.ENDIF
		
		@nextchar:
		.IF		dwSize==LCDTEXTSIZE_SMALL
			add		edi, 8							;small char takes 8 pixels
		.ELSEIF	dwSize==LCDTEXTSIZE_BIG
			add		edi, 22							;big char takes 22 pixels
		.ENDIF
	.ENDW

ret
DrawLCDText	endp
	
DrawChar	proc	uses esi edi ebx dwX:DWORD, dwY:DWORD, iChar:DWORD
LOCAL	tX:DWORD
LOCAL	tY:DWORD
	; This procedure draws one character at (dwX, dwY). iChar indentifies the
	; character by index in the LCDChars list.
	
	; Create byte index from character index (multiply by 7, each char takes 7 bytes)
	mov		esi, iChar
	shl		esi, 3		;iChar * 8
	sub		esi, iChar	;iChar * 8 - iChar = iChar * 7
	
	; Add base address of LCDChars array
	add		esi, offset LCDChars 
	
	; ebx is the row counter:
	xor		ebx, ebx
	.WHILE	ebx<7				; 7 rows for each character
		
		; edi is the column counter (each bit is one columnn)
		xor		edi, edi
		mov		dl, [esi]
		; dl holds bits for current row
		.WHILE	edi<6				;process 6 bits (6 columns for each char)
			shl		dl, 1			;get next bit
			.IF CARRY?				;if bit set (carry set), draw pixel:
			
				; A big char pixel consists of a 2x2 pixel shadow and a 2x2 pixel black
				; block. The pixels are seperated one pixel of each other.
				; So the calculations are:
				; xPixel = column * 3	(each pixel takes 2 pixels and one spacing pixel)
				; yPixel = row * 3		(same here)
				
				; The shadow is shifted two pixels to the right and to the bottom:
				; xShadow = column * 3 + 2
				; yShadow = row * 3 + 2
				
				push	edx			;save edx
			
				mov		eax, ebx	;eax = row
				shl		eax, 1		;eax = row * 2
				add		eax, ebx	;eax = row * 2 + row = row * 3
				mov		edx, edi	;edx = column
				shl		edx, 1		;edx = column * 2
				add		edx, edi	;edx = column * 2 + column = column * 3
				add		eax, dwY	;eax = dwY + row * 3
				mov		tY, eax		;tY  = edx
				add		edx, dwX	;edx = dwX + column * 3
				mov		tX, edx		;tX  = edx
				mov		ecx, edx	;ecx = edx
				add		eax, 2		;eax = row * 3 + 2			
				add		ecx, 2		;ecx = column * 3 + 2
				SHADOW2X2	ecx, eax ;draw 2x2pixel shadow at (ecx,eax)
				PLOT2X2 tX, tY, COLORINDEX_BLACK	;paint 2x2 pixel at (tX,tY)
				pop		edx			;pop saved edx
					
			.ENDIF
			.IF		dl==0
				.BREAK
			.ENDIF
		inc	edi
		.ENDW
	inc	esi
	inc	ebx
	.ENDW
ret
DrawChar	endp

DrawSmallChar	proc	uses esi edi ebx dwX:DWORD, dwY:DWORD, iChar:DWORD
LOCAL	tX:DWORD
LOCAL	tY:DWORD
	; This procedure draws one character at (dwX, dwY). iChar indentifies the
	; character by index in the LCDChars list.
	
	; Create byte index from character index (multiply by 7, each char takes 7 bytes)
	mov		esi, iChar
	shl		esi, 3		;iChar * 8
	sub		esi, iChar	;iChar * 8 - iChar = iChar * 7
	
	; Add base address of LCDChars array
	add		esi, offset LCDChars 
	
	; ebx is the row counter:
	xor		ebx, ebx
	.WHILE	ebx<7				; 7 rows for each character
		
		; edi is the column counter (each bit is one columnn)
		xor		edi, edi
		mov		dl, [esi]
		; dl holds bits for current row
		.WHILE	edi<6				;process 6 bits (6 columns for each char)
			shl		dl, 1			;get next bit
			.IF CARRY?				;if bit set (carry set), draw pixel:
			
				; A small char pixel consists of a shadow pixel and a black pixel.
				; The calculations are simple here:
				; xPixel = column 
				; yPixel = row 
				
				; The shadow is shifted two pixels to the right and to the bottom:
				; xShadow = column + 2
				; yShadow = row + 2
				
				push	edx			;save edx
			
				mov		eax, ebx	;eax = row
				mov		ecx, edi	;ecx = column
				add		ecx, dwX	;add X offset
				add		eax, dwY	;add Y offset
				mov		tX, ecx
				mov		tY, eax
				add		eax, 2		;eax = row + 2
				add		ecx, 2		;ecx = column + 2
				SHADOWPIXEL	ecx, eax ;draw shadow pixel at (ecx, eax)
				PLOTPIXEL tX, tY, COLORINDEX_BLACK	;paint black pixel at (tX,tY)
				pop		edx			;pop saved edx
					
			.ENDIF
			.IF		dl==0
				.BREAK
			.ENDIF
		inc	edi
		.ENDW
	inc	esi
	inc	ebx
	.ENDW
ret
DrawSmallChar	endp


GetPositionFromString	proc uses esi edi  lpString:DWORD,lpPosition:DWORD
	; Function to convert TMSF string to CDPOSITION structure.
	mov	edi, lpPosition
	assume	edi:ptr CDPOSITION
	mov		esi, lpString
	invoke	GetNextNumberFromTime
	mov		[edi].Track, al
	invoke	GetNextNumberFromTime
	mov		[edi].Minute, al
	invoke	GetNextNumberFromTime
	mov		[edi].Second, al
	invoke	GetNextNumberFromTime
	mov		[edi].Frame, al
ret
GetPositionFromString	endp

GetNextNumberFromTime	proc
	; This function returns the next number in a TMSF string. Note that
	; this procedure uses registers as parameters (esi points to the string).
	; It is used in GetPositionString.
	mov		ecx, 10
	xor		eax, eax
	xor		edx, edx
	.WHILE	TRUE
		mov		dl, [esi]
		; Check if end of string or collon detected:
		.IF		dl==0
			.BREAK
		.ELSEIF	dl==":"
			inc	esi
			.BREAK
		.ENDIF
		; convert 2 digit string to number:
		push	edx
		mul		ecx
		pop		edx
		sub		dl, "0"
		add		eax, edx
		inc		esi
	.ENDW
ret
GetNextNumberFromTime endp


CheckForButton	proc 	dwX:DWORD, dwY:DWORD
	; A simple serie of checks to see if a user clicked on a button.
	; Each PtInRect call checks if the click coordinates (dwX, dwY) is
	; in the region of a button. If yes, it returns the appropriate 
	; LCDBUTTON_?? value, otherwise it returns 0.
	
	invoke	PtInRect, ADDR ButtonNextTrack, dwX, dwY 
	.IF		eax!=0
		mov		eax, LCDBUTTON_NEXTTRACK
		ret
	.ENDIF
	invoke	PtInRect, ADDR ButtonPrevTrack, dwX, dwY 
	.IF		eax!=0
		mov		eax, LCDBUTTON_PREVTRACK
		ret
	.ENDIF
	invoke	PtInRect, ADDR ButtonPlay, dwX, dwY
	.IF		eax!=0
		mov		eax, LCDBUTTON_PLAY
		ret
	.ENDIF
	invoke	PtInRect, ADDR ButtonStop, dwX, dwY
	.IF		eax!=0
		mov		eax, LCDBUTTON_STOP
		ret
	.ENDIF

xor		eax, eax
ret
CheckForButton 	endp
end start

