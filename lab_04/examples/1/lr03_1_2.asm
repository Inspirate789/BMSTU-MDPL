PUBLIC output_X
EXTRN X: byte

DS2 SEGMENT AT 0b800h	       ; 0b800h - сегментная часть адреса b8000h (адреса начала сегмента)
	CA LABEL byte
	ORG 80 * 2 * 2 + 2 * 2 ; задаём отступ относительно НАЧАЛА СЕГМЕНТА, по которому будет располагаться следующая за директивой `ORG` переменная
	SYMB LABEL word
DS2 ENDS

CSEG SEGMENT PARA PUBLIC 'CODE'
	assume CS:CSEG, ES:DS2
output_X proc near
	mov ax, DS2
	mov es, ax    ; записываем в регистр ES адрес начала сегмента DS2
	mov ah, 10    ; устанавливаем зелёный цвет
	mov al, X     ; помещаем символ X
		      ; теперь в AX лежит символ зелёного цвета
	mov symb, ax  ; помещаем в видеопамять символ зелёного цвета. Он выводится сразу (без вызова прерываний, так как мы напрямую поменяли символ в сетке символов)
	ret
output_X endp
CSEG ENDS
END
