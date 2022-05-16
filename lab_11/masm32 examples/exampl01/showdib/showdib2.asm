; ###########################################################################
;
;   This file was written by Ron Thomas and is included in MASM32 with his
;   permission. It is an advanced program that builds differently to the
;   normal setup in MASM32. To build this program, run MAKE.BAT from this
;   directory. It uses 2 seperate asm files that are seperately built into
;   object modules and then linked together. The MAKE.BAT file has the
;   normal syntax for doing this.
;
; ###########################################################################

;	ShowDib2 - Shows a DIB in the client area; based on Petzolds "C" version 

;	1. Bitmap files are selected via a dialog and images may be cut to the clipboad
;	   for pasting into another program.

;	2. Bmp images can be saved to a file
	
; 	3. Bmp images can be printed
  
;	4. The image can be sized to fit the window, be stretched or displayed isotropically

;		by	Ron Thomas
 	
;	Ron_Thom@Compuserve.com 21/11/99	
;---------------------------------------------

.386                    ; 32 bit when .386 appears before .MODEL
.MODEL FLAT,STDCALL
option casemap :none    ; case sensitive

include \masm32\include\windows.inc

include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\gdi32.inc
include \masm32\include\comdlg32.inc

includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\gdi32.lib
includelib \masm32\lib\comdlg32.lib
		
WinMain		PROTO :DWORD, :DWORD, :DWORD, :SDWORD

DibFileInitialize PROTO :DWORD
DibFileOpenDlg	  PROTO :DWORD, :DWORD, :DWORD
DibFileSaveDlg	  PROTO :DWORD, :DWORD, :DWORD
DibLoadImage	  PROTO :DWORD
DibSaveImage	  PROTO :DWORD, :DWORD
;CopyMemory	  PROTO :DWORD, :DWORD, :DWORD
    	
.data

IDM_FILE_OPEN		EQU	40001
IDM_SHOW_NORMAL 	EQU	40002
IDM_SHOW_CENTRE		EQU	40003
IDM_SHOW_STRETCH 	EQU	40004
IDM_SHOW_ISOSTRETCH 	EQU	40005
IDM_FILE_PRINT		EQU	40006
IDM_EDIT_COPY		EQU	40007
IDM_EDIT_CUT		EQU	40008
IDM_EDIT_DELETE		EQU	40009
IDM_FILE_SAVE		EQU	40010

Flags			EQU 	PD_RETURNDC or PD_NOPAGENUMS or PD_NOSELECTION

doci	DOCINFO	   <sizeof DOCINFO,offset byte ptr PrintTitle>
pd	PRINTDLG   <sizeof PRINTDLG-2,,0,0,0,Flags,0,0,0,0,1,0,0,0,0,0,0,0,0>

iModeNum	DD	0
wShow		DD	IDM_SHOW_NORMAL
	
ClassName	db "SimpleWinClass",0
szAppName	db "ShowDib2",0
helpnotimpl	db "Help not yet implemented !",0
CantgetDC	db "Cannot obtain printer DC",0
Cantload	db "Cannot load DIB file",0
CantPrintBMP	db "Printer cannot print bitmaps",0
Cantsave	db "Cannot save DIB file",0 
NotEnoughMem	db "Not enough memory to create bitmap !",0
PrintTitle	db "ShowDib2: Printing",0

.data?

PUBLIC	hMemory

ofn   OPENFILENAME <>
	
hInstance	HINSTANCE ?
CommandLine	LPSTR	?
hdcMem		HDC	?
hBitMap		HBITMAP ?

cxClient	DD	?		; Screen size
cyClient	DD	?		;
cxDib		DD	?
cyDib		DD	?
cxBitMap	DD	?		; Width
cyBitMap	DD	?		; Height
pBits		DD	?
hAccel		DD	?
hTBWnd		DD	?
pbmfh		DD	?		; Pointer to BITMAPFILEHEADER structure in memory
pbmi		DD	?		; Pointer to BITMAPINFO		"	"	" 
hMemory		DD	?		 

	
szFileName	db	MAX_PATH DUP (?)
szTitleName	db	MAX_PATH DUP (?)
	
.const

;MACROS

LOWORD	MACRO 	bigword	;; Retrieves the low word from double word argument

	mov	eax,bigword
	and	eax,0FFFFh	;; Set to low word 
	ENDM

HIWORD	MACRO   bigword	;; Retrieves the high word from double word argument

	mov	ebx,bigword
	shr	ebx,16		;; Shift 16 for high word to set to high word
				
	ENDM
;----------------------------------------------------------------------------
.code
start:
	invoke GetModuleHandle, NULL
	mov    hInstance,eax
	invoke GetCommandLine
        invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT
	invoke ExitProcess,eax

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:SDWORD

	LOCAL wc:WNDCLASSEX, msg:MSG, hwnd:HWND

	mov   wc.lpszClassName, OFFSET ClassName
 	push  hInstance
        pop   wc.hInstance
	mov   wc.lpfnWndProc, OFFSET WndProc
	invoke LoadCursor,NULL,IDC_ARROW
	mov   wc.hCursor,eax
 	mov   wc.hIcon,0
 	mov   wc.hIconSm,0
	mov   wc.lpszMenuName,offset szAppName
	mov   wc.hbrBackground,COLOR_WINDOW+1 
	mov   wc.style, CS_HREDRAW or CS_VREDRAW
	mov   wc.cbSize,SIZEOF WNDCLASSEX
	mov   wc.cbClsExtra,NULL
	mov   wc.cbWndExtra,NULL
       
        invoke RegisterClassEx, addr wc
	.IF	!eax
	    ret
	.ENDIF

        INVOKE CreateWindowEx,NULL,ADDR ClassName,ADDR szAppName,\
           WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\
           CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,NULL,NULL,\
           hInst,NULL
        mov   hwnd,eax

        invoke ShowWindow, hwnd,CmdShow
        invoke UpdateWindow, hwnd

	invoke	LoadAccelerators, hInst, ADDR szAppName
	mov	hAccel,eax

        .WHILE TRUE
                invoke GetMessage, ADDR msg, 0,0,0
		.BREAK .IF (!eax)
		invoke TranslateAccelerator, hwnd, hAccel, ADDR msg

                .IF	!eax
		    invoke TranslateMessage, ADDR msg
                    invoke DispatchMessage, ADDR msg
		.ENDIF
        .ENDW

        mov     eax,msg.wParam
        ret
WinMain endp

ShowDib	proc	hdc:HDC, _pbmi:DWORD, _pBits:DWORD, _cxDib:DWORD, _cyDib:DWORD, \
		_cxClient:DWORD, _cyClient:DWORD, _wShow:DWORD

	mov	eax,_wShow

	.IF	eax==IDM_SHOW_NORMAL

	    invoke  SetDIBitsToDevice, hdc, 0,0, _cxDib, _cyDib, 0,0,0, _cyDib, pBits, \
				      _pbmi, DIB_RGB_COLORS
	    ret   	
	.ELSEIF eax==IDM_SHOW_CENTRE

	    mov	eax, _cxClient
	    sub eax, _cxDib
	    shr eax,1			; (cxClient-cxDib)/2
	    mov ecx, _cyClient
	    sub ecx, _cyDib
	    shr ecx,1			; (cyClient-cyDib)/2	

	    invoke  SetDIBitsToDevice, hdc, eax, ecx,_cxDib,_cyDib, 0,0,0, _cyDib, pBits, \
				      _pbmi, DIB_RGB_COLORS
	    ret
	.ELSEIF eax==IDM_SHOW_STRETCH

	    invoke  SetStretchBltMode, hdc, COLORONCOLOR 
	    invoke  StretchDIBits, hdc, 0,0, _cxClient, _cyClient, 0,0,_cxDib,_cyDib, \
				     _pBits, _pbmi, DIB_RGB_COLORS, SRCCOPY
  	    ret
	.ELSEIF eax==IDM_SHOW_ISOSTRETCH

	    invoke  SetStretchBltMode, hdc, COLORONCOLOR
  	    invoke  SetMapMode, hdc, MM_ISOTROPIC
	    invoke  SetWindowExtEx, hdc, _cxDib, _cyDib, 0
	    invoke  SetViewportExtEx, hdc, _cxClient, _cyClient, 0

	    mov	    eax,_cxDib			; Get cxDib/2 and cyDib/2
	    shr	    eax,1			;
	    mov	    ecx,_cyDib			;
	    shr	    ecx,1			;
 
	    invoke  SetWindowOrgEx, hdc, eax, ecx, 0

	    mov	    eax,_cxClient		; Get cxClient/2 and cyClient/2
	    shr	    eax,1			;
	    mov	    ecx,_cyClient		;
	    shr	    ecx,1			;

	    invoke  SetViewportOrgEx, hdc, eax, ecx, 0
	    invoke  StretchDIBits, hdc, 0,0, _cxDib,_cyDib, 0,0,_cxDib,_cyDib, \
				   _pBits, _pbmi, DIB_RGB_COLORS, SRCCOPY
	    ret
	.ENDIF

	ret
ShowDib endp

CopyMemory proc uses esi edi, Dest:DWORD, Source:DWORD, mlength:DWORD

; 	This routine is provided in place of Visual C's CopyMemory
;	----------------------------------------------------------

;	It could be developed a little more to move data faster as double words (movsd)
;	but possibly needs checking to ensure we copy the exact number of bytes
;	in the bitmap; this could be an odd number and a possible solution is to
;	copy as many Dwords as possible 1st then any remaining word or byte.
;	Leave this upgrade until later.
     	
	cld				; Work upwards

	mov	esi, Source		; Source address
	mov	edi, Dest		; Destination address
	mov	ecx, mlength		; Get size in bytes
	shr	ecx, 1			; Convert to words   

	rep	movsw			; repeat copy util all done
	ret

CopyMemory endp

WndProc proc uses ebx esi, hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

LOCAL bSuccess:DWORD, hdc:HDC, ps:PAINTSTRUCT, hdcPrn:HDC, hGlobal:DWORD, hMenu:DWORD
LOCAL cxPage:DWORD, cyPage:DWORD, iEnable:DWORD, pGlobal:DWORD
      
	mov   eax,uMsg

	.IF eax==WM_CREATE

	    invoke DibFileInitialize, hWnd
	    mov	eax,0
	    ret

	.ELSEIF eax==WM_SIZE
	
	    LOWORD  lParam
	    mov	cxClient,eax
	    HIWORD  lParam
	    mov	cyClient,ebx
	    mov	eax,0
	    ret

	.ELSEIF eax==WM_INITMENUPOPUP

	    invoke GetMenu, hWnd
	    mov hMenu, eax	

	    .IF pbmfh
	 	mov  iEnable, MF_ENABLED
	    .ELSE
		mov  iEnable, MF_GRAYED
	    .ENDIF
	    
	    invoke EnableMenuItem, hMenu, IDM_FILE_SAVE, iEnable
	    invoke EnableMenuItem, hMenu, IDM_FILE_PRINT, iEnable
	    invoke EnableMenuItem, hMenu, IDM_EDIT_CUT, iEnable
	    invoke EnableMenuItem, hMenu, IDM_EDIT_COPY, iEnable
	    invoke EnableMenuItem, hMenu, IDM_EDIT_DELETE, iEnable
	    
	    mov	eax,0
	    ret

	.ELSEIF eax==WM_COMMAND

	    invoke GetMenu, hWnd
	    mov	hMenu, eax
           
	    LOWORD wParam

	    .IF eax==IDM_FILE_OPEN		; Show the File Open dialog box

		invoke DibFileOpenDlg, hWnd, ADDR szFileName, ADDR szTitleName	;Open DIB dialog
		
	        .IF	!eax
		    mov  eax,0
		    ret
	        .ENDIF

	        .IF pbmfh			; If there's an existing DIB, free the memory 

		    invoke   GlobalUnlock, pbmfh
                    invoke   GlobalFree, hMemory
    
	        .ENDIF
		
;	Load entire DIB into memory
;	---------------------------

		invoke LoadCursor, 0, IDC_WAIT
		invoke SetCursor, eax
		invoke ShowCursor, TRUE 

		invoke DibLoadImage, ADDR szFileName		; Pointer to allocated
	        mov pbmfh, eax					; memory for BITMAPFILEHEADER
		mov  ebx,eax
 			
		invoke ShowCursor, FALSE

		invoke LoadCursor, 0, IDC_ARROW 
		invoke SetCursor, eax

		invoke InvalidateRect, hWnd, NULL, TRUE	;Invalidate client area for later update

	        .IF	pbmfh==NULL			; If NULL put out "Can't load" message

		    invoke MessageBox, hWnd, ADDR Cantload, ADDR szAppName, 0
	            mov eax, MB_ICONEXCLAMATION or MB_OK
		    ret
	       .ENDIF

;	Get pointers to the info structure & the bits
;	---------------------------------------------

	        mov	eax, sizeof BITMAPFILEHEADER	; BITMAPINFO immediately follows
		add	eax,ebx				; the header (pointed to by ebx)
		mov	pbmi,eax			; Points to bitmap information
		mov	esi,eax				; save to reg as well
	    
	        mov     eax,BITMAPFILEHEADER.bfOffBits[ebx]; offset from BMFH struct to pix bits
	        add	eax,ebx
	        mov	pBits,eax		; This is a pointer to the actual DIB pixel bits 
	
;	Get the DIB width & height
;	--------------------------

	       .IF  BITMAPINFO.bmiHeader.biSize[esi]== sizeof BITMAPCOREHEADER
								; width & height are WORDs
		    xor	eax,eax					; Make sure we clear high word
		    mov ax, BITMAPCOREHEADER.bcWidth[esi]	; Width of bitmap
		    mov cxDib, eax
		    mov ax, BITMAPCOREHEADER.bcHeight[esi]	; Height
		    mov cyDib, eax
	       .ELSE						; width & heght are DWORDs

		    xor	eax,eax					; Make sure we clear high word
		    mov eax, BITMAPINFO.bmiHeader.biWidth[esi]
		    mov cxDib, eax
		    mov eax, BITMAPINFO.bmiHeader.biHeight[esi]
			
 		    .IF eax < 1
			neg eax					; Get abs value
		    .ENDIF	

		    mov cyDib, eax			
	       .ENDIF

 		mov eax,0		    								
    		ret

	    .ELSEIF eax==IDM_FILE_SAVE

;	Show the File Save dialog
;	-------------------------

		invoke DibFileSaveDlg, hWnd, ADDR szFileName, ADDR szTitleName

		.IF !eax
		    mov eax,0
		    ret
		.ENDIF

;	Save the DIB to a disk file
;	---------------------------

		invoke	LoadCursor, 0, IDC_WAIT		; Load cursor resource
		invoke  SetCursor, eax 			; Set cursor shape
		invoke  ShowCursor, TRUE

		invoke  DibSaveImage, ADDR szFileName, pbmfh	; Save image as DIB
		mov	bSuccess, eax

		invoke  ShowCursor, FALSE
		invoke  LoadCursor, 0, IDC_ARROW
		invoke  SetCursor, eax

		.IF !bSuccess
		    invoke MessageBox, hWnd, ADDR Cantsave, ADDR szAppName, \
					MB_ICONEXCLAMATION or MB_OK
		.ENDIF

		mov	eax,0
      		ret

	    .ELSEIF eax==IDM_FILE_PRINT

		.IF !pbmfh
		    mov eax,0
		    ret
		.ENDIF

;	Get printer DC
;	--------------
		mov	eax,hWnd
		mov	pd.hWndOwner,eax

		invoke PrintDlg, ADDR pd

		.IF !eax			; If not true
		    mov eax,0
		    ret 
		.ENDIF

		mov	eax, pd.hDC
		mov	hdcPrn, eax

		.IF !eax ;eax==NULL
		    invoke MessageBox, hWnd, ADDR CantgetDC, ADDR szAppName, \
				       MB_ICONEXCLAMATION or MB_OK
		    mov eax,0
		    ret
 	     	.ENDIF

;	Check if printer can print bitmaps
;	----------------------------------

		invoke GetDeviceCaps, hdcPrn, RASTERCAPS
		and eax,RC_BITBLT

		.IF !eax
		    invoke DeleteDC, hdcPrn
		    invoke MessageBox, hWnd, ADDR CantPrintBMP, ADDR szAppName, \
				       MB_ICONEXCLAMATION or MB_OK
		    mov	eax,0
		    ret
		.ENDIF

;	Get size of printable area for page
;	-----------------------------------
 	
		invoke GetDeviceCaps, hdcPrn, HORZRES
		mov    cxPage,eax	
		invoke GetDeviceCaps, hdcPrn, VERTRES
 	        mov    cyPage,eax

		mov    bSuccess,FALSE

;	Send the DIB to the printer
;	---------------------------

		invoke LoadCursor, NULL, IDC_WAIT
		invoke SetCursor, eax
		invoke ShowCursor, TRUE

		invoke StartDoc, hdcPrn, ADDR doci; Start the document
		push eax			; Save truth

		invoke StartPage, hdcPrn	; Start the page
		pop  ecx			; Recover truth
		
		.IF eax && ecx > 0		; If StartDoc & StartPage calls are OK

		    invoke ShowDib, hdcPrn, pbmi, pBits, cxDib, cyDib, \
				    cxPage, cyPage, wShow
		    invoke EndPage, hdcPrn

		    .IF eax > 0
        		mov bSuccess,  TRUE
			invoke EndDoc, hdcPrn
		    .ENDIF

		.ENDIF

		invoke ShowCursor, FALSE
		invoke LoadCursor, NULL, IDC_ARROW
		invoke SetCursor, eax
		invoke DeleteDC, hdcPrn

		.IF !bSuccess
		    invoke MessageBox, hWnd, ADDR CantPrintBMP, ADDR szAppName, \
				       MB_ICONEXCLAMATION or MB_OK 
		.ENDIF

		mov eax,0
		ret
 	  	
	    .ELSEIF eax==IDM_EDIT_COPY || eax==IDM_EDIT_CUT

		.IF !pbmfh
		    mov eax,0
		    ret
		.ENDIF

		mov ebx, pbmfh				; Reload with pointer to DIB
							; as ebx may have changed
;	Make copy of the packed DIB
;	---------------------------

		mov	eax, BITMAPFILEHEADER.bfSize[ebx]
		sub	eax, sizeof BITMAPFILEHEADER

		invoke GlobalAlloc, GHND or GMEM_SHARE, eax
		mov  hGlobal, eax	 

		invoke GlobalLock, hGlobal
		mov  pGlobal, eax			; Points at destination

		mov  eax, ebx				; Get the source address
		add  eax, sizeof BITMAPFILEHEADER	;

		mov  ecx, BITMAPFILEHEADER.bfSize[ebx]	; Get length
		sub  ecx, sizeof BITMAPFILEHEADER	;

		invoke CopyMemory, pGlobal, eax,   ecx
;                                   destn  source length                            				   	
		invoke GlobalUnlock, hGlobal

;	Transfer it to the clipboard
;	----------------------------

		invoke OpenClipboard, hWnd
		invoke EmptyClipboard
		invoke SetClipboardData, CF_DIB, hGlobal
		invoke CloseClipboard

		LOWORD wParam

		.IF eax==IDM_EDIT_COPY
		    mov eax,0
		    ret
		.ENDIF
		jmp Fallthr1				; Fall through		
  		 
           .ELSEIF eax==IDM_EDIT_DELETE

Fallthr1:	.IF pbmfh
	    	    invoke   GlobalUnlock, pbmfh
                    invoke   GlobalFree, hMemory    
		    invoke InvalidateRect, hWnd, NULL, TRUE
		.ENDIF
		mov eax,0
		ret
	
	    .ELSEIF eax==IDM_SHOW_NORMAL || eax==IDM_SHOW_CENTRE || \
		    eax==IDM_SHOW_STRETCH || eax==IDM_SHOW_ISOSTRETCH
			
		invoke CheckMenuItem, hMenu, wShow, MF_UNCHECKED
		
		LOWORD wParam
		mov	wShow, eax
		
		invoke CheckMenuItem, hMenu, wShow, MF_CHECKED
		invoke InvalidateRect, hWnd, NULL, TRUE
		mov eax,0
		ret
 
            .ENDIF
	
       .ELSEIF eax==WM_PAINT 	
	   
	    invoke BeginPaint,hWnd, ADDR ps
	    mov    hdc,eax
 	 

	    .IF pbmfh			
		invoke ShowDib, hdc, pbmi, pBits, cxDib, cyDib, cxClient, cyClient, wShow	    
	    .ENDIF

            invoke EndPaint, hWnd, ADDR ps

	    mov	eax,0
	    ret

	.ELSEIF eax==WM_DESTROY

	    .IF pbmfh
	        invoke   GlobalUnlock, pbmfh		; Free allocated memory
                invoke   GlobalFree, hMemory    		
	    .ENDIF

	    invoke PostQuitMessage,NULL
	    mov	eax,0
	    ret
	
        .ELSE
            invoke DefWindowProc,hWnd,uMsg,wParam,lParam
            ret
	.ENDIF
 
WndProc endp

        end start

