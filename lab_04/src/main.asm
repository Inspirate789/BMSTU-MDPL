EXTRN input_string: far ; импортируем (делаем видимой в этом модуле) метку для дальнего перехода

PUBLIC String           ; экспортируем переменную и метку
PUBLIC output_string

SSEG SEGMENT PARA STACK 'STACK'
	db 512 dup(?)
SSEG ENDS

DSEG1 SEGMENT PARA PUBLIC 'DATA'
	InputMSG  db "Input string: ", '$'
	String    db 256 dup('$') ; выделяем под строку 256 байт (инициализируем символом "$", чтобы в конце строки всегда был "$", служащий символом окончания вывода для функции, которой мы будем выводить строку)
	OutputMSG db "The first 8 characters of the entered string: ", '$'
	Endline   db 13, 10, '$'
DSEG1 ENDS

CSEG1 SEGMENT PARA PUBLIC 'CODE'
	assume CS:CSEG1, DS:DSEG1, SS:SSEG
main:
	mov ax, DSEG1
    	mov ds, ax               ; записываем в регистр DS адрес начала сегмента DSEG1
	
	mov dx, OFFSET InputMSG
	mov AH, 09h
	int 21h                  ; выводим приглашение к вводу
	
	jmp input_string         ; "прыгаем" в другой модуль (дальний переход)

output_string:
	mov dx, OFFSET Endline   ; переходим на новую строку
	mov AH, 09h
	int 21h

	mov dx, OFFSET OutputMSG ; выводим подсказку к выводу
	mov AH, 09h
    int 21h

	mov bx, 2                ; bx - индекс начала строки (строка прерыванием с номером функции 0ah строка вводится так, что 1-й её байт - размер буфера, второй - число прочитанных символов; поэтому сама строка начинается с 3-го символа)
	mov cx, 8				 ; в цикле будет 8 итераций
	mov ah, 02h              ; функция вывода символа
	output_loop:             ; цикл вывода
		mov dl, String[bx]   ; получаем символ по его индексу в строке
		int 21h				 ; выводим символ
		inc bx               ; увеличиваем индекс (переходим на следующую букву)
		loop output_loop
	
	mov dx, OFFSET Endline   ; переходим на новую строку
	mov AH, 09h
    int 21h

	mov ax, 4c00h 			 ; завершение программы
	int 21h
	
CSEG1 ENDS
END main
