PUBLIC input_unsigned_oct
PUBLIC Number

DSEG SEGMENT PARA PUBLIC 'DATA'
	InputMSG            db "Input unsigned octal number: ", '$'
    	NumberErrorMSG      db "Incorrect number. Please, try again.", '$'
	Number		    dw 0                                            ; число занимает 16 бит, старший бит может рассматриваться как знаковый при выводе в знаковом представлении
	Endline             db 13, 10, '$'
DSEG ENDS

CSEG2 SEGMENT PARA PUBLIC 'CODE'
	assume CS:CSEG2, DS:DSEG                ; сегменты данных написаны так, чтобы они все объединялись в один и не нужно было в каждом модуле загружать свои сегменты в DS (именно в DS, потому что 09h работает с парой регистров ds:dx)

input_unsigned_oct proc far
	mov dx, OFFSET InputMSG
    	mov ah, 09h
    	int 21h                                 ; выводим приглашение к вводу

    	mov dx, OFFSET Endline
	int 21h

    	xor bx, bx                              ; зануляем регистр, в который мы будем вводить наше число

    	mov cx, 5                               ; в 16 бит влезет максимум 5 восьмеричных цифр (по 3 бита каждая)
    	mov ah, 01h                             ; выставляем функцию ввода символа
    
    	input_digits_loop:
		int 21h                         ; вводим символ

		cmp al, 13
		je exit_success                 ; нажатие enter является признаком окончания ввода

		sub al, '0'                     ; вычитаем '0', чтобы получить из кода символа само число (цифру)

		cmp al, 7
		ja exit_failure                 ; если цифра не восьмеричная, выходим, печатая сообщение об ошибке

		insert_digit:
		mov dx, cx                      ; сохраняем значение счётчика цикла в регистр dx
		mov cl, 3
		shl bx, cl                      ; сдвигаем число на 3 двоичных разряда влево
		mov cx, dx                      ; восстанавливаем значение счётчика цикла из регистра dx

		add bl, al                      ; помещаем введённную цифру в конец числа

		loop input_digits_loop

    	int 21h                                 ; после 5 цифр ожидаем enter
    	cmp al, 13
    	jne exit_failure
    
    	exit_success:
	mov Number, bx                  	; помещаем полученное число в Number только при полностью успешном вводе
	ret
    
    	exit_failure:
	mov dx, OFFSET Endline
	mov ah, 09h
	int 21h

	mov dx, OFFSET NumberErrorMSG 		; выводим сообщение об ошибке
	int 21h

	mov dx, OFFSET Endline
	int 21h

	ret
     
input_unsigned_oct endp

CSEG2 ENDS
END
