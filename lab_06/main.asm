EXTRN input_unsigned_oct: far
EXTRN output_unsign_bin: far
EXTRN output_sign_hex: far

DSEG SEGMENT PARA PUBLIC 'DATA'
    	Menu	     		db "Menu: ", 13, 10,
    				   "1 - Number input in unsigned octal representation", 13, 10,
				   "2 - Number output in unsigned binary representation", 13, 10,
				   "3 - Number output in signed hexadecimal representation", 13, 10,
				   "4 - Exit", 13, 10, '$'
	InputOptionMSG		db "Select the menu option: ", '$'
	MenuOption              db 0
    	OptionErrorMSG          db "Incorrect option. Please, try again.", '$'
	Commands		dd input_unsigned_oct, output_unsign_bin, output_sign_hex, exit ; массив указателей на подпрограммы, выполняющие действия, соответствующие пунктам меню
	Endline                 db 13, 10, '$'
DSEG ENDS

SSEG SEGMENT PARA STACK 'STACK'
	db 512 dup(0)
SSEG ENDS

CSEG1 SEGMENT PARA PUBLIC 'CODE'
	assume CS:CSEG1, SS:SSEG, DS:DSEG

exit proc far
	mov ax, 4c00h 			 						; завершение программы
	int 21h
exit endp

main:
	mov ax, DSEG
	mov ds, ax									; записываем в регистр DS адрес начала сегмента DSEG
	
	menu_loop:
		mov dx, OFFSET Endline
		mov ah, 09h
		int 21h
		
		mov dx, OFFSET Menu
		int 21h									; выводим меню

		mov dx, OFFSET InputOptionMSG
		int 21h									; выводим приглашение к вводу пункта меню

		mov ah, 01h
		int 21h									; вводим пункт меню
		mov bl, al								; временно помещаем пункт меню в регистр bl (для проверки ввода enter в регистр al)

		int 21h                                 				; после пункта меню ожидаем enter
		cmp al, 13
		jne write_error_message

		mov al, bl								; возвращаем пункт меню в регистр al
		sub al, '1'								; вычитаем именно '1', а не '0' (чтобы получить число, а не код символа), так как индексы в массиве указателей на функцию начинаются с 0, а пункты меню - с 1

		cmp al, 3
		ja write_error_message							; если пункт меню выбран неверно, выводим сообщение об ошибке, перепрыгивая вызов функции
		
		mov cl, 4								; пункт меню домножаем иенно на 4, потому что метка дальнего перехода занимает 4 байта
		mul cl									; получаем в регистре ax нужный индекс
		mov si, ax								; помещаем индекс в индексный регистр, так как регистрация с помощью ax вызовет ошибку компиляции
		call Commands[si]							; вызываем нужную подпрограмму
		jmp skip_error_message

		write_error_message:
			mov dx, OFFSET Endline
			mov ah, 09h
			int 21h

			mov dx, OFFSET OptionErrorMSG
			int 21h								; выводим сообщение об ошибке

			mov dx, OFFSET Endline
			int 21h
		
		skip_error_message:
			mov dx, OFFSET Endline
			mov ah, 09h
			int 21h

			jmp menu_loop							; запускаем бесконечный цикл работы с меню ; заершение только при вызове процедуры exit
	
CSEG1 ENDS
END main
