EXTRN Number: word

PUBLIC output_unsign_bin

DSEG SEGMENT PARA PUBLIC 'DATA'
	OutputBinMSG        db "Unsigned binary number representation: ", '$'
	Endline             db 13, 10, '$'
DSEG ENDS

CSEG3 SEGMENT PARA PUBLIC 'CODE'
	assume CS:CSEG3, DS:DSEG

output_unsign_bin proc far
	mov dx, OFFSET OutputBinMSG         	; выводим подсказку к выводу числа
	mov ah, 09h
	int 21h

    	mov dx, OFFSET Endline
	int 21h

    	mov bx, Number                      	; помещаем наше число в регистр bx
    
    	mov cx, 16                          	; будем выводить 16 двоичных цифр
    	mov ah, 02h                         	; выставляем функцию вывода символа

    	output_digits_loop:
		mov dl, 0

		sal bx, 1                  	; сдвигаем bx на 1 разряд влево через флаг CF
		adc dl, '0'                     ; в зависимости от флага CF получаем в регистре dl код '0' или '1'

		int 21h                         ; выводим символ

		loop output_digits_loop
    
	mov dx, OFFSET Endline
	mov ah, 09h
	int 21h

    	ret
output_unsign_bin endp

CSEG3 ENDS
END
