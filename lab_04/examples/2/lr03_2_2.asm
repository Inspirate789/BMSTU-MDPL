SD1 SEGMENT para common 'DATA'
	C1 LABEL byte
	ORG 1h        ; задаём отступ относительно НАЧАЛА СЕГМЕНТА, по которому будет располагаться следующая за директивой `ORG` переменная
	C2 LABEL byte
SD1 ENDS

; из-за public сегменты наложатся, поэтому в C1 будет лежать 44 (код символа "D"), 
; а в C2 - 34 (код символа "4"); обратный порядок байтов из-за little-endian

CSEG SEGMENT para 'CODE'
	ASSUME CS:CSEG, DS:SD1
main:
	mov ax, SD1
	mov ds, ax    ; записываем в регистр DS адрес начала сегмента SD2
	mov ah, 2
	mov dl, C1    ; Выводим C1 (символ "D")
	int 21h
	mov dl, C2    ; Выводим C2 (символ "4")
	int 21h
	mov ax, 4c00h ; завершение программы
	int 21h
CSEG ENDS
END main