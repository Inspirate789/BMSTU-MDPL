; Resource ID of overlay bitmap
PRINTED_TEXT_BITMAP	equ		800

; LCD text size styles
LCDTEXTSIZE_SMALL	equ		0
LCDTEXTSIZE_BIG		equ		1

; Button constants
LCDBUTTON_PREVTRACK	equ		20
LCDBUTTON_NEXTTRACK	equ		21
LCDBUTTON_VOLUMEPLUS equ	22
LCDBUTTON_VOLUMEMIN equ		23
LCDBUTTON_PLAY		equ		24
LCDBUTTON_STOP		equ		25

; CD Position structure
CDPOSITION	STRUCT
	Track	db	?
	Minute	db	?
	Second	db	?
	Frame	db	?
CDPOSITION	ENDS

; Main timer ID:
MAINTIMERID		equ		3748h

;-----------------------------------------------------------------------------
; Main window width & height 
;-----------------------------------------------------------------------------

; NOTE: WINDOW_WIDTH is the width of the actual window. This can be anything
;		as long as it's less than ALIGNED_WIDTH.
;		ALIGNED_WIDTH is the window size rounded up to the next power of 2.
;		This is done so the macros PLOTPIXEL etc can use a shift instead
;		of a mul, which is a lot faster. WIDTH_SHIFT_OFFSET is the power of
;		2 used for ALIGNED_WIDTH
;		(WIDTH_SHIFT_OFFSET = log(ALIGNED_WIDTH) / log(2))
;		WINDOW_HEIGHT can be anything.
;

WINDOW_WIDTH		equ		256 ; Can be anything less than ALIGNED_WIDTH
ALIGNED_WIDTH		equ		256 ; window width aligned to next power of 2
WIDTH_SHIFT_OFFSET	equ		8   ; = log(ALIGNED_WIDTH) / log(2)
WINDOW_HEIGHT		equ		60

; The plotpixel macro plots one pixel at (X,Y) with color COLOR onto the
; LCD bitmap. Note that X and Y may not be edx.
PLOTPIXEL	MACRO X:REQ, Y:REQ, COLOR:REQ
	; get Y coordinate
	mov		edx, Y
	
	; shift left WIDTH_SHIFT_OFFSET times,
	; which is the same as multiplying width ALIGNED_WIDTH
	shl		edx, WIDTH_SHIFT_OFFSET
	
	; add X coordinate
	add		edx, X
	
	; edx is now an offset for the pixel at X,Y. add base offset:
	add		edx, lpLCDBmp
	
	; save color:
	mov		byte ptr [edx], COLOR
ENDM

; Same as PLOTPIXEL, but for a 2x2 pixel block.
; Here too,  X and Y may not be edx.
PLOT2X2	MACRO X:REQ, Y:REQ, COLOR:REQ
	; get Y coordinate
	mov		edx, Y
	
	; shift left WIDTH_SHIFT_OFFSET times,
	; which is the same as multiplying width ALIGNED_WIDTH
	shl		edx, WIDTH_SHIFT_OFFSET
	
	; add X coordinate
	add		edx, X
	
	; edx is now an offset for the pixel at X,Y. add base offset:
	add		edx, lpLCDBmp
	
	; put color at (X,Y) and (X+1,Y)
	mov		word ptr [edx], COLOR SHL 8 + COLOR
	
	; put color at (X,Y+1) and (X+1,Y+1):
	mov		word ptr [edx+ALIGNED_WIDTH], COLOR SHL 8 + COLOR
ENDM

; Shadow pixel darkens a specific pixel by adding 7 to it's color index
; (this is a shift from the normal background colors to the shadow background
;  colors). When a pixel is already in shadowed state, it is left unchanged
SHADOWPIXEL	MACRO X:REQ, Y:REQ
	; get Y coordinate
	mov		edx, Y
	
	; shift left WIDTH_SHIFT_OFFSET times,
	; which is the same as multiplying width ALIGNED_WIDTH
	shl		edx, WIDTH_SHIFT_OFFSET
	
	; add X coordinate
	add		edx, X
	
	; add base offset:
	add		edx, lpLCDBmp
	
	; get pixel
	mov		al, [edx]
	
	; see if color index > 6 which means it's already a shadow color
	cmp		al, 6
	ja		@F
	
	; if not, add 7 to the color index to make it a shadow color
	add		al, 7
	
	; put new pixel
	mov		[edx], al
	@@:
ENDM

; same as shadowpixel, but for a 2x2 pixel block
; X and Y may not be edx.
SHADOW2X2	MACRO X:REQ, Y:REQ
	; get Y coordinate
	mov		edx, Y
	
	; shift left WIDTH_SHIFT_OFFSET times,
	; which is the same as multiplying width ALIGNED_WIDTH
	shl		edx, WIDTH_SHIFT_OFFSET
	
	; add X coordinate
	add		edx, X
	
	; add base offset:
	add		edx, lpLCDBmp
	
	; Check for each pixel if it's already a shadow color (index>6). If not,
	; add 7 to make it a shadow color (see also shadowpixel):
	
	; Shadow (x,y):
	mov		al, [edx]
	cmp		al, 6
	ja		@F
	add		al, 7
	mov		[edx], al
	@@:
	
	; Shadow (x+1,y):
	mov		al, [edx+1]
	cmp		al, 6
	ja		@F
	add		al, 7
	mov		[edx+1], al
	@@:
	
	; Shadow (x,y+1):
	mov		al, [edx+ALIGNED_WIDTH]
	cmp		al, 6
	ja		@F
	add		al, 7
	mov		[edx+ALIGNED_WIDTH], al
	@@:
	
	; Shadow (x+1,y+1):
	mov		al, [edx+ALIGNED_WIDTH+1]
	cmp		al, 6
	ja		@F
	add		al, 7
	mov		[edx+ALIGNED_WIDTH+1], al
	@@:
ENDM