
;	DIBFILE	- DIB File Functions
;	----------------------------

.386				; 32 bit when .386 appears before .MODEL
.MODEL FLAT,STDCALL
option casemap :none  ; case sensitive

include \masm32\include\windows.inc

include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\gdi32.inc
include \masm32\include\comdlg32.inc

includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\gdi32.lib
includelib \masm32\lib\comdlg32.lib
	
EXTRN	hMemory:DWORD     	

.data

szFilter  db	"Bitmap Files (*.bmp)",0, "*.bmp",0,\
		"All Files (*.*)",0,"*.*",0,0

DefExtn	  db	"bmp",0				; Default extension for file  	

.data?

ofn   OPENFILENAME <>

.const

;MACROS

.Code
;------------------------------------------------------------------------------
DibFileInitialize	proc	hwnd:HWND 

	mov	ofn.lStructSize, sizeof OPENFILENAME
	mov	eax, hwnd
	mov	ofn.hWndOwner, eax
	mov	ofn.hInstance, 0
	mov	ofn.lpstrFilter, offset szFilter
	mov	ofn.lpstrCustomFilter, 0
	mov	ofn.nMaxCustFilter, 0
	mov	ofn.nFilterIndex, 0
	mov	ofn.lpstrFile, 0		; Set in Open and Close functions
	mov	ofn.nMaxFile, MAX_PATH
	mov	ofn.lpstrFileTitle, 0		; Set in Open and Close functions
	mov	ofn.nMaxFileTitle, MAX_PATH
	mov	ofn.lpstrInitialDir, 0
	mov	ofn.lpstrTitle, 0		
	mov	ofn.Flags, 0			; Set in Open and Close functions
	mov	ofn.nFileOffset, 0
	mov	ofn.nFileExtension, 0
	mov	ofn.lpstrDefExt,offset DefExtn	; default extension is bmp
	mov	ofn.lCustData, 0
	mov	ofn.lpfnHook, 0
	mov	ofn.lpTemplateName, 0

	ret

DibFileInitialize	endp

DibFileOpenDlg		proc hwnd:HWND, pstrFileName:DWORD, pstrTitleName:DWORD

	mov	eax,hwnd
	mov	ofn.hWndOwner, eax
	mov	eax, pstrFileName
	mov	ofn.lpstrFile, eax
	mov	eax,pstrTitleName	
	mov	ofn.lpstrFileTitle, eax
	mov	ofn.Flags, 0

	invoke	GetOpenFileName, ADDR ofn

	ret

DibFileOpenDlg		endp

DibFileSaveDlg		proc hwnd:HWND, pstrFileName:DWORD, pstrTitleName:DWORD

	mov	eax,hwnd
	mov	ofn.hWndOwner, eax
	mov	eax,pstrFileName
	mov	ofn.lpstrFile,  eax
	mov	eax, pstrTitleName	
	mov	ofn.lpstrFileTitle, eax
	mov	ofn.Flags, OFN_OVERWRITEPROMPT
	
	invoke	GetSaveFileName, ADDR ofn

	ret

DibFileSaveDlg		endp

DibLoadImage	proc uses ebx, pstrFileName:DWORD

LOCAL	bSuccess:DWORD, dwFileSize:DWORD, dwHighSize:DWORD, dwBytesRead:DWORD, hFile:HANDLE
LOCAL   pbmfh:DWORD

	invoke	CreateFile, pstrFileName, GENERIC_READ, FILE_SHARE_READ, 0, \
			    OPEN_EXISTING, FILE_FLAG_SEQUENTIAL_SCAN, 0
	mov	hFile,eax

	.IF eax==INVALID_HANDLE_VALUE
	    mov	eax,0
	    ret
	.ENDIF

	invoke GetFileSize, hFile, ADDR dwHighSize
	mov dwFileSize, eax

	.IF dwHighSize
	    invoke CloseHandle, hFile
	    mov	eax,0
	    ret
	.ENDIF

	invoke GlobalAlloc,GMEM_MOVEABLE or GMEM_ZEROINIT, dwFileSize	; Allocate memory

        mov  hMemory,eax			; Handle to memory
	
        invoke GlobalLock,hMemory
        mov  pbmfh,eax				; got pointer to BITMAPFILEHEADER
	mov  ebx,eax
	
	.IF !pbmfh				; If it fails
	    invoke CloseHandle, hFile
	    mov eax,0
	    ret
	.ENDIF

	invoke ReadFile, hFile, pbmfh, dwFileSize, ADDR dwBytesRead, 0
	mov	bSuccess,eax
	invoke CloseHandle, hFile

	mov	eax, dwBytesRead
    	mov	cx, BITMAPFILEHEADER.bfType[ebx]	; Get file type from header; must be BM
	mov	edx,BITMAPFILEHEADER.bfSize[ebx]	; Size (in bytes) of bitmap
	
;	Note for the type comparison we need to compare against MB & not BM     

	.IF !bSuccess || eax != dwFileSize ||  cx != "MB" || edx != dwFileSize

	    invoke   GlobalUnlock,pbmfh
            invoke   GlobalFree, hMemory    
	    mov	eax,0
	    ret

	.ENDIF

	mov	eax, pbmfh
	ret

DibLoadImage	endp

DibSaveImage	proc uses ebx, pstrFileName:DWORD, pbmfh:DWORD

LOCAL	bSuccess:DWORD, dwBytesWritten:DWORD, hFile:HANDLE

	mov	ebx, pbmfh			; Get pointer to BITMAPFILEHEADER

	invoke	CreateFile, pstrFileName, GENERIC_WRITE, 0, 0, \
			    CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0
	mov	hFile, eax
	
	.IF eax==INVALID_HANDLE_VALUE
	    mov	eax,0
	    ret
	.ENDIF

	invoke WriteFile, hFile, pbmfh, BITMAPFILEHEADER.bfSize[ebx], ADDR dwBytesWritten, 0
	mov	bSuccess, eax

	invoke	CloseHandle, hFile

	mov	eax, dwBytesWritten

	.IF !bSuccess || eax!=BITMAPFILEHEADER.bfSize[ebx]
	    invoke DeleteFile, ADDR pstrFileName
	    mov	eax, FALSE
	.ELSE
	    mov	eax, TRUE
	.ENDIF

	ret
	
DibSaveImage	endp

	end

