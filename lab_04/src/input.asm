EXTRN String: byte
EXTRN output_string: far

PUBLIC input_string

CSEG2 SEGMENT PARA PUBLIC 'CODE'
	assume CS:CSEG2

input_string:
	mov dx, OFFSET String
	mov ah, 0ah
	int 21h               ; вводим строку
	
	jmp output_string     ; "прыгаем" в другой модуль (дальний переход)
	
CSEG2 ENDS
END
