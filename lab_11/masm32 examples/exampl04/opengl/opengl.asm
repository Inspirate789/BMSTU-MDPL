; ------------------------------------------
; Title: OpenGL test
; 
; Author: Franck Charlet.
;
; Notes: Just a little example on how to use OpenGL.
;	 Needs OpenGl32.dll and Glu32.dll (should be no problem).
;	 Object have 2112 faces / 3 (weird) moving light sources
;	 and it's f***ing slow on my cyrix 133.
;
; ------------------------------------------

; --------------- Assembler directives
			.386
      			.model	flat,stdcall
			option	casemap:none  

; --------------- External includes
			include	\masm32\include\windows.inc
			include \masm32\include\user32.inc
			include \masm32\include\kernel32.inc
			include \masm32\include\gdi32.inc
			include \masm32\include\opengl32.inc
			include \masm32\include\glu32.inc

			includelib \masm32\lib\user32.lib
			includelib \masm32\lib\kernel32.lib
			includelib \masm32\lib\gdi32.lib
			includelib \masm32\lib\gdi32.lib
			includelib \masm32\lib\opengl32.lib
			includelib \masm32\lib\glu32.lib

; --------------- Macros Section
szText			MACRO	Name,Text:VARARG
			LOCAL	lbl
			jmp	lbl
Name			db	Text,0
lbl:
			ENDM

m2m			MACRO	M1, M2
			push	M2
			pop	M1
			ENDM

return 			MACRO	arg
			mov	eax,arg
			ret
			ENDM

; --------------- These constants are not defined in windows.inc
PFD_MAIN_PLANE		equ	0
PFD_TYPE_COLORINDEX	equ	1
PFD_TYPE_RGBA		equ	0
PFD_DOUBLEBUFFER	equ	1
PFD_DRAW_TO_WINDOW	equ	4
PFD_SUPPORT_OPENGL	equ	020h

; --------------- Data Section
			.data
szDisplayName		db	"TestOpenGL - Written by Franck 'hitchhikr' Charlet.",0
			even
PixFrm			PIXELFORMATDESCRIPTOR <>

CommandLine		dd	0
hWnd			dd	0
MainHDC			dd	0
OpenDC			dd	0
hInstance		dd	0

; Some values
Value0Flt		dd	0.0
Value1Flt		dd	1.0
Value1Dbl		dq	1.0
Value45Dbl		dq	45.0
Value3Dbl		dq	3.0
Value7Dbl		dq	7.0

; Light position
LightSourcePosition	dd	-2.0,-2.0,-4.0,0.0
LightSource2Position	dd	2.0,2.0,4.0,0.0
LightSource3Position	dd	-2.0,2.0,4.0,0.0
LightAmbient		dd	0.2,0.0,0.0,1.0
Light2Ambient		dd	0.0,0.2,0.0,1.0
Light3Ambient		dd	0.0,0.0,0.2,1.0
LightDiffuse		dd	1.0,1.0,1.0,1.0
LightSpecular		dd	1.0,1.0,1.0,1.0
SpotCut			dd	-1.0
SpotExp			dd	0.0
SpotDir			dd	-1.0,-1.0,-1.0
LightConstAtt		dd	1.0
LightLinAtt		dd	1.0
LightQuadAtt		dd	1.0

; --- Sphere 1
; Angles
Sphere1AnglesFlt	dd	0.0,0.0,0.0
; Rotations speed
Sphere1AnglesSpeedFlt	dd	-1.0,-1.2,-1.4
; Objects datas
Sphere1Color		dd	0.6,0.4,0.2,0.0
Sphere1Radius		dq	1.0
sphere1Parts		dd	24
Sphere1Position		dd	0.0,0.0,-5.0
GlSphere1		dd	0

; --- Sphere 2
; Angles
Sphere2AnglesFlt	dd	0.0,0.0,0.0
; Rotations speed
Sphere2AnglesSpeedFlt	dd	-1.0,0.8,-0.4
; Objects datas
Sphere2Color		dd	0.4,0.6,0.2,0.0
Sphere2Radius		dq	0.3
sphere2Parts		dd	16
Sphere2Position		dd	0.0,0.0,-1.5
GlSphere2		dd	0

; --- Sphere 3
; Angles
Sphere3AnglesFlt	dd	0.0,0.0,0.0
; Rotations speed
Sphere3AnglesSpeedFlt	dd	-1.0,-0.8,1.4
; Objects datas
Sphere3Color		dd	0.2,0.4,0.6,0.0
Sphere3Radius		dq	0.3
sphere3Parts		dd	16
Sphere3Position		dd	0.0,0.0,1.5
GlSphere3		dd	0

; --- Sphere 4
; Angles
Sphere4AnglesFlt	dd	0.0,0.0,0.0
; Rotations speed
Sphere4AnglesSpeedFlt	dd	-1.0,1.4,-0.8
; Objects datas
Sphere4Color		dd	0.4,0.2,0.6,0.0
Sphere4Radius		dq	0.3
sphere4Parts		dd	16
Sphere4Position		dd	0.0,1.5,0.0
GlSphere4		dd	0

; --- Sphere 5
; Angles
Sphere5AnglesFlt	dd	0.0,0.0,0.0
; Rotations speed
Sphere5AnglesSpeedFlt	dd	1.0,1.8,0.8
; Objects datas
Sphere5Color		dd	0.6,0.2,0.4,0.0
Sphere5Radius		dq	0.3
sphere5Parts		dd	16
Sphere5Position		dd	1.5,0.0,0.0
GlSphere5		dd	0

; --- Sphere 6
; Angles
Sphere6AnglesFlt	dd	0.0,0.0,0.0
; Rotations speed
Sphere6AnglesSpeedFlt	dd	1.0,-1.8,2.0
; Objects datas
Sphere6Color		dd	0.2,0.6,0.4,0.0
Sphere6Radius		dq	0.3
sphere6Parts		dd	16
Sphere6Position		dd	-1.5,0.0,0.0
GlSphere6		dd	0

; --- Sphere 7
; Angles
Sphere7AnglesFlt	dd	0.0,0.0,0.0
; Rotations speed
Sphere7AnglesSpeedFlt	dd	-2.1,-1.8,2.0
; Objects datas
Sphere7Color		dd	0.6,0.6,0.6,0.0
Sphere7Radius		dq	0.3
sphere7Parts		dd	16
Sphere7Position		dd	0.0,-1.5,0.0
GlSphere7		dd	0

; --------------- Procedures Declarations
			.code

MainInit		PROTO	:DWORD,:DWORD,:DWORD,:DWORD
MainLoop		PROTO	:DWORD,:DWORD,:DWORD,:DWORD
TopXY			PROTO	:DWORD,:DWORD
DrawScene		PROTO
GlInit			PROTO	:DWORD,:DWORD
ResizeObject		PROTO	:DWORD,:DWORD
CreateSphere		PROTO	:DWORD,:DWORD,:DWORD,:DWORD,:DWORD,:DWORD
SetLightSource		PROTO	:DWORD,:DWORD,:DWORD
RotateObject		PROTO	:DWORD,:DWORD,:DWORD,:DWORD
DeleteSpheres		PROTO

; --------------- Procedures Section
CenterForm		PROC	wDim:DWORD, sDim:DWORD
			shr	sDim,1
			shr	wDim,1
			mov	eax,wDim
			sub	sDim,eax
			return	sDim
CenterForm		ENDP

DoEvents		PROC
			LOCAL	msg:MSG
StartLoop:		; Check for waiting messages
			invoke	PeekMessage,ADDR msg,0,0,0,PM_NOREMOVE
			or	eax,eax
			jz	NoMsg
			invoke	GetMessage,ADDR msg,NULL,0,0
			or	eax,eax
			jz	ExitLoop
			invoke	TranslateMessage,ADDR msg
			invoke	DispatchMessage,ADDR msg
			jmp	StartLoop
NoMsg:			; No pending messages: draw the scene
			invoke	DrawScene
			jmp	StartLoop
ExitLoop:		mov	eax,msg.wParam
			ret
DoEvents		ENDP

; --------------- Program start
start:			invoke	GetModuleHandle,NULL
			mov	hInstance, eax
			invoke	GetCommandLine
			mov	CommandLine,eax
			invoke	MainInit,hInstance,NULL,CommandLine,SW_SHOWDEFAULT
			invoke	ExitProcess,eax

; --------------- Program main inits
MainInit 		PROC	hInst:DWORD,hPrevInst:DWORD,CmdLine:DWORD,CmdShow:DWORD
			LOCAL	wc:WNDCLASSEX
			LOCAL	Wwd:DWORD
			LOCAL	Wht:DWORD
			LOCAL	Wtx:DWORD
			LOCAL	Wty:DWORD
	        	szText	szClassName,"Win32SDI_Class"
			mov	wc.cbSize,sizeof WNDCLASSEX
			mov	wc.style,0
			mov	wc.lpfnWndProc,offset MainLoop
			mov	wc.cbClsExtra,NULL
			mov	wc.cbWndExtra,NULL
			m2m	wc.hInstance,hInst
			mov	wc.hbrBackground,COLOR_WINDOWTEXT+1
			mov	wc.lpszMenuName,NULL
			mov	wc.lpszClassName,offset szClassName
			invoke	LoadIcon,hInst,2
			mov	wc.hIcon,eax
			invoke	LoadCursor,NULL,IDC_ARROW
			mov	wc.hCursor,eax
			mov	wc.hIconSm,0
			invoke	RegisterClassEx, ADDR wc
			mov	Wwd,400
			mov	Wht,420
			invoke	GetSystemMetrics,SM_CXSCREEN
			invoke	CenterForm,Wwd,eax
			mov	Wtx,eax
			invoke	GetSystemMetrics,SM_CYSCREEN
			invoke	CenterForm,Wht,eax
			mov	Wty,eax
			invoke	CreateWindowEx,0,ADDR szClassName,
						ADDR szDisplayName,
						WS_OVERLAPPEDWINDOW or WS_CLIPSIBLINGS or WS_CLIPCHILDREN,
						Wtx,Wty,Wwd,Wht,
						NULL,NULL,
						hInst,NULL
			mov	hWnd,eax
			invoke	LoadMenu,hInst,600
			invoke	SetMenu,hWnd,eax
			invoke	ShowWindow,hWnd,SW_SHOWNORMAL
			invoke	UpdateWindow,hWnd
			call	DoEvents
			ret
MainInit 		ENDP

; --------------- Program main loop
MainLoop		PROC	hWin:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
			LOCAL	WINRect:RECT
			LOCAL	PixFormat:DWORD
			.if uMsg == WM_COMMAND
				.if wParam == 1000
					invoke	SendMessage,hWin,WM_SYSCOMMAND,SC_CLOSE,NULL
				.endif
				return	0
			.elseif	uMsg == WM_CREATE
				invoke	GetDC,hWin
				mov	MainHDC,eax
				mov	ax,SIZEOF PixFrm
				mov	PixFrm.nSize,ax
				mov	PixFrm.nVersion,1
				mov	PixFrm.dwFlags,PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER
				mov	PixFrm.dwLayerMask,PFD_MAIN_PLANE
				mov	PixFrm.iPixelType,PFD_TYPE_RGBA
				mov	PixFrm.cColorBits,8
				mov	PixFrm.cDepthBits,16
				mov	PixFrm.cAccumBits,0
				mov	PixFrm.cStencilBits,0
				invoke	ChoosePixelFormat,MainHDC,ADDR PixFrm
				mov	PixFormat,eax
				invoke	SetPixelFormat,MainHDC,PixFormat,ADDR PixFrm
				or	eax,eax
				jz	NoPixelFmt
				invoke	wglCreateContext,MainHDC
				mov	OpenDC,eax
				invoke	wglMakeCurrent,MainHDC,OpenDC
				invoke	GetClientRect,hWin,ADDR WINRect
				invoke	GlInit,WINRect.right,WINRect.bottom
NoPixelFmt:		
				return	0
			.elseif	uMsg == WM_SIZE
				invoke	GetClientRect,hWin,ADDR WINRect
				invoke	ResizeObject,WINRect.right,WINRect.bottom
				return	0
				
			.elseif	uMsg == WM_CLOSE
				szText TheText,"Are you sure ?"
				invoke	MessageBox,hWin,ADDR TheText,ADDR szDisplayName,MB_YESNO+MB_ICONQUESTION
				.if eax == IDNO
					return	0
				.endif
				mov	eax,OpenDC
				or	eax,eax
				jz	NoGlDC
				; Delete our objects
				invoke	DeleteSpheres
				invoke	wglDeleteContext,OpenDC
NoGlDC:				invoke	ReleaseDC,hWin,MainHDC
				invoke	DestroyWindow,hWin
				return	0
			.elseif uMsg == WM_DESTROY
				invoke	PostQuitMessage,NULL
				return	0 
			.endif
			invoke	DefWindowProc,hWin,uMsg,wParam,lParam
			ret
MainLoop		ENDP

; ------------------------------
; OpenGl related stuff
; ------------------------------

; --------------- Init the scene
GlInit			PROC	ParentW:DWORD,ParentH:DWORD
			invoke	SetLightSource,GL_LIGHT0,ADDR LightSourcePosition,ADDR LightAmbient
			invoke	SetLightSource,GL_LIGHT1,ADDR LightSource2Position,ADDR Light2Ambient
			invoke	SetLightSource,GL_LIGHT2,ADDR LightSource3Position,ADDR Light3Ambient
			invoke	CreateSphere,1,GLU_FILL,GLU_SMOOTH,ADDR Sphere1Color,ADDR Sphere1Radius,sphere1Parts
			mov	GlSphere1,eax
			invoke	CreateSphere,2,GLU_FILL,GLU_SMOOTH,ADDR Sphere2Color,ADDR Sphere2Radius,sphere2Parts
			mov	GlSphere2,eax
			invoke	CreateSphere,3,GLU_FILL,GLU_SMOOTH,ADDR Sphere3Color,ADDR Sphere3Radius,sphere3Parts
			mov	GlSphere3,eax
			invoke	CreateSphere,4,GLU_FILL,GLU_SMOOTH,ADDR Sphere4Color,ADDR Sphere4Radius,sphere4Parts
			mov	GlSphere4,eax
			invoke	CreateSphere,5,GLU_FILL,GLU_SMOOTH,ADDR Sphere5Color,ADDR Sphere5Radius,sphere5Parts
			mov	GlSphere5,eax
			invoke	CreateSphere,6,GLU_FILL,GLU_SMOOTH,ADDR Sphere6Color,ADDR Sphere6Radius,sphere6Parts
			mov	GlSphere6,eax
			invoke	CreateSphere,7,GLU_FILL,GLU_SMOOTH,ADDR Sphere7Color,ADDR Sphere7Radius,sphere7Parts
			mov	GlSphere7,eax
			; Set global flags
			invoke	glEnable,GL_DEPTH_TEST
			invoke	glEnable,GL_LIGHTING
			invoke	glEnable,GL_CULL_FACE		; Don't render back faces
			invoke	glShadeModel,GL_SMOOTH
			invoke	glEnable,GL_NORMALIZE
			ret
GlInit			ENDP

; --------------- Display the scene
DrawScene		PROC
	    		invoke	glClear,GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT
			invoke	glPushMatrix
				invoke	RotateObject,1,ADDR Sphere1Position,ADDR Sphere1AnglesSpeedFlt,ADDR Sphere1AnglesFlt
				invoke	glPushMatrix
					invoke	RotateObject,2,ADDR Sphere2Position,ADDR Sphere2AnglesSpeedFlt,ADDR Sphere2AnglesFlt
					invoke	glLightfv,GL_LIGHT0,GL_POSITION,ADDR LightSourcePosition
				invoke	glPopMatrix
				invoke	glPushMatrix
					invoke	RotateObject,3,ADDR Sphere3Position,ADDR Sphere3AnglesSpeedFlt,ADDR Sphere3AnglesFlt
					invoke	glLightfv,GL_LIGHT1,GL_POSITION,ADDR LightSource2Position
				invoke	glPopMatrix
				invoke	glPushMatrix
					invoke	RotateObject,4,ADDR Sphere4Position,ADDR Sphere4AnglesSpeedFlt,ADDR Sphere4AnglesFlt
					invoke	glLightfv,GL_LIGHT2,GL_POSITION,ADDR LightSource3Position
				invoke	glPopMatrix
				invoke	glPushMatrix
					invoke	RotateObject,5,ADDR Sphere5Position,ADDR Sphere5AnglesSpeedFlt,ADDR Sphere5AnglesFlt
				invoke	glPopMatrix
				invoke	glPushMatrix
					invoke	RotateObject,6,ADDR Sphere6Position,ADDR Sphere6AnglesSpeedFlt,ADDR Sphere6AnglesFlt
				invoke	glPopMatrix
				invoke	glPushMatrix
					invoke	RotateObject,7,ADDR Sphere7Position,ADDR Sphere7AnglesSpeedFlt,ADDR Sphere7AnglesFlt
				invoke	glPopMatrix
			invoke	glPopMatrix
			invoke	SwapBuffers,MainHDC
			ret
DrawScene		ENDP

; --------------- Resize the scene
ResizeObject		PROC	ParentW:DWORD,ParentH:DWORD
			invoke	glViewport,0,0,ParentW,ParentH
			invoke	glMatrixMode,GL_PROJECTION
			invoke	glLoadIdentity
			invoke	gluPerspective,DWORD PTR Value45Dbl,DWORD PTR Value45Dbl+4,DWORD PTR Value1Dbl,DWORD PTR Value1Dbl+4,DWORD PTR Value3Dbl,DWORD PTR Value3Dbl+4,DWORD PTR Value7Dbl,DWORD PTR Value7Dbl+4
			invoke	glMatrixMode,GL_MODELVIEW
			invoke	glLoadIdentity
			ret
ResizeObject		ENDP

; --------------- Free the memory allocated for the spheres
DeleteSpheres		PROC
			invoke	gluDeleteQuadric,GlSphere1
			invoke	gluDeleteQuadric,GlSphere2
			invoke	gluDeleteQuadric,GlSphere3
			invoke	gluDeleteQuadric,GlSphere4
			invoke	gluDeleteQuadric,GlSphere5
			invoke	gluDeleteQuadric,GlSphere6
			invoke	gluDeleteQuadric,GlSphere7
			ret
DeleteSpheres		ENDP

; --------------- Create a sphere with glu object
CreateSphere		PROC	ListNumber:DWORD,FillType:DWORD,NormalsType:DWORD,Color:DWORD,Radius:DWORD,Parts:DWORD
			LOCAL	GlSphere:DWORD
			invoke	glNewList,ListNumber,GL_COMPILE
			; Create a template
			invoke	gluNewQuadric
			mov	GlSphere,eax
			; Set object draw style
			invoke	gluQuadricDrawStyle,GlSphere,FillType
			; Set normals style
			invoke	gluQuadricNormals,GlSphere,NormalsType
			; Set object color
			invoke	glMaterialfv,GL_FRONT,GL_AMBIENT_AND_DIFFUSE,Color
			mov	eax,Radius
			; Create a sphere primitive
			invoke	gluSphere,GlSphere,[eax],[eax+4],Parts,Parts
			invoke	glEndList
			mov	eax,GlSphere
			ret
CreateSphere		ENDP

; --------------- Set a light source
SetLightSource		PROC	LtNumber:DWORD,LtPosition:DWORD,LtAmbient:DWORD
			invoke	glLightfv,LtNumber,GL_POSITION,LtPosition
			invoke	glLightfv,LtNumber,GL_DIFFUSE,ADDR LightDiffuse
			invoke	glLightfv,LtNumber,GL_SPECULAR,ADDR LightSpecular
			invoke	glLightfv,LtNumber,GL_AMBIENT,LtAmbient
			invoke	glLightfv,LtNumber,GL_CONSTANT_ATTENUATION,ADDR LightConstAtt
			invoke	glLightfv,LtNumber,GL_LINEAR_ATTENUATION,ADDR LightLinAtt
			invoke	glLightfv,LtNumber,GL_QUADRATIC_ATTENUATION,ADDR LightQuadAtt
			invoke	glLightfv,LtNumber,GL_SPOT_CUTOFF,ADDR SpotCut
			invoke	glLightfv,LtNumber,GL_SPOT_EXPONENT,ADDR SpotExp
			invoke	glLightfv,LtNumber,GL_SPOT_DIRECTION,ADDR SpotDir
			invoke	glEnable,LtNumber
			ret	
SetLightSource		ENDP

; --------------- Position and rotate an object
RotateObject		PROC	ListNumber:DWORD,XYZPosition:DWORD,XYZRotations:DWORD,XYZAngles:DWORD
			LOCAL	LocXSpd:DWORD
			LOCAL	LocYSpd:DWORD
			LOCAL	LocZSpd:DWORD
			LOCAL	LocXAngle:DWORD
			LOCAL	LocYAngle:DWORD
			LOCAL	LocZAngle:DWORD
			mov	eax,XYZPosition
			mov	ecx,[eax]
			mov	ebx,[eax+4]
			mov	eax,[eax+8]
			invoke	glTranslatef,ecx,ebx,eax
	    		mov	eax,XYZAngles			; Rotate X
	    		mov	ebx,XYZRotations
	    		fld	DWORD PTR [eax]
	    		fadd	DWORD PTR [ebx]
	    		fstp	DWORD PTR [eax]
	    		invoke	glRotatef,[eax],Value0Flt,Value1Flt,Value0Flt
	    		mov	eax,XYZAngles			; Rotate Y
	    		mov	ebx,XYZRotations
	    		fld	DWORD PTR [eax+4]
	    		fadd	DWORD PTR [ebx+4]
	    		fstp	DWORD PTR [eax+4]
	    		invoke	glRotatef,[eax+4],Value1Flt,Value0Flt,Value0Flt
	    		mov	eax,XYZAngles			; Rotate Z
	    		mov	ebx,XYZRotations
	    		fld	DWORD PTR [eax+8]
	    		fadd	DWORD PTR [ebx+8]
	    		fstp	DWORD PTR [eax+8]
	    		invoke	glRotatef,DWORD PTR [eax+8],Value0Flt,Value0Flt,Value1Flt
			invoke	glCallList,ListNumber
			ret
RotateObject		ENDP

; --------------- Program end
end start
