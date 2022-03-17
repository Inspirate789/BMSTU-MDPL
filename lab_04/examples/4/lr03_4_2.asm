EXTRN X: byte
PUBLIC exit

SD2 SEGMENT para 'DATA'
	Y db 'Y'
SD2 ENDS

SC2 SEGMENT para public 'CODE'
	assume CS:SC2, DS:SD2
exit:
	; записываем в регистр ES адрес начала сегмента SD1
	mov ax, seg X ; адрес сегмента, в котором лежит X             ; Вроде как можно напрямую подтянуть сегмент из другого модуля, написав ASSUME ES:seg X
	mov es, ax    
	mov bh, es:X

	; записываем в регистр DS адрес начала сегмента SD2
	mov ax, SD2   ; также важно: в AX сейчас лежит адрес начала сегмента SD2, т.е. а AH лежит первый (старший) байт этого адреса (числа)
	mov ds, ax

	; перед обменом: в регистре AH - кусок адреса (по сути мусор), в переменной X - символ "X", в переменной Y - символ "Y"
	xchg ah, Y    ; теперь: в регистре AH - символ "Y", в переменной X - символ "X", в переменной Y - кусок адреса (по сути мусор)
	xchg ah, ES:X ; теперь: в регистре AH - символ "X", в переменной X - символ "Y", в переменной Y - кусок адреса (по сути мусор)
	xchg ah, Y	  ; теперь: в регистре AH - кусок адреса (по сути мусор), в переменной X - символ "Y", в переменной Y - символ "X"

	mov ah, 2     ; выведется символ "X"
	mov dl, Y
	int 21h
	
	mov ax, 4c00h ; завершение программы
	int 21h
SC2 ENDS
END