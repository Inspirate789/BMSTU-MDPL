EXTRN Number: word

PUBLIC output_sign_hex

DSEG SEGMENT PARA PUBLIC 'DATA'
	OutputHexMSG        db "Signed hexadecimal number representation: ", '$'
	Endline             db 13, 10, '$'
DSEG ENDS

CSEG4 SEGMENT PARA PUBLIC 'CODE'
	assume CS:CSEG4, DS:DSEG

output_sign_hex proc far
	mov dx, OFFSET OutputHexMSG             ; выводим подсказку к выводу числа
	mov ah, 09h
	int 21h

    mov dx, OFFSET Endline
	int 21h

    mov bx, Number                          ; помещаем наше число в регистр bx

    cmp bx, 7FFFh                           ; если число неотрицательное (первый двоичный разряд равен 0), то не печатаем минус
    jna skip_sign

    mov dl, '-'
    mov ah, 02h
    int 21h                                 ; выводим минус перед числом

    neg bx                                  ; перевели число из доп. кода в обычный

    skip_sign:
    mov cl, 12
    ror bx, cl                              ; выполняем циклический сдвиг на 12 разрядов вправо, чтобы старшие 4 разряда числа оказались в конце числа

    mov cx, 4                               ; будем выводить 4 шестнадцатеричные цифры
    mov ah, 02h                             ; выставляем функцию вывода символа

    output_digits_loop:
        mov dl, bl                          ; помещаем последние две шестнадцатеричные цифры в регистр dl
        and dl, 0Fh                         ; зануляем (стираем) старшую цифру ; так мы выделили последнюю цифру числа

        cmp dl, 9                           ; если цифра больше 9, то делаем в регистре dl код соответствующей буквы, иначе код цифры
        ja make_letter

        add dl, '0'                         ; получаем в регистре dl код выводимого символа (цифры)
        jmp output_digit

        make_letter:
        sub dl, 10d
        add dl, 'A'                         ; получаем в регистре dl код выводимого символа (буквы)

        output_digit:
        int 21h                             ; выводим получившуюся шестнадцатеричную цифру

        mov dx, cx                          ; сохраняем значение счётчика цикла в регистр dx
        mov cl, 4
        rol bx, cl                          ; сдвигаем число на 4 двоичных разряда влево (следующая шестнадцатеричная цифра теперь стоит в конце числа)
        mov cx, dx                          ; восстанавливаем значение счётчика цикла из регистра dx
    loop output_digits_loop
    
	mov dx, OFFSET Endline
	mov ah, 09h
	int 21h

    ret
output_sign_hex endp

CSEG4 ENDS
END
