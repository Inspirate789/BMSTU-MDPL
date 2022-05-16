;-----------------------------------------------------------------;
; This example shows how to to use the Unicode macros.            ;
; A short overview:                                               ;
;  UCSTR / UC    - unicode string                                 ;
;  UCCSTR / UCC  - unicode string with escape sequences           ;
;  uc$()         - returns offset to zero. term. unicode string   ;
;  ucc$()        - returns offset to zero. term. unicode c-string ;
;-----------------------------------------------------------------;
__UNICODE__ EQU 1
include \masm32\include\masm32rt.inc

; usage: printw pwsz1,pwsz2,...
printw macro args:VARARG
	prw_args TEXTEQU repargs(&args)
	prw_frmt TEXTEQU <">
	prw_cntr = 0
	WHILE prw_cntr LT repargs_cntr
		prw_frmt CATSTR prw_frmt,<!\ps>
		prw_cntr = prw_cntr + 1
	ENDM
	prw_frmt CATSTR prw_frmt,<">
	prw_call TEXTEQU <fnx crt_wprintf,>,ucc$(%prw_frmt),prw_args
	prw_call
endm

.data
    ; create zero terminated unicode string
	UCSTR wstr1, "Hello World",21h,13,10,"This is a test for MASM32's unicode macros.",13,10,0
	
	; create zero terminated unicode string with escape sequences
	UCCSTR wstr2, 'This is a C-String\x : \a\b\l\r\\\n',0
	
	; create a string over several lines. The term. zero is added in the last line.
	UCSTR wstr3, 9,"This Text",13,10
	UCSTR      , 9,"needs",13,10
	UCSTR      , 9,"four",13,10
	UCSTR      , 9,"lines",13,10,0
	
	; UC  = UCSTR
	; UCC = UCCSTR
	UC  wstr4,"123456789",13,10
	UCC wstr5,"abcdef\n",0
	
.code
main proc
    
    ; print the strings (&=ADDR)
	printw &wstr1,&wstr2,&wstr3
	
	; print a string with escape sequences
	printw ucc$("\t\x\x\x\n")

	; print some other string
	printw uc$("abcdefg...",13,10)

	; the fnx-macro produces unicode strings, if __UNICODE__ = 1
	fnx crt_wprintf,"%s%s","ABCDEFG...",uc$(13,10)

	inkey
	exit
	
main endp
end main